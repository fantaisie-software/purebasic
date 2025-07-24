; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Localisation File Consistency Checker.

; Usage:
; LFCheck /u /r="reference file path" /t="target file path" /l="log file path"
; /u - Check for untranslated text.
; /r= - Reference catalog path, omit this to reference the IDE's default language table.
; /t= - Target catalog path.
; /l= - Log problems to a file.

; Please note:
; Whilst this tool tells the truth it doesn't necessarily tell the _whole_ truth, particularly with the untranslated terms check active.
; Terms which do not get translated in langauges other than English or are spelled the same as their English counterpart will be 
; reported as an untranslated term.
; Please do not post these as a Documentation or IDE bug without checking first that there really is a problem.

EnableExplicit

;- Enumerations
EnumerationBinary Origin
  #Reference
  #Target
EndEnumeration
#Both = #Reference | #Target

EnumerationBinary Options
  #OptReferenceFile
  #OptReferenceTable
  #OptTestUntranslated
  #OptLogFile
EndEnumeration

#Key$ = "Key "
#Group$ = "Group "
#DefTable$ = "Default Language Table."
#RefFile$ = "Reference File."
#TargetFile$ = "Target File."

#SQ$ = "'"
#MsgTitle$ = "PureBasic Localisation File Consistency Checker"
#MsgRef$ = "The reference file "
#MsgTarget$ = "The target file "
#MsgLog = "The log file "
#MsgNoTarget$ = "No target file specified."
#MsgChecking = "Checking: "
#MsgAgainst = "Against: "
#MsgNotFound$ = " could not be found."
#MsgNotOpened$ = " could not be opened."
#MsgNotCreated$ = " could not be created."
#MsgNothing$ = "No problems detected."

#ErrEmpty$ = " is empty in the "
#ErrDup$ = " is duplicated in the "
#ErrUndef$ = " is not defined in the "
#ErrMissing$ = " is missing from the "
#ErrUnTrans$ = " is not translated in the "

;- Structures
Structure ASTRING
  State.I
  RefCount.I
  TargetCount.I
  Reference.S
  Target.S
EndStructure

;- Variables
Global.S ReferenceDesc = #DefTable$, ReferenceFile, TargetFile, LogFile
Global.I Options
Global NewMap Store.ASTRING()
Global NewMap Group.I()
Global NewList Bug.S()

;{ Extras
; These items are referenced by Language.pb so must be defined but are unused by this tool.
; If anything gets added to Language.pb in future it must also be represented here.
#CatalogFileIDE = #Empty$
#CompileWindows = 0
#DEFAULT_CatalogPath = #Empty$
#FLAG_Error = 0
#NewLine = #Empty$
#ProductName$ = #Empty$
#Separator = #Empty$
#SpiderBasic = 0

Global PureBasicPath$

Procedure BuildShortcutNamesTable()
EndProcedure
;}

; The default table is loaded from the IDE's own file to ensure the data is current.  
; You will need to update this line if you are compiling the tool elsewhere.
DisableExplicit
IncludeFile ".." + #PS$ + "Language.pb"
EnableExplicit

