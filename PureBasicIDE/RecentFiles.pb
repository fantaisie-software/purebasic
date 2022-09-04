; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure.s RecentFiles_EntryString(Index)
  
  If Index > #MAX_RecentFiles ; its a project
    
    Name$ = ProjectName(RecentFiles(Index))
    If Name$ <> ""
      Name$ = "  (" + Name$ + ")"
    EndIf
    
    ProcedureReturn RSet(Str(Index-#MAX_RecentFiles), Len(Str(FilesHistorySize))) + ")  " + GetFilePart(RecentFiles(Index)) + Name$
    
  Else ; its a source file
    
    ProcedureReturn RSet(Str(Index), Len(Str(FilesHistorySize))) + ")  " + RecentFiles(Index) ; Display full path here, to avoid issue if some files gets same name (ie: main.pb) https://www.purebasic.fr/english/viewtopic.php?f=3&t=60650
    
  EndIf
  
EndProcedure

Procedure RecentFiles_AddMenuEntries(IsProject)
  
  If IsProject = #False
    Offset = 0
  Else
    Offset = #MAX_RecentFiles
  EndIf
  
  Count = 0
  For i = 1 To FilesHistorySize
    If RecentFiles(Offset+i)
      MenuItem(#MENU_RecentFiles_Start+Offset+i-1, ReplaceString(RecentFiles_EntryString(Offset+i), "&", "&&")) ; escape the "menu char"
      Count + 1
    EndIf
  Next i
  
  If IsProject = #False
    DisplayedRecentFiles = Count
  Else
    DisplayedRecentProjects = Count
  EndIf
  
EndProcedure


Procedure RecentFiles_AddFile(FileName$, IsProject)
  
  CompilerIf #CompileWindows
    ; Also notify the OS of the file usage
    ; This is useful for the 'recent file' list in the start menu and Windows7 Taskbar
    
    CompilerIf #PB_Compiler_Unicode
      #SHARD_PATH = $00000003
    CompilerElse
      #SHARD_PATH = $00000002
    CompilerEndIf
    
    SHAddToRecentDocs_(#SHARD_PATH, @FileName$)
  CompilerEndIf
  
  If IsProject = #False
    Offset   = 0
    OldCount = DisplayedRecentFiles
  Else
    Offset   = #MAX_RecentFiles
    OldCount = DisplayedRecentProjects
  EndIf
  
  If IsEqualFile(FileName$, RecentFiles(Offset+1))
    ProcedureReturn ; the file is already at the top of the list, so there is nothing to do
  EndIf
  
  ; search for the same filename in the list
  ;
  Found = 0
  For index = 1 To FilesHistorySize
    If RecentFiles(Offset+index) = "" Or IsEqualFile(FileName$, RecentFiles(Offset+index))
      Found = 1
      Break
    EndIf
  Next index
  
  If Found = 0
    index = FilesHistorySize
  EndIf
  
  ; now move all other files one index down..
  ;
  For i = index-1 To 1 Step -1
    RecentFiles(Offset+i+1) = RecentFiles(Offset+i)
  Next i
  
  RecentFiles(Offset+1) = FileName$
  
  ; Count the number of entries we have
  Count = 0
  For i = 1 To FilesHistorySize
    If RecentFiles(Offset+i)
      Count + 1
    EndIf
  Next i
  
  If Count = OldCount And Count = FilesHistorySize
    ; rename the menu items for Recentfiles (no recreation of the whole menu)
    For i = 1 To FilesHistorySize
      SetMenuItemText(#MENU, #MENU_RecentFiles_Start+Offset+i-1, ReplaceString(RecentFiles_EntryString(Offset+i), "&", "&&"))
    Next i
  Else
    ; the count changed.. we must re-create the menu
    StartFlickerFix(#WINDOW_Main)
    CreateIDEMenu() ; update the menu
    StopFlickerFix(#WINDOW_Main, 1)
  EndIf
  
EndProcedure



Procedure RecentFiles_Open(MenuItemID)
  
  If MenuItemID >= #MENU_RecentFiles_Start And MenuItemID <= #MENU_RecentFiles_End
    If Trim(RecentFiles(MenuItemID - #MENU_RecentFiles_Start + 1)) <> ""
      
      If MenuItemID < #MENU_RecentFiles_Start+#MAX_RecentFiles ; RecentFiles range
        LoadSourceFile(RecentFiles(MenuItemID - #MENU_RecentFiles_Start + 1))
      Else ; RecentProjects range
        LoadProject(RecentFiles(MenuItemID - #MENU_RecentFiles_Start + 1))
      EndIf
      
      ; do not add the filename to the beginning of the list, LoadSourceFile()/LoadProject() will do so
    EndIf
  EndIf
  
EndProcedure


