; === Copyright Notice ===
;
;
;                   PureBasic source code file
;
;
; This file is part of the PureBasic Software package. It may not
; be distributed or published in source code or binary form without
; the expressed permission by Fantaisie Software.
;
; By contributing modifications or additions to this file, you grant
; Fantaisie Software the rights to use, modify and distribute your
; work in the PureBasic package.
;
;
; Copyright (C) 2000-2010 Fantaisie Software - all rights reserved
;
;

;
;
; Collect the default language options for the PB catalogs
;
; Updates the following:
;  - Editor.catalog
;  - Debugger.catalog
;  - Libraries.catalog
;
; Todo:
;  - Compiler.catalog
;  - Visual Designer Language.catalog (maybe rename that :p)
;
; Needed input: (environment variables)
;   PB_LIBRARIES    - input
;   PB_GITHUB/Documentation  - output
;

Global Libraries$ = GetEnvironmentVariable("PB_LIBRARIES")
Global Output$    = GetEnvironmentVariable("PB_GITHUB") + "/Documentation/Catalogs/"

#EXIT_SUCCESS = 0
#EXIT_FAILURE = 1

Structure Entry
  Group$
  Key$
  Value$
EndStructure

Global NewList Key.Entry()

;
; Stuff needed to include Language.pb from the IDE directly
;
Procedure BuildShortcutNamesTable(): EndProcedure

XIncludeFile "../PureBasicIDE/CompilerFlags.pb"
XIncludeFile "../DialogManager/DialogManager.pb"
XIncludeFile "../PureBasicIDE/Common.pb"
XIncludeFile "../PureBasicIDE/Language.pb"



Procedure WriteCatalogFile(Filename$, AppID$, Comment$ = "PureBasic Language file")
  
  Debug "Writing file: " + Output$ + Filename$
  
  NewList Group.s()
  
  ForEach Key()
    found = 0
    ForEach Group()
      If LCase(Key()\Group$) = LCase(Group())
        found = 1
        Break
      EndIf
    Next Group()
    
    If found = 0
      AddElement(Group())
      Group() = Key()\Group$
    EndIf
  Next Key()
  
  Debug "Total groups: " + Str(ListSize(Group()))
  Debug "Total keys  : " + Str(ListSize(Key()))
  
  If CreateFile(0, Output$ + Filename$)
    WriteStringN(0, ";")
    WriteStringN(0, "; " + Comment$)
    WriteStringN(0, ";")
    WriteStringN(0, "")
    WriteStringN(0, "[LanguageInfo]")
    WriteStringN(0, "Application = " + AppID$)
    WriteStringN(0, "Language    = English")
    ;    WriteStringN(0, "LastUpdated = " + FormatDate("%mm/%dd/%yyyy", Date())) ; It mess with git, we can use the commit date anyway
    WriteStringN(0, "Creator     = PureBasic Team")
    WriteStringN(0, "Email       = Support@PureBasic.com")
    WriteStringN(0, "")
    WriteStringN(0, "")
    
    ForEach Group()
      WriteStringN(0, "["+Group()+"]")
      
      length = 0
      ForEach Key()
        If LCase(Key()\Group$) = LCase(Group()) And Len(Key()\Key$) > length
          length = Len(Key()\Key$)
        EndIf
      Next Key()
      
      ForEach Key()
        If LCase(Key()\Group$) = LCase(Group()) And Trim(Key()\Key$) <> ""
          WriteStringN(0, LSet(Key()\Key$, length, " ") + " = " + Key()\Value$)
        EndIf
      Next Key()
      
      WriteStringN(0, "")
    Next Group()
    
    CloseFile(0)
  Else
    MessageRequester("Error", "Cannot write catalog file: " + Chr(13) + Output$)
    End #EXIT_FAILURE
    
  EndIf
  
EndProcedure

