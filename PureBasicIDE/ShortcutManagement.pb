; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



Procedure BuildShortcutNamesTable()
  
  ShortcutNames(0)  = ""
  ShortcutValues(0) = 0
  
  Restore ShortcutKeys
  index = 1
  
  ; number keys
  For i = 0 To 9
    ShortcutNames(index) = Str(i)
    Read.l ShortcutValues(index)
    index + 1
  Next i
  
  ; character keys
  For i = 'A' To 'Z'
    ShortcutNames(index) = Chr(i)
    Read.l ShortcutValues(index)
    index + 1
  Next i
  
  ; function keys
  For i = 1 To 24
    ShortcutNames(index) = "F" + Str(i)
    Read.l ShortcutValues(index)
    index + 1
  Next i
  
  ; numpad keys
  For i = 0 To 9
    ShortcutNames(index) = Language("Shortcuts", "Numpad")+" "+Str(i)
    Read.l ShortcutValues(index)
    index + 1
  Next i
  
  ; other keys
  For index = 71 To #NbShortcutKeys
    ShortcutNames(index) = Language("Shortcuts","Key"+Str(index))
    Read.l ShortcutValues(index)
  Next index
  
EndProcedure


Procedure CreateKeyboardShortcuts(Window)
  
  For item = 0 To #MENU_LastShortcutItem
    If KeyboardShortcuts(item) <> -1 And KeyboardShortcuts(item) <> 0
      If item = #MENU_AutoComplete_OK And Window = #WINDOW_Main
        If KeyboardShortcuts(item) <> #PB_Shortcut_Tab And KeyboardShortcuts(item) <> #PB_Shortcut_Return
          ; we have special shortcuts for Tab and Enter on Scintilla which call the appropriate autocomplete
          ; as well, so do not add such a shortcut again!
          ; this shortcut is needed on the main window as well for the "insert end keyword on double press" option
          AddKeyboardShortcut(Window, KeyboardShortcuts(item), item)
        EndIf
      ElseIf item <> #MENU_AutoComplete_Abort Or Window = #WINDOW_AutoComplete ; add "abort" only to the autocomplete window
        AddKeyboardShortcut(Window, KeyboardShortcuts(item), item)
      EndIf
    EndIf
  Next item
  
EndProcedure

