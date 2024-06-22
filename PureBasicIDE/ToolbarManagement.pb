; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

CompilerIf #SpiderBasic
  #NB_ToolbarMenuItems = 99-22 ; menu items specified in the datasection
CompilerElse
  #NB_ToolbarMenuItems = 99 ; menu items specified in the datasection
CompilerEndIf
;#NB_InternalIcons = 45

Global Dim ToolbarMenuID.l(#NB_ToolbarMenuItems)
Global Dim ToolbarMenuName$(#NB_ToolbarMenuItems)
Global Dim ToolbarMenuIcon(#NB_ToolbarMenuItems)

Procedure InitToolbar()
  
  ; read the possible menu items
  ;
  Restore ToolbarMenuItems
  For i = 1 To #NB_ToolbarMenuItems
    Read.l ToolbarMenuID(i)
    Read.s ToolbarMenuName$(i)
  Next i
  
  ; For the "Space" option, we have an empty png file
  ; (also for missing icons)
  ;
  CatchImage(#IMAGE_ToolBar_Space,   ?Image_ToolbarSpace)
  CatchImage(#IMAGE_ToolBar_Missing, ?Image_ToolbarMissing)
  
  ; read the default toolbar set
  ;
  Restore ToolbarPureBasic
  
  Read.l ToolbarItemCount
  For i = 1 To ToolbarItemCount
    Read.s Toolbar(i)\Name$
    Read.s Toolbar(i)\Action$
  Next i
  
EndProcedure

Procedure ToolbarMenuImage(MenuItem)
  Image = 0
  
  For i = 1 To #NB_ToolbarMenuItems
    If MenuItem = ToolbarMenuID(i) And ToolbarMenuIcon(i)
      Image = ImageID(ToolbarMenuIcon(i))
      Break
    EndIf
  Next i
  
  ProcedureReturn Image
EndProcedure


Procedure CreateIDEToolBar()
  
  CompilerIf #CompileMac
    flags = #PB_ToolBar_Large
  CompilerElse
    flags = 0
  CompilerEndIf
  
  *MainToolbar = CreateToolBar(#TOOLBAR, WindowID(#WINDOW_Main), flags)
  If *MainToolbar
    
    NbSpaceButtons = 0
    
    For i = 1 To ToolbarItemCount
      
      If Toolbar(i)\Name$ = "Separator"
        ToolBarSeparator()
        
      ElseIf Toolbar(i)\Name$ = "Space"
        NbSpaceButtons + 1
        ToolBarImageButton(#MENU_FirstUnused+NbSpaceButtons, ImageID(#IMAGE_Toolbar_Space))
        DisableToolBarButton(#TOOLBAR, #MENU_FirstUnused+NbSpaceButtons, 1)
        
      Else
        
        MenuID = -1
        Flag = 0
        ToolTip$ = ""
        
        If Left(Toolbar(i)\Action$, 4) = "Menu"
          For a = 1 To #NB_ToolbarMenuItems
            If Toolbar(i)\Action$ = ToolbarMenuName$(a)
              MenuID = ToolbarMenuID(a)
              ToolTip$ = Language("MenuItem", Right(ToolbarMenuName$(a), Len(ToolbarMenuName$(a))-5))
              Break
            EndIf
          Next a
          
        ElseIf Left(Toolbar(i)\Action$, 4) = "Tool"
          ForEach ToolsList()
            If Toolbar(i)\Action$ = "Tool:" + ToolsList()\MenuItemName$
              MenuID = #MENU_AddTools_Start+ListIndex(ToolsList())
              ToolTip$ = Right(Toolbar(i)\Action$, Len(Toolbar(i)\Action$)-5)
            EndIf
          Next ToolsList()
        EndIf
        
        If Toolbar(i)\Action$ = "Menu:VisualDesigner" And VisualDesigner$ = ""
          MenuID = -1
        ElseIf Toolbar(i)\Action$ = "Menu:Debugger"
          Flag = 1 ;#PB_Toolbar_Toggle
        EndIf
        
        If MenuID <> -1
          
          If Left(Toolbar(i)\Name$, 8) = "External"
            Toolbar(i)\Image = LoadImage(#PB_Any, Right(Toolbar(i)\Name$, Len(Toolbar(i)\Name$)-9))
            If Toolbar(i)\Image
              ToolBarImageButton(MenuID, ImageID(Toolbar(i)\Image), Flag)
              Found = 1
            Else
              MessageRequester(#ProductName$,Language("Misc","ToolbarError")+":"+#NewLine+Right(Toolbar(i)\Name$, Len(Toolbar(i)\Name$)-9), #FLAG_Error)
              Found = 0
            EndIf
            
          Else
            
            ; check for menu icon
            ;
            Found = 0
            For a = 1 To #NB_ToolbarMenuItems
              If Toolbar(i)\Name$ = ToolbarMenuName$(a) And ToolbarMenuIcon(a)
                ToolBarImageButton(MenuID, ImageID(ToolbarMenuIcon(a)), Flag)
                Found = 1
                Break
              EndIf
            Next a
            
            If Found = 0
              ToolBarImageButton(MenuID, ImageID(#IMAGE_ToolBar_Missing), Flag)
            EndIf
            
          EndIf
          
          If Found
            ToolBarToolTip(#TOOLBAR, MenuID, RemoveString(ToolTip$, "&"))
          EndIf
          
        EndIf
        
      EndIf
      
    Next i
    
    If *ActiveSource
      SetToolBarButtonState(#TOOLBAR, #MENU_Debugger, *ActiveSource\Debugger)
    EndIf
    
    If CompilerReady = 0
      DisableToolBarButton (#TOOLBAR, #MENU_CompileRun, 1)
      DisableToolBarButton (#TOOLBAR, #MENU_SyntaxCheck, 1)
    EndIf
    
    UpdateToolbarView()
  EndIf
  
  ProcedureReturn *MainToolbar
EndProcedure

Procedure FreeIDEToolbar()
  
  If IsToolBar(#TOOLBAR)
    FreeToolBar(#TOOLBAR)
    
    For i = 1 To ToolbarItemCount
      If IsImage(Toolbar(i)\Image)
        FreeImage(Toolbar(i)\Image)
      EndIf
      Toolbar(i)\Image = 0
    Next i
  EndIf
  
EndProcedure

; Convert the pre-4.40 naming scheme for the menu icons
; to the new Theme compatible names
;
Procedure.s ConvertToolbarIconName(OldName$)
  
  If Left(OldName$, 9) = "Internal:"
    Select Right(OldName$, Len(OldName$)-9)
      Case "CompileAndRun"        : ProcedureReturn "Menu:Compile"
      Case "CompilerOptions"      : ProcedureReturn "Menu:CompilerOptions"
      Case "CompileToExe"         : ProcedureReturn "Menu:CreateEXE"
      Case "DebugBreakPoint"      : ProcedureReturn "Menu:BreakPoint"
      Case "DebugContinue"        : ProcedureReturn "Menu:Run"
      Case "DebugKill"            : ProcedureReturn "Menu:Kill"
      Case "DebugMemoryViewer"    : ProcedureReturn "Menu:Memory"
      Case "DebugOnOff"           : ProcedureReturn "Menu:Debugger"
      Case "DebugOutput"          : ProcedureReturn "Menu:DebugOutput"
      Case "DebugStep"            : ProcedureReturn "Menu:Step"
      Case "DebugStepNumber"      : ProcedureReturn "Menu:StepX"
      Case "DebugStepOut"         : ProcedureReturn "Menu:StepOut"
      Case "DebugStepOver"        : ProcedureReturn "Menu:StepOver"
      Case "DebugStop"            : ProcedureReturn "Menu:Stop"
      Case "DebugVariables"       : ProcedureReturn "Menu:VariableList"
      Case "DebugWatchList"       : ProcedureReturn "Menu:WatchList"
      Case "DisplayHelp"          : ProcedureReturn "Menu:Help"
      Case "EditAddBookmark"      : ProcedureReturn "Menu:AddMarker"
      Case "EditCopy"             : ProcedureReturn "Menu:Copy"
      Case "EditCut"              : ProcedureReturn "Menu:Cut"
      Case "EditFind"             : ProcedureReturn "Menu:FindNext"
      Case "EditFindAndReplace"   : ProcedureReturn "Menu:Find"
      Case "EditFindInFiles"      : ProcedureReturn "Menu:FindInFiles"
      Case "EditGoToBookmark"     : ProcedureReturn "Menu:JumpToMarker"
      Case "EditGoToLineNumber"   : ProcedureReturn "Menu:Goto"
      Case "EditInsertComment"    : ProcedureReturn "Menu:InsertComment"
      Case "EditPaste"            : ProcedureReturn "Menu:Paste"
      Case "EditRedo"             : ProcedureReturn "Menu:Redo"
      Case "EditRemoveComment"    : ProcedureReturn "Menu:RemoveComment"
      Case "EditUndo"             : ProcedureReturn "Menu:Undo"
      Case "FileClose"            : ProcedureReturn "Menu:Close"
      Case "FileNew"              : ProcedureReturn "Menu:New"
      Case "FileOpen"             : ProcedureReturn "Menu:Open"
      Case "FilePreferences"      : ProcedureReturn "Menu:Preferences"
      Case "FileSave"             : ProcedureReturn "Menu:Save"
      Case "FileSortSources"      : ProcedureReturn "Menu:SortSources"
      Case "StartVisualDesigner"  : ProcedureReturn "Menu:VisualDesigner"
      Case "ToolsAsciiTable"      : ProcedureReturn "Menu:AsciiTable"
      Case "ToolsColorPicker"     : ProcedureReturn "Menu:ColorPicker"
      Case "ToolsExplorer"        : ProcedureReturn "Menu:Explorer"
      Case "ToolsFileViewer"      : ProcedureReturn "Menu:FileViewer"
      Case "ToolsProcedureBrowser": ProcedureReturn "Menu:ProcedureBrowser"
      Case "ToolsStructureViewer" : ProcedureReturn "Menu:StructureViewer"
      Case "ToolsVariableViewer"  : ProcedureReturn "Menu:VariableViewer"
      Case "ToolsWebView"         : ProcedureReturn "Menu:WebView"
        
      Default
        ProcedureReturn OldName$
    EndSelect
  Else
    ProcedureReturn OldName$
  EndIf
EndProcedure

Procedure UpdatePrefsToolbarList()
  
  For i = 1 To PreferenceToolbarCount
    
    Select StringField(PreferenceToolbar(i)\Name$, 1, ":")
      Case "Separator"
        Text$ = Language("Preferences","Separator")
        
      Case "Space"
        Text$ = Language("Preferences","Space")
        
      Case "Menu"
        Text$ = Language("Preferences","ThemeIcon") + ": " + StringField(PreferenceToolbar(i)\Name$, 2, ":")
        
      Case "External"
        Text$ = Language("Preferences","ExternalIcon") + ": " + StringField(PreferenceToolbar(i)\Name$, 2, ":")
        
      Default: Text$ = ""
    EndSelect
    
    SetGadgetItemText(#GADGET_Preferences_ToolbarList, i-1, Text$, 0)
    
    If Left(PreferenceToolbar(i)\Action$, 4) = "Menu"
      Text$ = Language("Preferences","ActionMenu") + ": " +  RemoveString(Language("MenuItem", Right(PreferenceToolbar(i)\Action$, Len(PreferenceToolbar(i)\Action$)-5)), "&")
      
    ElseIf Left(PreferenceToolbar(i)\Action$, 4) = "Tool"
      Text$ = Language("Preferences","ActionTool") + ": " + Right(PreferenceToolbar(i)\Action$, Len(PreferenceToolbar(i)\Action$)-5)
      
    Else
      Text$ = ""
    EndIf
    
    SetGadgetItemText(#GADGET_Preferences_ToolbarList, i-1, Text$, 1)
    
  Next i
  
EndProcedure

Procedure UpdatePrefsToolbarItem(FirstCall=#False)
  Static SelectedItem
  
  ; StartFlickerFix(#WINDOW_Preferences) ; - Don't use it as it makes the whole window flicker on XP (quite interesting huh ?)
  
  ; check if the selection in the main list has changed
  ; or if it is the first call after preferences opened
  ;
  If GetGadgetState(#GADGET_Preferences_ToolbarList) <> SelectedItem Or FirstCall
    SelectedItem = GetGadgetState(#GADGET_Preferences_ToolbarList)
    
    If SelectedItem = -1
      SetGadgetState(#GADGET_Preferences_ToolbarIconType, #TOOLBARICONTYPE_Separator)
    Else
      DisableGadget(#GADGET_Preferences_ToolbarIconType, 0)
      
      Select StringField(PreferenceToolbar(SelectedItem+1)\Name$, 1, ":")
        Case "Separator"
          SetGadgetState(#GADGET_Preferences_ToolbarIconType, #TOOLBARICONTYPE_Separator)
          ToolbarPreferenceMode = 0
          
        Case "Space"
          SetGadgetState(#GADGET_Preferences_ToolbarIconType, #TOOLBARICONTYPE_Space)
          ToolbarPreferenceMode = 0
          
        Case "Menu"
          SetGadgetState(#GADGET_Preferences_ToolbarIconType, #TOOLBARICONTYPE_Internal)
          
          ClearGadgetItems(#GADGET_Preferences_ToolbarIconList)
          index = 0
          For i = 1 To #NB_ToolbarMenuItems
            AddGadgetItem(#GADGET_Preferences_ToolbarIconList, -1, StringField(ToolbarMenuName$(i), 2, ":"))
            If PreferenceToolbar(SelectedItem+1)\Name$ = ToolbarMenuName$(i)
              index = i-1
            EndIf
          Next i
          SetGadgetState(#GADGET_Preferences_ToolbarIconList, index)
          
          ToolbarPreferenceMode = 2
          
        Case "External"
          SetGadgetState(#GADGET_Preferences_ToolbarIconType, #TOOLBARICONTYPE_External)
          SetGadgetText(#GADGET_Preferences_ToolbarIconName, Right(PreferenceToolbar(SelectedItem+1)\Name$, Len(PreferenceToolbar(SelectedItem+1)\Name$)-9))
          ToolbarPreferenceMode = 3
          
      EndSelect
      
      Select Left(PreferenceToolbar(SelectedItem+1)\Action$, 4)
        Case "Menu"
          ClearGadgetItems(#GADGET_Preferences_ToolbarActionList)
          index = 0
          For i = 1 To #NB_ToolbarMenuItems
            AddGadgetItem(#GADGET_Preferences_ToolbarActionList, -1, RemoveString(Language("MenuItem", Right(ToolbarMenuName$(i), Len(ToolbarMenuName$(i))-5)), "&"))
            If PreferenceToolbar(SelectedItem+1)\Action$ = ToolbarMenuName$(i)
              index = i-1
            EndIf
          Next i
          
          SetGadgetState(#GADGET_Preferences_ToolbarActionList, index)
          SetGadgetState(#GADGET_Preferences_ToolbarActionType, 0)
          ToolbarPreferenceAction = 1
          
        Case "Tool"
          ClearGadgetItems(#GADGET_Preferences_ToolbarActionList)
          index = 0
          ForEach ToolsList()
            AddGadgetItem(#GADGET_Preferences_ToolbarActionList, -1, ToolsList()\MenuItemName$)
            If PreferenceToolbar(SelectedItem+1)\Action$ = "Tool:"+ToolsList()\MenuItemName$
              index = i
            EndIf
            i + 1
          Next ToolsList()
          
          SetGadgetState(#GADGET_Preferences_ToolbarActionList, index)
          SetGadgetState(#GADGET_Preferences_ToolbarActionType, 1)
          
          ToolbarPreferenceAction = 2
          
      EndSelect
      
    EndIf
    
  EndIf
  
  ; enable/disable the settings gadgets according to the settings
  ;
  Select GetGadgetState(#GADGET_Preferences_ToolbarIconType)
      
    Case #TOOLBARICONTYPE_Separator
      HideGadget(#GADGET_Preferences_ToolbarIconList, 0)
      HideGadget(#GADGET_Preferences_ToolbarIconName, 1)
      HideGadget(#GADGET_Preferences_ToolbarOpenIcon, 1)
      
      DisableGadget(#GADGET_Preferences_ToolbarIconList, 1)
      DisableGadget(#GADGET_Preferences_ToolbarActionType, 1)
      DisableGadget(#GADGET_Preferences_ToolbarActionList, 1)
      
      ToolbarPreferenceMode = 0
      
    Case #TOOLBARICONTYPE_Space
      HideGadget(#GADGET_Preferences_ToolbarIconList, 0)
      HideGadget(#GADGET_Preferences_ToolbarIconName, 1)
      HideGadget(#GADGET_Preferences_ToolbarOpenIcon, 1)
      
      DisableGadget(#GADGET_Preferences_ToolbarIconList, 1)
      DisableGadget(#GADGET_Preferences_ToolbarActionType, 1)
      DisableGadget(#GADGET_Preferences_ToolbarActionList, 1)
      
      ToolbarPreferenceMode = 0
      
    Case #TOOLBARICONTYPE_Internal
      If ToolbarPreferenceMode <> 2
        ClearGadgetItems(#GADGET_Preferences_ToolbarIconList)
        For i = 1 To #NB_ToolbarMenuItems
          AddGadgetItem(#GADGET_Preferences_ToolbarIconList, -1, StringField(ToolbarMenuName$(i), 2, ":"))
        Next i
        SetGadgetState(#GADGET_Preferences_ToolbarIconList, 0)
        
        ToolbarPreferenceMode = 2
      EndIf
      
      HideGadget(#GADGET_Preferences_ToolbarIconList, 0)
      HideGadget(#GADGET_Preferences_ToolbarIconName, 1)
      HideGadget(#GADGET_Preferences_ToolbarOpenIcon, 1)
      
      DisableGadget(#GADGET_Preferences_ToolbarIconList, 0)
      DisableGadget(#GADGET_Preferences_ToolbarActionType, 0)
      DisableGadget(#GADGET_Preferences_ToolbarActionList, 0)
      
    Case #TOOLBARICONTYPE_External
      HideGadget(#GADGET_Preferences_ToolbarIconList, 1)
      HideGadget(#GADGET_Preferences_ToolbarIconName, 0)
      HideGadget(#GADGET_Preferences_ToolbarOpenIcon, 0)
      
      DisableGadget(#GADGET_Preferences_ToolbarIconName, 0)
      DisableGadget(#GADGET_Preferences_ToolbarOpenIcon, 0)
      DisableGadget(#GADGET_Preferences_ToolbarActionType, 0)
      DisableGadget(#GADGET_Preferences_ToolbarActionList, 0)
      
      ToolbarPreferenceMode = 3
  EndSelect
  
  Select GetGadgetState(#GADGET_Preferences_ToolbarActionType)
    Case 0 ; menu
      If ToolbarPreferenceAction <> 1
        ClearGadgetItems(#GADGET_Preferences_ToolbarActionList)
        For i = 1 To #NB_ToolbarMenuItems
          AddGadgetItem(#GADGET_Preferences_ToolbarActionList, -1, RemoveString(Language("MenuItem", Right(ToolbarMenuName$(i), Len(ToolbarMenuName$(i))-5)), "&"))
        Next i
        
        SetGadgetState(#GADGET_Preferences_ToolbarActionList, 0)
        ToolbarPreferenceAction = 1
      EndIf
      
    Case 1 ; tool
      If ToolbarPreferenceAction <> 2
        ClearGadgetItems(#GADGET_Preferences_ToolbarActionList)
        ForEach ToolsList()
          AddGadgetItem(#GADGET_Preferences_ToolbarActionList, -1, ToolsList()\MenuItemName$)
        Next ToolsList()
        SetGadgetState(#GADGET_Preferences_ToolbarActionList, 0)
        
        ToolbarPreferenceAction = 2
      EndIf
      
  EndSelect
  
EndProcedure


DataSection
  
  Image_ToolbarSpace:
    IncludeBinary "data/EmptySpace.png"
  
  Image_ToolbarMissing:
    IncludeBinary "data/MissingIcon.png"
  
  ; this list specifies all menu items that can have a toolbar button and the name
  ; for them in the Preferences. The preference name also references the
  ; images in the Theme.prefs (if they are present)
  ;
  ; Do not forget to update the count on top of this file when adding things!
  ;
  ;- ToolbarMenuItems
  ToolbarMenuItems:
  Data.l #MENU_New:                 Data$ "Menu:New"
  Data.l #MENU_Open:                Data$ "Menu:Open"
  Data.l #MENU_Save:                Data$ "Menu:Save"
  Data.l #MENU_SaveAs:              Data$ "Menu:SaveAs"
  Data.l #MENU_SaveAll:             Data$ "Menu:SaveAll"
  Data.l #MENU_Reload:              Data$ "Menu:Reload"
  Data.l #MENU_Close:               Data$ "Menu:Close"
  Data.l #MENU_CloseAll:            Data$ "Menu:CloseAll"
  Data.l #MENU_DiffCurrent:         Data$ "Menu:DiffCurrent"
  Data.l #MENU_EncodingPlain:       Data$ "Menu:EncodingPlain"
  Data.l #MENU_EncodingUtf8:        Data$ "Menu:EncodingUtf8"
  Data.l #MENU_NewlineWindows:      Data$ "Menu:NewlineWindows"
  Data.l #MENU_NewlineLinux:        Data$ "Menu:NewlineLinux"
  Data.l #MENU_NewlineMacOS:        Data$ "Menu:NewlineMacOS"
  ;Data.l #MENU_SortSources:         Data$ "Menu:SortSources"
  Data.l #MENU_Preference:          Data$ "Menu:Preferences"
  Data.l #MENU_History:             Data$ "Menu:EditHistory"
  Data.l #MENU_Exit:                Data$ "Menu:Quit"
  
  Data.l #MENU_Undo:                Data$ "Menu:Undo"
  Data.l #MENU_Redo:                Data$ "Menu:Redo"
  Data.l #MENU_Cut:                 Data$ "Menu:Cut"
  Data.l #MENU_Copy:                Data$ "Menu:Copy"
  Data.l #MENU_Paste:               Data$ "Menu:Paste"
  Data.l #MENU_CommentSelection:    Data$ "Menu:InsertComment"
  Data.l #MENU_UnCommentSelection:  Data$ "Menu:RemoveComment"
  Data.l #MENU_AutoIndent:          Data$ "Menu:AutoIndent"
  Data.l #MENU_SelectAll:           Data$ "Menu:SelectAll"
  Data.l #MENU_Goto:                Data$ "Menu:Goto"
  Data.l #MENU_JumpToKeyword:       Data$ "Menu:JumpToKeyword"
  Data.l #MENU_LastViewedLine:      Data$ "Menu:LastViewedLine"
  Data.l #MENU_ToggleThisFold:      Data$ "Menu:ToggleThisFold"
  Data.l #MENU_ToggleFolds:         Data$ "Menu:ToggleFolds"
  Data.l #MENU_AddMarker:           Data$ "Menu:AddMarker"
  Data.l #MENU_JumpToMarker:        Data$ "Menu:JumpToMarker"
  Data.l #MENU_ClearMarkers:        Data$ "Menu:ClearMarkers"
  Data.l #MENU_Find:                Data$ "Menu:Find"
  Data.l #MENU_FindNext:            Data$ "Menu:FindNext"
  Data.l #MENU_FindPrevious:        Data$ "Menu:FindPrevious"
  Data.l #MENU_FindInFiles:         Data$ "Menu:FindInFiles"
  Data.l #MENU_Replace:             Data$ "Menu:Replace"
  
  Data.l #MENU_NewProject:          Data$ "Menu:NewProject"
  Data.l #MENU_OpenProject:         Data$ "Menu:OpenProject"
  Data.l #MENU_CloseProject:        Data$ "Menu:CloseProject"
  Data.l #MENU_ProjectOptions:      Data$ "Menu:ProjectOptions"
  Data.l #MENU_AddProjectFile:      Data$ "Menu:AddProjectFile"
  Data.l #MENU_RemoveProjectFile:   Data$ "Menu:RemoveProjectFile"
  ;     Data.l #MENU_BackupManager:       Data$ "Menu:BackupManager"
  ;     Data.l #MENU_MakeBackup:          Data$ "Menu:MakeBackup"
  ;     Data.l #MENU_TodoList:            Data$ "Menu:TodoList"
  Data.l #MENU_OpenProjectFolder:   Data$ "Menu:OpenProjectFolder"
  
  Data.l #MENU_NewForm:             Data$ "Menu:NewForm"
  Data.l #MENU_FormSwitch:          Data$ "Menu:FormSwitch"
  Data.l #MENU_Duplicate:           Data$ "Menu:FormDuplicate"
  Data.l #MENU_FormImageManager:    Data$ "Menu:FormImageManager"
  
  Data.l #MENU_CompileRun:          Data$ "Menu:Compile"
  Data.l #MENU_RunExe:              Data$ "Menu:RunExe"
  Data.l #MENU_SyntaxCheck:         Data$ "Menu:SyntaxCheck"
  Data.l #MENU_DebuggerCompile:     Data$ "Menu:DebuggerCompile"
  Data.l #MENU_NoDebuggerCompile:   Data$ "Menu:NoDebuggerCompile"
  Data.l #MENU_RestartCompiler:     Data$ "Menu:RestartCompiler"
  Data.l #MENU_CompilerOption:      Data$ "Menu:CompilerOptions"
  CompilerIf Not #SpiderBasic
    Data.l #MENU_CreateExecutable:    Data$ "Menu:CreateEXE"
  CompilerEndIf
  Data.l #MENU_BuildAllTargets:     Data$ "Menu:BuildAllTargets"
  
  Data.l #MENU_Debugger:            Data$ "Menu:Debugger"
  Data.l #MENU_Kill:                Data$ "Menu:Kill"
  CompilerIf Not #SpiderBasic
    Data.l #MENU_Stop:                Data$ "Menu:Stop"
    Data.l #MENU_Run:                 Data$ "Menu:Run"
    Data.l #MENU_Step:                Data$ "Menu:Step"
    Data.l #MENU_StepX:               Data$ "Menu:StepX"
    Data.l #MENU_StepOver:            Data$ "Menu:StepOver"
    Data.l #MENU_StepOut:             Data$ "Menu:StepOut"
    Data.l #MENU_BreakPoint:          Data$ "Menu:BreakPoint"
    Data.l #MENU_BreakClear:          Data$ "Menu:BreakClear"
    Data.l #MENU_DataBreakPoints:     Data$ "Menu:DataBreakPoints"
    Data.l #MENU_ShowLog:             Data$ "Menu:ShowLog"
    Data.l #MENU_ClearLog:            Data$ "Menu:ClearLog"
    Data.l #MENU_CopyLog:             Data$ "Menu:CopyLog"
    Data.l #MENU_ClearErrorMarks:     Data$ "Menu:ClearErrorMarks"
    Data.l #MENU_DebugOutput:         Data$ "Menu:DebugOutput"
    Data.l #MENU_Watchlist:           Data$ "Menu:WatchList"
    Data.l #MENU_VariableList:        Data$ "Menu:VariableList"
    Data.l #MENU_Profiler:            Data$ "Menu:Profiler"
    Data.l #MENU_History:             Data$ "Menu:History"
    Data.l #MENU_Memory:              Data$ "Menu:Memory"
    Data.l #MENU_LibraryViewer:       Data$ "Menu:LibraryViewer"
    Data.l #MENU_DebugAsm:            Data$ "Menu:DebugAsm"
    Data.l #MENU_Purifier:            Data$ "Menu:Purifier"
  CompilerEndIf
  
  Data.l #MENU_VisualDesigner:      Data$ "Menu:VisualDesigner"
  Data.l #MENU_StructureViewer:     Data$ "Menu:StructureViewer"
  Data.l #MENU_FileViewer:          Data$ "Menu:FileViewer"
  Data.l #MENU_VariableViewer:      Data$ "Menu:VariableViewer"
  Data.l #MENU_ColorPicker:         Data$ "Menu:ColorPicker"
  Data.l #MENU_AsciiTable:          Data$ "Menu:AsciiTable"
  Data.l #MENU_Explorer:            Data$ "Menu:Explorer"
  Data.l #MENU_ProcedureBrowser:    Data$ "Menu:ProcedureBrowser"
  Data.l #MENU_Issues:              Data$ "Menu:Issues"
  Data.l #MENU_ProjectPanel:        Data$ "Menu:ProjectPanel"
  Data.l #MENU_Templates:           Data$ "Menu:Templates"
  Data.l #MENU_Diff:                Data$ "Menu:Diff"
  CompilerIf #SpiderBasic
    Data.l #MENU_WebView:             Data$ "Menu:WebView"
  CompilerEndIf
  Data.l #MENU_AddTools:            Data$ "Menu:AddTools"
  
  Data.l #MENU_Help:                Data$ "Menu:Help"
  Data.l #MENU_UpdateCheck:         Data$ "Menu:UpdateCheck"
  Data.l #MENU_About:               Data$ "Menu:About"
  
  ; this specifies the layout of the 'classic' toolbar
  ;
  ;- ToolBarClassic
  ToolBarClassic:
  Data.l 11  ; item count
  Data$ "Menu:New",            "Menu:New"
  Data$ "Menu:Open",           "Menu:Open"
  Data$ "Menu:Save",           "Menu:Save"
  Data$ "Separator",           ""
  Data$ "Menu:Close",          "Menu:Close"
  Data$ "Separator",           ""
  Data$ "Menu:Cut",            "Menu:Cut"
  Data$ "Menu:Copy",           "Menu:Copy"
  Data$ "Menu:Paste",          "Menu:Paste"
  Data$ "Separator",           ""
  Data$ "Menu:Compile",        "Menu:Compile"
  
  
  ; this specifies the new toolbar layout
  ;
  ;- ToolbarPureBasic
  ToolbarPureBasic:
  Data.l 23 ; item count
  Data$ "Menu:New",        "Menu:New"
  Data$ "Menu:Open",       "Menu:Open"
  Data$ "Menu:Save",       "Menu:Save"
  Data$ "Separator",       ""
  Data$ "Menu:Close",      "Menu:Close"
  Data$ "Separator",       ""
  Data$ "Menu:Cut",        "Menu:Cut"
  Data$ "Menu:Copy",       "Menu:Copy"
  Data$ "Menu:Paste",      "Menu:Paste"
  Data$ "Separator",       ""
  Data$ "Menu:Undo",       "Menu:Undo"
  Data$ "Menu:Redo",       "Menu:Redo"
  Data$ "Separator",       ""
  Data$ "Menu:Compile",    "Menu:Compile"
  Data$ "Menu:CompilerOptions","Menu:CompilerOptions"
  Data$ "Separator",       ""
  Data$ "Menu:Debugger",   "Menu:Debugger"
  
  Data$ "Menu:Stop",      "Menu:Stop"
  Data$ "Menu:Run",       "Menu:Run"
  Data$ "Menu:Step",      "Menu:Step"
  Data$ "Menu:StepOver",  "Menu:StepOver"
  Data$ "Menu:StepOut",   "Menu:StepOut"
  Data$ "Menu:Kill",      "Menu:Kill"
  
EndDataSection