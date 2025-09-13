; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Localisation File Consistency Checker.

; Usage:
; LanguageCheck /u /r="reference file path" /t="target file path" /l="log file path"
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
  #ORIGIN_Reference
  #ORIGIN_Target
EndEnumeration

EnumerationBinary Option
  #OPTION_ReferenceFile
  #OPTION_ReferenceTable
  #OPTION_TestUntranslated
  #OPTION_LogFile
EndEnumeration

#Key$ = "Key "
#Group$ = "Group "
#DefTable$ = "Default Language Table."
#RefFile$ = "Reference File."
#TargetFile$ = "Target File."

#SQ$ = "'"
#MSG_Title$ = "PureBasic Localisation File Consistency Checker"
#MSG_Ref$ = "The reference file "
#MSG_Target$ = "The target file "
#MSG_Log = "The log file "
#MSG_NoTarget$ = "No target file specified."
#MSG_Checking = "Checking: "
#MSG_Against = "Against: "
#MSG_NotFound$ = " could not be found."
#MSG_NotOpened$ = " could not be opened."
#MSG_NotCreated$ = " could not be created."
#MSG_Nothing$ = "No problems detected."

#ERR_Empty$ = " is empty in the "
#ERR_Dup$ = " is duplicated in the "
#ERR_Undef$ = " is not defined in the "
#ERR_Missing$ = " is missing from the "
#ERR_UnTrans$ = " is not translated in the "

;- Structures
Structure AString
  State.I
  RefCount.I
  TargetCount.I
  Reference$
  Target$
EndStructure

