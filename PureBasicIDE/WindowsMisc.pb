; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;windows only
CompilerIf #CompileWindows
  
  #NM_CUSTOMDRAW = #NM_FIRST - 12
  
  #CDDS_ITEM = $10000
  #CDDS_PREPAINT = $1
  #CDDS_ITEMPREPAINT = #CDDS_ITEM | #CDDS_PREPAINT
  #CDRF_DODEFAULT = $0
  #CDRF_NOTIFYITEMDRAW = $20
  
  #ODS_NOACCEL = $100
  
  Prototype GlobalMemoryStatusExPrototype(*MemoryStatus.MEMORYSTATUSEX)
  
  
  Global DebuggerSystemMenu
  
  #ERROR_ALREADY_EXISTS = $B7
  #WM_UNINITMENUPOPUP = $125
  
  Global RunOnceMessageID, RunOnceMutex
  Global AutoCompleteWindowProc
  
  Global SessionMutex
  
  Global StatusbarBoldFontID
  
  Global OSVersion = OSVersion() ; Used to disactivate the ownerdraw menus on NT4
  
  Procedure UpdateRegistryKey(Key, Path$, Value$)
    
    NeedUpdate = 1 ; By default, the key is changed, unless we found exactly the same string
    
    If RegCreateKeyEx_(Key, Path$, 0, #Null$, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
      
      ; Get the current value, and check if we need to update it
      ;
      CurrentValue$ = Space(#MAX_PATH*2) ; Ensure it will be big enough for a path + some infos
      CurrentValueSize = Len(CurrentValue$)*#CharSize
      If RegQueryValueEx_(NewKey, "", 0, @Type, @CurrentValue$, @CurrentValueSize) = #ERROR_SUCCESS
        If Value$ = CurrentValue$
          NeedUpdate = 0
        EndIf
      EndIf
      
      If NeedUpdate
        RegSetValueEx_(NewKey, "", 0, #REG_SZ,  @Value$, (Len(Value$)+1) * #CharSize)
      EndIf
      
      RegCloseKey_(NewKey)
    EndIf
    
    ProcedureReturn NeedUpdate
  EndProcedure
  
  
  Procedure OSStartupCode()
    Shared DontCreateExtensions
    
    ; This creates the mutex, or opens an existing one, which is perfect for us.
    ; The mutex will exist until all programs that called this have ended.
    ; There is no CloseHandle_(), so the mutex stays open until the program ends
    ; (the Global\ part is for Terminal Services only, but ignored else)
    ;
    ; NOTE: Do not use any namespace prefix, although "Global\" would make sense here,
    ;   as \ is an illegal character for the name on NT and Win9x.
    ;
    CreateMutex_(#Null, #False, #ProductName$+"_Running")
    
    LineNumbersCursor = LoadCursor_(0, #IDC_ARROW)
    
    ; Ensure it won't happen in release build !
    CompilerIf #PB_Compiler_Debugger
      
      CompilerIf Defined(FredLocalCompile, #PB_Constant) ; Fred config
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
          CompilerIf #SpiderBasic
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\SpiderBasic_x64\"
          CompilerElse
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\PureBasic_x64\"
          CompilerEndIf
        CompilerElse
          CompilerIf #SpiderBasic
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\SpiderBasic_x86\"
          CompilerElse
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\PureBasic_x86\"
          CompilerEndIf
        CompilerEndIf
      CompilerElse
        PureBasicPath$ = #PB_Compiler_Home
      CompilerEndIf
      
      If FileSize(PureBasicPath$) <> -2
        MessageRequester("RootPath not found", "RootPath '" + PureBasicPath$ + "' not found !", #PB_MessageRequester_Error)
        End
      EndIf
      
      
    CompilerEndIf
    
    
    ; Set the default Path Values
    ;
    If PureBasicPath$ = "" ; Only change if not set by commandline
      PureBasicPath$ = Space(#MAX_PATH)
      GetModuleFileName_(GetModuleHandle_(#Null$), @PureBasicPath$, #MAX_PATH)
      PureBasicPath$ = GetPathPart(PureBasicPath$)
    EndIf
    
    TempPath$        = GetTemporaryDirectory()
    
    If PreferencesFile$ = "" ; Only change if not set by commandline
      PreferencesFile$ = PureBasicConfigPath() + #PreferenceFileName$
    EndIf
    
    If AddToolsFile$ = "" ; Only change if not set by commandline
      AddToolsFile$    = PureBasicConfigPath() + "Tools.prefs"
    EndIf
    
    If TemplatesFile$ = "" ; Only change if not set by commandline
      TemplatesFile$   = PureBasicConfigPath() + "Templates.prefs"
    EndIf
    
    If HistoryDatabaseFile$ = "" ; Only change if not set by commandline
      HistoryDatabaseFile$ = PureBasicConfigPath() + "History.db"
    EndIf
    
    If SourcePathSet = 0 ; Only change if not set by commandline
      
      ; Starting with Windows Vista, we can't write in ProgramFiles anymore, so the examples are copied in the common app user data by the installer.
      ; It's important to point on the examples when the path is not set as when your run PureBasic for the first
      ; time, you want to open examples to test them. This value can be changed in the prefs and won't be
      ; used if another pref is found
      ;
      If SHGetSpecialFolderLocation_(0,  #CSIDL_COMMON_APPDATA, @*pidlMyDocuments) = #S_OK
        SourcePath$ = Space(#MAX_PATH)
        If SHGetPathFromIDList_(*pidlMyDocuments, @SourcePath$)
          SourcePath$ + "\" + #ProductName$ + "\Examples\" ; We be something like: C:\ProgramData\SpiderBasic\Examples
        Else                                               ; Failed
          SourcePath$ = PureBasicPath$
        EndIf
      Else
        SourcePath$ = PureBasicPath$
      EndIf
      
      If Right(SourcePath$, 1) <> #Separator
        SourcePath$ + #Separator
      EndIf
    EndIf
    
    If DontCreateExtensions = 0
      
      ExecutableName$ = GetFilePart(ProgramFilename()) ; PureBasic.exe or SpiderBasic.exe
      
      ; Create .pb, .pbi, .pbp and .pbf association
      ; We include the position of preferences etc in the registry commandline
      ; so switches like /LOCAL will also effect later opened files.
      ;
      CommandLine$ =          Chr(34) + ProgramFilename() + Chr(34)
      CommandLine$ + " "    + Chr(34) + "%1"              + Chr(34)
      CommandLine$ + " /P " + Chr(34) + PreferencesFile$  + Chr(34)
      CommandLine$ + " /T " + Chr(34) + TemplatesFile$    + Chr(34)
      CommandLine$ + " /A " + Chr(34) + AddToolsFile$     + Chr(34)
      CommandLine$ + " /H " + Chr(34) + HistoryDatabaseFile$ + Chr(34)
      
      ; Note: since we now include the /P /A etc into the registry commandline,
      ;   Windows does not seem to correctly display the PB icon for files anymore.
      ;   So we must add this to the registry as well
      ;
      ; The icon is at index 1. It is the PBSourceFile.ico that is added in the
      ; resource script created by makeversion.exe
      ;
      Icon$ = ProgramFilename() + ",1"
      
      ; Vista and newer - only HKEY_CURRENT_USER is allowed!
      ; Now also used on XP, as else if an admin runs the IDE, the user will never be able
      ; to overwrite the admin's setting in HKEY_CLASSES_ROOT!
      If OSVersion() >= #PB_OS_Windows_XP
        
        ; Funny, this is the exact same code as for Win9x, only with
        ; #HKEY_CURRENT_USER instead of #HKEY_LOCA_MACHINE ;)
        ;
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\Classes\" + ExecutableName$ + "\shell\open\command", CommandLine$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\Classes\" + ExecutableName$ + "\DefaultIcon", Icon$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\CLASSES\" + #SourceFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\CLASSES\" + #IncludeFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\CLASSES\" + #ProjectFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\CLASSES\" + #FormFileExtension, ExecutableName$)
        
        ; Until 4.10, XP used the #HKEY_CLASSES_ROOT way like NT below, but this seems
        ; to dominate the new location in #HKEY_CURRENT_USER, so the 4.10 path will dominate
        ; any newer setting. Try to delete these keys
        ;
        If OSVersion() = #PB_OS_Windows_XP
          ; This fails if the key does not exist, and deletes all children if it does exist,
          ; which is perfect for us.
          If SHDeleteKey_(#HKEY_CLASSES_ROOT, "Applications\" + ExecutableName$) = #ERROR_SUCCESS
            NeedUpdate | 1
          EndIf
          If SHDeleteKey_(#HKEY_CLASSES_ROOT, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" + #SourceFileExtension) = #ERROR_SUCCESS
            NeedUpdate | 1
          EndIf
          If SHDeleteKey_(#HKEY_CLASSES_ROOT, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" + #IncludeFileExtension) = #ERROR_SUCCESS
            NeedUpdate | 1
          EndIf
        EndIf
        
      ElseIf GetVersion_() & $ff0000  ; Windows NT
        
        NeedUpdate | UpdateRegistryKey(#HKEY_CLASSES_ROOT, "Applications\" + ExecutableName$ + "\shell\open\command", CommandLine$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CLASSES_ROOT, "Applications\" + ExecutableName$ + "\DefaultIcon", Icon$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" + #SourceFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" + #IncludeFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" + #ProjectFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" + #FormFileExtension, ExecutableName$)
        
      Else  ; The same for Win9x
        
        NeedUpdate | UpdateRegistryKey(#HKEY_LOCAL_MACHINE, "Software\Classes\" + ExecutableName$ + "\shell\open\command", CommandLine$)
        NeedUpdate | UpdateRegistryKey(#HKEY_LOCAL_MACHINE, "Software\Classes\" + ExecutableName$ + "\DefaultIcon", Icon$)
        NeedUpdate | UpdateRegistryKey(#HKEY_LOCAL_MACHINE, "Software\CLASSES\" + #SourceFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_LOCAL_MACHINE, "Software\CLASSES\" + #IncludeFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_LOCAL_MACHINE, "Software\CLASSES\" + #ProjectFileExtension, ExecutableName$)
        NeedUpdate | UpdateRegistryKey(#HKEY_LOCAL_MACHINE, "Software\CLASSES\" + #FormFileExtension, ExecutableName$)
        
      EndIf
      
      ; We don't do it at every start, as it can take some time, and a bad desktop flikering (if the registry hasn't
      ; changed since the last run, there is no need refresh anyway)
      ;
      If NeedUpdate
        ; Notify the shell of the extension change
        ;
        #SHCNE_ASSOCCHANGED = $08000000
        #SHCNF_IDLIST       = $0000
        SHChangeNotify_(#SHCNE_ASSOCCHANGED, #SHCNF_IDLIST, #Null, #Null)
      EndIf
      
    EndIf
    
    ButtonBackgroundColor = GetButtonBackgroundColor()
    
    ; RunOnce
    ;
    RunOnceMessageID = RegisterWindowMessage_(#ProductName$ + "_RunOnce")
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure OSEndCode()
    
    ClosePlatformSDKWindow()
    
    If RunOnceMutex
      CloseHandle_(RunOnceMutex)
    EndIf
    
  EndProcedure
  
  
  ; windows only helper function. applies the Debugger menu states
  ; to the systemmenu-debuggermenu
  ;
  Procedure ApplySYSTEMMenuState(MenuItem)
    #MIIM_STATE = $1
    
    info.MENUITEMINFO\cbSize = SizeOf(MENUITEMINFO)
    info\fMask = #MIIM_STATE
    
    GetMenuItemInfo_(*MainMenu, MenuItem, #False, @info)
    If info\fState & #MFS_DISABLED
      EnableMenuItem_(DebuggerSystemMenu, MenuItem<<4, #MF_BYCOMMAND|#MF_GRAYED)
    Else
      EnableMenuItem_(DebuggerSystemMenu, MenuItem<<4, #MF_BYCOMMAND|#MF_ENABLED)
    EndIf
    
  EndProcedure
  
  
  Procedure MainWindowCallback(Window, Message, wParam, lParam)
    Shared IsMenuOpen
    Shared StatusBarOwnerDrawText$
    
    Result = #PB_ProcessPureBasicEvents
    
    If Message = #WM_DROPFILES ; drag and drop stuff
      
      CompilerIf #PB_Compiler_Debugger
        InDragDropCallback = #True
      CompilerEndIf
      
      *hdrop = wParam
      
      count = DragQueryFile_(*hdrop, $FFFFFFFF, 0, 0)
      For i = 0 To count-1
        size = DragQueryFile_(*hdrop, i, 0, 0)
        FileName$ = Space(size)
        DragQueryFile_(*hdrop, i, @FileName$, size+1) ; include the 0 byte in the count!
        
        LoadSourceFile(FileName$)
        
        ; Flush events. So when many sources are opened at once, the User can see a bit the
        ; progress, instead of just an unresponsive window for quite a while.
        ; There is almost no flicker anymore, so it actually looks quite good.
        ;
        ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
        FlushEvents()
      Next i
      
      DragFinish_(*hdrop)
      
      CompilerIf #PB_Compiler_Debugger
        InDragDropCallback = #False
      CompilerEndIf
      
    ElseIf Message = #WM_SYSCOMMAND
      wParam & $FFF0    ; mask out the windows internal 4 bits
      If wParam < $F000 ; check for our own commands
        PostMessage_(WindowID(#WINDOW_Main), #WM_COMMAND, wParam>>4, 0) ; simulate the normal menu command
        result = 0
      EndIf
      
      ;ElseIf Message = #WM_UNINITMENUPOPUP ; This one is Windows 98/2000/XP only (ie: not NT4)
      
    ElseIf Message = #WM_ENTERMENULOOP ; For compatibility with NT4
      IsMenuOpen = 1
      
    ElseIf Message = #WM_EXITMENULOOP ; For compatibility with NT4
      IsMenuOpen = 0
      
    ElseIf Message = #WM_INITMENUPOPUP ; enable/disable the special systemenu debugger submenu
      
      If wParam = DebuggerSystemMenu
        ; we simply apply the same state as the real debugger menu has.
        ApplySYSTEMMenuState(#MENU_Stop)
        ApplySYSTEMMenuState(#MENU_Run)
        ApplySYSTEMMenuState(#MENU_Step)
        ApplySYSTEMMenuState(#MENU_StepX)
        ApplySYSTEMMenuState(#MENU_StepOver)
        ApplySYSTEMMenuState(#MENU_StepOut)
        ApplySYSTEMMenuState(#MENU_Kill)
        ApplySYSTEMMenuState(#MENU_DebugOutput)
        ApplySYSTEMMenuState(#MENU_Watchlist)
        ApplySYSTEMMenuState(#MENU_VariableList)
        ApplySYSTEMMenuState(#MENU_History)
        ApplySYSTEMMenuState(#MENU_Memory)
        ApplySYSTEMMenuState(#MENU_DebugAsm)
        ApplySYSTEMMenuState(#MENU_Profiler)
        ApplySYSTEMMenuState(#MENU_LibraryViewer)
        
        Result = 0
      EndIf
      
      ; allow external programs to access the Log (ie TailBite)
      ; Now also handles the RunOnce feature's data
      ;
    ElseIf Message = #WM_COPYDATA
      *copydata.COPYDATASTRUCT = lParam
      If *copydata\dwData = AsciiConst3('L', 'O', 'G') And *ActiveSource And *copydata\cbData > 0
        Message$ = PeekS(*copydata\lpData, *copydata\cbData, #PB_Ascii)
        Debugger_AddLog_BySource(*ActiveSource, Message$, Date())
        result = #True
        
      ElseIf *copydata\dwData = AsciiConst('O', 'N', 'C', 'E') And *copydata\cbData > 0  ; RunOnce files are sent
        List$ = PeekS(*copydata\lpData, *copydata\cbData/#CharSize)
        Sender$ = StringField(List$, 1, Chr(10))
        
        ; Check if this message is for this instance
        ;
        If IsEqualFile(Sender$, ProgramFilename())
          ; Send a response back to the sender that it can quit now
          PostMessage_(wParam, RunOnceMessageID, AsciiConst('D', 'O', 'N', 'E'), WindowID(#WINDOW_Main))
          
          ; Open the files
          Count = Val(StringField(List$, 2, Chr(10)))
          Line  = Val(StringField(List$, 3, Chr(10))) ; for -l option
          
          For i = 1 To Count
            FileName$ = StringField(List$, 3+i, Chr(10))
            
            If FileName$ <> ""
              LoadSourceFile(FileName$)
              
              ; Flush events. So when many sources are opened at once, the User can see a bit the
              ; progress, instead of just an unresponsive window for quite a while.
              ; There is almost no flicker anymore, so it actually looks quite good.
              ;
              ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
              FlushEvents()
            EndIf
          Next i
          
          If Line > 0 And Line < GetLinesCount(*ActiveSource) ; apply the -l option
            ChangeActiveLine(Line, -5)
          EndIf
          
          ; NOTE:
          ;   Do not call SetWindowForeground_Real() as it does the ugly hack to attach to the foreground
          ;   Window's queue, which will crash the IDE if the foreground window hangs.
          ;   Steps to reproduce:
          ;   - run a PB program (with GUI) which does "RunProgram(some PB source)"
          ;   - the program and the IDE will crash.  (https://www.purebasic.fr/english/viewtopic.php?t=36934)
          ;
          ;   Instead we use the normal SetWindowForeground() here, and it even works:
          ;   - the starting program has focus
          ;   - when it launches the RunOnce IDE instance, that instance has foreground rights too
          ;   - the RunOnce instance calls AllowWindowSetForeground() to give the rights to this instance
          ;   - all works (the old IDE ends up with focus)
          ;
          ;   The only case where this does not work is if a background program tries to run the IDE
          ;   but this is the problem of the background program, not of the IDE. This works fine with
          ;   Explorer double-clicks and the like which is the important part
          ;
          SetWindowForeground(#WINDOW_Main)
        EndIf
        
        result = #True
        
      EndIf
      
      
    ElseIf Message = #WM_CONTEXTMENU
      If *ActiveSource <> *ProjectInfo And wParam = GadgetID(*ActiveSource\EditorGadget)
        DisplayPopupMenu(#POPUPMENU, WindowID(#WINDOW_Main))
      EndIf
      
    ElseIf Message = #WM_DRAWITEM
      *lpdis.DRAWITEMSTRUCT = lParam
      
      If wParam <> 0 ; ownerdrawn statusbar field
        TextStart$ = Left(StatusBarOwnerDrawText$, *lpdis\itemData&$FFFF)
        TextBold$  = Mid(StatusBarOwnerDrawText$, (*lpdis\itemData&$FFFF)+1, (*lpdis\itemData>>16)-(*lpdis\itemData&$FFFF)-1)
        TextEnd$   = Right(StatusBarOwnerDrawText$, Len(StatusBarOwnerDrawText$)-(*lpdis\itemData>>16)+1)
        
        SetBkMode_(*lpdis\hDC, #TRANSPARENT)
        
        CopyMemory(@*lpdis\rcItem, @DrawTextRect.RECT, SizeOf(RECT))
        
        GetTextExtentPoint32_(*lpdis\hDC, TextStart$, Len(TextStart$), @sizestart.SIZE)
        DrawTextRect\left+1
        DrawText_(*lpdis\hDC, @TextStart$, Len(TextStart$), DrawTextRect, #DT_VCENTER | #DT_SINGLELINE)
        
        hOldObject = SelectObject_(*lpdis\hDC, StatusbarBoldFontID)
        
        GetTextExtentPoint32_(*lpdis\hDC, TextBold$, Len(TextBold$), @sizebold.SIZE)
        DrawTextRect\left+sizestart\cx
        DrawText_(*lpdis\hDC, @TextBold$, Len(TextBold$), DrawTextRect, #DT_VCENTER | #DT_SINGLELINE)
        
        If hOldObject
          SelectObject_(*lpdis\hDC, hOldObject)
        EndIf
        
        DrawTextRect\left+sizebold\cx
        DrawText_(*lpdis\hDC, @TextEnd$, Len(TextEnd$), DrawTextRect, #DT_VCENTER | #DT_SINGLELINE)
      EndIf
      
      result = #True
      
    ElseIf Message = #WM_QUERYENDSESSION
      ; session is about to end, check for unsaved sources / close them
      ; only checks/asks, does not close sources
      ; returns 1 when not aported, so the shutdown can continue
      If Window = WindowID(#WINDOW_Main) ; received on multiple windows, so respond only once!
        result = CheckAllSourcesSaved()
      EndIf
      
    ElseIf Message = #WM_ENDSESSION
      ; only if wParam is true there is a real shutdown. (else it is an aborted one)
      ; do not call ShutdownIDE() for an aborted one, as it leaves the IDE in
      ; an invalid state (any further user action may cause a crash!)
      If wParam And Window = WindowID(#WINDOW_Main)
        ; orderly shutdown of the IDE.
        ; Note that asking/saving sources is done on the WM_QUERYENDSESSION already
        ShutdownIDE()
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  ; Windows only:
  ; Adds the debugger commands to the Systemmenu, making them accessible by rightclicking
  ; on the TaskbarButton too
  ;
  Procedure CreateSYSTEMMenu()
    Static hSubMenu
    
    If hSubMenu
      DestroyMenu_(hSubMenu) ; destroy old submenu
      hSubMenu = 0
    EndIf
    
    GetSystemMenu_(WindowID(#WINDOW_Main), #True) ; revert changes done the last time
    
    hMenu = GetSystemMenu_(WindowID(#WINDOW_Main), #False) ; copy the systemenu
    hSubMenu = CreatePopupMenu_()
    
    If hMenu And hSubMenu
      
      ; Menu ids in the sysmenu should be below $F000 and above $000F (as the low 4 bits are masked out)
      ;
      CompilerIf Not #SpiderBasic
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_Stop<<4,  LanguageStringAddress("MenuItem","Stop"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_Run<<4,   LanguageStringAddress("MenuItem","Run"))
      CompilerEndIf
      AppendMenu_(hSubMenu, #MF_STRING, #MENU_Kill<<4,  LanguageStringAddress("MenuItem","Kill"))
      AppendMenu_(hSubMenu, #MF_SEPARATOR, 0, @"")
      CompilerIf Not #SpiderBasic
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_Step<<4,  LanguageStringAddress("MenuItem","Step"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_StepX<<4, LanguageStringAddress("MenuItem","StepX"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_StepOver<<4, LanguageStringAddress("MenuItem","StepOver"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_StepOut<<4, LanguageStringAddress("MenuItem","StepOut"))
        AppendMenu_(hSubMenu, #MF_SEPARATOR, 0, @"")
      CompilerEndIf
      AppendMenu_(hSubMenu, #MF_STRING, #MENU_DebugOutput<<4,  LanguageStringAddress("MenuItem","DebugOutput"))
      CompilerIf Not #SpiderBasic
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_Watchlist<<4,    LanguageStringAddress("MenuItem","WatchList"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_VariableList<<4, LanguageStringAddress("MenuItem","VariableList"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_Profiler<<4, LanguageStringAddress("MenuItem","Profiler"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_History<<4,      LanguageStringAddress("MenuItem","History"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_Memory<<4,       LanguageStringAddress("MenuItem","Memory"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_LibraryViewer<<4,       LanguageStringAddress("MenuItem","LibraryViewer"))
        AppendMenu_(hSubMenu, #MF_STRING, #MENU_DebugAsm<<4,     LanguageStringAddress("MenuItem","DebugAsm"))
      CompilerEndIf      
      
      ; insert into system menu
      ;
      InsertMenu_(hMenu, #SC_CLOSE, #MF_BYCOMMAND|#MF_POPUP|#MF_STRING, hSubMenu, LanguageStringAddress("MenuTitle","Debugger"))
      InsertMenu_(hMenu, #SC_CLOSE, #MF_BYCOMMAND|#MF_SEPARATOR, 0, @"")
      
      DebuggerSystemMenu = hSubMenu ; the value is needed in the mainWindowCallback too
    EndIf
    
  EndProcedure
  
  
  ; determine things like StatusBarHeight once after the GUI is created.
  Procedure GetWindowMetrics()
    
    GetWindowRect_(*MainToolBar, @Size.RECT)
    ToolbarHeight = DesktopUnscaledY(Size\bottom - Size\top)
    ToolbarTopOffset = ToolbarHeight
    
    MenuHeight = MenuHeight()
    
    StatusbarHeight = StatusBarHeight(#STATUSBAR)
    ; GUI is created now, so set up the callback
    ;
    SetWindowCallback(@MainWindowCallback())
    
    ; Turn on the drag & drop feature..
    ;
    DragAcceptFiles_(WindowID(#WINDOW_Main), 1)
    
    ; Windows only:
    ; Adds the debugger commands to the Systemmenu, making them accessible by rightclicking
    ; on the TaskbarButton too
    ;
    CreateSYSTEMMenu()
    
    
    ;  This is the recommanded way to create a font which is correctly DPI aware. Don't use GetStockObject_(#DEFAULT_GUI_FONT) as it's not DPI aware
    ;
    Metrics.NONCLIENTMETRICS 
    Metrics\cbSize = SizeOf(NONCLIENTMETRICS)
    If SystemParametersInfo_(#SPI_GETNONCLIENTMETRICS, SizeOf(Metrics), @Metrics, 0)
      Metrics\lfMessageFont\lfWeight = #FW_BOLD
      StatusbarBoldFontID = CreateFontIndirect_(@Metrics\lfMessageFont)
    EndIf
    
    If StatusbarBoldFontID = 0
      ; fallback option
      StatusbarBoldFontID = FontID(LoadFont(#PB_Any, "MS Sans Serif", 8, #PB_Font_Bold|#PB_Font_HighQuality))
    EndIf
    
  EndProcedure
  
  
  Procedure LoadEditorFonts()
    
    If LoadFont(#FONT_Editor, EditorFontName$, EditorFontSize, EditorFontStyle)
      EditorFontID = FontID(#FONT_Editor)
    EndIf
    
    EditorBoldFontName$ = EditorFontName$ ; for scintilla
    
  EndProcedure
  
  
  Procedure UpdateToolbarView()
    
    If ShowMainToolbar
      ShowWindow_(*MainToolBar, #SW_SHOWNA)
    Else
      ShowWindow_(*MainToolBar, #SW_HIDE)
    EndIf
    
    ResizeMainWindow()
  EndProcedure
  
  
  Procedure RunOnce_Startup(InitialSourceLine)
    Result = #False ; do not quit IDE
    
    ; The Mutex name is now constructed from the Program filename.
    ; This way we have "one instance per installation", which allows multiple
    ; versions or x86/x64 at once, but only one instance of one installation
    ;
    ; The name cannot contain \ etc, so use the MD5 of the FileName$
    ;
    File$ = ProgramFilename()
    Mutex$ = #ProductName$ + "_" + StringFingerprint(File$, #PB_Cipher_MD5)
    Debug "RunOnce Mutex: " + Mutex$
    
    RunOnceMutex = CreateMutex_(0, 0, Mutex$)
    
    If GetLastError_() = #ERROR_ALREADY_EXISTS
      Result = #True ; close IDE after this
                     ;
                     ; We now handle the communication with the old instance here as well,
                     ; so we can make use of Message based communication instead of the old
                     ; file routine.
                     ;
                     ; The problem with the file routine is that if many files are opened at once,
                     ; different instances will overwrite the file, causing files to be ignored.
                     ; (This happens when opening many files from the explorer for example)
      
      ; we need a window for communication
      If OpenWindow(0, 0, 0, 0, 0, "", #PB_Window_Invisible)
        
        ; post message to look for other instances
        ; Note: the WM_COPYDATA sent is now incompatible to pre 4.30 versions,
        ;   so we use a new ID here ('OPEN' instead of 'LOOK' before)
        ;   This way old IDE versions will not react to this.
        ;
        Debug "broadcast"
        PostMessage_(#HWND_BROADCAST, RunOnceMessageID, AsciiConst('O', 'P', 'E', 'N'), WindowID(0))
        
        ; wait for a response
        Timeout.q = ElapsedMilliseconds() + 10000 ; since it is a hidden process, we can afford a bigger timeout
        
        While Timeout > ElapsedMilliseconds()
          If WaitWindowEvent(100) = RunOnceMessageID
            If EventwParam() = AsciiConst('H', 'W', 'N', 'D') ; response from an older instance
              Target = EventlParam()                          ; target HWND
              
              ; allow the target window to grab the keyboard focus.
              ; this avoids the ugly taskbar blinking when we steal the focus with SetWindowForeground_Real()
              AllowSetForeground = GetProcAddress_(GetModuleHandle_("User32.dll"), "AllowSetForegroundWindow")
              If AllowSetForeground
                GetWindowThreadProcessId_(Target, @TargetPID)
                CallFunctionFast(AllowSetForeground, TargetPID)
              EndIf
              
              ; Note: We send this to all responding windows (which could be multiple)
              ;   but we include the ProgramFilename() so only the right instance will open the files
              ;
              ; Data: ProgramFilename()
              ;       FilenameCount
              ;       InitialSourceLine
              ;       File1
              ;       File2
              ;       ...
              ;
              List$ = ProgramFilename() + Chr(10) + Str(ListSize(OpenFilesCommandline())) + Chr(10) + Str(InitialSourceLine)
              ForEach OpenFilesCommandline()
                List$ + Chr(10) + OpenFilesCommandline()
              Next OpenFilesCommandline()
              
              copydata.COPYDATASTRUCT
              copydata\dwData = AsciiConst('O', 'N', 'C', 'E') ; to identify the kind of data ('LOG' is used to access the error log)
              copydata\cbData = (Len(List$) + 1)*#CharSize     ; include null
              copydata\lpData = @List$
              SendMessage_(Target, #WM_COPYDATA, WindowID(0), @copydata)
              
              Debug "Sending #WM_COPYDATA: " + List$
              
              ; No more loop quitting, as there could be multiple instances answering,
              ; and we have to send the WM_COPYDATA to all (the right one will react to it)
              ;
              ; To not wait the full timeout, the (correct) target will send a 'DONE'
              ; Message, on which we quit
            ElseIf EventwParam() = AsciiConst('D', 'O', 'N', 'E')
              Break
              
            EndIf
          EndIf
        Wend
        
        CloseWindow(0)
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure RunOnce_UpdateSetting()
    
    If Editor_RunOnce And RunOnceMutex = 0
      ; See RunOnce_Startup()
      File$ = ProgramFilename()
      
      RunOnceMutex = CreateMutex_(0, 0, #ProductName$ + "_" + StringFingerprint(File$, #PB_Cipher_MD5))
      
    ElseIf Editor_RunOnce = 0 And RunOnceMutex
      CloseHandle_(RunOnceMutex)
      RunOnceMutex = 0
      
    EndIf
    
  EndProcedure
  
  ; Dead session detection
  ; Similar to RunOnce, but must support concurrent sessions (to support the case of RunOnce=off)
  Procedure Session_IsRunning(OSSessionID$)
    Handle = OpenMutex_(#SYNCHRONIZE, #False, @OSSessionID$)
    If Handle
      CloseHandle_(Handle)
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s Session_Start()
    SID$ = "PB_Session_" + History_MakeUniqueId()
    SessionMutex = CreateMutex_(0, 0, SID$)
    ProcedureReturn SID$
  EndProcedure
  
  Procedure Session_End(OSSessionID$)
    CloseHandle_(SessionMutex)
    SessionMutex = 0
  EndProcedure
  
  Procedure AutoComplete_FocusProc(Window, Message, wParam, lParam)
    
    If AutoCompleteWindowOpen
      
      If Message = #WM_KILLFOCUS
        AutoComplete_Close()
        
      ElseIf Message = #WM_KEYDOWN Or Message = #WM_KEYUP
        ; redirect all key messages except up/down, tab and return/esc to the scintilla gadget
        If wParam = #VK_LEFT Or wParam = #VK_RIGHT Or wParam = #VK_PRIOR Or wParam = #VK_NEXT Or wParam = #VK_HOME Or wParam = #VK_END
          AutoComplete_Close()
          PostMessage_(GadgetID(*ActiveSource\EditorGadget), Message, wParam, lParam) ; also post this message!
          
          ; handle specially the tab/enter if it is the "confirm" shortcut
        ElseIf wParam = #VK_TAB And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Tab
          ProcedureReturn CallWindowProc_(AutoCompleteWindowProc, Window, Message, wParam, lParam)
          
        ElseIf wParam = #VK_RETURN And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Return
          ProcedureReturn CallWindowProc_(AutoCompleteWindowProc, Window, Message, wParam, lParam)
          
          ; Note: for unhandled Enter/Tab, we must first close the AutoComplete window or else
          ; the event will not be handled by the main window as it checks if the Scintilla has the focus!
        ElseIf wParam = #VK_RETURN Or wParam = #VK_TAB
          AutoComplete_Close()
          PostMessage_(GadgetID(*ActiveSource\EditorGadget), Message, wParam, lParam) ; also post this message!
          ProcedureReturn 0
          
        ElseIf  wParam <> #VK_UP And wParam <> #VK_DOWN And wParam <> #VK_ESCAPE
          PostMessage_(GadgetID(*ActiveSource\EditorGadget), Message, wParam, lParam)
          ProcedureReturn 0
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn CallWindowProc_(AutoCompleteWindowProc, Window, Message, wParam, lParam)
  EndProcedure
  
  Procedure AutoComplete_SetFocusCallback()
    AutoCompleteWindowProc = SetWindowLongPtr_(GadgetID(#GADGET_AutoComplete_List), #GWL_WNDPROC, @AutoComplete_FocusProc())
  EndProcedure
  
  Procedure AutoComplete_AdjustWindowSize(MaxWidth, MaxHeight)
    ;
    ; Note: on windows there is no horizontal scrollbar in ListViewGadget, so
    ;   we do not resize in this direction at all
    ;
    NewHeight   = MaxHeight
    
    ItemHeight = SendMessage_(GadgetID(#GADGET_AutoComplete_List), #LB_GETITEMHEIGHT, 0, 0)
    If ItemHeight <> #LB_ERR
      NewHeight = ItemHeight * CountGadgetItems(#GADGET_AutoComplete_List) + GetSystemMetrics_(#SM_CYEDGE) * 2
      If NewHeight > MaxHeight
        NewHeight = MaxHeight
      EndIf
    EndIf
    
    ResizeGadget(#GADGET_AutoComplete_List, #PB_Ignore, #PB_Ignore, #PB_Ignore, NewHeight)
    ResizeWindow(#WINDOW_AutoComplete, #PB_Ignore, #PB_Ignore, #PB_Ignore, NewHeight)
    
  EndProcedure
  
  
  Procedure ToolsPanel_ApplyColors(Gadget)
    
    If Gadget = propgrid
      grid_SetGadgetColor(Gadget, #Grid_Color_Background, ToolsPanelBackColor)
      grid_SetDefaultStyle(Gadget,P_FontGrid, #P_FontGridSize, ToolsPanelFrontColor)
      
    Else
      If ToolsPanelFontID <> #PB_Default
        SetGadgetFont(Gadget, ToolsPanelFontID)
      EndIf
      
      If ToolsPanelUseColors
        SetGadgetColor(Gadget, #PB_Gadget_FrontColor, ToolsPanelFrontColor)
        SetGadgetColor(Gadget, #PB_Gadget_BackColor, ToolsPanelBackColor)
        ;SetGadgetColor(Gadget, #PB_Gadget_LineColor, ToolsPanelFrontColor) ; just set linecolor too. will be ignored if unsupported
      EndIf
    EndIf
    
  EndProcedure
  
  
  Structure PB_MenuStructure
    Menu.i      ; OS Menu pointer (HMENU)
    Window.i    ; OS Window pointer on which the menu has been created (HWINDOW)
  EndStructure
  
  
  Procedure IsAdmin()
    Shell32 = OpenLibrary(#PB_Any,"shell32.dll")
    If Shell32
      Result = CallCFunction(Shell32, "IsUserAnAdmin") ; Default to 0 if the function isn't found
      CloseLibrary(Shell32)
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure IsScreenReaderActive()
    
    ; Detect screen readers that properly announce their presence
    ;
    IsActive = 0
    If SystemParametersInfo_(#SPI_GETSCREENREADER, 0, @IsActive, 0)
      If IsActive
        ProcedureReturn #True
      EndIf
    EndIf
    
    ; Special case for the "Narrator" reader included in Windows which does not use the above setting
    ; (this is not documented)
    ;
    hMutex = OpenMutex_(#SYNCHRONIZE, #False, @"NarratorRunning")
    If hMutex
      CloseHandle_(hMutex)
      ProcedureReturn #True
    EndIf

    ProcedureReturn #False
  EndProcedure
  
CompilerEndIf