Procedure GetBaseKeyIndex(Shortcut)
  
  If Shortcut
    For i = 0 To #NbShortcutKeys
      If Shortcut & ~(#PB_Shortcut_Control|#PB_Shortcut_Alt|#PB_Shortcut_Shift|#PB_Shortcut_Command) = ShortcutValues(i)
        ProcedureReturn i
      EndIf
    Next i
  EndIf
  
  ProcedureReturn 0
EndProcedure

Procedure.s GetShortcutText(Shortcut)
  
  If Shortcut = -1
    ProcedureReturn ""
  EndIf
  
  Text$ = ""
  
  CompilerIf #CompileMac
    If Shortcut & #PB_Shortcut_Command
      Text$ + "+CMD" ; do not use the name from the Language here, as only "CMD" produces that key symbol
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileWindows = 0
    
    ; On Linux and OSX, the MenuItem command parses the text for shortcuts, so it needs to be the
    ; english name here!
    ;
    If Shortcut & #PB_Shortcut_Control
      Text$ + "+Ctrl"
    EndIf
    If Shortcut & #PB_Shortcut_Alt
      Text$ + "+Alt"
    EndIf
    If Shortcut & #PB_Shortcut_Shift
      Text$ + "+Shift"
    EndIf
    
  CompilerElse
    
    ; For other OS, put the language specific strings here
    ;
    If Shortcut & #PB_Shortcut_Control
      Text$ + "+" + Language("Shortcuts","Control")
    EndIf
    If Shortcut & #PB_Shortcut_Alt
      Text$ + "+" + Language("Shortcuts","Alt")
    EndIf
    If Shortcut & #PB_Shortcut_Shift
      Text$ + "+" + Language("Shortcuts","Shift")
    EndIf
    
  CompilerEndIf
  
  Text$ + "+" + ShortcutNames(GetBaseKeyIndex(Shortcut))
  
  ProcedureReturn Right(Text$, Len(Text$)-1)
EndProcedure

Procedure ShortcutMenuItem(MenuItemID, Text$)
  
  Select MenuItemID
      
      ; suppress the image so the checkmark shows
    Case #MENU_Debugger, #MENU_EncodingPlain, #MENU_EncodingUtf8, #MENU_NewlineWindows, #MENU_NewlineLinux, #MENU_NewlineMacOS, #MENU_ShowLog
      ImageID = 0
      
    Default
      ImageID = ToolbarMenuImage(MenuItemID)
      
  EndSelect
  
  If MenuItemID >= 0 ; On OS X, MenuItemID can be negative for #PB_Menu_Quit, #PB_Menu_About and #PB_Menu_Preferences
    Shortcut$ = GetShortcutText(KeyboardShortcuts(MenuItemID))
  EndIf
  
  If Shortcut$ = ""
    ProcedureReturn MenuItem(MenuItemID, Text$, ImageID)
  Else
    ProcedureReturn MenuItem(MenuItemID, Text$ + Chr(9) + Shortcut$, ImageID)
  EndIf
  
EndProcedure


Procedure FillShortcutList()
  
  ClearGadgetItems(#GADGET_Preferences_ShortcutList)
  Restore ShortcutItems
  
  For item = 0 To #MENU_LastShortcutItem
    Read.s MenuTitle$
    Read.s MenuItem$
    Read.l DefaultShortcut
    
    If MenuTitle$ <> ""
      Text$ = RemoveString(Language("MenuTitle",MenuTitle$), "&") + " -> " + RemoveString(Language("MenuItem",MenuItem$), "&")
    Else
      Text$ = Language("Shortcuts",MenuItem$)
    EndIf
    
    AddGadgetItem(#GADGET_Preferences_ShortcutList, -1, Text$)
    SetGadgetItemText(#GADGET_Preferences_ShortcutList, item, GetShortcutText(Prefs_KeyboardShortcuts(item)), 1)
  Next item
  
EndProcedure


Procedure.s GetShortcutOwner(Shortcut)
  
  ; check main window shortcuts
  ;
  Restore ShortcutItems
  
  If IsWindow(#WINDOW_Preferences)
    For i = 0 To #MENU_LastShortcutItem
      Read.s MenuTitle$
      Read.s MenuItem$
      Read.l DefaultShortcut
      
      If Prefs_KeyboardShortcuts(i) = Shortcut
        If MenuTitle$ = ""
          ProcedureReturn Language("Shortcuts",MenuItem$)
        Else
          ProcedureReturn RemoveString(Language("MenuTitle",MenuTitle$)+" -> "+Language("MenuItem",MenuItem$), "&")
        EndIf
      EndIf
    Next i
  Else
    For i = 0 To #MENU_LastShortcutItem
      Read.s MenuTitle$
      Read.s MenuItem$
      Read.l DefaultShortcut
      
      If KeyboardShortcuts(i) = Shortcut
        If MenuTitle$ = ""
          ProcedureReturn Language("Shortcuts",MenuItem$)
        Else
          ProcedureReturn RemoveString(Language("MenuTitle",MenuTitle$)+" -> "+Language("MenuItem",MenuItem$), "&")
        EndIf
      EndIf
    Next i
  EndIf
  
  ; check add tools shortcuts
  ;
  If IsWindow(#WINDOW_AddTools)
    ForEach ToolsList_Edit()
      If ToolsList_Edit()\Shortcut = Shortcut
        ProcedureReturn Language("Shortcuts","ExternalTool")+": "+ToolsList_Edit()\MenuItemName$
      EndIf
    Next ToolsList_Edit()
  Else
    ForEach ToolsList()
      If ToolsList()\Shortcut = Shortcut
        ProcedureReturn Language("Shortcuts","ExternalTool")+": "+ToolsList()\MenuItemName$
      EndIf
    Next ToolsList()
  EndIf
  
  ; Check the main menu's shortcuts
  ;
  If Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","File")))-'A')
    ProcedureReturn Language("Shortcuts","Menu")+": "+Language("MenuTitle","File")
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Edit")))-'A')
    ProcedureReturn Language("Shortcuts","Menu")+": "+Language("MenuTitle","Edit")
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Compiler")))-'A')
    ProcedureReturn Language("Shortcuts","Menu")+": "+Language("MenuTitle","Compiler")
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Tools")))-'A')
    ProcedureReturn Language("Shortcuts","Menu")+": "+Language("MenuTitle","Tools")
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Help")))-'A')
    ProcedureReturn Language("Shortcuts","Menu")+": "+Language("MenuTitle","Help")
    
  EndIf
  
  ; Check for Tab & Shift+Tab (these are for intend/unintend. they can't be changed because they are handled directly by the keyhandler)
  ;
  If Shortcut = #PB_Shortcut_Tab Or Shortcut = #PB_Shortcut_Shift | #PB_Shortcut_Tab
    ProcedureReturn Language("Shortcuts","TabIntend")
  EndIf
  
  ; check for reserved shortcuts
  ;
  Restore ReservedShortcuts
  Repeat
    Read.l ReservedShortcut
    If Shortcut = ReservedShortcut
      ProcedureReturn Language("Shortcuts","SystemShortcut")
    EndIf
  Until Shortcut = -1
  
EndProcedure

Procedure IsShortcutUsed(Shortcut, CurrentPrefsItem, *CurrentAddTool)
  
  If Shortcut = 0 Or Shortcut = -1
    ProcedureReturn 0
  EndIf
  
  ; special check: Tab and Enter can be used to confirm AutoComplete even though
  ; they are also used for Indent/Unindent (the code handles this)
  ;
  If CurrentPrefsItem = #MENU_AutoComplete_OK And (Shortcut = #PB_Shortcut_Tab Or Shortcut = #PB_Shortcut_Return)
    ProcedureReturn 0
  EndIf
  
  ; check main window shortcuts
  ;
  If IsWindow(#WINDOW_Preferences)
    For i = 0 To #MENU_LastShortcutItem
      If Prefs_KeyboardShortcuts(i) = Shortcut And i <> CurrentPRefsItem
        ProcedureReturn 1
      EndIf
    Next i
  Else
    For i = 0 To #MENU_LastShortcutItem
      If KeyboardShortcuts(i) = Shortcut
        ProcedureReturn 1
      EndIf
    Next i
  EndIf
  
  ; check add tools shortcuts
  ;
  If IsWindow(#WINDOW_AddTools)
    ForEach ToolsList_Edit()
      If ToolsList_Edit()\Shortcut = Shortcut And @ToolsList_Edit() <> *CurrentAddTool
        ProcedureReturn 1
      EndIf
    Next ToolsList_Edit()
  Else
    ForEach ToolsList()
      If ToolsList()\Shortcut = Shortcut
        ProcedureReturn 1
      EndIf
    Next ToolsList()
  EndIf
  
  ; Check the main menu's shortcuts
  ;
  If Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","File")))-'A')
    ProcedureReturn 1
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Edit")))-'A')
    ProcedureReturn 1
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Compiler")))-'A')
    ProcedureReturn 1
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Tools")))-'A')
    ProcedureReturn 1
    
  ElseIf Shortcut = #PB_Shortcut_Alt | (#PB_Shortcut_A + Asc(UCase(Language("MenuTitle","Help")))-'A')
    ProcedureReturn 1
    
  EndIf
  
  ; Check for Tab & Shift+Tab (these are for intend/unintend. they can't be changed because they are handled directly by the keyhandler)
  ;
  If Shortcut = #PB_Shortcut_Tab Or Shortcut = #PB_Shortcut_Shift | #PB_Shortcut_Tab
    ProcedureReturn 1
  EndIf
  
  ; check for reserved shortcuts
  ;
  Restore ReservedShortcuts
  Repeat
    Read.l ReservedShortcut
    If Shortcut = ReservedShortcut
      ProcedureReturn 1
    EndIf
  Until ReservedShortcut = -1
  
  ProcedureReturn 0
EndProcedure

Procedure.s ShortcutToIndependentName(Shortcut)
  
  If Shortcut = -1
    ProcedureReturn ""
  EndIf
  
  Text$ = ""
  
  If Shortcut & #PB_Shortcut_Control
    Text$ + "CONTROL+"
  EndIf
  
  If Shortcut & #PB_Shortcut_Alt
    Text$ + "ALT+"
  EndIf
  
  If Shortcut & #PB_Shortcut_Shift
    Text$ + "SHIFT+"
  EndIf
  
  If Shortcut & #PB_Shortcut_Command
    Text$ + "COMMAND+"
  EndIf
  
  Text$ + Str(GetBaseKeyIndex(Shortcut)) ; do not use the shortcut name,as it is language specific
  
  ProcedureReturn Text$
  
EndProcedure

Procedure IndependentNameToShortcut(Name$)
  
  Name$ = RemoveString(RemoveString(UCase(Name$), " "), Chr(9))
  
  Index = Val(StringField(Name$, CountString(Name$, "+")+1, "+"))
  If Index > 0 And Index <= #NbShortcutKeys
    Shortcut = ShortcutValues(Index)
  Else
    Shortcut = 0
  EndIf
  
  If FindString(Name$, "CONTROL", 1) <> 0
    Shortcut | #PB_Shortcut_Control
  EndIf
  
  If FindString(Name$, "ALT", 1) <> 0
    Shortcut | #PB_Shortcut_Alt
  EndIf
  
  If FindString(Name$, "SHIFT", 1) <> 0
    Shortcut | #PB_Shortcut_Shift
  EndIf
  
  CompilerIf #CompileMac ; apply the CONTROL one only on the mac
    If FindString(Name$, "CONTROL", 1) <> 0
      Shortcut | #PB_Shortcut_Command
    EndIf
  CompilerEndIf
  
  ProcedureReturn Shortcut
EndProcedure


;- Default shortcuts
; Default shortcuts for the IDE, they are depending of the plateform so put them here
;
CompilerIf #CompileLinux | #CompileWindows
  #SHORTCUT_New                = #PB_Shortcut_Control | #PB_Shortcut_N
  #SHORTCUT_Open               = #PB_Shortcut_Control | #PB_Shortcut_O
  #SHORTCUT_Save               = #PB_Shortcut_Control | #PB_Shortcut_S
  #SHORTCUT_Close              = #PB_Shortcut_Control | #PB_Shortcut_W
  #SHORTCUT_Undo               = #PB_Shortcut_Control | #PB_Shortcut_Z
  #SHORTCUT_Redo               = #PB_Shortcut_Control | #PB_Shortcut_Y
  #SHORTCUT_Cut                = #PB_Shortcut_Control | #PB_Shortcut_X
  #SHORTCUT_Copy               = #PB_Shortcut_Control | #PB_Shortcut_C
  #SHORTCUT_Paste              = #PB_Shortcut_Control | #PB_Shortcut_V
  #SHORTCUT_PasteAsComment     = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_V
  #SHORTCUT_CommentSelection   = #PB_Shortcut_Control | #PB_Shortcut_B
  #SHORTCUT_UnCommentSelection = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_B ; Avoid 'Alt+B' shorcut as it conflict with german menu title: https://www.purebasic.fr/english/viewtopic.php?f=23&t=37098
  #SHORTCUT_SelectAll          = #PB_Shortcut_Control | #PB_Shortcut_A
  #SHORTCUT_Goto               = #PB_Shortcut_Control | #PB_Shortcut_G
  #SHORTCUT_JumpToKeyword      = #PB_Shortcut_Control | #PB_Shortcut_K
  #SHORTCUT_LastViewedLine     = #PB_Shortcut_Control | #PB_Shortcut_L
  #SHORTCUT_AddMarker          = #PB_Shortcut_Control | #PB_Shortcut_F2
  #SHORTCUT_JumpToMarker       = #PB_Shortcut_F2
  #SHORTCUT_Find               = #PB_Shortcut_Control | #PB_Shortcut_F
  #SHORTCUT_FindNext           = #PB_Shortcut_F3
  #SHORTCUT_FindPrevious       = #PB_Shortcut_Shift | #PB_Shortcut_F3
  #SHORTCUT_FindInFiles        = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_F
  #SHORTCUT_Replace            = #PB_Shortcut_Control | #PB_Shortcut_H
  #SHORTCUT_NewProject         = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_N
  #SHORTCUT_OpenProject        = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_O
  #SHORTCUT_CloseProject       = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_W
  #SHORTCUT_AddProjectFile     = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_A
  #SHORTCUT_RemoveProjectFile  = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_R
  #SHORTCUT_MakeBackup         = #PB_Shortcut_Control | #PB_Shortcut_M
  #SHORTCUT_TodoList           = #PB_Shortcut_Control | #PB_Shortcut_T
  #SHORTCUT_CompileRun         = #PB_Shortcut_F5
  #SHORTCUT_Run                = #PB_Shortcut_Shift   | #PB_Shortcut_F5
  #SHORTCUT_VisualDesigner     = #PB_Shortcut_Alt | #PB_Shortcut_V
  #SHORTCUT_StructureViewer    = #PB_Shortcut_Alt | #PB_Shortcut_S
  #SHORTCUT_Help               = #PB_Shortcut_F1
  #SHORTCUT_NextOpenedFile     = #PB_Shortcut_Tab | #PB_Shortcut_Control
  #SHORTCUT_PreviousOpenedFile = #PB_Shortcut_Tab | #PB_Shortcut_Control | #PB_Shortcut_Shift
  #SHORTCUT_ShiftCommentRight  = #PB_Shortcut_Control | #PB_Shortcut_E
  #SHORTCUT_ShiftCommentLeft   = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_E
  #SHORTCUT_SelectBlock        = #PB_Shortcut_Control | #PB_Shortcut_M
  #SHORTCUT_DeselectBlock      = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_M
  #SHORTCUT_MoveLinesUp        = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_Up
  #SHORTCUT_MoveLinesDown      = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_Down
  #SHORTCUT_DeleteLines        = 0
  #SHORTCUT_DuplicateSelection = #PB_Shortcut_Control | #PB_Shortcut_D
  CompilerIf #PB_Compiler_OS   = #PB_OS_Windows
    #SHORTCUT_ZoomIn           = #PB_Shortcut_Control | #VK_OEM_PLUS
    #SHORTCUT_ZoomOut          = #PB_Shortcut_Control | #VK_OEM_MINUS
    #SHORTCUT_ZoomDefault      = #PB_Shortcut_Control | #PB_Shortcut_0
  CompilerElse
    #SHORTCUT_ZoomIn           = 0
    #SHORTCUT_ZoomOut          = 0
    #SHORTCUT_ZoomDefault      = #PB_Shortcut_Control | #PB_Shortcut_0
  CompilerEndIf
  #SHORTCUT_ProcedureListUpdate= #PB_Shortcut_F12
  #SHORTCUT_VariableViewer     = 0 ; Alt+V already used by VD!
  #SHORTCUT_ColorPicker        = 0 ; Alt+P is for Menu/&Project
  #SHORTCUT_AsciiTable         = #PB_Shortcut_A | #PB_Shortcut_Alt
  #SHORTCUT_Explorer           = #PB_Shortcut_X | #PB_Shortcut_Alt
  #SHORTCUT_ToggleFolds        = #PB_Shortcut_Control | #PB_Shortcut_F4
  #SHORTCUT_ToggleThisFold     = #PB_Shortcut_F4
  #SHORTCUT_Stop               = #PB_Shortcut_F6
  #SHORTCUT_Continue           = #PB_Shortcut_F7
  #SHORTCUT_Step               = #PB_Shortcut_F8
  #SHORTCUT_StepX              = #PB_Shortcut_Control | #PB_Shortcut_F8
  #SHORTCUT_StepOver           = #PB_Shortcut_F10
  #SHORTCUT_StepOut            = #PB_Shortcut_F11
  #SHORTCUT_BreakPoint         = #PB_Shortcut_F9
  #SHORTCUT_AutoComplete       = #PB_Shortcut_Control | #PB_Shortcut_Space
  #SHORTCUT_AutoCompleteConfirm= #PB_Shortcut_Tab
  #SHORTCUT_AutoCompleteAbort  = #PB_Shortcut_Escape
  #SHORTCUT_AutoIndent         = #PB_Shortcut_Control | #PB_Shortcut_I
  #SHORTCUT_UpperCase          = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_U
  #SHORTCUT_LowerCase          = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_L
  #SHORTCUT_InvertCase         = #PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_X
  #SHORTCUT_SelectWord         = 0
CompilerElse
  ; MacOS default shortcuts
  ;
  #SHORTCUT_New                = #PB_Shortcut_Command | #PB_Shortcut_N
  #SHORTCUT_Open               = #PB_Shortcut_Command | #PB_Shortcut_O
  #SHORTCUT_Save               = #PB_Shortcut_Command | #PB_Shortcut_S
  #SHORTCUT_Close              = #PB_Shortcut_Command | #PB_Shortcut_W
  #SHORTCUT_Undo               = #PB_Shortcut_Command | #PB_Shortcut_Z
  #SHORTCUT_Redo               = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_Z
  #SHORTCUT_Cut                = #PB_Shortcut_Command | #PB_Shortcut_X
  #SHORTCUT_Copy               = #PB_Shortcut_Command | #PB_Shortcut_C
  #SHORTCUT_Paste              = #PB_Shortcut_Command | #PB_Shortcut_V
  #SHORTCUT_PasteAsComment     = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_V
  #SHORTCUT_CommentSelection   = #PB_Shortcut_Command | #PB_Shortcut_B
  #SHORTCUT_UnCommentSelection = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_B
  #SHORTCUT_SelectAll          = #PB_Shortcut_Command | #PB_Shortcut_A
  #SHORTCUT_Goto               = #PB_Shortcut_Command | #PB_Shortcut_G
  #SHORTCUT_JumpToKeyword      = #PB_Shortcut_Command | #PB_Shortcut_K
  #SHORTCUT_LastViewedLine     = #PB_Shortcut_Command | #PB_Shortcut_L
  #SHORTCUT_AddMarker          = #PB_Shortcut_Command | #PB_Shortcut_F2
  #SHORTCUT_JumpToMarker       = #PB_Shortcut_F2
  #SHORTCUT_Find               = #PB_Shortcut_Command | #PB_Shortcut_F
  #SHORTCUT_FindNext           = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_F
  #SHORTCUT_FindPrevious       = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_P
  #SHORTCUT_FindInFiles        = 0
  #SHORTCUT_Replace            = #PB_Shortcut_Command | #PB_Shortcut_H
  #SHORTCUT_NewProject         = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_N
  #SHORTCUT_OpenProject        = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_O
  #SHORTCUT_CloseProject       = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_W
  #SHORTCUT_AddProjectFile     = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_A
  #SHORTCUT_RemoveProjectFile  = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_R
  #SHORTCUT_MakeBackup         = #PB_Shortcut_Command | #PB_Shortcut_M
  #SHORTCUT_TodoList           = #PB_Shortcut_Command | #PB_Shortcut_Alt  | #PB_Shortcut_T
  #SHORTCUT_CompileRun         = #PB_Shortcut_F5
  #SHORTCUT_Run                = #PB_Shortcut_Shift   | #PB_Shortcut_F5
  #SHORTCUT_VisualDesigner     = #PB_Shortcut_Command | #PB_Shortcut_Y
  #SHORTCUT_StructureViewer    = #PB_Shortcut_Command | #PB_Shortcut_Alt | #PB_Shortcut_S
  #SHORTCUT_Help               = #PB_Shortcut_F1
  #SHORTCUT_NextOpenedFile     = #PB_Shortcut_Tab | #PB_Shortcut_Control
  #SHORTCUT_PreviousOpenedFile = #PB_Shortcut_Tab | #PB_Shortcut_Control | #PB_Shortcut_Shift
  #SHORTCUT_ShiftCommentRight  = #PB_Shortcut_Command | #PB_Shortcut_E
  #SHORTCUT_ShiftCommentLeft   = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_E
  #SHORTCUT_SelectBlock        = #PB_Shortcut_Command | #PB_Shortcut_M
  #SHORTCUT_DeselectBlock      = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_M
  #SHORTCUT_MoveLinesUp        = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_Up
  #SHORTCUT_MoveLinesDown      = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_Down
  #SHORTCUT_DeleteLines        = 0
  #SHORTCUT_DuplicateSelection = #PB_Shortcut_Command | #PB_Shortcut_D
  #SHORTCUT_ZoomIn             = 0
  #SHORTCUT_ZoomOut            = 0
  #SHORTCUT_ZoomDefault        = #PB_Shortcut_Command | #PB_Shortcut_0
  #SHORTCUT_ProcedureListUpdate= #PB_Shortcut_F12
  #SHORTCUT_VariableViewer     = #PB_Shortcut_Command | #PB_Shortcut_Alt | #PB_Shortcut_V
  #SHORTCUT_ColorPicker        = #PB_Shortcut_Command | #PB_Shortcut_Alt | #PB_Shortcut_M
  #SHORTCUT_AsciiTable         = #PB_Shortcut_Command | #PB_Shortcut_Alt | #PB_Shortcut_A
  #SHORTCUT_Explorer           = #PB_Shortcut_Command | #PB_Shortcut_Alt | #PB_Shortcut_X
  #SHORTCUT_ToggleFolds        = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_T
  #SHORTCUT_ToggleThisFold     = #PB_Shortcut_Command | #PB_Shortcut_T
  #SHORTCUT_Stop               = #PB_Shortcut_F6
  #SHORTCUT_Continue           = #PB_Shortcut_F7
  #SHORTCUT_Step               = #PB_Shortcut_F8
  #SHORTCUT_StepX              = #PB_Shortcut_Command | #PB_Shortcut_F8
  #SHORTCUT_BreakPoint         = #PB_Shortcut_F9
  #SHORTCUT_StepOver           = #PB_Shortcut_F10
  #SHORTCUT_StepOut            = #PB_Shortcut_F11
  #SHORTCUT_AutoComplete       = #PB_Shortcut_Control | #PB_Shortcut_Space ; CMT+Space is reserved in 10.4
  #SHORTCUT_AutoCompleteConfirm= #PB_Shortcut_Tab                          ; to be tested
  #SHORTCUT_AutoCompleteAbort  = #PB_Shortcut_Escape
  #SHORTCUT_AutoIndent         = #PB_Shortcut_Command | #PB_Shortcut_I
  #SHORTCUT_UpperCase          = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_U
  #SHORTCUT_LowerCase          = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_L
  #SHORTCUT_InvertCase         = #PB_Shortcut_Command | #PB_Shortcut_Shift | #PB_Shortcut_X
  #SHORTCUT_SelectWord         = 0
CompilerEndIf


;- Datasection
DataSection
  
  ; This list specifies each menu item that can have a shortcut.
  ; first is the menu title, second the menuitem (all language ID's)
  ; If MenuTitle is empty, the string is searched in the "Shortcuts" group.
  ; Following is the default shortcut for this item.
  ; they must be in the order of menu ID's in the Enumeration (1st is 0)
  ;
  ; NOTE: On Mac, About, Exit and Preferences have fixed shortcuts. However, there
  ; is a dummy constant in their place in the menu constants, so even though this is loaded, it is ignored
  ;
  ShortcutItems:
  Data$ "File", "New":           Data.l #SHORTCUT_New
  Data$ "File", "Open":          Data.l #SHORTCUT_Open
  Data$ "File", "Save":          Data.l #SHORTCUT_Save
  Data$ "File", "SaveAs":        Data.l 0
  Data$ "File", "SaveAll":       Data.l 0
  Data$ "File", "Reload":        Data.l 0
  Data$ "File", "Close":         Data.l #SHORTCUT_Close
  Data$ "File", "CloseAll":      Data.l 0
  Data$ "File", "DiffCurrent":   Data.l 0
  Data$ "File", "EncodingPlain": Data.l 0
  Data$ "File", "EncodingUtf8":  Data.l 0
  Data$ "File", "NewlineWindows":Data.l 0
  Data$ "File", "NewlineLinux":  Data.l 0
  Data$ "File", "NewlineMacOS":  Data.l 0
  ;Data$ "File", "SortSources":   Data.l 0
  Data$ "File", "ShowInFolder":  Data.l 0
  Data$ "File", "Preferences":   Data.l 0
  Data$ "File", "EditHistory":   Data.l 0
  Data$ "File", "Quit":          Data.l 0
  
  Data$ "Edit", "Undo":           Data.l #SHORTCUT_Undo
  Data$ "Edit", "Redo":           Data.l #SHORTCUT_Redo
  Data$ "Edit", "Cut":            Data.l #SHORTCUT_Cut
  Data$ "Edit", "Copy":           Data.l #SHORTCUT_Copy
  Data$ "Edit", "Paste":          Data.l #SHORTCUT_Paste
  Data$ "Edit", "PasteComment":   Data.l #SHORTCUT_PasteAsComment
  Data$ "Edit", "InsertComment":  Data.l #SHORTCUT_CommentSelection
  Data$ "Edit", "RemoveComment":  Data.l #SHORTCUT_UnCommentSelection
  Data$ "Edit", "AutoIndent":     Data.l #SHORTCUT_AutoIndent
  Data$ "Edit", "SelectAll":      Data.l #SHORTCUT_SelectAll
  Data$ "Edit", "Goto":           Data.l #SHORTCUT_Goto
  Data$ "Edit", "JumpToKeyword":  Data.l #SHORTCUT_JumpToKeyword
  Data$ "Edit", "LastViewedLine": Data.l #SHORTCUT_LastViewedLine
  Data$ "Edit", "ToggleThisFold": Data.l #SHORTCUT_ToggleThisFold
  Data$ "Edit", "ToggleFolds":    Data.l #SHORTCUT_ToggleFolds
  Data$ "Edit", "AddMarker":      Data.l #SHORTCUT_AddMarker
  Data$ "Edit", "JumpToMarker":   Data.l #SHORTCUT_JumpToMarker
  Data$ "Edit", "ClearMarkers":   Data.l 0
  Data$ "Edit", "Find":           Data.l #SHORTCUT_Find
  Data$ "Edit", "FindNext":       Data.l #SHORTCUT_FindNext
  Data$ "Edit", "FindPrevious":   Data.l #SHORTCUT_FindPrevious
  Data$ "Edit", "FindInFiles":    Data.l #SHORTCUT_FindInFiles
  Data$ "Edit", "Replace":        Data.l #SHORTCUT_Replace
  
  Data$ "Project", "NewProject":         Data.l #SHORTCUT_NewProject
  Data$ "Project", "OpenProject":        Data.l #SHORTCUT_OpenProject
  Data$ "Project", "CloseProject":       Data.l #SHORTCUT_CloseProject
  Data$ "Project", "ProjectOptions":     Data.l 0
  Data$ "Project", "AddProjectFile":     Data.l #SHORTCUT_AddProjectFile
  Data$ "Project", "RemoveProjectFile":  Data.l #SHORTCUT_RemoveProjectFile
  Data$ "Project", "OpenProjectFolder":  Data.l 0
  
  Data$ "Form", "NewForm":          Data.l 0
  Data$ "Form", "FormSwitch":       Data.l 0
  Data$ "Form", "FormDuplicate":    Data.l 0
  Data$ "Form", "FormImageManager": Data.l 0
  
  Data$ "Compiler", "Compile":           Data.l #SHORTCUT_CompileRun
  Data$ "Compiler", "RunExe":            Data.l #SHORTCUT_Run
  Data$ "Compiler", "SyntaxCheck":       Data.l 0
  Data$ "Compiler", "DebuggerCompile":   Data.l 0
  Data$ "Compiler", "NoDebuggerCompile": Data.l 0
  Data$ "Compiler", "RestartCompiler":   Data.l 0
  Data$ "Compiler", "CompilerOptions":   Data.l 0
  Data$ "Compiler", "CreateEXE":         Data.l 0
  Data$ "Compiler", "BuildAllTargets":   Data.l 0
  
  Data$ "Debugger", "Debugger":        Data.l 0
  Data$ "Debugger", "Stop":            Data.l #SHORTCUT_Stop
  Data$ "Debugger", "Run":             Data.l #SHORTCUT_Continue
  Data$ "Debugger", "Step":            Data.l #SHORTCUT_Step
  Data$ "Debugger", "StepX":           Data.l #SHORTCUT_StepX
  Data$ "Debugger", "StepOver":        Data.l #SHORTCUT_StepOver
  Data$ "Debugger", "StepOut":         Data.l #SHORTCUT_StepOut
  Data$ "Debugger", "Kill":            Data.l 0
  Data$ "Debugger", "BreakPoint":      Data.l #SHORTCUT_BreakPoint
  Data$ "Debugger", "BreakClear":      Data.l 0
  Data$ "Debugger", "DataBreakPoints": Data.l 0
  Data$ "Debugger", "ShowLog":         Data.l 0
  Data$ "Debugger", "ClearLog":        Data.l 0
  Data$ "Debugger", "CopyLog"    :     Data.l 0
  Data$ "Debugger", "ClearErrorMarks": Data.l 0
  Data$ "Debugger", "DebugOutput":     Data.l 0
  Data$ "Debugger", "WatchList":       Data.l 0
  Data$ "Debugger", "VariableList":    Data.l 0
  Data$ "Debugger", "Profiler":        Data.l 0
  Data$ "Debugger", "History":         Data.l 0
  Data$ "Debugger", "Memory":          Data.l 0
  Data$ "Debugger", "LibraryViewer":   Data.l 0
  Data$ "Debugger", "DebugAsm":        Data.l 0
  Data$ "Debugger", "Purifier":        Data.l 0
  
  Data$ "Tools", "VisualDesigner":   Data.l #SHORTCUT_VisualDesigner
  Data$ "Tools", "StructureViewer":  Data.l #SHORTCUT_StructureViewer
  Data$ "Tools", "FileViewer":       Data.l 0
  Data$ "Tools", "VariableViewer":   Data.l #SHORTCUT_VariableViewer
  Data$ "Tools", "ColorPicker":      Data.l #SHORTCUT_ColorPicker
  Data$ "Tools", "AsciiTable":       Data.l #SHORTCUT_AsciiTable
  Data$ "Tools", "Explorer":         Data.l #SHORTCUT_Explorer
  Data$ "Tools", "ProcedureBrowser": Data.l 0
  Data$ "Tools", "Issues":           Data.l 0
  Data$ "Tools", "ProjectPanel":     Data.l 0
  Data$ "Tools", "Templates":        Data.l 0
  Data$ "Tools", "Diff":             Data.l 0
  Data$ "Tools", "WebView":          Data.l 0
  Data$ "Tools", "AddTools":         Data.l 0
  
  Data$ "Help", "Help":              Data.l #SHORTCUT_Help
  Data$ "Help", "UpdateCheck":       Data.l 0
  Data$ "Help", "About":             Data.l 0
  
  Data$ "", "NextOpenFile":        Data.l #SHORTCUT_NextOpenedFile
  Data$ "", "PreviousOpenFile":    Data.l #SHORTCUT_PreviousOpenedFile
  Data$ "", "ShiftCommentRight":   Data.l #SHORTCUT_ShiftCommentRight
  Data$ "", "ShiftCommentLeft":    Data.l #SHORTCUT_ShiftCommentLeft
  Data$ "", "SelectBlock":         Data.l #SHORTCUT_SelectBlock
  Data$ "", "DeselectBlock":       Data.l #SHORTCUT_DeselectBlock
  Data$ "", "MoveLinesUp":         Data.l #SHORTCUT_MoveLinesUp
  Data$ "", "MoveLinesDown":       Data.l #SHORTCUT_MoveLinesDown
  Data$ "", "DeleteLines":         Data.l #SHORTCUT_DeleteLines
  Data$ "", "DuplicateSelection":  Data.l #SHORTCUT_DuplicateSelection
  Data$ "", "UpperCase":           Data.l #SHORTCUT_UpperCase
  Data$ "", "LowerCase":           Data.l #SHORTCUT_LowerCase
  Data$ "", "InvertCase":          Data.l #SHORTCUT_InvertCase
  Data$ "", "SelectWord":          Data.l #SHORTCUT_SelectWord
  Data$ "", "ZoomIn":              Data.l #SHORTCUT_ZoomIn
  Data$ "", "ZoomOut":             Data.l #SHORTCUT_ZoomOut
  Data$ "", "ZoomDefault":         Data.l #SHORTCUT_ZoomDefault
  Data$ "", "AutoComplete":        Data.l #SHORTCUT_AutoComplete
  Data$ "", "AutoCompleteConfirm": Data.l #SHORTCUT_AutoCompleteConfirm
  Data$ "", "AutoCompleteAbort":   Data.l #SHORTCUT_AutoCompleteAbort
  Data$ "", "ProceduresUpdate":    Data.l #SHORTCUT_ProcedureListUpdate
  
  ; This is a list of shortcuts used by the OS or Windowmanager. Trying to use these
  ; will output an error
  ;
  ReservedShortcuts:
  Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_Delete ; i wonder what that one is for.. ;)
  
  CompilerIf #CompileWindows
    Data.l #PB_Shortcut_Alt | #PB_Shortcut_Tab
    Data.l #PB_Shortcut_Alt | #PB_Shortcut_F4
    
  CompilerElse
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F1
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F2
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F3
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F4
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F5
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F6
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_F7
    Data.l #PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_Back
    
  CompilerEndIf
  
  Data.l -1 ; indicates the end of the reserved list
  
  
  
  ; Note: Since the #PB_Shortcut_* Constants have different values for each OS,
  ; they need to be listed here, so they can be read into an array.
  ; The constants are sorted as they appear in the language list (and thus in the shortcut Combobox)
  ;
  ShortcutKeys:
  Data.l #PB_Shortcut_0
  Data.l #PB_Shortcut_1
  Data.l #PB_Shortcut_2
  Data.l #PB_Shortcut_3
  Data.l #PB_Shortcut_4
  Data.l #PB_Shortcut_5
  Data.l #PB_Shortcut_6
  Data.l #PB_Shortcut_7
  Data.l #PB_Shortcut_8
  Data.l #PB_Shortcut_9
  Data.l #PB_Shortcut_A
  Data.l #PB_Shortcut_B
  Data.l #PB_Shortcut_C
  Data.l #PB_Shortcut_D
  Data.l #PB_Shortcut_E
  Data.l #PB_Shortcut_F
  Data.l #PB_Shortcut_G
  Data.l #PB_Shortcut_H
  Data.l #PB_Shortcut_I
  Data.l #PB_Shortcut_J
  Data.l #PB_Shortcut_K
  Data.l #PB_Shortcut_L
  Data.l #PB_Shortcut_M
  Data.l #PB_Shortcut_N
  Data.l #PB_Shortcut_O
  Data.l #PB_Shortcut_P
  Data.l #PB_Shortcut_Q
  Data.l #PB_Shortcut_R
  Data.l #PB_Shortcut_S
  Data.l #PB_Shortcut_T
  Data.l #PB_Shortcut_U
  Data.l #PB_Shortcut_V
  Data.l #PB_Shortcut_W
  Data.l #PB_Shortcut_X
  Data.l #PB_Shortcut_Y
  Data.l #PB_Shortcut_Z
  Data.l #PB_Shortcut_F1
  Data.l #PB_Shortcut_F2
  Data.l #PB_Shortcut_F3
  Data.l #PB_Shortcut_F4
  Data.l #PB_Shortcut_F5
  Data.l #PB_Shortcut_F6
  Data.l #PB_Shortcut_F7
  Data.l #PB_Shortcut_F8
  Data.l #PB_Shortcut_F9
  Data.l #PB_Shortcut_F10
  Data.l #PB_Shortcut_F11
  Data.l #PB_Shortcut_F12
  Data.l #PB_Shortcut_F13
  Data.l #PB_Shortcut_F14
  Data.l #PB_Shortcut_F15
  Data.l #PB_Shortcut_F16
  Data.l #PB_Shortcut_F17
  Data.l #PB_Shortcut_F18
  Data.l #PB_Shortcut_F19
  Data.l #PB_Shortcut_F20
  Data.l #PB_Shortcut_F21
  Data.l #PB_Shortcut_F22
  Data.l #PB_Shortcut_F23
  Data.l #PB_Shortcut_F24
  Data.l #PB_Shortcut_Pad0
  Data.l #PB_Shortcut_Pad1
  Data.l #PB_Shortcut_Pad2
  Data.l #PB_Shortcut_Pad3
  Data.l #PB_Shortcut_Pad4
  Data.l #PB_Shortcut_Pad5
  Data.l #PB_Shortcut_Pad6
  Data.l #PB_Shortcut_Pad7
  Data.l #PB_Shortcut_Pad8
  Data.l #PB_Shortcut_Pad9
  Data.l #PB_Shortcut_Back ; key no 71. first key in the language section
  Data.l #PB_Shortcut_Tab
  Data.l #PB_Shortcut_Clear
  Data.l #PB_Shortcut_Return
  Data.l #PB_Shortcut_Menu
  Data.l #PB_Shortcut_Pause
  Data.l #PB_Shortcut_Print
  Data.l #PB_Shortcut_Capital
  Data.l #PB_Shortcut_Escape
  Data.l #PB_Shortcut_Space
  Data.l #PB_Shortcut_PageUp
  Data.l #PB_Shortcut_PageDown
  Data.l #PB_Shortcut_End
  Data.l #PB_Shortcut_Home
  Data.l #PB_Shortcut_Left
  Data.l #PB_Shortcut_Up
  Data.l #PB_Shortcut_Right
  Data.l #PB_Shortcut_Down
  Data.l #PB_Shortcut_Select
  Data.l #PB_Shortcut_Execute
  Data.l #PB_Shortcut_Snapshot
  Data.l #PB_Shortcut_Insert
  Data.l #PB_Shortcut_Delete
  Data.l #PB_Shortcut_Help
  Data.l #PB_Shortcut_LeftWindows
  Data.l #PB_Shortcut_RightWindows
  Data.l #PB_Shortcut_Apps
  Data.l #PB_Shortcut_Multiply
  Data.l #PB_Shortcut_Add
  Data.l #PB_Shortcut_Separator
  Data.l #PB_Shortcut_Subtract
  Data.l #PB_Shortcut_Decimal
  Data.l #PB_Shortcut_Divide ; Key103
  Data.l #PB_Shortcut_Numlock
  Data.l #PB_Shortcut_Scroll ; Key105
  CompilerIf #CompileWindows
    Data.l #VK_OEM_PLUS
    Data.l #VK_OEM_MINUS ; Key107
  CompilerElse
    Data.l '='
    Data.l '-' ; Key107
  CompilerEndIf
  
EndDataSection
