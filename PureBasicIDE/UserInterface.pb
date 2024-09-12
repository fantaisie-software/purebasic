; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Global RunOnceMessageID ; setup in WindowsMisc.pb, handled in here, because messages are posted to the queue

#WINDOW_Main_Flags = #PB_Window_Invisible | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_SystemMenu

Procedure StartupCheckScreenReader()
  
  ; Only ask this on the first start so we do not annoy the user
  If ScreenReaderChecked = #False 
    
    If IsScreenReaderActive()
      If MessageRequester(#ProductName$, Language("Misc", "AskScreenReader"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
        
        ; Set the accessibility flag and disable related options
        EnableAccessibility = #True
        EnableMenuIcons = #False
        
        ; Switch to the "Accessibility" scheme
        Restore AccessibilityColorScheme
        Read.l ToolsPanelFrontColor
        Read.l ToolsPanelBackColor
        For i = 0 To #COLOR_Last
          Read.l Colors(i)\UserValue
        Next i
        
        ; Refresh the main menu
        CreateIDEMenu()
        CreateIDEPopupMenu()
        
        ; Refresh editor colors
        CalculateHighlightingColors()
        *Source = *ActiveSource
        ForEach FileList()
          If @FileList() <> *ProjectInfo
            *ActiveSource = @FileList()

            If EnableColoring
              SetUpHighlightingColors() ; needed for every gadget individually now (scintilla)
              SetBackgroundColor()
              SetLineNumberColor()
              UpdateHighlighting()   ; highlight everything after a prefs update
            Else
              RemoveAllColoring()
            EndIf
          EndIf
        Next FileList()
        ChangeCurrentElement(FileList(), *Source)
        *ActiveSource = *Source
        
        ; Destroy and recreate toolspanel for the color change
        ForEach UsedPanelTools()
          *ToolData.ToolsPanelEntry = UsedPanelTools()
          If *ToolData\NeedDestroyFunction
            PanelTool.ToolsPanelInterface = UsedPanelTools()
            PanelTool\DestroyFunction()
          EndIf
        Next UsedPanelTools()
        
        If IsGadget(#GADGET_ToolsPanel)
          ClearGadgetItems(#GADGET_ToolsPanel) ; no more freegadget
        EndIf
        
        ToolsPanel_Create(#True)
        ToolsPanel_ApplyColors(#GADGET_ErrorLog)
        
      EndIf
      
      ScreenReaderChecked = #True
      SavePreferences()
    EndIf
    
  EndIf
  
EndProcedure


Procedure CreateIDEMenu()
  
  ; note: there is no flicker fix directly in here. The code that calls CreateIDEMenu()
  ; is responsible for calling Start.../StopFlickerFix()
  ; this allows for more flexibility in whether or not to redraw the window after the fix
  
  If EnableMenuIcons
    *MainMenu = CreateImageMenu(#MENU, WindowID(#WINDOW_Main))
  Else
    *MainMenu = CreateMenu(#MENU, WindowID(#WINDOW_Main))
  EndIf
  
  If *MainMenu
    
    MenuTitle(Language("MenuTitle","File"))
    
    ShortcutMenuItem(#MENU_New   , Language("MenuItem","New"))
    ShortcutMenuItem(#MENU_Open  , Language("MenuItem","Open"))
    ShortcutMenuItem(#MENU_Save  , Language("MenuItem","Save"))
    ShortcutMenuItem(#MENU_SaveAs, Language("MenuItem","SaveAs"))
    ShortcutMenuItem(#MENU_SaveAll, Language("MenuItem","SaveAll"))
    ShortcutMenuItem(#MENU_Reload, Language("MenuItem","Reload"))
    ShortcutMenuItem(#MENU_Close , Language("MenuItem","Close"))
    ShortcutMenuItem(#MENU_CloseAll, Language("MenuItem","CloseAll"))
    ShortcutMenuItem(#MENU_DiffCurrent, Language("MenuItem","DiffCurrent"))
    MenuBar()
    ShortcutMenuItem(#MENU_ShowInFolder, Language("MenuItem","ShowInFolder"))
    MenuBar()
    OpenSubMenu(Language("MenuItem","FileFormat"))
    ShortcutMenuItem(#MENU_EncodingPlain,  Language("MenuItem", "EncodingPlain"))
    ShortcutMenuItem(#MENU_EncodingUtf8,   Language("MenuItem", "EncodingUtf8"))
    MenuBar()
    ShortcutMenuItem(#MENU_NewlineWindows, Language("MenuItem", "NewlineWindows"))
    ShortcutMenuItem(#MENU_NewlineLinux,   Language("MenuItem", "NewlineLinux"))
    ShortcutMenuItem(#MENU_NewlineMacOS,   Language("MenuItem", "NewlineMacOS"))
    CloseSubMenu()
    
    CompilerIf #CompileMac = #False
      MenuBar()
    CompilerEndIf
    
    ShortcutMenuItem(#MENU_Preference, Language("MenuItem","Preferences"))
    MenuBar()
    ShortcutMenuItem(#MENU_EditHistory, Language("MenuItem", "EditHistory"))
    OpenSubMenu(Language("MenuItem","RecentFiles"))
    RecentFiles_AddMenuEntries(#False)
    CloseSubMenu()
    
    CompilerIf #CompileMac = #False
      MenuBar()
    CompilerEndIf
    
    ShortcutMenuItem(#MENU_Exit, Language("MenuItem","Quit"))
    
    
    MenuTitle(Language("MenuTitle","Edit"))
    
    
    ShortcutMenuItem(#MENU_Undo, Language("MenuItem","Undo"))
    ShortcutMenuItem(#MENU_Redo, Language("MenuItem","Redo"))
    MenuBar()
    ShortcutMenuItem(#MENU_Cut  , Language("MenuItem","Cut"))
    ShortcutMenuItem(#MENU_Copy , Language("MenuItem","Copy"))
    ShortcutMenuItem(#MENU_Paste, Language("MenuItem","Paste"))
    ShortcutMenuItem(#MENU_PasteAsComment, Language("MenuItem","PasteComment"))
    MenuBar()
    ShortcutMenuItem(#MENU_CommentSelection,   Language("MenuItem","InsertComment"))
    ShortcutMenuItem(#MENU_UnCommentSelection, Language("MenuItem","RemoveComment"))
    ShortcutMenuItem(#MENU_AutoIndent, Language("MenuItem","AutoIndent"))
    MenuBar()
    ShortcutMenuItem(#MENU_SelectAll, Language("MenuItem","SelectAll"))
    MenuBar()
    ShortcutMenuItem(#MENU_Goto, Language("MenuItem","Goto"))
    ShortcutMenuItem(#MENU_JumpToKeyword, Language("MenuItem","JumpToKeyword"))
    ShortcutMenuItem(#MENU_LastViewedLine, Language("MenuItem","LastViewedLine"))
    
    If EnableFolding
      MenuBar()
      ShortcutMenuItem(#MENU_ToggleThisFold, Language("MenuItem","ToggleThisFold"))
      ShortcutMenuItem(#MENU_ToggleFolds, Language("MenuItem","ToggleFolds"))
    EndIf
    
    If EnableMarkers
      MenuBar()
      ShortcutMenuItem(#MENU_AddMarker,    Language("MenuItem","AddMarker"))
      ShortcutMenuItem(#MENU_JumpToMarker, Language("MenuItem","JumpToMarker"))
      ShortcutMenuItem(#MENU_ClearMarkers, Language("MenuItem","ClearMarkers"))
    EndIf
    
    MenuBar()
    ShortcutMenuItem(#MENU_Find, Language("MenuItem","Find"))
    ShortcutMenuItem(#MENU_FindNext, Language("MenuItem","FindNext"))
    ShortcutMenuItem(#MENU_FindPrevious, Language("MenuItem","FindPrevious"))
    ShortcutMenuItem(#MENU_FindInFiles, Language("MenuItem","FindInFiles"))
    ShortcutMenuItem(#MENU_Replace, Language("MenuItem","Replace"))
    
    MenuTitle(Language("MenuTitle","Project"))
    
    ShortcutMenuItem(#MENU_NewProject, Language("MenuItem","NewProject"))
    ShortcutMenuItem(#MENU_OpenProject, Language("MenuItem","OpenProject"))
    OpenSubMenu(Language("MenuItem","RecentProjects"))
    RecentFiles_AddMenuEntries(#True)
    CloseSubMenu()
    ShortcutMenuItem(#MENU_CloseProject, Language("MenuItem","CloseProject"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_ProjectOptions, Language("MenuItem","ProjectOptions"))
    ShortcutMenuItem(#MENU_AddProjectFile, Language("MenuItem","AddProjectFile"))
    ShortcutMenuItem(#MENU_RemoveProjectFile, Language("MenuItem","RemoveProjectFile"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_OpenProjectFolder, Language("MenuItem","OpenProjectFolder"))
    
    CompilerIf Not #SpiderBasic
      MenuTitle(Language("MenuTitle","Form"))
      
      ShortcutMenuItem(#MENU_NewForm, Language("MenuItem","NewForm"))
      
      MenuBar()
      ShortcutMenuItem(#MENU_FormSwitch, Language("MenuItem","FormSwitch"))
      
      MenuBar()
      ShortcutMenuItem(#MENU_Duplicate, Language("MenuItem","FormDuplicate"))
      ShortcutMenuItem(#MENU_FormImageManager, Language("MenuItem","FormImageManager"))
    CompilerEndIf
    
    MenuTitle(Language("MenuTitle","Compiler"))
    
    ShortcutMenuItem(#MENU_CompileRun      , Language("MenuItem","Compile"))
    CompilerIf Not #SpiderBasic
      ShortcutMenuItem(#MENU_RunExe          , Language("MenuItem","RunExe"))
    CompilerEndIf
    ShortcutMenuItem(#MENU_SyntaxCheck     , Language("MenuItem","SyntaxCheck"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_DebuggerCompile, Language("MenuItem","DebuggerCompile"))
    ShortcutMenuItem(#MENU_NoDebuggerCompile, Language("MenuItem","NoDebuggerCompile"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_RestartCompiler , Language("MenuItem","RestartCompiler"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_CompilerOption  , Language("MenuItem","CompilerOptions"))
    ShortcutMenuItem(#MENU_CreateExecutable, Language("MenuItem","CreateExe")) ; Will be "Create App" in SpiderBasic
    
    MenuBar()
    OpenSubMenu(Language("MenuItem","SetDefaultTarget"))
    AddProjectDefaultMenuEntries()
    CloseSubMenu()
    
    OpenSubMenu(Language("MenuItem","BuildTarget"))
    AddProjectBuildMenuEntries()
    CloseSubMenu()
    
    ShortcutMenuItem(#MENU_BuildAllTargets, Language("MenuItem","BuildAllTargets"))
    
    
    MenuTitle(Language("MenuTitle","Debugger"))
    
    *DebuggerMenuItem = ShortcutMenuItem(#MENU_Debugger   , Language("MenuItem","Debugger"))
    MenuBar()
    
    CompilerIf Not #SpiderBasic
      ShortcutMenuItem(#MENU_Stop, Language("MenuItem", "Stop"))
      ShortcutMenuItem(#MENU_Run, Language("MenuItem", "Run"))
    CompilerEndIf
      ShortcutMenuItem(#MENU_Kill, Language("MenuItem", "Kill"))
    CompilerIf Not #SpiderBasic
      MenuBar()
      ShortcutMenuItem(#MENU_Step, Language("MenuItem", "Step"))
      ShortcutMenuItem(#MENU_StepX, Language("MenuItem", "StepX"))
      ShortcutMenuItem(#MENU_StepOver, Language("MenuItem", "StepOver"))
      ShortcutMenuItem(#MENU_StepOut, Language("MenuItem", "StepOut"))
      MenuBar()
      ShortcutMenuItem(#MENU_BreakPoint, Language("MenuItem", "BreakPoint"))
      ShortcutMenuItem(#MENU_BreakClear, Language("MenuItem", "BreakClear"))
      ShortcutMenuItem(#MENU_DataBreakPoints, Language("MenuItem", "DataBreakPoints"))
      MenuBar()
    CompilerEndIf
    
    If AlwaysHideLog = 0
      OpenSubMenu(Language("MenuItem","ErrorLog"))
      *ErrorLogMenuItem = ShortcutMenuItem(#MENU_ShowLog, Language("MenuItem", "ShowLog"))
      If *ActiveSource
        If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
          SetMenuItemState(#MENU, #MENU_ShowLog, ProjectShowLog)
        Else
          SetMenuItemState(#MENU, #MENU_ShowLog, *ActiveSource\ErrorLog)
        EndIf
      EndIf
      MenuBar()
      ShortcutMenuItem(#MENU_ClearLog, Language("MenuItem", "ClearLog"))
      ShortcutMenuItem(#MENU_CopyLog, Language("MenuItem", "CopyLog"))
      MenuBar()
      ShortcutMenuItem(#MENU_ClearErrorMarks, Language("MenuItem","ClearErrorMarks"))
      CloseSubMenu()
      
    Else
      ShortcutMenuItem(#MENU_ClearErrorMarks, Language("MenuItem","ClearErrorMarks")) ; this one makes sense without the log even
    EndIf
    
    MenuBar()
    ShortcutMenuItem(#MENU_DebugOutput, Language("MenuItem", "DebugOutput"))
    
    CompilerIf Not #SpiderBasic
      ShortcutMenuItem(#MENU_Watchlist, Language("MenuItem", "WatchList"))
      ShortcutMenuItem(#MENU_VariableList, Language("MenuItem", "VariableList"))
      ShortcutMenuItem(#MENU_Profiler, Language("MenuItem", "Profiler"))
      ShortcutMenuItem(#MENU_History, Language("MenuItem", "History"))
      ShortcutMenuItem(#MENU_Memory, Language("MenuItem", "Memory"))
      ShortcutMenuItem(#MENU_LibraryViewer, Language("MenuItem","LibraryViewer"))
      ShortcutMenuItem(#MENU_DebugAsm, Language("MenuItem", "DebugAsm"))
      ShortcutMenuItem(#MENU_Purifier, Language("MenuItem", "Purifier"))
      ;     MenuBar()
      ;     ShortcutMenuItem(#MENU_CPUMonitor, Language("MenuItem","CPUMonitor"))
      
      ;     If IsCPUMonitorInitialized = 0
      ;       DisableMenuItem(#MENU, #MENU_CPUMonitor, 1)
      ;     EndIf
    CompilerEndIf
    
    MenuTitle(Language("MenuTitle","Tools"))
    
    CompilerIf #SpiderBasic
      ShortcutMenuItem(#MENU_WebView, Language("MenuItem","WebView"))
    CompilerElse
      ShortcutMenuItem(#MENU_VisualDesigner , Language("MenuItem","VisualDesigner"))
    CompilerEndIf
    ShortcutMenuItem(#MENU_FileViewer, Language("MenuItem","FileViewer"))
    ShortcutMenuItem(#MENU_StructureViewer, Language("MenuItem","StructureViewer"))
    ShortcutMenuItem(#MENU_VariableViewer, Language("MenuItem","VariableViewer"))
    ShortcutMenuItem(#MENU_Diff, Language("MenuItem","Diff"))
    ShortcutMenuItem(#MENU_ProcedureBrowser, Language("MenuItem","ProcedureBrowser"))
    ShortcutMenuItem(#MENU_Issues, Language("MenuItem","Issues"))
    ShortcutMenuItem(#MENU_ProjectPanel, Language("MenuItem","ProjectPanel"))
    ShortcutMenuItem(#MENU_Templates, Language("MenuItem","Templates"))
    ShortcutMenuItem(#MENU_Explorer, Language("MenuItem","Explorer"))
    ShortcutMenuItem(#MENU_ColorPicker, Language("MenuItem","ColorPicker"))
    ShortcutMenuItem(#MENU_AsciiTable, Language("MenuItem","AsciiTable"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_AddTools, Language("MenuItem","AddTools"))
    AddTools_AddMenuEntries()
    
    
    MenuTitle(Language("MenuTitle","Help"))
    ShortcutMenuItem(#MENU_Help , Language("MenuItem","Help"))
    
    If AddHelpFiles_Count > 0
      MenuBar()
      OpenSubMenu(Language("MenuItem","ExternalHelp"))
      AddHelpFiles_AddMenuEntries()
      CloseSubMenu()
      
      CompilerIf #CompileMac = #False ; No 'About' menu on Mac, so no need for a separator
        MenuBar()
      CompilerEndIf
    EndIf
    
    CompilerIf Not #SpiderBasic
      ShortcutMenuItem(#MENU_UpdateCheck, Language("MenuItem","UpdateCheck"))
    CompilerEndIf
    
    CompilerIf #DEBUG
      MenuItem(#MENU_Debugging, "Debugging...") ; special menu item for IDE debugging
    CompilerEndIf
    
    ShortcutMenuItem(#MENU_About, Language("MenuItem","About"))

    Result = 1
    
    UpdateMenuStates()
    SetDebuggerMenuStates()
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure CreateIDEPopupMenu()
  
  If IsMenu(#POPUPMENU)
    FreeMenu(#POPUPMENU)
  EndIf
  
  If EnableMenuIcons
    *Popup = CreatePopupImageMenu(#POPUPMENU)
  Else
    *Popup = CreatePopupMenu(#POPUPMENU)
  EndIf
  
  If *Popup
    
    ShortcutMenuItem(#MENU_Cut  , Language("MenuItem", "Cut"))
    ShortcutMenuItem(#MENU_Copy , Language("MenuItem", "Copy"))
    ShortcutMenuItem(#MENU_Paste, Language("MenuItem", "Paste"))
    ShortcutMenuItem(#MENU_PasteAsComment, Language("MenuItem", "PasteComment"))
    MenuBar()
    ShortcutMenuItem(#MENU_CommentSelection,   Language("MenuItem", "InsertComment"))
    ShortcutMenuItem(#MENU_UnCommentSelection, Language("MenuItem", "RemoveComment"))
    ShortcutMenuItem(#MENU_AutoIndent,         Language("MenuItem","AutoIndent"))
    
    MenuBar()
    ShortcutMenuItem(#MENU_LastViewedLine, Language("MenuItem","LastViewedLine"))
    
    If EnableFolding
      MenuBar()
      ShortcutMenuItem(#MENU_ToggleThisFold, Language("MenuItem","ToggleThisFold"))
      ShortcutMenuItem(#MENU_ToggleFolds, Language("MenuItem","ToggleFolds"))
    EndIf
    
    If EnableMarkers
      MenuBar()
      ShortcutMenuItem(#MENU_AddMarker,    Language("MenuItem","AddMarker"))
      ShortcutMenuItem(#MENU_JumpToMarker, Language("MenuItem","JumpToMarker"))
    EndIf
    
    MenuBar()
    ShortcutMenuItem(#MENU_SelectAll, Language("MenuItem", "SelectAll"))
    MenuBar()
    If AddHelpFiles_Count > 0
      OpenSubMenu(Language("MenuItem","ExternalHelp"))
      AddHelpFiles_AddMenuEntries()
      CloseSubMenu()
      MenuBar()
    EndIf
    ShortcutMenuItem(#MENU_Help  , Language("MenuItem", "Help"))
    ShortcutMenuItem(#MENU_SaveAll, Language("MenuItem","SaveAll"))
    ShortcutMenuItem(#MENU_CloseAll, Language("MenuItem","CloseAll"))
    ShortcutMenuItem(#MENU_Close , Language("MenuItem","Close"))
    
    ;
    ; Create the ProjectInfo PopupMenu's here as well
    ;
    
    ; Shared with ProjectPanel
    ;
    If EnableMenuIcons
      *Popup = CreatePopupImageMenu(#POPUPMENU_ProjectPanel)
    Else
      *Popup = CreatePopupMenu(#POPUPMENU_ProjectPanel)
    EndIf
    
    If *Popup
      MenuItem(#MENU_ProjectPanel_Open,       Language("Project","PanelOpen"), OptionalImageID(#IMAGE_ProjectPanel_Open))
      MenuItem(#MENU_ProjectPanel_OpenViewer, Language("Project","PanelOpenViewer"), ToolbarMenuImage(#MENU_FileViewer))
      MenuItem(#MENU_ProjectPanel_OpenExplorer, LanguagePattern("Project","PanelOpenIn", "%name%", GetExplorerName()), ToolbarMenuImage(#MENU_OpenProjectFolder))
      MenuBar()
      MenuItem(#MENU_ProjectPanel_Add,        Language("Project","PanelAdd"), OptionalImageID(#IMAGE_ProjectPanel_AddFile))
      MenuItem(#MENU_ProjectPanel_Remove,     Language("Project","PanelRemove"), OptionalImageID(#IMAGE_ProjectPanel_RemoveFile))
      MenuBar()
      MenuItem(#MENU_ProjectPanel_Rescan,     Language("Project","PanelRescan"), OptionalImageID(#IMAGE_ProjectPanel_RescanFile))
    EndIf
    
    ; ProjectInfo only
    ;
    If EnableMenuIcons
      *Popup = CreatePopupImageMenu(#POPUPMENU_Targets)
    Else
      *Popup = CreatePopupMenu(#POPUPMENU_Targets)
    EndIf
    
    If *Popup
      MenuItem(#MENU_ProjectInfo_EditTarget,     Language("Compiler","EditTarget"),    ImageID(#IMAGE_Option_EditTarget))
      MenuBar()
      MenuItem(#MENU_ProjectInfo_DefaultTarget, Language("Compiler","DefaultTarget"))
      MenuItem(#MENU_ProjectInfo_EnableTarget, Language("Compiler","EnableTarget"))
    EndIf
    
    
    ; TabBar specific popup menu
    ;
    If EnableMenuIcons
      *Popup = CreatePopupImageMenu(#POPUPMENU_TabBar)
    Else
      *Popup = CreatePopupMenu(#POPUPMENU_TabBar)
    EndIf
    
    If *Popup
      ShortcutMenuItem(#MENU_Save, Language("MenuItem","Save"))
      ShortcutMenuItem(#MENU_SaveAs, Language("MenuItem","SaveAs"))
      ShortcutMenuItem(#MENU_SaveAll, Language("MenuItem","SaveAll"))
      MenuBar()
      ShortcutMenuItem(#MENU_Reload, Language("MenuItem","Reload"))
      MenuBar()
      ShortcutMenuItem(#MENU_AddProjectFile, Language("MenuItem","AddProjectFile"))
      ShortcutMenuItem(#MENU_RemoveProjectFile, Language("MenuItem","RemoveProjectFile"))
      MenuBar()
      ShortcutMenuItem(#MENU_ShowInFolder, Language("MenuItem","ShowInFolder"))
      MenuBar()
      ShortcutMenuItem(#MENU_Close , Language("MenuItem","Close"))
      ShortcutMenuItem(#MENU_CloseAll, Language("MenuItem","CloseAll"))
    EndIf
    
  EndIf
  
EndProcedure


Procedure ResizeTools()
  Window = AvailablePanelTools()\ToolWindowID
  Tool.ToolsPanelInterface = @AvailablePanelTools()
  
  If #DEFAULT_CanWindowStayOnTop
    Height = GetRequiredHeight(AvailablePanelTools()\ToolStayOnTop)
    ResizeGadget(AvailablePanelTools()\ToolStayOnTop, 5, WindowHeight(Window)-Height-5, WindowWidth(Window)-10, Height)
    Tool\ResizeHandler(WindowWidth(Window), WindowHeight(Window)-Height-5)
  Else
    Tool\ResizeHandler(WindowWidth(Window), WindowHeight(Window))
  EndIf
EndProcedure


Declare UpdateSourceContainer()
Declare ResizeHelpSplitterContent()
Declare ResizeFileViewer()

CompilerIf #CompileMacCocoa
  Declare ResizeHelpWindow()
CompilerEndIf

Procedure RealtimeSizeWindowEventHandler()
  
  Window = EventWindow()
  Gadget = EventGadget()
  EventType = EventType()
  
  Select Window
    Case #WINDOW_Main
      ResizeMainWindow()
      
      CompilerIf #CompileMacCocoa
      Case #WINDOW_Help
        ResizeHelpWindow()
      CompilerEndIf
      
    Case #WINDOW_FileViewer
      ResizeFileViewer()
      
    Case #WINDOW_MacroError
      MacroErrorWindowEvents(#PB_Event_SizeWindow)
      
    Case #WINDOW_StructureViewer
      If StructureViewerDialog
        StructureViewerDialog\SizeUpdate()
      EndIf
      
    Case #WINDOW_ProjectOptions
      If ProjectOptionsDialog
        ProjectOptionsDialog\SizeUpdate()
      EndIf
      
    Case #WINDOW_AddTools
      If AddToolsWindowDialog
        AddToolsWindowDialog\SizeUpdate()
      EndIf
      
    Case #WINDOW_GrepOutput
      If GrepOutputDialog
        GrepOutputDialog\SizeUpdate()
      EndIf
      
    Case #WINDOW_Build
      If BuildWindowDialog
        BuildWindowDialog\SizeUpdate()
      EndIf
      
    Case #WINDOW_EditHistory
      If EditHistoryDialog
        EditHistoryDialog\SizeUpdate()
        CompilerIf #CompileWindows
          SendMessage_(GadgetID(#GADGET_History_FileList), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
        CompilerEndIf
      EndIf
      
    Default:
      PushListPosition(AvailablePanelTools())
      ForEach AvailablePanelTools()
        If AvailablePanelTools()\IsSeparateWindow And AvailablePanelTools()\ToolWindowID = Window
          ResizeTools()
          PopListPosition(AvailablePanelTools())
          ProcedureReturn
        EndIf
      Next
      PopListPosition(AvailablePanelTools())
      
      PushListPosition(RunningDebuggers())
      ForEach RunningDebuggers()
        Select Window
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Debug]
            DebugWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Asm]
            AsmWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Library]
            LibraryViewerEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_WatchList]
            WatchListWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Variable]
            VariableWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Profiler]
            ProfilerWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_History]
            HistoryWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
          Case RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Memory]
            MemoryViewerWindowEvents(RunningDebuggers(), #PB_Event_SizeWindow)
            PopListPosition(RunningDebuggers())
            ProcedureReturn
            
        EndSelect
      Next
      PopListPosition(RunningDebuggers())
      
  EndSelect
EndProcedure

CompilerIf #CompileMacCocoa
  
  Procedure CocoaGadgetEventHandler()
    
    Gadget = EventGadget()
    EventType = EventType()
    
    Select Gadget
      Case #GADGET_ToolsSplitter ; Resize current ToolsPanel Item
        If ToolsPanelVisible And CurrentTool
          CurrentTool\ResizeHandler(GetPanelWidth(#GADGET_ToolsPanel), GetPanelHeight(#GADGET_ToolsPanel))
        EndIf
        
        If ErrorLogVisible = 0
          UpdateSourceContainer()
        EndIf
        
      Case #GADGET_LogSplitter
        If ErrorLogVisible
          UpdateSourceContainer()
        EndIf
        
      Case #GADGET_Help_Splitter
        ResizeHelpSplitterContent()
        
    EndSelect
  EndProcedure
  
CompilerEndIf

Procedure CustomizeTabBarGadget()
  TabBarGadgetInclude\EnableDoubleClickForNewTab = #False
  ;TabBarGadgetInclude\EnableMiddleClickForCloseTab = #False
  
  TabBarGadgetInclude\ArrowWidth = 18
  TabBarGadgetInclude\ArrowHeight = 18
  
  ; determine colors and font in an OS-specific way
  ;
  CompilerIf #CompileWindows
    ; Windows defaults of the TabBarGadget are ok
  CompilerEndIf
  
  CompilerIf #CompileLinuxGtk
    *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
    TabBarGadgetInclude\TabBarColor = RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
    
    ; some adjustments to the generally larger fonts on Linux
    TabBarGadgetInclude\CloseButtonSize = 15
  CompilerEndIf
  
  CompilerIf #CompileMac
    With TabBarGadgetInclude
      If OSVersion() >= #PB_OS_MacOSX_10_14
        \TabBarColor   = GetCocoaColor("windowBackgroundColor")
        \TextColor   = GetCocoaColor("windowFrameTextColor")
        \FaceColor   = GetCocoaColor("windowBackgroundColor")
      Else
        ;
        ; Note: The GetThemeBrushAsColor() color below always gives me full white no matter what brush i try (except the black brush),
        ;   so i think there is something wrong with that.
        ;   Try the 10.4+ only alternative first in the x86 version where this is always available
        ;
        HIThemeBrushCreateCGColor(#kThemeBrushAlertBackgroundActive, @CGColor.i)
        If CGColor
          NbComponents = CGColorGetNumberOfComponents(CGColor)
          *Components  = CGColorGetComponents(CGColor)
          
          If *Components And NbComponents = 2 ; its grey and alpha
            
            CompilerIf #PB_Compiler_64Bit ; CGFloat is a double on 64 bit system
              c = 255 * PeekD(*Components)
            CompilerElse
              c = 255 * PeekF(*Components)
            CompilerEndIf
            
            \TabBarColor = RGBA(c, c, c, $FF)
            
          ElseIf *Components And NbComponents = 4 ; its rgba
            
            CompilerIf #PB_Compiler_64Bit
              r = 255 * PeekD(*Components)
              g = 255 * PeekD(*Components + 8)
              b = 255 * PeekD(*Components + 16)
            CompilerElse
              r = 255 * PeekF(*Components)
              g = 255 * PeekF(*Components + 4)
              b = 255 * PeekF(*Components + 8)
            CompilerEndIf
            
            \TabBarColor = RGBA(r, g, b, $FF)
          EndIf
          
          CGColorRelease(CGColor)
        EndIf
      EndIf
      \BorderColor = GetCocoaColor("systemGrayColor")
    EndWith
  CompilerEndIf
  
EndProcedure

Procedure CreateGUI()
  Success = 0
  
  LoadEditorFonts()
  
  If OpenWindow(#WINDOW_Main, EditorWindowX, EditorWindowY, EditorWindowWidth, EditorWindowHeight, DefaultCompiler\VersionString$, #WINDOW_Main_Flags)
    
    CompilerIf #CompileMac
      If OSVersion() >= #PB_OS_MacOSX_10_14
        ; Fix Toolbar style from titlebar to expanded (Top Left)
        #NSWindowToolbarStyleExpanded = 1
        CocoaMessage(0, WindowID(#WINDOW_Main), "setToolbarStyle:", #NSWindowToolbarStyleExpanded)
      EndIf
    CompilerEndIf
    
    SmartWindowRefresh(#WINDOW_Main, 1)
    
    RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_All)
    
    If CreateIDEMenu()
      DisableMenuItem(#MENU, #MENU_StructureViewer, 1)
      DisableMenuItem(#MENU, #MENU_CompileRun, 1)
      DisableMenuItem(#MENU, #MENU_SyntaxCheck, 1)
      DisableMenuItem(#MENU, #MENU_CreateExecutable, 1)
      
      ContainerGadget(#GADGET_SourceContainer, 0, 0, 0, 0) ; put all the source part in a container
      
      ; To remove bad flickering when resizing the editor area
      CompilerIf #CompileWindows
        SetWindowLongPtr_(GadgetID(#GADGET_SourceContainer), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#GADGET_SourceContainer), #GWL_STYLE) | #WS_CLIPCHILDREN)
      CompilerEndIf
      
      ; customize some TabBarGadget global settings for the IDE
      CustomizeTabBarGadget()
      
      If FilesPanelMultiline
        PanelFlags = #TabBarGadget_MultiLine
      Else
        PanelFlags = #TabBarGadget_PopupButton ; include this only in non-multiline mode as it is weird otherwise (always disabled)
      EndIf
      
      If FilesPanelCloseButtons
        PanelFlags | #TabBarGadget_CloseButton
      EndIf
      
      ; 0 height means autosize for the height (according to the used font)
      CompilerIf #CompileWindows
        TabBarGadget(#GADGET_FilesPanel, 0, 0, 0, 25, PanelFlags, #WINDOW_Main) ; Auto height doesn't look OK on Windows
        
      CompilerElseIf #CompileMacCocoa
        TabBarGadget(#GADGET_FilesPanel, 0, 0, 0, 27, PanelFlags, #WINDOW_Main) ; Auto height doesn't look OK on OS X
        
      CompilerElse
        TabBarGadget(#GADGET_FilesPanel, 0, 0, 0, 0, PanelFlags, #WINDOW_Main)
        
      CompilerEndIf
      
      If FilesPanelNewButton
        AddTabBarGadgetItem(#GADGET_FilesPanel, #TabBarGadgetItem_NewTab, "", ImageID(#IMAGE_FilePanel_New))
      EndIf
      
      CloseGadgetList() ; close source container
      
      ListViewGadget(#GADGET_ErrorLog, 0, 0, 0, 0)
      ToolsPanel_ApplyColors(#GADGET_ErrorLog)
      ToolsPanel_Create(#False)
      
      ErrorLogVisible = 1 ; important to set the state correctly now
      ToolsPanelVisible = 1
      
      ; create our dummy gadgets and splitters...
      ContainerGadget(#GADGET_LogDummy, 0, 0, 0, 0): CloseGadgetList()
      ContainerGadget(#GADGET_ToolsDummy, 0, 0, 0, 0): CloseGadgetList()
      HideGadget(#GADGET_LogDummy, 1)
      HideGadget(#GADGET_ToolsDummy, 1)
      
      SplitterGadget(#GADGET_LogSplitter, 0, 0, 0, 0, #GADGET_SourceContainer, #GADGET_ErrorLog, #PB_Splitter_SecondFixed)
      
      ; LINUX-X64:
      ;   This causes a wrong debugger message (#Gadget not initialized) and a crash later
      ;   probably a compiler error when calling the debug routine because the gadgets are initialized (as shown in library viewer)
      ;
      DisableDebugger
      If ToolsPanelSide = 0
        SplitterGadget(#GADGET_ToolsSplitter, 0, 0, 0, 0, #GADGET_LogSplitter, #GADGET_ToolsPanel, #PB_Splitter_Vertical | #PB_Splitter_SecondFixed)
      Else
        SplitterGadget(#GADGET_ToolsSplitter, 0, 0, 0, 0, #GADGET_ToolsPanel, #GADGET_LogSplitter, #PB_Splitter_Vertical | #PB_Splitter_FirstFixed)
      EndIf
      EnableDebugger
      
      ; set a minimum size for all the splitters
      SetGadgetAttribute(#GADGET_LogSplitter, #PB_Splitter_FirstMinimumSize, 80)
      SetGadgetAttribute(#GADGET_LogSplitter, #PB_Splitter_SecondMinimumSize, 20)
      SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstMinimumSize, 30)
      SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondMinimumSize, 30)
      
      *MainStatusBar = CreateStatusBar(#STATUSBAR, WindowID(#WINDOW_Main))
      If *MainStatusBar
        AddStatusBarField(230)
        AddStatusBarField(#PB_Ignore)
        StatusBarText(#STATUSBAR, 1, "", #PB_StatusBar_BorderLess)
        
        CreateIDEPopupMenu()
        
        If CreateIDEToolbar()
          Success = 1
        EndIf
      EndIf
    EndIf
  EndIf
  
  GetWindowMetrics()
  ResizeMainWindow()
  
  ; For the toolpanel auto-hide stuff
  AddWindowTimer(#WINDOW_Main, #TIMER_ToolPanelAutoHide, 500)
  
  BindEvent(#PB_Event_SizeWindow, @RealtimeSizeWindowEventHandler(), #PB_All, #PB_All, #PB_All)
  
  CompilerIf #CompileWindows | #CompileMac ; special shortcuts for tab/enter on scintilla
    AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return, #MENU_Scintilla_Enter)
    AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab, #MENU_Scintilla_Tab)
    AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab, #MENU_Scintilla_ShiftTab)
  CompilerEndIf
  
  CreateKeyboardShortcuts(#WINDOW_Main) ; Some shortcuts are not menu related, so we add them all on OS X as well
  
  CompilerIf #CompileMacCocoa
    PB_Gadget_AddFullScreenButton(WindowID(#WINDOW_Main)) ; Add the full screen button for OS X 10.7+
    
    BindEvent(#PB_Event_Gadget    , @CocoaGadgetEventHandler(), #PB_All, #PB_All, #PB_All)
  CompilerEndIf
  
  ProcedureReturn Success
EndProcedure

Procedure ActivateMainWindow()
  SetActiveWindow(#WINDOW_Main)
  
  If *ActiveSource
    If *ActiveSource = *ProjectInfo
      ; todo
    Else
      SetActiveGadget(*ActiveSource\EditorGadget)
    EndIf
  EndIf
EndProcedure

; Update menu item states after a source switch (except debugger/error log)
;
Procedure UpdateMenuStates()
  
  ; Can be 0 during startup. in this case we need no change as it will be
  ; applied when creating the first source.
  ;
  If *ActiveSource
    
    If *ActiveSource\IsForm
      DisableMenuItem(#MENU, #MENU_FormSwitch, 0)
      DisableMenuItem(#MENU, #MENU_Duplicate, 0)
      DisableMenuItem(#MENU, #MENU_FormImageManager, 0)
    Else
      DisableMenuItem(#MENU, #MENU_FormSwitch, 1)
      DisableMenuItem(#MENU, #MENU_Duplicate, 1)
      DisableMenuItem(#MENU, #MENU_FormImageManager, 1)
    EndIf
    
    If *ActiveSource\Parser\Encoding = 0 ; ascii
      SetMenuItemState(#MENU, #MENU_EncodingPlain, 1)
      SetMenuItemState(#MENU, #MENU_EncodingUtf8,  0)
    Else ; utf8
      SetMenuItemState(#MENU, #MENU_EncodingPlain, 0)
      SetMenuItemState(#MENU, #MENU_EncodingUtf8,  1)
    EndIf
    
    Select *ActiveSource\NewLineType
      Case 0 ; windows
        SetMenuItemState(#MENU, #MENU_NewlineWindows, 1)
        SetMenuItemState(#MENU, #MENU_NewlineLinux,   0)
        SetMenuItemState(#MENU, #MENU_NewlineMacOS,   0)
        
      Case 1 ; linux
        SetMenuItemState(#MENU, #MENU_NewlineWindows, 0)
        SetMenuItemState(#MENU, #MENU_NewlineLinux,   1)
        SetMenuItemState(#MENU, #MENU_NewlineMacOS,   0)
        
      Case 2 ; macos
        SetMenuItemState(#MENU, #MENU_NewlineWindows, 0)
        SetMenuItemState(#MENU, #MENU_NewlineLinux,   0)
        SetMenuItemState(#MENU, #MENU_NewlineMacOS,   1)
        
    EndSelect
    
    If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
      IsProjectSource = 1
    Else
      IsProjectSource = 0
    EndIf
    
    If IsProjectSource Or *ActiveSource\IsCode
      NonPBFile = 0
    Else
      NonPBFile = 1
    EndIf
    
    If HistoryActive
      DisableMenuAndToolbarItem(#MENU_EditHistory, 0)
    Else
      DisableMenuAndToolbarItem(#MENU_EditHistory, 1)
    EndIf
    
    If IsProject
      DisableMenuAndToolbarItem(#MENU_CloseProject, 0)
      DisableMenuAndToolbarItem(#MENU_ProjectOptions, 0)
      DisableMenuAndToolbarItem(#MENU_OpenProjectFolder, 0)
      
      If *ActiveSource = *ProjectInfo
        DisableMenuAndToolbarItem(#MENU_AddProjectFile, 1)
        DisableMenuAndToolbarItem(#MENU_RemoveProjectFile, 1)
      Else
        DisableMenuAndToolbarItem(#MENU_AddProjectFile, IsProjectSource)
        DisableMenuAndToolbarItem(#MENU_RemoveProjectFile, 1-IsProjectSource)
      EndIf
      
    Else
      DisableMenuAndToolbarItem(#MENU_CloseProject, 1)
      DisableMenuAndToolbarItem(#MENU_ProjectOptions, 1)
      DisableMenuAndToolbarItem(#MENU_AddProjectFile, 1)
      DisableMenuAndToolbarItem(#MENU_RemoveProjectFile, 1)
      DisableMenuAndToolbarItem(#MENU_OpenProjectFolder, 1)
      
    EndIf
    
    DisableMenuAndToolbarItem(#MENU_BuildAllTargets, 1-IsProject)
    
    ForEach ProjectTargets()
      Index = ListIndex(ProjectTargets())
      DisableMenuAndToolbarItem(#MENU_DefaultTarget_Start+Index, 1-IsProject)
      DisableMenuAndToolbarItem(#MENU_BuildTarget_Start+Index, 1-IsProject)
    Next ProjectTargets()
    
    ; Disable Menu entries if we are on the ProjectInfo tab
    ;
    If *ActiveSource = *ProjectInfo
      NoRealSource = 1
    Else
      NoRealSource = 0
    EndIf
    
    ; File menu
    DisableMenuAndToolbarItem(#MENU_Save, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_SaveAs, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_Close, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_EncodingPlain, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_EncodingUtf8, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_NewlineWindows, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_NewlineLinux, NoRealSource)
    DisableMenuAndToolbarItem(#MENU_NewlineMacOS, NoRealSource)
    
    ; File menu special cases
    DisableMenuAndToolbarItem(#MENU_Reload, Bool( (*ActiveSource\FileName$ = "") Or (*ActiveSource = *ProjectInfo) Or (*ActiveSource\IsForm) ))
    DisableMenuAndToolbarItem(#MENU_DiffCurrent, Bool( (*ActiveSource\FileName$ = "") Or (*ActiveSource = *ProjectInfo) Or (*ActiveSource\IsForm) Or (GetSourceModified(*ActiveSource) = 0) ))
    DisableMenuAndToolbarItem(#MENU_ShowInFolder, Bool( (*ActiveSource <> *ProjectInfo) And (*ActiveSource\FileName$ = "") ))
    
    ; Edit menu (disable all, except FileInFiles)
    ;
    For Item = #MENU_Undo To #MENU_FindPrevious
      DisableMenuAndToolbarItem(Item, NoRealSource)
    Next Item
    
    ; Disable some edit stuff when in non-pb mode
    If NoRealSource = 0
      DisableMenuAndToolbarItem(#MENU_CommentSelection,   NonPBFile)
      DisableMenuAndToolbarItem(#MENU_UnCommentSelection, NonPBFile)
      DisableMenuAndToolbarItem(#MENU_AutoIndent,         NonPBFile)
      DisableMenuAndToolbarItem(#MENU_JumpToKeyword,      NonPBFile)
      DisableMenuAndToolbarItem(#MENU_ToggleThisFold,     NonPBFile)
      DisableMenuAndToolbarItem(#MENU_ToggleFolds ,       NonPBFile)
    EndIf
    
    ; Compiler menu
    DisableMenuAndToolbarItem(#MENU_CompileRun,        NonPBFile)
    DisableMenuAndToolbarItem(#MENU_RunExe,            NonPBFile)
    DisableMenuAndToolbarItem(#MENU_SyntaxCheck,       NonPBFile)
    DisableMenuAndToolbarItem(#MENU_DebuggerCompile,   NonPBFile)
    DisableMenuAndToolbarItem(#MENU_NoDebuggerCompile, NonPBFile)
    DisableMenuAndToolbarItem(#MENU_CompilerOption,    NonPBFile)
    DisableMenuAndToolbarItem(#MENU_CreateExecutable,  NonPBFile)
    DisableMenuAndToolbarItem(#MENU_BuildAllTargets,   NonPBFile)
    
    ; Project Menu done above
    ; Compiler Menu: no changes needed
    ; Debugger Menu: done in SetDebuggerMenuStates()
    ; Tools Menu: no changes needed
    ; Help Menu: no changes needed
  EndIf
  
EndProcedure

; Update the main window title with new filename
;
Procedure UpdateMainWindowTitle()
  Title$ = DefaultCompiler\VersionString$
  Title$ = RemoveString(Title$, "Windows - ") ; remove the OS part as it is redundant information
  Title$ = RemoveString(Title$, "Linux - ")
  Title$ = RemoveString(Title$, "MacOS X - ")
  
  If IsProject And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile)
    Title$ + " - " + ProjectName$
  EndIf
  
  If *ActiveSource And *ActiveSource <> *ProjectInfo And *ActiveSource\FileName$ <> ""
    If DisplayFullPath
      Title$ + " - " + *ActiveSource\FileName$
    Else
      Title$ + " - " + GetFilePart(*ActiveSource\FileName$)
    EndIf
  EndIf
  
  SetWindowTitle(#WINDOW_Main, Title$)
EndProcedure

; the sticky time parameter defines how long the message should stay in the statusbar (in MS)
; values:
; 0  - low priority message, only displayed if no sticky message is on (for the quickhelp messages)
; -1 - overwrites a sticky message, but is itself low-priority (for language updates)
; other values: defines in MS, how long the message will have priority over '0' messages.
; Note: a new sticky message always overwrites an old one, no matter how long it is to stay on.
;
Procedure ChangeStatus(Message$, StickyTime)
  Shared StatusMessageTimeout.q ; shared for the special access in QuickHelpFromLine()
  
  time.q = ElapsedMilliseconds()
  
  If StickyTime = -1
    StatusMessageTimeout = 0
    StatusBarText(#STATUSBAR, 1, Message$, #PB_StatusBar_BorderLess)
    
  ElseIf StickyTime > 0
    StatusMessageTimeout = time + StickyTime
    StatusBarText(#STATUSBAR, 1, Message$, #PB_StatusBar_BorderLess)
    
  ElseIf StickyTime = 0 And time > StatusMessageTimeout
    StatusMessageTimeout = 0
    StatusBarText(#STATUSBAR, 1, Message$, #PB_StatusBar_BorderLess)
    
  EndIf
  
EndProcedure

Procedure ChangeCurrentFile(Previous)
  
  NbFiles = ListSize(FileList())-1
  
  If NbFiles > 0 ; At least 2 files else there is nothing to do
    Index = ListIndex(FileList())
    
    If Previous  ; Need to display the previous file
      If Index
        Index - 1  ; Previous one
      Else
        Index = NbFiles  ; Go back to last if we were on the first
      EndIf
    Else
      If Index < NbFiles
        Index + 1  ; Next one
      Else
        Index = 0  ; Go back to first
      EndIf
    EndIf
    
    Debug "selecting... " + Str(Index)
    
    SelectElement(FileList(), Index)
    ChangeActiveSourcecode()
  EndIf
  
EndProcedure

Procedure MainMenuEvent(MenuItemID)
  Quit = 0
  
  Select MenuItemID
      
    Case #MENU_New
      NewSource("", #True)
      HistoryEvent(*ActiveSource, #HISTORY_Create)
      
    Case #MENU_Open
      LoadSource()
      
    Case #MENU_Save
      SaveSource()
      
    Case #MENU_SaveAs
      SaveSourceAs()
      
    Case #MENU_Reload
      ReloadSource()
      
    Case #MENU_Close
      If CheckSourceSaved() = 1  ; -1 means user abort, 0=error
        RemoveSource()
      EndIf
      
    Case #MENU_SaveAll
      SaveAll()
      
    Case #MENU_CloseAll
      If CheckAllSourcesSaved() ; returns true if abort was not chosen.
        NbFiles = ListSize(FileList())
        If *ProjectInfo
          NbFiles - 1
        EndIf
        
        For i = 1 To NbFiles
          ; the ProjectInfo cannot be removed, so make sure its not the current display
          If *ActiveSource = *ProjectInfo
            LastElement(FileList())
            ChangeActiveSourceCode()
          EndIf
          RemoveSource()
        Next i
      EndIf
      
    Case #MENU_DiffCurrent
      If *ActiveSource And *ActiveSource <> *ProjectInfo And *ActiveSource\FileName$
        DiffSourceToFile(*ActiveSource, *ActiveSource\FileName$, #True) ; swap output, so it is File -> Source
      EndIf
      
    Case #MENU_ShowInFolder
      ShowInFolder()
      
    Case #MENU_EncodingPlain
      ChangeTextEncoding(*ActiveSource, 0) ; only changes the encoding if needed, also sets the "edited" flag (because it modifies the text)
      UpdateMenuStates()
      
    Case #MENU_EncodingUtf8
      ChangeTextEncoding(*ActiveSource, 1)
      UpdateMenuStates()
      
    Case #MENU_NewlineWindows
      If *ActiveSource\NewLineType <> 0
        *ActiveSource\NewLineType = 0 ; this only affects the saving, not the current display state
        UpdateSourceStatus(#True)
        UpdateMenuStates()
      EndIf
      
    Case #MENU_NewlineLinux
      If *ActiveSource\NewLineType <> 1
        *ActiveSource\NewLineType = 1
        UpdateSourceStatus(#True)
        UpdateMenuStates()
      EndIf
      
    Case #MENU_NewlineMacOS
      If *ActiveSource\NewLineType <> 2
        *ActiveSource\NewLineType = 2
        UpdateSourceStatus(#True)
        UpdateMenuStates()
      EndIf
      
    Case #MENU_Preference
      OpenPreferencesWindow()
      
    Case #MENU_EditHistory
      OpenEditHistoryWindow()
      
    Case #MENU_Exit
      Quit = CheckAllSourcesSaved()
      
    Case #MENU_Undo
      If *ActiveSource And *ActiveSource\IsForm And FormWindows()\current_view = 0
        FormUndo()
      Else
        Undo()
      EndIf
      
    Case #MENU_Redo
      If *ActiveSource And *ActiveSource\IsForm And FormWindows()\current_view = 0
        FormRedo()
      Else
        Redo()
      EndIf
      
    Case #MENU_Cut
      If *ActiveSource And *ActiveSource\IsForm And FormWindows()\current_view = 0
        FD_CutEvent()
      Else
        Cut()
      EndIf
      
    Case #MENU_Copy
      If *ActiveSource And *ActiveSource\IsForm And FormWindows()\current_view = 0
        FD_CopyEvent()
      Else
        Copy()
      EndIf
      
    Case #MENU_Paste
      If *ActiveSource And *ActiveSource\IsForm And FormWindows()\current_view = 0
        FD_PasteEvent()
      Else
        Paste()
      EndIf
      
    Case #MENU_PasteAsComment
      If *ActiveSource And *ActiveSource\IsForm = 0
        PasteAsComment()
      EndIf
      
    Case #MENU_CommentSelection
      InsertComments()
      
    Case #MENU_UnCommentSelection
      RemoveComments()
      
    Case #MENU_AutoIndent
      AutoIndent()
      ;AlignComments()
      
    Case #MENU_SelectAll
      SelectAll()
      
    Case #MENU_Goto
      OpenGotoWindow()
      
    Case #MENU_JumpToKeyword
      JumpToMatchingKeyword()
      
    Case #MENU_Find
      OpenFindWindow()
      
    Case #MENU_FindNext,
         #MENU_FindPrevious
      If *ActiveSource <> *ProjectInfo
        If FindSearchString$ = ""
          OpenFindWindow()
        Else
          If MenuItemID = #MENU_FindPrevious
            Reverse = 1
          EndIf
          FindText(1, Reverse)
        EndIf
      EndIf
      
    Case #MENU_FindInFiles
      OpenGrepWindow()
      
    Case #MENU_Replace
      OpenFindWindow(#True)     ; Replace=#True
       
    Case #MENU_NewProject
      OpenProjectOptions(#True) ; creates a new project
      
    Case #MENU_OpenProject
      OpenProject()
      
    Case #MENU_CloseProject
      CloseProject()
      
    Case #MENU_ProjectOptions
      OpenProjectOptions(#False)
      
    Case #MENU_AddProjectFile
      AddProjectFile()
      
    Case #MENU_RemoveProjectFile
      RemoveProjectFile()
      
      ;       Case #MENU_BackupManager
      ;       Case #MENU_MakeBackup
      ;       Case #MENU_TodoList
      ;         ; todo
      
    Case #MENU_OpenProjectFolder
      If IsProject
        ShowExplorerDirectory(GetPathPart(ProjectFile$))
      EndIf
      
    Case #MENU_CompileRun
      ForceDebugger = 0   ; use the source file setting
      ForceNoDebugger = 0
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *DefaultTarget
        CompileRunProject(#False)
      Else
        If *ActiveSource\IsForm
          FD_PrepareTestCode()
        EndIf
        
        CompileRun(#False)
      EndIf
      
    Case #MENU_SyntaxCheck
      ForceDebugger = 0   ; use the source file setting
      ForceNoDebugger = 0
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *DefaultTarget
        CompileRunProject(#True)
      Else
        If *ActiveSource\IsForm
          FD_PrepareTestCode()
        EndIf
        
        CompileRun(#True)
      EndIf
      
    Case #MENU_RunExe
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *DefaultTarget
        RunProject()
      Else
        Run()
      EndIf
      
    Case #MENU_DebuggerCompile
      ForceDebugger = 1   ; force debugger on
      ForceNoDebugger = 0
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *DefaultTarget
        CompileRunProject(#False)
      Else
        CompileRun(#False)
      EndIf
      
    Case #MENU_NoDebuggerCompile
      ForceDebugger = 0
      ForceNoDebugger = 1 ; force debugger off
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *DefaultTarget
        CompileRunProject(#False)
      Else
        CompileRun(#False)
      EndIf
      
    Case #MENU_Debugger
      *Target.CompileTarget = GetActiveCompileTarget()
      If *Target
        *Target\Debugger = 1-*Target\Debugger
        SetDebuggerMenuStates()
      EndIf
      
    Case #MENU_RestartCompiler
      If CompilerBusy
        MessageRequester(#ProductName$, Language("Compiler","Busy"))
      Else
        RestartCompiler(@DefaultCompiler)
      EndIf
      
    Case #MENU_CompilerOption
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile Or *ActiveSource\IsCode)
        OpenOptionWindow(#False)
      EndIf
      
    Case #MENU_CreateExecutable
      
      If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *DefaultTarget
        
        CompilerIf #SpiderBasic
          ; Note: CreateExecutableProject() will be called by CreateApp window
          ;
          OpenCreateAppWindow(*DefaultTarget, #True)
        CompilerElse
          CreateExecutableProject()
        CompilerEndIf
        
      Else
        If *ActiveSource\IsForm
          FD_PrepareTestCode()
        EndIf
        
        CreateExecutable()
      EndIf
      
    Case #MENU_DefaultTarget_Start To #MENU_DefaultTarget_End
      If IsProject
        Index = MenuItemID-#MENU_DefaultTarget_Start
        
        *DefaultTarget = 0
        ForEach ProjectTargets()
          If Index = ListIndex(ProjectTargets())
            ProjectTargets()\IsDefault = #True
            SetMenuItemState(#MENU, #MENU_DefaultTarget_Start+ListIndex(ProjectTargets()), #True)
            *DefaultTarget = @ProjectTargets()
          Else
            ProjectTargets()\IsDefault = #False
            SetMenuItemState(#MENU, #MENU_DefaultTarget_Start+ListIndex(ProjectTargets()), #False)
          EndIf
        Next ProjectTargets()
      EndIf
      
    Case #MENU_BuildTarget_Start To #MENU_BuildTarget_End
      If IsProject
        If SelectElement(ProjectTargets(), MenuItemID-#MENU_BuildTarget_Start)
          BuildTarget(@ProjectTargets())
        EndIf
      EndIf
      
    Case #MENU_BuildAllTargets
      If IsProject
        BuildAll()
      EndIf
      
    Case #MENU_NewForm
      NewForm()
      
    Case #MENU_FormImageManager
      InitImgList()
      
    Case #MENU_VisualDesigner
      ActivateTool("Form")
      
    Case #MENU_StructureViewer
      OpenStructureViewerWindow()
      
    Case #MENU_FileViewer
      OpenFileViewerWindow()
      
    Case #MENU_AddTools
      AddTools_OpenWindow()
      
    Case #MENU_Help
      DisplayHelp(GetCurrentWord())
      
    Case #MENU_UpdateCheck
      CheckForUpdatesManual()
      
    Case #MENU_About
      OpenAboutWindow()
      
    Case #MENU_NextOpenedFile
      ChangeCurrentFile(0)
      
    Case #MENU_PreviousOpenedFile
      ChangeCurrentFile(1)
      
    Case #MENU_ShiftCommentRight
      ShiftComments(#True)
      
    Case #MENU_ShiftCommentLeft
      ShiftComments(#False)
      
    Case #MENU_SelectBlock
      SelectBlock()
      
    Case #MENU_DeselectBlock
      DeselectBlock()
      
    Case #MENU_MoveLinesUp
      If *ActiveSource And *ActiveSource\IsForm = 0
        SendEditorMessage(#SCI_MOVESELECTEDLINESUP)
      EndIf
      
    Case #MENU_MoveLinesDown
      If *ActiveSource And *ActiveSource\IsForm = 0
        SendEditorMessage(#SCI_MOVESELECTEDLINESDOWN)
      EndIf
      
    Case #MENU_DeleteLines
      If *ActiveSource And *ActiveSource\IsForm = 0
        ; Do this manually, because the built-in Scintilla functions have drawbacks:
        ; #SCI_LINECUT can delete multiple selected lines (nice!) but overwrites your clipboard
        ; #SCI_LINEDELETE does not touch the clipboard, but can only delete 1 line at a time
        StartLine  = SendEditorMessage(#SCI_LINEFROMPOSITION, SendEditorMessage(#SCI_GETSELECTIONSTART))
        EndLine    = SendEditorMessage(#SCI_LINEFROMPOSITION, SendEditorMessage(#SCI_GETSELECTIONEND))
        RangeStart = SendEditorMessage(#SCI_POSITIONFROMLINE, StartLine)
        RangeEnd   = SendEditorMessage(#SCI_POSITIONFROMLINE, EndLine) + SendEditorMessage(#SCI_LINELENGTH, EndLine)
        SendEditorMessage(#SCI_DELETERANGE, RangeStart, RangeEnd - RangeStart)
      EndIf
      
    Case #MENU_DuplicateSelection
      If *ActiveSource And *ActiveSource\IsForm = 0
        SendEditorMessage(#SCI_SELECTIONDUPLICATE)
      EndIf
      
    Case #MENU_UpperCase
      AdjustSelection(0)
    Case #MENU_LowerCase
      AdjustSelection(1)
    Case #MENU_InvertCase
      AdjustSelection(2)
    Case #MENU_SelectWord
      AdjustSelection(3)
      
    Case #MENU_ZoomIn
      If *ActiveSource And *ActiveSource\IsForm = 0 And *ActiveSource <> *ProjectInfo
        ZoomStep(1)
      EndIf
      
    Case #MENU_ZoomOut
      If *ActiveSource And *ActiveSource\IsForm = 0 And *ActiveSource <> *ProjectInfo
        ZoomStep(-1)
      EndIf
      
    Case #MENU_ZoomDefault
      If *ActiveSource And *ActiveSource\IsForm = 0 And *ActiveSource <> *ProjectInfo
        ZoomDefault()
      EndIf
      
    Case #MENU_ToggleFolds
      *ActiveSource\ToggleFolds = 1-*ActiveSource\ToggleFolds
      LineCount = GetLinesCount(*ActiveSource)-1
      For i = 0 To LineCount
        If IsFoldPoint(i)
          SetFoldState(i, *ActiveSource\ToggleFolds)
        EndIf
      Next i
      
      ; make sure the caret remains in view (if not inside a closed fold now)
      If *ActiveSource\ToggleFolds Or SendEditorMessage(#SCI_GETFOLDPARENT, *ActiveSource\CurrentLine-1, 0) = -1
        SendEditorMessage(#SCI_SCROLLCARET, 0, 0)
      EndIf
      
    Case #MENU_ToggleThisFold
      UpdateCursorPosition()
      If IsFoldPoint(*ActiveSource\CurrentLine-1)
        SendEditorMessage(#SCI_TOGGLEFOLD, *ActiveSource\CurrentLine-1, 0)
      Else
        FoldStart = SendEditorMessage(#SCI_GETFOLDPARENT, *ActiveSource\CurrentLine-1, 0)
        If FoldStart <> -1
          SendEditorMessage(#SCI_TOGGLEFOLD, FoldStart, 0)
        EndIf
      EndIf
      
    Case #MENU_LastViewedLine
      If *ActiveSource
        ; first "POP" the line history stack.
        ; we set the last seen current line (index 0) to the line we jump to (index 1),
        ; to avoid that this jump triggers no update of the line history
        ;
        MoveMemory(@*ActiveSource\LineHistory[1], @*ActiveSource\LineHistory[0], (#MAX_LineHistory-1)*4)
        ChangeActiveLine(*ActiveSource\LineHistory[0], -5)
      EndIf
      
    Case #MENU_AddMarker
      AddMarker()
      
    Case #MENU_JumpToMarker
      MarkerJump()
      
    Case #MENU_ClearMarkers
      ClearMarkers()
      
    Case #MENU_AutoComplete
      OpenAutoCompleteWindow()
      
    Case #MENU_AutoComplete_OK
      If AutoCompleteWindowOpen
        AutoComplete_Insert()
      ElseIf AutoCompleteKeywordInserted
        AutoComplete_InsertEndKEyword()
      EndIf
      
    Case #MENU_ProcedureListUpdate
      FullSourceScan(*ActiveSource)
      UpdateFolding(*ActiveSource, 0, -1)
      UpdateProcedureList()
      UpdateVariableViewer()
      UpdateSelectionRepeat()
      
    Case #MENU_VariableViewer
      ActivateTool("VariableViewer")
      
    Case #MENU_ColorPicker
      ActivateTool("ColorPicker")
      
    Case #MENU_AsciiTable
      ActivateTool("AsciiTable")
      
    Case #MENU_Explorer
      ActivateTool("Explorer")
      
    Case #MENU_WebView
      ActivateTool("WebView")
      
    Case #MENU_ProcedureBrowser
      ActivateTool("ProcedureBrowser")
      
    Case #MENU_Issues
      ActivateTool("Issues")
      
    Case #MENU_ProjectPanel
      ActivateTool("ProjectPanel")
      
    Case #MENU_Templates
      ActivateTool("Templates")
      
    Case #MENU_Diff
      OpenDiffDialogWindow()
      
    Case #MENU_Stop
      Debugger_Stop()
      
    Case #MENU_Run
      Debugger_Run()
      
    Case #MENU_Step
      Debugger_Step()
      
    Case #MENU_StepX
      Debugger_StepX()
      
    Case #MENU_StepOver
      Debugger_StepOver()
      
    Case #MENU_StepOut
      Debugger_StepOut()
      
    Case #MENU_Kill
      CompilerIf #SpiderBasic
        SetWebViewUrl("") ; Set a blank URL to empty the webview and actually stop the JS program
      CompilerElse
        Debugger_Kill()
      CompilerEndIf
            
    Case #MENU_BreakPoint
      UpdateCursorPosition() ; to get the current line
      Debugger_BreakPoint(*ActiveSource\CurrentLine-1)
      
    Case #MENU_BreakClear
      Debugger_ClearBreakPoints()
      
    Case #MENU_DataBreakPoints
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenDataBreakpointWindow(*Debugger)
      EndIf
      
    Case #MENU_ShowLog
      If *ActiveSource\ProjectFile
        ProjectShowLog = 1-ProjectShowLog
        ShowLog = ProjectShowLog
      Else
        *ActiveSource\ErrorLog = 1-*ActiveSource\ErrorLog
        ShowLog = *ActiveSource\ErrorLog
      EndIf
      
      If AlwaysHideLog = 0 And ShowLog
        ErrorLog_Show()
      Else
        ErrorLog_Hide()
      EndIf
      SetMenuItemState(#MENU, #MENU_ShowLog, ShowLog)
      ResizeMainWindow()
      
    Case #MENU_ClearLog
      ClearGadgetItems(#GADGET_ErrorLog)
      If *ActiveSource\ProjectFile
        ClearList(ProjectLog())
      Else
        *ActiveSource\LogSize = 0
      EndIf
      SetDebuggerMenuStates()
      
    Case #MENU_CopyLog
      Text$ = ""
      If *ActiveSource\ProjectFile
        ForEach ProjectLog()
          Text$ + ProjectLog() + #NewLine
        Next ProjectLog()
      Else
        For i = 0 To *ActiveSource\LogSize-1
          Text$ + *ActiveSource\LogLines$[i] + #NewLine
        Next i
      EndIf
      If Text$ <> ""
        SetClipboardText(Text$)
      EndIf
      
    Case #MENU_ClearErrorMarks
      ClearErrorLines(*ActiveSource)
      
    Case #MENU_DebugOutput
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenDebugWindow(*Debugger, #True)
      EndIf
      
    Case #MENU_Watchlist
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenWatchListWindow(*Debugger)
      EndIf
      
    Case #MENU_VariableList
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenVariableWindow(*Debugger)
      EndIf
      
    Case #MENU_Profiler
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenProfilerWindow(*Debugger)
      EndIf
      
    Case #MENU_History
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenHistoryWindow(*Debugger)
      EndIf
      
    Case #MENU_Memory
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenMemoryViewerWindow(*Debugger)
      EndIf
      
    Case #MENU_LibraryViewer
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenLibraryViewerWindow(*Debugger)
      EndIf
      
    Case #MENU_Purifier
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenPurifierWindow(*Debugger)
      EndIf
      
    Case #MENU_DebugAsm
      *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
      If *Debugger
        OpenAsmWindow(*Debugger)
      EndIf
      
      ;       Case #MENU_CPUMonitor
      ;         OpenCPUMonitorWindow()
      ;
    Case #MENU_ProjectInfo_EditTarget
      index = GetGadgetState(#GADGET_ProjectInfo_Targets)
      If index <> -1 And SelectElement(ProjectTargets(), index)
        OpenOptionWindow(#True, @ProjectTargets())
      EndIf
      
    Case #MENU_ProjectInfo_DefaultTarget
      index = GetGadgetState(#GADGET_ProjectInfo_Targets)
      If index <> -1 And SelectElement(ProjectTargets(), index)
        *Current = @ProjectTargets()
        
        If ProjectTargets()\IsDefault
          If ListSize(ProjectTargets()) = 1
            ProjectTargets()\IsDefault = 1 ; cannot unset this in this case
            *DefaultTarget = @ProjectTargets()
          Else
            ProjectTargets()\IsDefault = 0
            
            ; Set the first found target as the default
            ForEach ProjectTargets()
              If @ProjectTargets() <> *Current
                ProjectTargets()\IsDefault = 1
                *DefaultTarget = @ProjectTargets()
                Break
              EndIf
            Next ProjectTargets()
          EndIf
        Else
          ProjectTargets()\IsDefault = 1
          *DefaultTarget = *Current
          
          ForEach ProjectTargets()
            If @ProjectTargets() <> *Current
              ProjectTargets()\IsDefault = 0
            EndIf
          Next ProjectTargets()
        EndIf
        
        ; Update the icons
        ForEach ProjectTargets()
          SetGadgetItemImage(#GADGET_ProjectInfo_Targets, ListIndex(ProjectTargets()), ProjectTargetImage(@ProjectTargets()))
        Next ProjectTargets()
      EndIf
      
    Case #MENU_ProjectInfo_EnableTarget
      index = GetGadgetState(#GADGET_ProjectInfo_Targets)
      If index <> -1 And SelectElement(ProjectTargets(), index)
        If ProjectTargets()\IsEnabled
          ProjectTargets()\IsEnabled = 0
        Else
          ProjectTargets()\IsEnabled = 1
        EndIf
        SetGadgetItemImage(#GADGET_ProjectInfo_Targets, index, ProjectTargetImage(@ProjectTargets()))
      EndIf
      
      ; Enter handling in Scintilla (and other places) via global shortcut
      ; For linux this is done via ScintillaShortcutHandler()
      CompilerIf #CompileWindows | #CompileMac
        
      Case #MENU_Scintilla_Enter
        If AutoCompleteWindowOpen And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Return    ; special handling when enter is used here
          AutoComplete_Insert()
          
        ElseIf GetFocusGadgetID(#WINDOW_Main) = GadgetID(*ActiveSource\EditorGadget)
          If AutoCompleteKeywordInserted And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Return
            AutoComplete_InsertEndKEyword()
          Else
            SendEditorMessage(#SCI_NEWLINE, 0, 0)
          EndIf
          
        ; See ProjectInfo_EnterKeyHandler() in ProjectManagement.pb for Linux specific handling of this
        ElseIf IsProject And (GetFocusGadgetID(#WINDOW_Main) = GadgetID(#GADGET_ProjectInfo_Files))
          PostEvent(#PB_Event_Gadget, #WINDOW_Main, #GADGET_ProjectInfo_Files, #PB_EventType_LeftDoubleClick)
          
        ElseIf IsProject And (GetFocusGadgetID(#WINDOW_Main) = GadgetID(#GADGET_ProjectInfo_Targets))
          PostEvent(#PB_Event_Gadget, #WINDOW_Main, #GADGET_ProjectInfo_Targets, #PB_EventType_LeftDoubleClick)
          
        Else
          CompilerIf #CompileWindows
            SendMessage_(GetFocus_(), #WM_KEYDOWN, #VK_RETURN, 0) ; for the label editing in Templates for example
            SendMessage_(GetFocus_(), #WM_KEYUP, #VK_RETURN, 0)
          CompilerEndIf
          
        EndIf
        
      Case #MENU_Scintilla_Tab
        If AutoCompleteWindowOpen And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Tab ; special handling when tab is used
          AutoComplete_Insert()
          
        ElseIf GetFocusGadgetID(#WINDOW_Main) = GadgetID(*ActiveSource\EditorGadget)
          If AutoCompleteKeywordInserted And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Tab
            AutoComplete_InsertEndKEyword()
          Else
            GetSelection(@LineStart, 0, @LineEnd, 0)
            If LineStart = LineEnd ; normal tab
              SendEditorMessage(#SCI_TAB, 0, 0)
            Else
              InsertTab()
            EndIf
          EndIf
        
        ElseIf IsProject And (GetFocusGadgetID(#WINDOW_Main) = GadgetID(#GADGET_ProjectInfo_Files))
          EnsureListIconSelection(#GADGET_ProjectInfo_Targets)
          SetActiveGadget(#GADGET_ProjectInfo_Targets)
        ElseIf IsProject And (*ActiveSource = *ProjectInfo)
          EnsureListIconSelection(#GADGET_ProjectInfo_Files)
          SetActiveGadget(#GADGET_ProjectInfo_Files)

          
        EndIf
        
      Case #MENU_Scintilla_ShiftTab
        If GetFocusGadgetID(#WINDOW_Main) = GadgetID(*ActiveSource\EditorGadget)
          GetSelection(@LineStart, 0, @LineEnd, 0)
          If LineStart = LineEnd ; normal tab
            SendEditorMessage(#SCI_BACKTAB, 0, 0)
          Else
            RemoveTab()
          EndIf
        
        ElseIf IsProject And (GetFocusGadgetID(#WINDOW_Main) = GadgetID(#GADGET_ProjectInfo_Files))
          EnsureListIconSelection(#GADGET_ProjectInfo_Targets)
          SetActiveGadget(#GADGET_ProjectInfo_Targets)
        ElseIf IsProject And (*ActiveSource = *ProjectInfo)
          EnsureListIconSelection(#GADGET_ProjectInfo_Files)
          SetActiveGadget(#GADGET_ProjectInfo_Files)
        
        EndIf
        
      CompilerEndIf
      
      ;
      ; for the template tool
      ;
    Case #MENU_Template_Use:       TemplatePlugin\EventHandler(#GADGET_Template_Use)
    Case #MENU_Template_New:       TemplatePlugin\EventHandler(#GADGET_Template_Add)
    Case #MENU_Template_Edit:      TemplatePlugin\EventHandler(#GADGET_Template_Edit)
    Case #MENU_Template_Remove:    TemplatePlugin\EventHandler(#GADGET_Template_Remove)
    Case #MENU_Template_NewDir:    TemplatePlugin\EventHandler(#GADGET_Template_AddDir)
    Case #MENU_Template_RemoveDir: TemplatePlugin\EventHandler(#GADGET_Template_RemoveDir)
    Case #MENU_Template_Rename:    TemplatePlugin\EventHandler(#GADGET_Template_Rename)
    Case #MENU_Template_Up:        TemplatePlugin\EventHandler(#GADGET_Template_Up)
    Case #MENU_Template_Down:      TemplatePlugin\EventHandler(#GADGET_Template_Down)
      
      
      ;
      ; for ProjectPanel tool
      ;
    Case #MENU_ProjectPanel_Open To #MENU_ProjectPanel_Remove
      ProjectPanelMenuEvent(MenuItemID)
      
      
      CompilerIf #CompileMacCocoa
        
      Case #MENU_AutocompleteUp
        AutoComplete_ChangeSelectedItem(0) ; Up
        
      Case #MENU_AutocompleteDown
        AutoComplete_ChangeSelectedItem(1) ; Down
        
      Case #MENU_AutocompleteEscape
        AutoComplete_Close()
        
      CompilerEndIf
      
      
      CompilerIf #DEBUG
        
      Case #MENU_Debugging
        OpenDebuggingWindow() ; our special debug window
        
      CompilerEndIf
      
    Default
      If MenuItemID >= #MENU_RecentFiles_Start And MenuItemID <= #MENU_RecentFiles_End
        RecentFiles_Open(MenuItemID)
        
      ElseIf MenuItemID >= #MENU_AddTools_Start And MenuItemID <= #MENU_AddTools_End
        AddTools_Execute(#TRIGGER_Menu, MenuItemID)
        
      ElseIf MenuItemID >= #MENU_AddHelpFiles_Start And MenuItemID <= #MENU_AddHelpFiles_End
        AddHelpFiles_Display(MenuItemID)
        
      ElseIf MenuItemID >= #MENU_FirstOpenFile
        Index = EventMenu() - #MENU_FirstOpenFile
        SelectElement(FileList(), Index)
        ChangeActiveSourcecode()
        
      EndIf
      
  EndSelect
  
  ProcedureReturn Quit
EndProcedure


Procedure UpdateSourceContainer()
  
  EditWidth  = GadgetWidth(#GADGET_SourceContainer)
  EditHeight = GadgetHeight(#GADGET_SourceContainer)
  
  ResizeGadget(#GADGET_FilesPanel, 0, 0, EditWidth, #PB_Ignore)
  UpdateTabBarGadget(#GADGET_FilesPanel)
  PanelTabHeight = GadgetHeight(#GADGET_FilesPanel)
  
  If *ActiveSource ; Check if a source is opened!
    If *ActiveSource = *ProjectInfo
      ResizeGadget(#GADGET_ProjectInfo, 0, PanelTabHeight, EditWidth, EditHeight-PanelTabHeight)
      ResizeProjectInfo(EditWidth, EditHeight-PanelTabHeight)
    Else
      If *ActiveSource\IsForm <> 0
        ResizeGadget(#GADGET_Form, 0, PanelTabHeight, EditWidth, EditHeight-PanelTabHeight)
        ResizeFormInfo(EditWidth, EditHeight-PanelTabHeight)
      EndIf
      
      ResizeEditorGadget(*ActiveSource\EditorGadget, 0, PanelTabHeight, EditWidth, EditHeight-PanelTabHeight)
    EndIf
  EndIf
EndProcedure


Procedure MainWindowEvents(EventID)
  Quit = 0
  
  If EventID = #PB_Event_ActivateWindow
    If GetActiveWindow() = #WINDOW_Main  ; check if it still got the focus and it is not just a delayed focus event!
      If *ActiveSource And *ActiveSource <> *ProjectInfo And *ActiveSource\IsForm = 0
        SetActiveGadget(*ActiveSource\EditorGadget) ; Always give back the focus to the editor when the window gets activated
      EndIf
      FileMonitorEvent()
    EndIf
    
  ElseIf EventID = #PB_Event_CloseWindow
    Quit = CheckAllSourcesSaved()
    
  ElseIf EventID = #PB_Event_GadgetDrop
    
    Select EventGadget()
        
      Case #GADGET_Template_Tree
        Template_DropEvent()
        
      Case #GADGET_Explorer_Favorites
        Explorer_FavoritesDropEvent()
        
      Default
        ; We stay with WM_DROPFILES for Windows, as somehow PB's own D+D stuff is
        ; not working right as Scintilla has its own D+D handling...
        ;
        CompilerIf #CompileWindows = 0
          
          ; No #Gadget check, as this is set for all scintilla gadgets
          ;
          If EventDropType() = #PB_Drop_Files And EventDropAction() = #PB_Drag_Copy
            Files$ = EventDropFiles()
            If Files$ <> ""
              
              count = CountString(Files$, Chr(10)) + 1
              For i = 1 To count
                File$ = StringField(Files$, i, Chr(10))
                
                If FileSize(File$) >= 0 ; filter out directories (which can appear in the list)
                  LoadSourceFile(File$)
                  
                  ; Flush events. So when many sources are opened at once, the User can see a bit the
                  ; progress, instead of just an unresponsive window for quite a while.
                  ; There is almost no flicker anymore, so it actually looks quite good.
                  ;
                  ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
                  FlushEvents()
                EndIf
              Next i
              
            EndIf
          EndIf
          
        CompilerEndIf
        
        
    EndSelect
    
    
  ElseIf EventID = #PB_Event_Timer
    Select EventTimer()
        
      Case #TIMER_FileMonitor
        If GetActiveWindow() = #WINDOW_Main
          ; only fire the event when the main window has the focus
          FileMonitorEvent()
        EndIf
        
      Case #TIMER_History
        HistoryTimer()
        
      Case #TIMER_DebuggerProcessing
        If ListSize(RunningDebuggers()) > 0 Or StandaloneDebuggers_IsRunning()
          ProcessDebuggerEvent()
        Else
          Debug "[Remove debug timer]"
          RemoveWindowTimer(#WINDOW_Main, #TIMER_DebuggerProcessing) ; remove the timer to save some CPU time on OS X
          IsDebuggerTimer = 0
        EndIf
        
      Case #TIMER_UpdateCheck
        UpdateCheckTimer()
        
      Case #TIMER_ToolPanelAutoHide
        ToolsPanel_CheckAutoHide()
        
    EndSelect
    
    ;- Gadget Events
  ElseIf EventID = #PB_Event_Gadget
    EventGadgetID = EventGadget()
    Select EventGadgetID
        
      Case #GADGET_ToolsSplitter ; Resize current ToolsPanel Item
        If ToolsPanelVisible And CurrentTool
          CurrentTool\ResizeHandler(GetPanelWidth(#GADGET_ToolsPanel), GetPanelHeight(#GADGET_ToolsPanel))
        EndIf
        
        If ErrorLogVisible = 0
          UpdateSourceContainer()
        EndIf
        
      Case #GADGET_LogSplitter
        If ErrorLogVisible
          UpdateSourceContainer()
        EndIf
        
      Case #GADGET_FilesPanel
        Select EventType()
          Case #PB_EventType_RightClick
            ; special handler for right-click event
            
            ; find the hovered and select it
            *TabBarGadget.TabBarGadget = GetGadgetData(#GADGET_FilesPanel)
            
            If *TabBarGadget\HoverItem And *TabBarGadget\HoverItem <> *TabBarGadget\NewTabItem
              
              ; change active source if it does not match the hover item
              ChangeCurrentElement(*TabBarGadget\Item(), *TabBarGadget\HoverItem)
              TabIndex = ListIndex(*TabBarGadget\Item())
              
              If TabIndex <> ListIndex(FileList())
                SelectElement(FileList(), TabIndex)
                ChangeActiveSourcecode()
                UpdateTabBarGadget(#GADGET_FilesPanel) ; force a redraw
              EndIf
              
              ; Disable some items in the popupmenu if needed
              ;
              Disabled = #True
              If IsProject And *ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile = #False ; File not in the project
                Disabled = #False
              EndIf
              DisableMenuItem(#POPUPMENU_TabBar, #MENU_AddProjectFile, Disabled)
              
              Disabled = #True
              If IsProject And *ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile ; File already in the project
                Disabled = #False
              EndIf
              DisableMenuItem(#POPUPMENU_TabBar, #MENU_RemoveProjectFile, Disabled)
              
              ; Disable the Save items if project info tab
              DisableMenuItem(#POPUPMENU_TabBar, #MENU_Save, Bool(*ActiveSource = *ProjectInfo))
              DisableMenuItem(#POPUPMENU_TabBar, #MENU_SaveAs, Bool(*ActiveSource = *ProjectInfo))
              
              ; Disable the Reload item if new source, project info tab, or form
              DisableMenuItem(#POPUPMENU_TabBar, #MENU_Reload, Bool( (*ActiveSource\FileName$ = "") Or (*ActiveSource = *ProjectInfo) Or (*ActiveSource\IsForm) ))
              
              Disabled = #True
              If *ActiveSource = *ProjectInfo Or *ActiveSource\FileName$
                Disabled = #False
              EndIf
              DisableMenuItem(#POPUPMENU_TabBar, #MENU_ShowInFolder, Disabled)
              
              ; Display the TabBar popup menu
              DisplayPopupMenu(#POPUPMENU_TabBar, WindowID(#WINDOW_Main))
              
            EndIf
            
            ChangeCurrentElement(*TabBarGadget\Item(), *TabBarGadget\SelectedItem)
            
          Case #TabBarGadget_EventType_NewItem
            NewSource("", #True)
            HistoryEvent(*ActiveSource, #HISTORY_Create)
            
          Case #TabBarGadget_EventType_CloseItem
            Index = GetTabBarGadgetItemPosition(#GADGET_FilesPanel, #TabBarGadgetItem_Event)
            PushListPosition(FileList())
            *Source = SelectElement(FileList(), Index)
            PopListPosition(FileList())
            If *Source = *ProjectInfo
              ; ask to avoid accidental clicks on the close button
              If MessageRequester(#ProductName$, Language("Project","ReallyClose"), #PB_MessageRequester_YesNo|#FLAG_Question) = #PB_MessageRequester_Yes
                CloseProject()
              EndIf
            Else
              If CheckSourceSaved(*Source) = 1  ; -1 means user abort, 0=error
                RemoveSource(*Source)
              EndIf
            EndIf
            
          Case #TabBarGadget_EventType_Change
            SelectElement(FileList(), GetTabBarGadgetItemPosition(#GADGET_FilesPanel, #TabBarGadgetItem_Event))
            ChangeActiveSourcecode()
            
          Case #TabBarGadget_EventType_SwapItem
            ; when swapping a form tab, it seems the FileList() position is sometimes wrong
            ; and end up swapping the wrong content to a new position - dirty fix but it works.
            If *ActiveSource <> FileList()
              ChangeCurrentElement(FileList(), *ActiveSource)
            EndIf
            
            OldIndex = ListIndex(FileList())
            NewIndex = GetTabBarGadgetItemPosition(#GADGET_FilesPanel, #TabBarGadgetItem_Event)
            If OldIndex > NewIndex
              PushListPosition(FileList())
              *Other = SelectElement(FileList(), NewIndex)
              PopListPosition(FileList())
              MoveElement(FileList(), #PB_List_Before, *Other)
            ElseIf OldIndex < NewIndex
              PushListPosition(FileList())
              *Other = SelectElement(FileList(), NewIndex)
              PopListPosition(FileList())
              MoveElement(FileList(), #PB_List_After, *Other)
            EndIf
            
          Case #TabBarGadget_EventType_PopupButton
            ; clear any menu from a previous time
            If IsMenu(#POPUPMENU_FilesPanel)
              FreeMenu(#POPUPMENU_FilesPanel)
            EndIf
            
            CreatePopupMenu(#POPUPMENU_FilesPanel)
            ForEach FileList()
              MenuItem(#MENU_FirstOpenFile + ListIndex(FileList()), GetSourceTitle(@FileList()))
            Next FileList()
            DisplayPopupMenu(#POPUPMENU_FilesPanel, WindowID(#WINDOW_Main))
            
          Case #TabBarGadget_EventType_Resize
            ResizeMainWindow()
            
        EndSelect
        
      Case #GADGET_ToolsPanel ; set new current ToolsPanel tool and resize it
        If ToolsPanelMode And GetGadgetState(#GADGET_ToolsPanel) >= 0
          SelectElement(UsedPanelTools(), GetGadgetState(#GADGET_ToolsPanel))
          CurrentTool = UsedPanelTools()
          CurrentTool\ResizeHandler(GetPanelWidth(#GADGET_ToolsPanel), GetPanelHeight(#GADGET_ToolsPanel))
        EndIf
        
      Case #GADGET_ErrorLog
        If EventType() = #PB_EventType_RightClick
          ; show the error log specific popup menu
          If EnableMenuIcons
            CreatePopupImageMenu(#POPUPMENU_ErrorLog)
          Else
            CreatePopupMenu(#POPUPMENU_ErrorLog)
          EndIf
          ShortcutMenuItem(#MENU_ClearLog, Language("MenuItem", "ClearLog"))
          ShortcutMenuItem(#MENU_CopyLog, Language("MenuItem", "CopyLog"))
          MenuBar()
          ShortcutMenuItem(#MENU_ClearErrorMarks, Language("MenuItem","ClearErrorMarks"))
          
          DisplayPopupMenu(#POPUPMENU_ErrorLog, WindowID(#WINDOW_Main))
        EndIf
        
      Case #GADGET_ProjectInfo_Files
        index = GetGadgetState(#GADGET_ProjectInfo_Files)
        Select EventType()
            
          Case #PB_EventType_DragStart
            If index <> -1 And SelectElement(ProjectFiles(), index)
              DragFiles(ProjectFiles()\Filename$)
            EndIf
            
          Case #PB_EventType_LeftDoubleClick
            If index <> -1 And SelectElement(ProjectFiles(), index)
              LoadSourceFile(ProjectFiles()\Filename$) ; will just switch if open
            EndIf
            
          Case #PB_EventType_RightClick
            DisplayProjectPanelMenu(0, #GADGET_ProjectInfo_Files) ; shared with ProjectPanel menu
            
        EndSelect
        
        
      Case #GADGET_ProjectInfo_Targets
        index = GetGadgetState(#GADGET_ProjectInfo_Targets)
        Select EventType()
            
          Case #PB_EventType_LeftDoubleClick
            If index <> -1 And SelectElement(ProjectTargets(), index)
              OpenOptionWindow(#True, @ProjectTargets())
            EndIf
            
          Case #PB_EventType_RightClick
            If IsWindow(#WINDOW_Option) = 0 ; no menu when the options are open
              If index <> -1 And SelectElement(ProjectTargets(), index)
                SetMenuItemState(#POPUPMENU_Targets, #MENU_ProjectInfo_DefaultTarget, ProjectTargets()\IsDefault)
                SetMenuItemState(#POPUPMENU_Targets, #MENU_ProjectInfo_EnableTarget, ProjectTargets()\IsEnabled)
                DisplayPopupMenu(#POPUPMENU_Targets, WindowID(#WINDOW_Main))
              EndIf
            Else
              SetWindowForeground(#WINDOW_Option)
            EndIf
            
        EndSelect
        
      Case #GADGET_ProjectInfo_OpenOptions
        OpenProjectOptions(#False) ; no new project
        
      Case #GADGET_ProjectInfo_OpenCompilerOptions
        OpenOptionWindow(#True)
        
      Default ; unknown gadget .. pass to active ToolsPanel item..
        
        ; Detect right click on scintilla gadget
        If *ActiveSource And EventGadget() = *ActiveSource\EditorGadget And EventType() = #PB_EventType_RightClick
          DisplayPopupMenu(#POPUPMENU, WindowID(#WINDOW_Main))
        EndIf
        
        
        If CurrentTool
          CurrentTool\EventHandler(EventGadgetID)
        EndIf
    EndSelect
    
  ElseIf EventID = #PB_Event_Menu
    Quit = MainMenuEvent(EventMenu())
    
  ElseIf EventID = #PB_Event_SizeWindow
    ResizeMainWindow()
    
  ElseIf EventID = #PB_Event_MoveWindow
    If IsWindowMaximized(#WINDOW_Main) = 0 And IsWindowMinimized(#WINDOW_Main) = 0
      Save_EditorX = WindowX(#WINDOW_Main)
      Save_EditorY = WindowY(#WINDOW_Main)
    EndIf
    
  EndIf
  
  ProcedureReturn Quit
EndProcedure


Procedure ResizeMainWindow()
  EditorWindowWidth  = WindowWidth(#WINDOW_Main)   ; update the global variables to speed up things like splitter movement
  EditorWindowHeight = WindowHeight(#WINDOW_Main)
  
  If IsWindowMaximized(#WINDOW_Main) = 0 And IsWindowMinimized(#WINDOW_Main) = 0
    Save_EditorX = WindowX(#WINDOW_Main)
    Save_EditorY = WindowY(#WINDOW_Main)
    Save_EditorWidth = EditorWindowWidth
    Save_EditorHeight = EditorWindowHeight
  EndIf
  
  If ShowMainToolbar
    EditTop = ToolbarTopOffset
    CompilerIf #CompileLinux
      ; On linux the toolbar can accept any sized icon, so use a dynamic height (https://www.purebasic.fr/english/viewtopic.php?f=23&t=48951)
      EditHeight = EditorWindowHeight - ToolBarHeight(#TOOLBAR) - StatusbarHeight - MenuHeight
    CompilerElse
      EditHeight = EditorWindowHeight - ToolbarHeight - StatusbarHeight - MenuHeight
    CompilerEndIf
  Else
    EditTop = 0
    EditHeight = EditorWindowHeight - StatusbarHeight - MenuHeight
  EndIf
  
  PanelTabHeight = GadgetHeight(#GADGET_FilesPanel)
  
  CompilerIf #CompileMacCocoa
    EditHeight - 9
  CompilerEndIf
  
  If ToolsPanelMode = 0 ; no toolspanel
    EditWidth = EditorWindowWidth
    EditLeft = 0
    
  ElseIf ToolsPanelAutoHide And ToolsPanelVisible = 0 ; toolspanel existing, but hidden
    EditWidth = EditorWindowWidth - ToolsPanelHiddenWidth
    
    CompilerIf #CompileLinux
      ; On linux, we have a nice vertical panel As well here...
      If ToolsPanelSide = 0  ; ToolsPanel on right side
        EditLeft = 0
        ResizeGadget(#GADGET_ToolsPanelFake, EditWidth-1, EditTop+PanelTabHeight, ToolsPanelHiddenWidth, EditHeight-PanelTabHeight)
      Else
        EditLeft = ToolsPanelHiddenWidth
        ResizeGadget(#GADGET_ToolsPanelFake, 3, EditTop+PanelTabHeight, ToolsPanelHiddenWidth, EditHeight-PanelTabHeight)
      EndIf
      
    CompilerElse
      
      CompilerIf #CompileWindows
        ; on windows we have a special replacement for the hidden panel (= vertical tab)
        ; which does not work on XP
        If FakeToolsPanelID
          If ToolsPanelSide = 0  ; ToolsPanel on right side
            EditLeft = 0
            ResizeGadget(#GADGET_ToolsPanelFake, EditWidth+1, EditTop+PanelTabHeight, 22, EditHeight-PanelTabHeight)
          Else
            EditLeft = ToolsPanelHiddenWidth - 1
            ResizeGadget(#GADGET_ToolsPanelFake, 3, EditTop+PanelTabHeight, 22, EditHeight-PanelTabHeight)
          EndIf
          MoveWindow_(FakeToolsPanelID, 0, 0, 22, EditHeight, 1)
        Else
          
        CompilerEndIf
        
        If ErrorLogVisible
          ImageTop = EditTop+(EditHeight-ErrorLogHeight-16)/2
        Else
          ImageTop = EditTop+(EditHeight-16)/2
        EndIf
        
        If ToolsPanelSide = 0  ; ToolsPanel on right side
          EditLeft = 0
          ResizeGadget(#GADGET_ToolsPanelFake, EditWidth+1, ImageTop, 16, 16)
        Else
          EditLeft = ToolsPanelHiddenWidth + 2
          ResizeGadget(#GADGET_ToolsPanelFake, 1, ImageTop, 16, 16)
        EndIf
        
        CompilerIf #CompileWindows
        EndIf
      CompilerEndIf
      
    CompilerEndIf
    
  Else
    EditWidth = EditorWindowWidth ; if the toolspanel is present, it is in the splitter
    EditLeft = 0
    
  EndIf
  
  CompilerIf #CompileLinux
    EditLeft + 2
    EditWidth - 4 ; on linux this looks a bit better
  CompilerEndIf
  
  ; resize the right splitter/container
  ; everything else is resized as a response to the events from this
  ;
  If ToolsPanelVisible
    ResizeGadget(#GADGET_ToolsSplitter, EditLeft, EditTop, EditWidth, EditHeight)
  ElseIf ErrorLogVisible
    ResizeGadget(#GADGET_LogSplitter, EditLeft, EditTop, EditWidth, EditHeight)
  Else
    ResizeGadget(#GADGET_SourceContainer, EditLeft, EditTop, EditWidth, EditHeight)
  EndIf
  
  ; Update the tool size in realtime as well
  If ToolsPanelVisible And CurrentTool
    CurrentTool\ResizeHandler(GetPanelWidth(#GADGET_ToolsPanel), GetPanelHeight(#GADGET_ToolsPanel))
  EndIf
  
  UpdateSourceContainer()
  
EndProcedure


; Update the main window after a preferences change
;
Procedure UpdateMainWindow()
  
  CompilerIf #CompileMac
    If OSVersion() >= #PB_OS_MacOSX_10_14
      ; Update DarkMode
      UpdateAppearance()
    EndIf
  CompilerEndIf
  
  ToolsPanel_Update()
  
  ToolsPanel_ApplyColors(#GADGET_ErrorLog)
  
  ; update the files panel
  ; always re-create the newTab to update any theme changes
  ;
  RemoveTabBarGadgetItem(#GADGET_FilesPanel, #TabBarGadgetItem_NewTab)
  If FilesPanelNewButton
    AddTabBarGadgetItem(#GADGET_FilesPanel, #TabBarGadgetItem_NewTab, "", ImageID(#IMAGE_FilePanel_New))
  EndIf
  SetTabBarGadgetAttribute(#GADGET_FilesPanel, #TabBarGadget_MultiLine, FilesPanelMultiline)
  SetTabBarGadgetAttribute(#GADGET_FilesPanel, #TabBarGadget_PopupButton, 1-FilesPanelMultiline)
  SetTabBarGadgetAttribute(#GADGET_FilesPanel, #TabBarGadget_CloseButton, FilesPanelCloseButtons)
  
  ; update current source stuff:
  ;
  ChangeActiveSourcecode()     ; updates linenumbers and stuff
  ChangeStatus("", -1)         ; clear the message field (-1 forces an update, even if a sticky string is present)
  
  ; update gadget sizes
  ;
  ResizeMainWindow()
  
EndProcedure

; This procedure is called in all places where there is an event loop
; in-between the calls to (Wait)WindowEvent(). This can be used to check
; on some special event conditions and react
;
Procedure EventLoopCallback()
  
  ; See the main ScintillaCallback with #SCN_DOUBLECLICK for the cause of this
  CompilerIf #CompileLinux = 0
    If CtrlDoubleClickHappened
      CtrlDoubleClickHappened = #False
      
      Word$ = LCase(GetCurrentWord())
      If Word$ = "includefile" Or Word$ = "xincludefile" Or Word$ = "includebinary"
        OpenIncludeOnDoubleClick()
      Else
        ; On Mac, Ctrl+Click is a right-click, so it opens the context menu
        ; So use the Command key instead here
        ; (On other OS, Command just maps to Control)
        If ModifierKeyPressed(#PB_Shortcut_Command)
          CompilerIf #CompileWindows
            SendMessage_(GadgetID(*ActiveSource\EditorGadget), #WM_LBUTTONUP, 0, 0) ; simulate a mouseup to fix the ugly selection problem (https://www.purebasic.fr/english/viewtopic.php?f=4&t=50135)
          CompilerEndIf
          
          JumpToProcedure()
        EndIf
      EndIf
    EndIf
  CompilerEndIf
  
EndProcedure

; Processes all events.
; Moved into a procedure, so it can be called from the FlushEvents() too, so no events are lost.
;
Procedure DispatchEvent(EventID)
  
  CompilerIf #PB_Compiler_Debugger
    If InDebuggerCallback
      Debug "DispatchEvent() can't be call inside the debugger callback !"
      CallDebugger
    EndIf
  CompilerEndIf
  
  
  If EventID = 0
    ProcedureReturn 0
  EndIf
  
  ; Handle the RunOnce message here as it is posted to the queue
  CompilerIf #CompileWindows
    If EventID = RunOnceMessageID And EventWindow() = #WINDOW_Main
      CompilerIf #DEBUG
        ID = EventwParam()
        Debug "[RunOnceMessage received] Code = '" + PeekS(@ID, 4, #PB_Ascii) + "', Window = " + Hex(EventlParam())
      CompilerEndIf
      
      If EventwParam() = AsciiConst('F', 'I', 'N', 'D')
        PostMessage_(EventlParam(), RunOnceMessageID, AsciiConst('H', 'W', 'N', 'D'), WindowID(#WINDOW_Main))
        
      ElseIf EventwParam() = AsciiConst('O', 'P', 'E', 'N') And Editor_RunOnce
        ; to this one we only answer when RunOnce is enabled
        ; This way non-runonce instances are not affected
        ; The data is actually sent after this with WM_COPYDATA (see Window callback)
        PostMessage_(EventlParam(), RunOnceMessageID, AsciiConst('H', 'W', 'N', 'D'), WindowID(#WINDOW_Main))
      EndIf
      ProcedureReturn 1
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileMac
    ; The focus callback is a mess on OS X, so do it the 'easy' way (may be we can do that on every OSes).
    ;
    If EventID = #PB_Event_ActivateWindow
      If AutoCompleteWindowOpen And EventWindow() <> #WINDOW_AutoComplete
        AutoComplete_Close()
      EndIf
    EndIf
    
    ; On MacOS X, the quit can be invoked from the dock for example, so there will be no current window
    ;
    If EventID = #PB_Event_Menu And EventMenu() = #MENU_Exit
      QuitIDE = MainWindowEvents(EventID)
    Else
    CompilerEndIf
    
    ;   If EventID <> 4 And EventID <> -1
    ;   ;  Debug "Event: "+Str(EventID)+"   Window: " + Str(EventWindow())
    ;   EndIf
    
    ; Form events - this is not in the main window event procedure as it handles the grid events as well
    ; it also handles the specific menu events related to form popups
    FD_Event(EventID, EventGadget(), EventType())
    
    Select EventWindow()
        
      Case #WINDOW_Main
        QuitIDE = MainWindowEvents(EventID)
        
      Case #WINDOW_About
        AboutWindowEvents(EventID)
        
      Case #WINDOW_Preferences
        PreferencesWindowEvents(EventID)
        
      Case #WINDOW_FileViewer
        FileViewerWindowEvents(EventID)
        
      Case #WINDOW_Goto
        GotoWindowEvents(EventID)
        
      Case #WINDOW_Find
        FindWindowEvents(EventID)
        
      Case #WINDOW_StructureViewer
        StructureViewerWindowEvents(EventID)
        
      Case #WINDOW_Grep
        GrepWindowEvents(EventID)
        
      Case #WINDOW_GrepOutput
        GrepOutputWindowEvents(EventID)
        
      Case #WINDOW_Option
        OptionWindowEvents(EventID)
        
        CompilerIf #SpiderBasic
        Case #WINDOW_CreateApp
          CreateAppWindowEvents(EventID)
        CompilerEndIf
        
      Case #WINDOW_AddTools
        AddTools_WindowEvents(EventID)
        
      Case #WINDOW_EditTools
        AddTools_EditWindowEvents(EventID)
        
      Case #WINDOW_AutoComplete
        AutoCompleteWindowEvents(EventID)
        
      Case #WINDOW_Template
        TemplateWindowEvents(EventID)
        
      Case #WINDOW_MacroError
        MacroErrorWindowEvents(EventID)
        
      Case #WINDOW_Warnings
        WarningWindowEvents(EventID)
        
      Case #WINDOW_Compiler
        CompilerWindowEvents(EventID)
        
      Case #WINDOW_ProjectOptions
        ProjectOptionsEvents(EventID)
        
      Case #WINDOW_Build
        BuildWindowEvents(EventID)
        
      Case #WINDOW_Diff
        DiffWindowEvents(EventID)
        
      Case #WINDOW_DiffDialog
        DiffDialogWindowEvents(EventID)
        
      Case #WINDOW_FileMonitor
        FileMonitorWindowEvents(EventID)
        
      Case #Form_ImgList
        FormImgListWindowEvents(EventID)
        
      Case #Form_Columns
        FormColumnsWindowEvents(EventID)
        
      Case #Form_Items
        FormItemsWindowEvents(EventID)
        
      Case #WINDOW_Form_Parent
        FD_EventSelectParent(EventID)
        
      Case #WINDOW_EditHistory
        EditHistoryWindowEvent(EventID)
        
      Case #WINDOW_Updates
        UpdateWindowEvents(EventID)
        
        CompilerIf #CompileLinux | #CompileMac
          
        Case #WINDOW_Help
          HelpWindowEvents(EventID)
          
        CompilerEndIf
        
        CompilerIf #DEBUG
          
        Case #WINDOW_Debugging
          DebuggingWindowEvents(EventID)
          
        CompilerEndIf
        
      Default
        ; check debugger events
        ;
        If Debugger_ProcessShortcuts(EventWindow(), EventID) = 0 ; ide debugger
          If Debugger_ProcessEvents(EventWindow(), EventID) = 0  ; 0 means unhandled (debugger general function)
            
            ; check ToolsPanel tools in separate windows
            ;
            ForEach AvailablePanelTools()
              If AvailablePanelTools()\IsSeparateWindow And AvailablePanelTools()\ToolWindowID = EventWindow()
                If EventID = #PB_Event_CloseWindow
                  
                  If AvailablePanelTools()\NeedDestroyFunction
                    Tool.ToolsPanelInterface = @AvailablePanelTools()
                    Tool\DestroyFunction()
                  EndIf
                  
                  If MemorizeWindow
                    Window = AvailablePanelTools()\ToolWindowID
                    If IsWindowMinimized(Window) = 0
                      AvailablePanelTools()\ToolWindowX      = WindowX(Window)
                      AvailablePanelTools()\ToolWindowY      = WindowY(Window)
                      AvailablePanelTools()\ToolWindowWidth  = WindowWidth(Window)
                      AvailablePanelTools()\ToolWindowHeight = WindowHeight(Window)
                    EndIf
                  EndIf
                  CloseWindow(AvailablePanelTools()\ToolWindowID)
                  AvailablePanelTools()\ToolWindowID = -1
                  AvailablePanelTools()\IsSeparateWindow = 0
                  
                ElseIf EventID = #PB_Event_Gadget
                  If #DEFAULT_CanWindowStayOnTop And EventGadget() = AvailablePanelTools()\ToolStayOnTop
                    AvailablePanelTools()\IsToolStayOnTop = GetGadgetState(AvailablePanelTools()\ToolStayOnTop)
                    SetWindowStayOnTop(AvailablePanelTools()\ToolWindowID, AvailablePanelTools()\IsToolStayOnTop)
                  Else
                    Tool.ToolsPanelInterface = @AvailablePanelTools()
                    Tool\EventHandler(EventGadget())
                  EndIf
                  
                  ; menu events in a separate toolspanel item are treated as main window events,
                  ; same as when they are integrated in the sidepanel
                  ; same for drag & drop events
                ElseIf EventID = #PB_Event_Menu Or EventID = #PB_Event_GadgetDrop
                  MainWindowEvents(EventID)
                  
                ElseIf EventID = #PB_Event_SizeWindow
                  ResizeTools()
                  
                ElseIf EventID = #PB_Event_GadgetDrop
                  ; special case for the Templates D+D
                  If EventGadget() = #GADGET_Template_Tree
                    Template_DropEvent()
                  EndIf
                  
                EndIf
                
                Break
              EndIf
            Next AvailablePanelTools()
            
          EndIf
        EndIf
        
    EndSelect
    
    CompilerIf #CompileMac
    EndIf
  CompilerEndIf
  
  ProcedureReturn EventID ; return the eventid still, to be able to check for 0 events (empty queue)
EndProcedure

; remove all events from the queue.
;
Procedure FlushEvents()
  
  While DispatchEvent(WindowEvent()) ; returns the eventid
    EventLoopCallback()
  Wend
  
EndProcedure


Procedure ErrorLog_Refresh()
  ClearGadgetItems(#GADGET_ErrorLog)
  
  If *ActiveSource
    If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
      
      If ListSize(ProjectLog()) > 0
        ForEach ProjectLog()
          AddGadgetItem(#GADGET_ErrorLog, -1, ProjectLog())
        Next ProjectLog()
        SetGadgetState(#GADGET_ErrorLog, CountGadgetItems(#GADGET_ErrorLog)-1)
      EndIf
      
    Else
      
      If *ActiveSource\LogSize <> 0
        For i = 0 To *ActiveSource\LogSize-1
          AddGadgetItem(#GADGET_ErrorLog, -1, *ActiveSource\LogLines$[i])
        Next i
        SetGadgetState(#GADGET_ErrorLog, CountGadgetItems(#GADGET_ErrorLog)-1)
      EndIf
      
    EndIf
  EndIf
EndProcedure

Procedure ErrorLog_Show()
  If ErrorLogVisible = 0 ; only do this if it is needed ! (problems otherwise)
    
    If ToolsPanelVisible
      ; switch the logsplitter with the source container, so the logsplitter is again in the toolspanel one
      ; if there is no toolspanel, this step is not needed
      ;
      If ToolsPanelSide = 0
        SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget, #GADGET_LogSplitter)
      Else
        SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondGadget, #GADGET_LogSplitter)
      EndIf
    EndIf
    
    ; switch the SourceContainer with the dummy so it is back in the correct splitter
    SetGadgetAttribute(#GADGET_LogSplitter, #PB_Splitter_FirstGadget, #GADGET_SourceContainer)
    
    HideGadget(#GADGET_LogSplitter, 0)
    ErrorLogVisible = 1  ; must be before the resize!
    ResizeMainWindow()   ; resize main window and we are done.
    
    ; restore splitter position
    SetGadgetState(#GADGET_LogSplitter, GadgetHeight(#GADGET_LogSplitter)-ErrorLogHeight_Hidden)
  EndIf
EndProcedure

Procedure ErrorLog_Hide()
  If ErrorLogVisible
    ErrorLogHeight_Hidden = GadgetHeight(#GADGET_LogSplitter) - GetGadgetState(#GADGET_LogSplitter)
    HideGadget(#GADGET_LogSplitter, 1)
    
    ; switch the SourceContainer with the dummy
    SetGadgetAttribute(#GADGET_LogSplitter, #PB_Splitter_FirstGadget, #GADGET_LogDummy)
    
    If ToolsPanelVisible
      ; switch the logsplitter with the source container, so the container is directly in the ToolsSplitter
      ; if there is no toolspanel, the sourcecontainer is already on the main window.
      ;
      If ToolsPanelSide = 0
        SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget, #GADGET_SourceContainer)
      Else
        SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondGadget, #GADGET_SourceContainer)
      EndIf
    EndIf
    
    ErrorLogVisible = 0  ; must be before the resize!
    ResizeMainWindow()   ; resize main window and we are done.
  EndIf
EndProcedure

Procedure ErrorLog_SyncState(DoResize = #True) ; make sure the errorlog reflects the show/hide state of the current source
  If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
    Show = ProjectShowLog
  Else
    Show = *ActiveSource\ErrorLog
  EndIf
  
  If AlwaysHideLog = 0 And Show
    ErrorLog_Show()
    SetMenuItemState(#MENU, #MENU_ShowLog, #True)
  Else
    ErrorLog_Hide()
    SetMenuItemState(#MENU, #MENU_ShowLog, #False)
  EndIf
  UpdateErrorLogMenuState()
  
  If DoResize
    ResizeMainWindow()
  EndIf
EndProcedure

Procedure DisableMenuAndToolbarItem(MenuItemID, State)
  DisableMenuItem(#MENU, MenuItemID, State)
  If *MainToolbar
    DisableToolBarButton(#TOOLBAR, MenuItemID, State)
  EndIf
EndProcedure
