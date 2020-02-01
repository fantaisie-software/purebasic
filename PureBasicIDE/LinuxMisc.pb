﻿;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


; linux specific file:
CompilerIf #CompileLinux
  
  Global AlreadyRunning
  
  Procedure OSStartupCode()
    Shared DetectedGUITerminal$, GUITerminalParameters$ ; for the debugger
    
    ; Set the default Path Values
    ;
    ;  *home = getenv_("HOME")
    ;  If *home
    ;    Home$ = PeekS(*home)
    ;    If Right(Home$, 1) <> #Separator
    ;      Home$ + #Separator
    ;    EndIf
    ;  Else
    ;    Home$ = ""
    ;  EndIf
    ;
    ;  If PureBasicPath$ = "" ; Only change if not set by commandline
    ;    *directory = getenv_("PUREBASIC_HOME")
    ;    If *directory
    ;      PureBasicPath$ = PeekS(*directory)
    ;      If Right(PureBasicPath$, 1) <> #Separator
    ;        PureBasicPath$ + #Separator
    ;      EndIf
    ;    Else
    ;      PureBasicPath$ = "/usr/share/purebasic/"
    ;    EndIf
    ;
    ;  EndIf
    
    Home$ = GetEnvironmentVariable("HOME")
    If Right(Home$, 1) <> #Separator
      Home$ + #Separator
    EndIf
    
    ; If the PUREBASIC_HOME is not set, we use the path to the purebasic executable as a reference.
    ; This way IDE compilation should work completely without the PUREBASIC_HOME. (so it is only needed
    ; for commandline compilation). This should be easier to setup for people.
    ;
    If PureBasicPath$ = "" ; only change if not set by commandline -b
      CompilerIf #SpiderBasic
        PureBasicPath$ = GetEnvironmentVariable("SPIDERBASIC_HOME")
      CompilerElse
        PureBasicPath$ = GetEnvironmentVariable("PUREBASIC_HOME")
      CompilerEndIf
      
      If PureBasicPath$ = ""
        PureBasicPath$ = GetPathPart(ProgramFilename())
        
        ; cut the compilers dir part
        If Right(PureBasicPath$, 10) = "compilers/"
          PureBasicPath$ = Left(PureBasicPath$, Len(PureBasicPath$)-10)
        ElseIf Right(PureBasicPath$, 9) = "compilers"
          PureBasicPath$ = Left(PureBasicPath$, Len(PureBasicPath$)-9)
        EndIf
        
        ; check if what we have here is a valid path. (if /proc is not mounted, ProgramFileName() may return a relative path
        If FileSize(PureBasicPath$) <> -2
          CompilerIf #SpiderBasic
            PureBasicPath$ = "/usr/share/spiderbasic/" ; absolute fallback
          CompilerElse
            PureBasicPath$ = "/usr/share/purebasic/" ; absolute fallback
          CompilerEndIf
        EndIf
      EndIf
    EndIf
    
    Debug "PureBasicPath$ = " + PureBasicPath$
    
    If Right(PureBasicPath$, 1) <> #Separator
      PureBasicPath$ + #Separator
    EndIf
    
    
    If FindString(PureBasicPath$, "\ ", 1) = 0
      PureBasicPath$ = ReplaceString(PureBasicPath$, " ", "\ ") ; this is only needed here, to work on the commandline
    EndIf
    
    TempPath$         = "/tmp/"
    
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
    
    If SourcePathSet = 0
      
      ; It's important to point on the examples when the path is not set as when your run PureBasic for the first
      ; time, you want to open examples to test them. This value can be changed in the prefs and won't be
      ; used if another pref is found
      ;
      SourcePath$ = PureBasicPath$ + "examples/"
    EndIf
    
    CompilerIf #SpiderBasic
      RunOnceFile$      = TempPath$ + ".sbrunonce.txt"
    CompilerElse
      RunOnceFile$      = TempPath$ + ".pbrunonce.txt"
    CompilerEndIf
    
    ;Debug "PureBasicPath: "+PureBasicPath$
    ;Debug "Preferences: "+ PreferencesFile$
    ;Debug "Tools settings: "+AddToolsFile$
    
    
    ;   #GDK_SB_H_DOUBLE_ARROW = 108
    ;   #GDK_SB_V_DOUBLE_ARROW = 116
    ;   SplitterCursor    = gdk_cursor_new_(#GDK_SB_H_DOUBLE_ARROW)
    ;   SplitterCursor2   = gdk_cursor_new_(#GDK_SB_V_DOUBLE_ARROW)
    
    ButtonBackgroundColor = GetButtonBackgroundColor()
    
    
    ; Try to detect a gui terminal program, where the debugger can be displayed in...
    ; Note: somehow, when the title option is set, often it does not execute correctly (for example in gnome-terminal)
    ; so remove them all
    ;
    If system_(ToAscii("which gnome-terminal > "+TempPath$+"PB_TerminalTest.txt 2>/dev/null")) = 0
      GUITerminalParameters$ = "-x "
      
    ElseIf system_(ToAscii("which konsole > "+TempPath$+"PB_TerminalTest.txt 2>/dev/null")) = 0
      GUITerminalParameters$ = " -e "
      
    ElseIf system_(ToAscii("which aterm > "+TempPath$+"PB_TerminalTest.txt 2>/dev/null")) = 0
      GUITerminalParameters$ = " -e "
      
    ElseIf system_(ToAscii("which mlterm > "+TempPath$+"PB_TerminalTest.txt 2>/dev/null")) = 0
      GUITerminalParameters$ = " -e "
      
    ElseIf system_(ToAscii("which rxvt > "+TempPath$+"PB_TerminalTest.txt 2>/dev/null")) = 0
      GUITerminalParameters$ = " -e "
      
    ElseIf system_(ToAscii("which xterm > "+TempPath$+"PB_TerminalTest.txt 2>/dev/null")) = 0
      GUITerminalParameters$ = " -e "
      
    Else
      GUITerminalParameters$ = ""
      
    EndIf
    
    ; read the which output, to get the full path (as the internal debugger doesn't search the PATH environment
    ;
    If GUITerminalParameters$ <> ""
      If ReadFile(#FILE_CompilerInfo, TempPath$+"PB_TerminalTest.txt")
        DetectedGUITerminal$ = ReadString(#FILE_CompilerInfo)
        CloseFile(#FILE_CompilerInfo)
      Else
        DetectedGUITerminal$ = ""
      EndIf
    EndIf
    
    DeleteFile(TempPath$+"PB_TerminalTest.txt")
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure OSEndCode()
    
    If AlreadyRunning = 0
      DeleteFile(TempPath$ + ".purebasic.running")
    EndIf
    
    ; still used for IDE->Debugger communication when using a FIFO
    DeleteFile(TempPath$ + ".purebasic.out")
    
  EndProcedure
  
  
  Declare RunOnce_MessageFilter(*XEvent.XClientMessageEvent, *Event._GdkEventClient, user_data)
  
  
  ; determine things like StatusBarHeight once after the GUI is created.
  Procedure GetWindowMetrics()
    
    StatusbarHeight = StatusBarHeight(#STATUSBAR)
    
    ToolbarHeight = 35
    ToolbarTopOffset = 0
    
    ; MenuHeight = MenuHeight() ; returns a fixed value!
    ;
    MenuSize.GtkRequisition;
    gtk_widget_size_request_(MenuID(#MENU), @MenuSize)
    MenuHeight = MenuSize\height
    
    ; Get the fixed widget instead of the window, as on GTK2 the motion notify event doesn't work on a window
    ; (probably because the fixed has it's own window)
    ;
    Window = g_object_get_data_(WindowID(#WINDOW_Main), "pb_gadgetlist")
    
    ; Set up the callback for the RunOnce event
    ; (don't do this in OSStartupCode(), because at this point it is not determined if there is already an editor Window)
    ;
    gdk_add_client_message_filter_(gdk_atom_intern_("PureBasic_RunOnceSignal", 0), @RunOnce_MessageFilter(), 0)
    
  EndProcedure
  
  
  Procedure LoadEditorFonts()
    
    ; The font still needs to be loaded for the Preferences display
    If LoadFont(#FONT_Editor, EditorFontName$, EditorFontSize)
      EditorFontID = FontID(#FONT_Editor)
    EndIf
    
    EditorBoldFontName$ = EditorFontName$
  EndProcedure
  
  
  Procedure UpdateToolbarView()
    
    If ShowMainToolbar
      gtk_widget_show_(*MainToolbar)
    Else
      gtk_widget_hide_(*MainToolbar)
    EndIf
    
  EndProcedure
  
  Procedure RunOnceSignalReceived()
    If ReadFile(#FILE_RunOnce, RunOnceFile$)
      
      While Eof(#FILE_RunOnce) = 0
        FileName$ = ReadString(#FILE_RunOnce)
        
        ;If Left(FileName$, 7) = "--LINE "
        ;  ; apply the current line commandline option
        ;  InitialSourceLine = Val(Right(FileName$, Len(FileName$)-7))
        ;  If InitialSourceLine > 0 And InitialSourceLine < GetLinesCount(*ActiveSource) ; apply the -l option
        ;    ChangeActiveLine(InitialSourceLine, -5)
        ;  EndIf
        ;ElseIf FileName$ <> ""
        ;  LoadSourceFile(FileName$)
        ;EndIf
        
        ; NOTE: Trying to open the files from here will cause the IDE to lock up on Linux x64,
        ;   so we add the names to this list (which is empty after startup), and the main loop
        ;   checks for the size of this list and opens it from there (see PureBasic.pb)
        ;
        ;   We still have the file reading in here, as all this could happen multiple times in succession
        ;   when PB files are opened by a file explorer etc.
        ;
        AddElement(OpenFilesCommandLine())
        OpenFilesCommandLine() = FileName$
      Wend
      CloseFile(#FILE_RunOnce)
    EndIf
    
    DeleteFile(RunOnceFile$)
    
    ; Still need the SetWindowForeground here, as apparently it has no effect if we delay it until after the X message
    SetWindowForeground(#WINDOW_Main)
    ;ResizeMainWindow()
  EndProcedure
  
  ProcedureC RunOnce_MessageFilter(*XEvent.XClientMessageEvent, *Event._GdkEventClient, user_data)
    Static LastEventSender
    
    If Editor_RunOnce
      If *XEvent\l[0] <> LastEventSender
        RunOnceSignalReceived()
        LastEventSender = *XEvent\l[0]
      EndIf
      ProcedureReturn #GDK_FILTER_REMOVE ; there is only 1 instance, so no need to send this message further
    Else
      ProcedureReturn #GDK_FILTER_CONTINUE
    EndIf
    
  EndProcedure
  
  ; Return true of PID is a running instance of this IDE
  Procedure IsRunningIDEInstance(PID)
    IsRunning = 0
    
    ; the other Instance isn't running (kill with '0' doesn't kill if it is still running, but returns > 0 if the PID is invalid)
    If kill_(PID, 0) = 0
      ;
      ; if the IDE crashes, and then the PC is restarted, the PID in this file could be
      ; in use by another process, which will stop the IDE from starting.
      ; /proc/PID/exe is a symbolic link, so simply check if that leads to the IDE exe
      ;
      ; This code is what ProgramFilename() does, so it can be compared
      ;
      Executable$ = ProgramFilename()
      length      = Len(Executable$)
      File$       = "/proc/"+Str(PID)+"/exe"
      *Buffer     = AllocateMemory(length+20) ; do not use the exe length alone, as else we cannot tell if the link name is longer than that
      
      If *Buffer
        readlength = readlink_(ToAscii(File$), *Buffer, length+20)
        If readlength = length And PeekS(*Buffer, length, #PB_Ascii) = Executable$ ; *Buffer is not 0-terminated!
          IsRunning = 1
        EndIf
        
        FreeMemory(*Buffer)
      EndIf
    EndIf
    
    ProcedureReturn IsRunning
  EndProcedure
  
  Procedure IsEditorRunning()
    IsRunning = 0
    
    If ReadFile(#FILE_RunOnce, TempPath$ + ".purebasic.running")
      PID = Val(ReadString(#FILE_RunOnce))
      CloseFile(#FILE_RunOnce)
      IsRunning = IsRunningIDEInstance(PID)
      
      If IsRunning = 0
        DeleteFile(TempPath$ + ".purebasic.running") ; this was the file of a dead instance so delete it.
      EndIf
    EndIf
    
    If IsRunning = 0
      If CreateFile(#FILE_RunOnce, TempPath$ + ".purebasic.running")
        WriteString(#FILE_RunOnce, Str(getpid_()))
        CloseFile(#FILE_RunOnce)
      EndIf
    EndIf
    
    AlreadyRunning = IsRunning
    ProcedureReturn IsRunning
  EndProcedure
  
  Procedure EmitRunOnceSignal()
    
    Event._GdkEventClient
    Event\type         = #GDK_CLIENT_EVENT
    Event\send_event   = 1
    Event\message_type = gdk_atom_intern_("PureBasic_RunOnceSignal", 0)
    Event\data_format  = 32
    Event\l[0]         = getpid_() ; identify the sender, to filter out multiple arriving signals
    gdk_event_send_clientmessage_toall_(@Event)
    
  EndProcedure
  
  Procedure RunOnce_Startup(InitialSourceLine)
    Result = #False ; do not close IDE
    
    If IsEditorRunning()
      If CreateFile(#FILE_RunOnce, RunOnceFile$)
        ForEach OpenFilesCommandline()
          WriteStringN(#FILE_RunOnce, OpenFilesCommandline())
        Next OpenFilesCommandline()
        If InitialSourceLine <> -1
          WriteStringN(#FILE_RunOnce, "--LINE "+Str(InitialSourceLine)) ; send this option on to the opened IDE (always as last one!)
        EndIf
        CloseFile(#FILE_RunOnce)
        
        EmitRunOnceSignal()
        Result = #True ; close IDE
      EndIf
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure RunOnce_UpdateSetting()
    
    If Editor_RunOnce
      If CreateFile(#FILE_RunOnce, TempPath$ + ".purebasic.running")
        WriteString(#FILE_RunOnce, Str(getpid_()))
        CloseFile(#FILE_RunOnce)
      EndIf
    Else
      DeleteFile(TempPath$ + ".purebasic.running")
    EndIf
    
  EndProcedure
  
  ; Dead session detection
  Procedure Session_IsRunning(OSSessionID$)
    ; The OSSessionID is the PID of the process
    PID = Val(OSSessionID$)
    ProcedureReturn IsRunningIDEInstance(PID)
  EndProcedure
  
  Procedure.s Session_Start()
    ; Return the current PID as the OSSessionID
    ; This can then be used to delect if the session is still active
    ProcedureReturn Str(getpid_())
  EndProcedure
  
  Procedure Session_End(OSSessionID$)
    ; No need to clean up anything
  EndProcedure
  
  
  ProcedureC AutoComplete_FocusSignal(*Window, *Event, user_data)
    
    If AutoCompleteWindowOpen
      If user_data+500 < ElapsedMilliseconds()  ; to ignore the immediate lost focus that seems to be reportet on Mandrake
        AutoComplete_Close()
      EndIf
    EndIf
    
    ProcedureReturn 1
  EndProcedure
  
  
  ProcedureC AutoComplete_TabHandler(*Widget, *Event._GdkEventKey, user_data)
    
    If AutoCompleteWindowOpen
      Accelerators = g_object_get_data_(gtk_widget_get_toplevel_(*Widget), "pb_accelerators")
      If Accelerators
        
        Key = *Event\keyval
        
        ; The TAB shortcut willn't be processed correctly, so catch it here
        ;
        If Key = $FF09 And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Tab
          AutoComplete_Insert()
          ProcedureReturn 1
        EndIf
        
        If *Event\type = #GDK_KEY_PRESS
          
          ; gtk_accel_groups_activate_() works as well for our case, but it's not sure than the shortcut is
          ; really in our accelerator list, so check it. Note the '& $F' for the query, without which it fails
          ;
          If gtk_accel_group_query_(Accelerators, Key, *Event\state & $F, @NbEntriesFound)
            ProcedureReturn gtk_accel_groups_activate_(gtk_widget_get_toplevel_(*Widget), Key, *Event\state)
          EndIf
          
        EndIf
      EndIf
      
      ; close autocomplete on PGUP/DOWN, LEFT and RIGHT
      If *Event\keyval = #GDK_Prior Or *Event\keyval = #GDK_Next Or *Event\keyval = #GDK_Left Or *Event\keyval = #GDK_Right
        AutoComplete_Close()
        
      ElseIf *Event\keyval <> $FF52  And *Event\keyval <> $FF54
        gtk_widget_event_(GadgetID(*ActiveSource\EditorGadget), *Event)  ; pass on any events except for up/down to the editor
        ProcedureReturn 1
        
      EndIf
    EndIf
    
    ProcedureReturn 0
  EndProcedure
  
  
  Procedure AutoComplete_SetFocusCallback()
    
    ; set the tab handler for the gadget
    ;
    GtkSignalConnect(GadgetID(#GADGET_AutoComplete_List), "key-press-event", @AutoComplete_TabHandler(), 0)
    GtkSignalConnect(GadgetID(#GADGET_AutoComplete_List), "key-release-event", @AutoComplete_TabHandler(), 0)
    
    ; set up a callback to close the autocomplete window if the user selects some other window
    ;
    GtkSignalConnect(WindowID(#WINDOW_AutoComplete), "focus-out-event", @AutoComplete_FocusSignal(), ElapsedMilliseconds())
    
  EndProcedure
  
  
  Procedure AutoComplete_AdjustWindowSize(MaxWidth, MaxHeight)
  EndProcedure
  
  
  Procedure ToolsPanel_ApplyColors(Gadget)
    
    ; Disable ToolsPanel colors for Linux, because of the background
    ; color bug of GtkTreeView based gadgets that we have no fix for so far.
    ; Better no color than this ugly color change.
    ;
    ; NOTE: This bug seems to be gone, all is working OK in ubuntu 11.04 and PB v4.70
    
    If Gadget = propgrid
      grid_SetGadgetColor(Gadget, #Grid_Color_Background, ToolsPanelBackColor)
      grid_SetDefaultStyle(Gadget,P_FontGrid, #P_FontGridSize, ToolsPanelFrontColor)
      
    Else
      If ToolsPanelUseColors
        SetGadgetColor(Gadget, #PB_Gadget_FrontColor, ToolsPanelFrontColor)
        SetGadgetColor(Gadget, #PB_Gadget_BackColor, ToolsPanelBackColor)
      EndIf
      
      If ToolsPanelFontID <> #PB_Default
        SetGadgetFont(Gadget, ToolsPanelFontID)
      EndIf
    EndIf
  EndProcedure
  
  
CompilerEndIf