Procedure.s UnEscape(String$)
  ; not much others are used anyway
  String$ = ReplaceString(String$, "\\", Chr(1)) ; special case
  String$ = ReplaceString(String$, "\'", "'")
  String$ = ReplaceString(String$, "\t", Chr(9))
  String$ = ReplaceString(String$, "\"+Chr(34), Chr(34))
  ProcedureReturn ReplaceString(String$, Chr(1), "\")
EndProcedure


;
;- Libraries.Catalog
;

; NOTE: The format must match exactly
;
; static PB_Language LanguageTable =
; {
;   "Libraries.catalog",
;   "PB_Libraries",
;   "Common",
;   0,
;   {
;     "NoStartDrawing",   "StopDrawing() must be called after a successful StartDrawing().",
;     "", "",
;   }
; };

Procedure SearchLibraryFile(File$)
  
  If ReadFile(0, File$)
    While Eof(0) = 0
      Line$ = ReadString(0)
      
      If FindString(Line$, "static PB_Language LanguageTable", 1) <> 0
        ReadString(0) ; {
        ReadString(0) ; catalog file
        ReadString(0) ; app id
        Group$ = ReadString(0)
        ReadString(0) ; 0,
        ReadString(0) ; {
        
        Group$ = Trim(StringField(Group$, 2, Chr(34)))
        Debug "-- LanguageTable found in: " +File$ + "  ("+Group$+")"
        
        Repeat
          Line$ = ReadString(0)
          
          ; need a pair of strings
          If CountString(Line$, ",") < 1 Or CountString(Line$, Chr(34)) < 4
            Continue
          EndIf
          
          Key$ = Trim(StringField(Line$, 2, Chr(34)))
          
          Start = FindString(Line$, Chr(34), FindString(Line$, ",", 1)) + 1
          Value$ = Mid(Line$, Start)
          
          While Right(Value$, 1) <> Chr(34)
            Value$ = Left(Value$, Len(Value$)-1)
          Wend
          
          Value$ = Trim(UnEscape(Left(Value$, Len(Value$)-1)))
          
          If Key$ <> ""
            AddElement(Key())
            Key()\Group$ = Group$
            Key()\Key$   = Key$
            Key()\Value$ = Value$
          EndIf
        Until Eof(0) Or Key$ = ""
        
        Break
      EndIf
    Wend
    
    CloseFile(0)
  Else
    MessageRequester("Error", "Cannot read file: " + Chr(13) + File$)
    End #EXIT_FAILURE
  EndIf
  
EndProcedure

Procedure SearchLibraries(ID, Path$)
  
  ; Find further directories
  ;
  If ExamineDirectory(ID, Path$, "*")
    While NextDirectoryEntry(ID)
      If DirectoryEntryType(ID) = #PB_DirectoryEntry_Directory
        Name$ = DirectoryEntryName(ID)
        If Name$ <> "." And Name$ <> ".."
          SearchLibraries(ID+1, Path$+"/"+Name$)
        EndIf
      EndIf
    Wend
    
    FinishDirectory(ID)
  EndIf
  
  ; Find debugger files
  ;
  If ExamineDirectory(ID, Path$, "*_DEBUG.c")
    While NextDirectoryEntry(ID)
      If DirectoryEntryType(ID) = #PB_DirectoryEntry_File
        Name$ = DirectoryEntryName(ID)
        SearchLibraryFile(Path$+"/"+Name$)
      EndIf
    Wend
    
    FinishDirectory(ID)
  EndIf
  
EndProcedure

ClearList(Key())
SearchLibraryFile(Libraries$ + "/Debugger/Helpers.c") ; contains the "Common" table
SearchLibraries(0, Libraries$)
WriteCatalogFile("Libraries.catalog", "PB_Libraries", "PureBasic Debugger - Libraries language file")

;
;- Debugger.catalog
;
ClearList(Key())

; NOTE:
;   The DebuggerLanguage.c is expected to only contain the PB_DEBUGGER_LanguageTable
;   array, with one entry per line max, else this fails.
;
If ReadFile(0, Libraries$ + "/Debugger/DebuggerLanguage.c")
  Group$ = ""
  
  While Eof(0) = 0
    Line$ = Trim(ReadString(0))
    
    If Left(Line$, 2) <> "//" And CountString(Line$, ",") >= 1 And CountString(Line$, Chr(34)) >= 4 ; need atleast "", ""
      Key$ = StringField(Line$, 2, Chr(34))
      
      Start = FindString(Line$, Chr(34), FindString(Line$, ",", 1)) + 1
      Value$ = Mid(Line$, Start)
      
      While Right(Value$, 1) <> Chr(34)
        Value$ = Left(Value$, Len(Value$)-1)
      Wend
      
      Value$ = Trim(UnEscape(Left(Value$, Len(Value$)-1)))
      
      If UCase(Key$) = "_GROUP_"
        Group$ = Value$
        
      ElseIf UCase(Key$) = "_END_"
        Break
        
      Else
        AddElement(Key())
        Key()\Group$ = Group$
        Key()\Key$   = Key$
        Key()\Value$ = Value$
        
      EndIf
      
    EndIf
  Wend
Else
  MessageRequester("Error", "Cannot read input file: " + Chr(13) + Libraries$ + "/Debugger/DebuggerLanguage.c")
  End #EXIT_FAILURE
  
EndIf

WriteCatalogFile("Debugger.catalog", "PB_Debugger", "PureBasic Debugger language file")

;
;- Editor.Catalog
;
ClearList(Key())

; We include directly the IDE Language.pb, so this is easy to read
;
Restore Language
Group$ = ""

Repeat
  Read.s Name$
  Read.s String$
  
  If Name$ = "_GROUP_"
    Group$ = String$
    
  ElseIf Name$ = "_END_"
    Break
    
  Else
    AddElement(Key())
    Key()\Group$ = Group$
    Key()\Key$   = Name$
    Key()\Value$ = String$
    
  EndIf
ForEver

WriteCatalogFile("Editor.catalog", "PB_IDE", "PureBasic IDE language file")

End #EXIT_SUCCESS