;- Implementation
Procedure CheckConsistency()
  ; Perform consistency checks.
  
  ; Groups.
  ForEach Group()
    
    ; This section is irrelevant for consitency, ignore it.
    If MapKey(Group()) = "LANGUAGEINFO"
      Continue
    EndIf
    
    If Group() & #Reference = 0
      AddElement(Bug())
      Bug() = #Group$ + #SQ$ + MapKey(Group()) + #SQ$ + #ErrUndef$ + ReferenceDesc
    EndIf
    
    If Group() & #Target = 0
      AddElement(Bug())
      Bug() = #Group$ + #SQ$ + MapKey(Group()) + #SQ$ + #ErrMissing$ + #TargetFile$
    EndIf
    
  Next Group()
  
  ; Strings.
  ForEach Store()
    
    ; This section is irrelevant for consitency, ignore it.
    If Left(MapKey(Store()), 12) = "LANGUAGEINFO"
      Continue
    EndIf
    
    If Store()\State & #Reference = 0
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrUndef$  + ReferenceDesc
      
    ElseIf Store()\Reference = #Empty$
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrEmpty$ + ReferenceDesc
      
    EndIf
    
    If Store()\State & #Target = 0
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrMissing$ + #TargetFile$
      
    ElseIf Store()\Target = #Empty$
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrEmpty$ + #TargetFile$
      
    EndIf
      
    If Store()\RefCount > 1 
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrDup$ + ReferenceDesc
    EndIf
    
    If Store()\TargetCount > 1 
     AddElement(Bug())
     Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrDup$ + #TargetFile$
    EndIf
    
    If (Options & #OptTestUntranslated) = #OptTestUntranslated And UCase(Store()\Reference) = UCase(Store()\Target)
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ErrUnTrans$ + #TargetFile$
    EndIf
 
  Next Store()
   
EndProcedure

Procedure LoadDefault()
  ; Read default table from data section into Store().
  ; Report duplicated keys and empty strings in the default table.
  
  Define Group$, Name$, Key$, String$
  
  Restore Language
  
  Repeat
    
    Read.S Name$
    Read.S String$
    
    If Name$ = "_GROUP_"
      Group$ = UCase(String$)
      Group(Group$) | #Reference
      
    ElseIf Name$ = "_END_"
      Break
      
    Else
      Key$ = Group$ + "\" + UCase(Name$)
      
      Store(Key$)\State | #Reference
      Store(Key$)\Reference = String$
      Store(Key$)\RefCount + 1
      
    EndIf
    
  ForEver
  
EndProcedure

Procedure ProcessOptions()
  ; Process the command line options, or shows the usage.
  
  Define.I Index, Count = CountProgramParameters()
  Define Key$
  
  Options | #OptReferenceTable 
        
  If Count = 0
    
    PrintN(#MsgTitle$ + " " + StrF(#PB_Compiler_Version / 100, 2))
    PrintN(#Empty$)
    PrintN("Usage:")
    PrintN("LFCheck /u /r=" + #DQUOTE$ + "reference file path" + #DQUOTE$ + 
           " /t=" + #DQUOTE$ + "target file path" + #DQUOTE$ + " /l=" + #DQUOTE$ + "log file path" + #DQUOTE$)
    PrintN(#Empty$)
    PrintN("/u - Check for untranslated text.")
    PrintN("/r= - Reference catalog path, omit this to reference the IDE's default language table.")
    PrintN("/t= - Target catalog path.")
    PrintN("/l= - Log problems to a file.")
    
    CompilerIf #PB_Compiler_Debugger
      Input()
    CompilerEndIf
    
    End
    
  EndIf
  
  Count - 1
  
  For Index = 0 To Count
    
    Key$ = LCase(Left(ProgramParameter(Index), 2))
    
    Select Key$
        
      Case "/l", "-l"
        Options | #OptLogFile
        LogFile = Trim(Mid(ProgramParameter(Index), 4))
        
      Case "/r", "-r"
        Options | #OptReferenceFile
        Options ! #OptReferenceTable 
        ReferenceDesc = "Reference File."
        ReferenceFile = Trim(Mid(ProgramParameter(Index), 4))
        
      Case "/t", "-t"
        TargetFile = Trim(Mid(ProgramParameter(Index), 4))
        
      Case "/u", "-u"
        Options | #OptTestUntranslated
        
    EndSelect
    
  Next Index
  
EndProcedure

Procedure.I ReadCatalog(Catalog.S, Destination.I) 
  ; Read groups from a catalog file into Group() map and strings into the specified destination in the Store() map.
  
  ; Catalog: The fully qualified path to the catalog file to open.
  ; Destination: Either #Reference or #Target, see Enum Origin.
  
  Define.I File, Result
  Define Group$, Name$, Key$, String$
  
  If FileSize(Catalog) < 1 
    ProcedureReturn #False
  EndIf
  
  File = OpenPreferences(Catalog)
  
  If File
    ; Iterate groups.
    ExaminePreferenceGroups()
    
    While NextPreferenceGroup()
      
      ; Set group stuff.
      Group$ = UCase(PreferenceGroupName())
      Group(Group$) | Destination
      
      ; Iterate value keys.
      ExaminePreferenceKeys()
      
      While NextPreferenceKey()
        
        ; Update the key map.
        Key$ = Group$ + "\" + UCase(PreferenceKeyName())
        String$ = PreferenceKeyValue()
        
        If Destination = #Reference
          Store(Key$)\State | #Reference
          Store(Key$)\Reference = String$
          Store(Key$)\RefCount + 1
          
        Else
          Store(Key$)\State | #Target
          Store(Key$)\Target = String$
          Store(Key$)\TargetCount + 1
          
        EndIf
        
      Wend
      
    Wend
    
    ClosePreferences()
    
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure Report()
  ; Create the report, sending to a file if requested.
  
  Define.I File
  
  If ListSize(Bug()) = 0
    AddElement(Bug()) 
    Bug() = #MsgNothing$
  EndIf
  
  ; Sort bug reports.
  SortList(Bug(), #PB_Sort_Ascending)
  
  ; Add report title at the top.
  FirstElement(Bug())
  InsertElement(Bug())
  Bug() = #Empty$
  InsertElement(Bug())
  If Options & #OptReferenceFile
    Bug() = #MsgAgainst + ReferenceFile
  Else
    Bug() = #MsgAgainst + #DefTable$
  EndIf
  InsertElement(Bug())
  Bug() = #MsgChecking + TargetFile
  InsertElement(Bug())
  Bug() = #Empty$
  InsertElement(Bug())
  Bug() = #MsgTitle$
  
  If Options & #OptLogFile
    
    File = OpenFile(#PB_Any, LogFile)
    
    If File = 0
      PrintN(#MsgLog + #SQ$ + LogFile + #SQ$ + #MsgNotCreated$)
    Else
      FileSeek(File, Lof(File))
    EndIf
    
  EndIf
  
  ; Create report.
  ForEach Bug()
    
    PrintN(Bug())
    
    If File
      WriteStringN(File, Bug())
    EndIf
    
  Next Bug()
  
  If File
    CloseFile(File)
  EndIf
  
EndProcedure

;- Main
OpenConsole()    
ProcessOptions()

If (Options & #OptReferenceFile) = #OptReferenceFile 
  ; Check the file and load it.
  If FileSize(ReferenceFile) < 1 
    PrintN(#MsgRef$ + #SQ$ + ReferenceFile + #SQ$ + #MsgNotFound$)
    End
  
  ElseIf ReadCatalog(ReferenceFile, #Reference) = #False
    PrintN(#MsgRef$ + #SQ$ + ReferenceFile + #SQ$ + #MsgNotOpened$)
    End
    
  EndIf
  
Else
  ; Load the default catalog from the table.
  LoadDefault()  
  
EndIf
  
If TargetFile = #Empty$ 
  PrintN(#MsgNoTarget$)
  End
EndIf

If FileSize(TargetFile) < 1
  PrintN(#MsgTarget$ + #SQ$ + TargetFile + #SQ$ + #MsgNotFound$)
  End
EndIf

If ReadCatalog(TargetFile, #Target) = #False
  PrintN(#MsgTarget$ + #SQ$ + TargetFile + #SQ$ + #MsgNotOpened$)
  End
EndIf

CheckConsistency()
Report()

CompilerIf #PB_Compiler_Debugger
  Input()
CompilerEndIf

End