;- Variables
Global ReferenceDesc$ = #DefTable$, ReferenceFile$, TargetFile$, LogFile$
Global Options
Global NewMap Store.AString()
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
    
    If Group() & #ORIGIN_Reference = 0
      AddElement(Bug())
      Bug() = #Group$ + #SQ$ + MapKey(Group()) + #SQ$ + #ERR_Undef$ + ReferenceDesc$
    EndIf
    
    If Group() & #ORIGIN_Target = 0
      AddElement(Bug())
      Bug() = #Group$ + #SQ$ + MapKey(Group()) + #SQ$ + #ERR_Missing$ + #TargetFile$
    EndIf
    
  Next Group()
  
  ; Strings.
  ForEach Store()
    
    ; This section is irrelevant for consitency, ignore it.
    If Left(MapKey(Store()), 12) = "LANGUAGEINFO"
      Continue
    EndIf
    
    If Store()\State & #ORIGIN_Reference = 0
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_Undef$  + ReferenceDesc$
      
    ElseIf Store()\Reference$ = #Empty$
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_Empty$ + ReferenceDesc$
      
    EndIf
    
    If Store()\State & #ORIGIN_Target = 0
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_Missing$ + #TargetFile$
      
    ElseIf Store()\Target$ = #Empty$
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_Empty$ + #TargetFile$
      
    EndIf
      
    If Store()\RefCount > 1 
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_Dup$ + ReferenceDesc$
    EndIf
    
    If Store()\TargetCount > 1 
     AddElement(Bug())
     Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_Dup$ + #TargetFile$
    EndIf
    
    If (Options & #OPTION_TestUntranslated) = #OPTION_TestUntranslated And UCase(Store()\Reference$) = UCase(Store()\Target$)
      AddElement(Bug())
      Bug() = #Key$ + #SQ$ + MapKey(Store()) + #SQ$ + #ERR_UnTrans$ + #TargetFile$
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
      Group(Group$) | #ORIGIN_Reference
      
    ElseIf Name$ = "_END_"
      Break
      
    Else
      Key$ = Group$ + "\" + UCase(Name$)
      
      Store(Key$)\State | #ORIGIN_Reference
      Store(Key$)\Reference$ = String$
      Store(Key$)\RefCount + 1
      
    EndIf
    
  ForEver
  
EndProcedure

Procedure ProcessOptions()
  ; Process the command line options, or shows the usage.
  
  Define Index, Count = CountProgramParameters()
  Define Key$
  
  Options | #OPTION_ReferenceTable 
        
  If Count = 0
    
    PrintN(#MSG_Title$ + " " + StrF(#PB_Compiler_Version / 100, 2))
    PrintN(#Empty$)
    PrintN("Usage:")
    PrintN("LanguageCheck /u /r=" + #DQUOTE$ + "reference file path" + #DQUOTE$ + 
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
        Options | #OPTION_LogFile
        LogFile$ = Trim(Mid(ProgramParameter(Index), 4))
        
      Case "/r", "-r"
        Options | #OPTION_ReferenceFile
        Options ! #OPTION_ReferenceTable 
        ReferenceDesc$ = "Reference File."
        ReferenceFile$ = Trim(Mid(ProgramParameter(Index), 4))
        
      Case "/t", "-t"
        TargetFile$ = Trim(Mid(ProgramParameter(Index), 4))
        
      Case "/u", "-u"
        Options | #OPTION_TestUntranslated
        
    EndSelect
    
  Next Index
  
EndProcedure

Procedure.I ReadCatalog(Catalog.S, Destination.I) 
  ; Read groups from a catalog file into Group() map and strings into the specified destination in the Store() map.
  
  ; Catalog: The fully qualified path to the catalog file to open.
  ; Destination: Either #ORIGIN_Reference or #ORIGIN_Target, see Enum Origin.
  
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
        
        If Destination = #ORIGIN_Reference
          Store(Key$)\State | #ORIGIN_Reference
          Store(Key$)\Reference$ = String$
          Store(Key$)\RefCount + 1
          
        Else
          Store(Key$)\State | #ORIGIN_Target
          Store(Key$)\Target$ = String$
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
    Bug() = #MSG_Nothing$
  EndIf
  
  ; Sort bug reports.
  SortList(Bug(), #PB_Sort_Ascending)
  
  ; Add report title at the top.
  FirstElement(Bug())
  InsertElement(Bug())
  Bug() = #Empty$
  InsertElement(Bug())
  If Options & #OPTION_ReferenceFile
    Bug() = #MSG_Against + ReferenceFile$
  Else
    Bug() = #MSG_Against + #DefTable$
  EndIf
  InsertElement(Bug())
  Bug() = #MSG_Checking + TargetFile$
  InsertElement(Bug())
  Bug() = #Empty$
  InsertElement(Bug())
  Bug() = #MSG_Title$
  
  If Options & #OPTION_LogFile
    
    File = OpenFile(#PB_Any, LogFile$)
    
    If File = 0
      PrintN(#MSG_Log + #SQ$ + LogFile$ + #SQ$ + #MSG_NotCreated$)
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

If (Options & #OPTION_ReferenceFile) = #OPTION_ReferenceFile 
  ; Check the file and load it.
  If FileSize(ReferenceFile$) < 1 
    PrintN(#MSG_Ref$ + #SQ$ + ReferenceFile$ + #SQ$ + #MSG_NotFound$)
    End
  
  ElseIf ReadCatalog(ReferenceFile$, #ORIGIN_Reference) = #False
    PrintN(#MSG_Ref$ + #SQ$ + ReferenceFile$ + #SQ$ + #MSG_NotOpened$)
    End
    
  EndIf
  
Else
  ; Load the default catalog from the table.
  LoadDefault()  
  
EndIf
  
If TargetFile$ = #Empty$ 
  PrintN(#MSG_NoTarget$)
  End
EndIf

If FileSize(TargetFile$) < 1
  PrintN(#MSG_Target$ + #SQ$ + TargetFile$ + #SQ$ + #MSG_NotFound$)
  End
EndIf

If ReadCatalog(TargetFile$, #ORIGIN_Target) = #False
  PrintN(#MSG_Target$ + #SQ$ + TargetFile$ + #SQ$ + #MSG_NotOpened$)
  End
EndIf

CheckConsistency()
Report()

CompilerIf #PB_Compiler_Debugger
  Input()
CompilerEndIf

End
