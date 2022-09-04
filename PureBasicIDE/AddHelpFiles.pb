; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure AddHelpFiles_Init()
  
  AddHelpFiles_Count = 0
  
  ; all extensions are now accepted as help files (unknown ones are opened in the fileviewer)
  ;
  If ExamineDirectory(0, PureBasicPath$+#DEFAULT_HelpPath, "*")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = 1
        Type$ = UCase(GetExtensionPart(DirectoryEntryName(0)))
        If Type$ <> "GID" And Type$ <> "CNT"  And Type$ <> "CHW" And Left(DirectoryEntryName(0), 1) <> "." ; hide hidden files (mac and linux)
          
          AddHelpFiles_Count + 1
          HelpFiles(AddHelpFiles_Count-1) = DirectoryEntryName(0)
          
        EndIf
        
      EndIf
    Wend
    
    FinishDirectory(0)
  EndIf
  
  SortArray(HelpFiles(), 0, 0, AddHelpFiles_Count-1)
  
EndProcedure

Procedure AddHelpFiles_AddMenuEntries()
  
  For i = 0 To AddHelpFiles_Count-1
    MenuItem(#MENU_AddHElpFiles_Start + i, ReplaceString(HelpFiles(i), "&", "&&")) ; escape the "help underline char"
                                                                                   ;     If GetExtensionPart(HelpFiles(i)) = "" ; files without extension
                                                                                   ;       MenuItem(#MENU_AddHElpFiles_Start + i, HelpFiles(i))
                                                                                   ;     Else
                                                                                   ;       MenuItem(#MENU_AddHElpFiles_Start + i, Left(HelpFiles(i), Len(HelpFiles(i))-Len(GetExtensionPart(HelpFiles(i)))-1))
                                                                                   ;     EndIf
  Next i
  
EndProcedure

Procedure AddHelpFiles_Display(MenuID)
  
  File$ = HelpFiles(MenuID - #MENU_AddHelpFiles_Start)
  
  CompilerIf #CompileWindows
    If LCase(GetExtensionPart(File$)) = "hlp" Or LCase(GetExtensionPart(File$)) = "chm" ; on windows, open these with the help lib.
      OpenHelp(PureBasicPath$+#DEFAULT_HelpPath+File$, "")
      ProcedureReturn
    EndIf
  CompilerEndIf
  
  ; open any external help with the internal file viewer (or external tool if the user configured it like that)
  ;
  FileViewer_OpenFile(PureBasicPath$+#DEFAULT_HelpPath+File$)
  
EndProcedure
