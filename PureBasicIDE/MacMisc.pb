; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; OS X specific file:

CompilerIf #CompileMacCocoa
  
  ; Global AlreadyRunning
  
  ; handler for the "open document" event
  ;
  ; Problem: We must install this handler inside the OSStartupCode() to catch the event
  ;   when double-clicking on a file caused the IDE to load. (if we set the handler later, a WaitWindowEvent call will eat the event)
  ;   But we cannot actually load the file before the IDE is ready. So this variable checks this (set in PureBasic.pb)
  ;
  Global ReadyForDocumentEvent = 0
  
  ProcedureC OpenDocument(*FilesUTF8)
    
    ; Files are separated by a tab
    ;
    Files$ = PeekS(*FilesUTF8, -1, #PB_UTF8)
    
    Repeat
      File$ = StringField(Files$, k+1, #TAB$) ; index is 1 based
      If File$ <> ""
        If FileSize(File$) >= 0 ; no directories here...
          Debug "passed file: "+File$
          
          ; Use the queue, as loading a document from this callback crash the IDE (probably because we do GUI operations in startup callback
          ; It will be loaded in the main loop
          LastElement(OpenFilesCommandLine())
          AddElement(OpenFilesCommandLine())  ; will cause this file to be loaded when the IDE is ready for it
          OpenFilesCommandLine() = File$
        EndIf
        
        k+1
      EndIf
    Until File$ = ""
    
  EndProcedure
  
  
  Procedure OSStartupCode()
    ; Set the default Path Values
    ;
    Home$ = GetEnvironmentVariable("HOME")
    If Right(Home$, 1) <> #Separator
      Home$ + #Separator
    EndIf
    
    If PureBasicPath$ = "" ; Only change if not set by commandline
      CompilerIf #SpiderBasic
        PureBasicPath$ = GetEnvironmentVariable("SPIDERBASIC_HOME")
      CompilerElse
        PureBasicPath$ = GetEnvironmentVariable("PUREBASIC_HOME")
      CompilerEndIf
      
      CompilerIf Defined(FredLocalCompile, #PB_Constant) ; Fred config
        CompilerIf #PB_Compiler_Processor = #PB_Processor_Arm64
          CompilerIf #SpiderBasic
            PureBasicPath$ = "/Users/fred/svn/"+#SVNVersion+"/Build/SpiderBasic"
          CompilerElse
            PureBasicPath$ = "/Users/fred/svn/"+#SVNVersion+"/Build/purebasic_arm64"
          CompilerEndIf
        CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
          CompilerIf #SpiderBasic
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\SpiderBasic_x64\"
          CompilerElse
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\PureBasic_x64\"
          CompilerEndIf
        CompilerElse
          CompilerIf #SpiderBasic
            PureBasicPath$ = "/Users/fred/svn/"+#SVNVersion+"/Build/SpiderBasic"
          CompilerElse
            PureBasicPath$ = "C:\PureBasic\Svn\"+#SVNVersion+"\Build\PureBasic_x86\"
          CompilerEndIf
        CompilerEndIf
      CompilerEndIf
      
      If PureBasicPath$ <> ""
        If Right(PureBasicPath$, 1) <> #Separator
          PureBasicPath$ + #Separator
        EndIf
      Else
        ; If the PUREBASIC_HOME isn't set, then it's probably launched from the Finder so gets the bundle path
        ;
        Bundle = CFBundleGetMainBundle_()
        If Bundle
          BundleURL = CFBundleCopyBundleURL_(Bundle)
          If BundleURL
            *Buffer = AllocateMemory(256)
            CFURLGetFileSystemRepresentation_(BundleURL, #True, *Buffer, 255) ; it returns a byte buffer (UTF-8)
            BundlePath$ = PeekS(*Buffer, -1, #PB_UTF8)                        ; It returns something like: /tmp/PureBasic.app, so gets the path only
            FreeMemory(*Buffer)
            
            CompilerIf #SpiderBasic
              ; If SpiderBasic home is bundled inside the .app, uses this path.
              ; Note: it needs to be in the resources directory, or the app signing will fail
              ;
              If FileSize(BundlePath$ + "/Contents/Resources/compilers") = -2
                PureBasicPath$ = BundlePath$ + "/Contents/Resources/"
              Else
                PureBasicPath$ = GetPathPart(BundlePath$)        ; It returns something like: /tmp/PureBasic.app, so gets the path only
              EndIf
            CompilerElse
              ; If PureBasic home is bundled inside the .app, uses this path.
              ; Note: it needs to be in the resources directory, or the app signing will fail
              ;
              If FileSize(BundlePath$ + "/Contents/Resources/compilers") = -2
                PureBasicPath$ = BundlePath$ + "/Contents/Resources/"
              Else
                PureBasicPath$ = GetPathPart(BundlePath$)        ; It returns something like: /tmp/PureBasic.app, so gets the path only
              EndIf
            CompilerEndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
    TempPath$ = "/tmp/"
    
    If PreferencesFile$ = "" ; Only change if not set by commandline
      PreferencesFile$  = PureBasicConfigPath() + #PreferenceFileName$
    EndIf
    
    If AddToolsFile$ = "" ; Only change if not set by commandline
      AddToolsFile$     = PureBasicConfigPath() + "tools.prefs"
    EndIf
    
    If TemplatesFile$ = "" ; Only change if not set by commandline
      TemplatesFile$    = PureBasicConfigPath() + "templates.prefs"
    EndIf
    
    If HistoryDatabaseFile$ = "" ; Only change if not set by commandline
      HistoryDatabaseFile$ = PureBasicConfigPath() + "history.db"
    EndIf
    
    If SourcePathSet = 0  ; Only change if not set by commandline
      
      ; It's important to point on the examples when the path is not set as when your run PureBasic for the first
      ; time, you want to open examples to test them. This value can be changed in the prefs and won't be
      ; used if another pref is found
      ;
      SourcePath$ = PureBasicPath$ + "Examples/"
    EndIf
    
    CompilerIf #SpiderBasic
      RunOnceFile$      = TempPath$ + ".sbrunonce.txt"
    CompilerElse
      RunOnceFile$      = TempPath$ + ".pbrunonce.txt"
    CompilerEndIf
    
    
    ;Debug "PureBasicPath: "+PureBasicPath$
    ;Debug "Preferences: "+ PreferencesFile$
    ;Debug "Tools settings: "+AddToolsFile$
    
    ButtonBackgroundColor = GetButtonBackgroundColor()
    
    ; Install the "Open Document" event handler
    ; Do not do this in OSStartupCode so we only receive this event when we are ready
    ; to actually load a file...
    ;
    PB_Gadget_SetOpenFinderFiles(@OpenDocument())
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure OSEndCode()
    
    ;If AlreadyRunning = 0
    ;  DeleteFile(TempPath$ + ".purebasic.running")
    ;EndIf
    
  EndProcedure
  
  
  ; determine things like StatusBarHeight once after the GUI is created.
  
  Procedure GetWindowMetrics()
    
    StatusbarHeight = StatusBarHeight(#STATUSBAR)
    
    ToolbarHeight = 0 ; Toolbar is not calculated in client area on OS X
    
    ToolbarTopOffset = 2
    MenuHeight = MenuHeight()
    
  EndProcedure
  
  
  Procedure LoadEditorFonts()
    ; The font still needs to be loaded for the Preferences display
    If LoadFont(#FONT_Editor, EditorFontName$, EditorFontSize)
      EditorFontID = FontID(#FONT_Editor)
    EndIf
    
    EditorBoldFontName$ = EditorFontName$ ; for scintilla
  EndProcedure
  
  
  Procedure UpdateToolbarView()
    PB_Gadget_ShowToolBar(ToolBarID(#TOOLBAR), ShowMainToolbar)
  EndProcedure
  
  
  Procedure RunOnce_Startup(InitialSourceLine)
    ProcedureReturn #False ; do not quit the IDE, as RunOnce is not implemented
  EndProcedure
  
  Procedure RunOnce_UpdateSetting()
    
    ;   If Editor_RunOnce
    ;     If CreateFile(#FILE_RunOnce, TempPath$ + ".purebasic.running")
    ;       WriteString(#FILE_RunOnce, Str(getpid_()))
    ;       CloseFile(#FILE_RunOnce)
    ;     EndIf
    ;   Else
    ;     DeleteFile(TempPath$ + ".purebasic.running")
    ;   EndIf
    
  EndProcedure
  
  
  ; Dead session detection
  Procedure Session_IsRunning(OSSessionID$)
    ; Only one instance can run on OSX, so any instance that is not the current one must be dead
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s Session_Start()
    ; no need to track any information
    ProcedureReturn ""
  EndProcedure
  
  Procedure Session_End(OSSessionID$)
  EndProcedure
  
  
  Procedure AutoComplete_SetFocusCallback()
    ; nothing to do here
  EndProcedure
  
  Procedure AutoComplete_AdjustWindowSize(MaxWidth, MaxHeight)
    ; TODO: works without this as well, but would be nice to have
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
  
  Procedure IsScreenReaderActive()
    ProcedureReturn #False
  EndProcedure
  
  ; Procedure CPUMonitor_Init()
  ;
  ;   IsCPUMonitorInitialized = 0
  ;
  ; EndProcedure
  ;
  ; ; This procedure must do the following:
  ; ; - update the #GADGET_CPU_List values for each process
  ; ; - update the CPUUsage value in the RunningDebuggers() list (for all processes)
  ; ; - fill the pointers to the general values (all % CPU usage)
  ; ;
  ; Procedure GetCPUInfo(*Free.LONG, *Used.LONG)
  ; EndProcedure
  
CompilerEndIf
