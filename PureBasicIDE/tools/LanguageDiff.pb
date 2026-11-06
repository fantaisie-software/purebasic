; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
;
; This little tool takes an old english.catalog file and includes the
; Language.pb and creates a file containing all the differences between the two
;
; The english.catalog in this directory should ALWAYS stay at the version of the
; LAST ide release, so that on a new release, this tool can be used to see the
; changes that were made to the language. This diff can then be helpful for
; the translators to update their translated languages.
;
; After that, the english.catalog should be brought up to date by the
; CreateLanguage.pb tool so it can be used as reference with the next ide release.
;


; dummy function which is needed by Language.pb
;
Procedure BuildShortcutNamesTable()
EndProcedure

; include the file
;
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  XIncludeFile "../CompilerFlags.pb"
  
  IncludePath "../../DialogManager/"
  XIncludeFile "DialogManager.pb"
  IncludePath ""
  
  XIncludeFile "../Common.pb"
  XIncludeFile "../Language.pb"
CompilerElse
  XIncludeFile "..\CompilerFlags.pb"
  
  
  IncludePath "..\..\DialogManager\"
  XIncludeFile "DialogManager.pb"
  IncludePath ""
  
  XIncludeFile "..\Common.pb"
  XIncludeFile "..\Language.pb"
CompilerEndIf

FileName$ = ".."+#Separator+"catalogs"+#Separator+"editor.catalog"
DiffFile$ = SaveFileRequester("Save diff file to...","LanguageUpdate.txt","Text Files|*.txt|All Files|*.*", 0)


If FileName$ <> "" And DiffFile$ <> ""
  
  If OpenPreferences(FileName$)
    
    If CreateFile(0, DiffFile$)
      
      WriteStringN(0, "*********************************************")
      WriteStringN(0, "*      PureBasic IDE - Language updates     *")
      WriteStringN(0, "*********************************************")
      WriteStringN(0, FormatDate(" %mm/%dd/%yyyy", Date()))
      WriteStringN(0, "")
      
      Restore Language
      Repeat
        Read.s Name$
        Read.s String$
        
        If Name$ = "_GROUP_"
          WriteStringN(0, "")
          WriteStringN(0, "GROUP: [" + String$ + "]")
          WriteStringN(0, "---------------------------------------------")
          PreferenceGroup(String$)
          
        ElseIf Name$ <> "_END_"
          Old$ = ReadPreferenceString(Name$, "<---not-found--->")
          
          If Old$ = "<---not-found--->"
            WriteStringN(0, "ADDED: " + Name$ + " = " + String$)
            
          ElseIf Old$ <> String$
            WriteStringN(0, "CHANGED: "+Name$)
            WriteStringN(0, "FROM: "+Old$)
            WriteStringN(0, "  TO: "+String$)
            
          EndIf
        EndIf
        
      Until Name$ = "_END_"
      
      CloseFile(0)
    Else
      MessageRequester("Error","Cannot create output file")
      
    EndIf
    
    ClosePreferences()
  Else
    MessageRequester("Error","Cannot open english.catalog")
  EndIf
EndIf