; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



; first must of course be the shared compiling flags:
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    XIncludeFile "..\PureBasicIDE\CompilerFlags.pb"
  CompilerCase #PB_OS_Linux
    XIncludeFile "../PureBasicIDE/CompilerFlags.pb"
  CompilerCase #PB_OS_MacOS
    XIncludeFile "../PureBasicIDE/CompilerFlags.pb"
CompilerEndSelect

; next must be the debugger common file and the standalone common stuff
XIncludeFile "DebuggerCommon.pb"
XIncludeFile "Standalone_Common.pb"

XIncludeFile ".."+#Separator+"PureBasicConfigPath.pb"

; must be here to affect all OpenWindow() calls with a macro
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"LinuxWindowIcon.pb"

; Gadget Size file from dialog manager
;
XIncludeFile ".." + #Separator + "DialogManager" + #Separator + "GetRequiredSize.pb"

; include non-debugger files of the IDE
;
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"Macro.pb"
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"LinuxExtensions.pb"
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"WindowsExtensions.pb"
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"MacExtensions.pb"

XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"WindowsDebugging.pb" ; has IDE dependencies, not really needed anyway
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"LinuxDebugging.pb"

XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"FileSystem.pb"
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"Misc.pb"
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"Language.pb"
XIncludeFile ".."+#Separator+"PureBasicIDE"+#Separator+"HighlightingEngine.pb"

; include shared debugger files
;
XIncludeFile "Misc.pb"
XIncludeFile "VariableGadget.pb"
XIncludeFile "Communication_PipeWindows.pb"
XIncludeFile "Communication_PipeUnix.pb"
XIncludeFile "Communication.pb"
XIncludeFile "DebugOutput.pb"
XIncludeFile "AsmDebug.pb"
XIncludeFile "MemoryViewer.pb"
XIncludeFile "VariableDebug.pb"
XIncludeFile "History.pb"
XIncludeFile "DataBreakPoints.pb"
XIncludeFile "WatchList.pb"
XIncludeFile "LibraryViewer.pb"
XIncludeFile "Profiler.pb"
XIncludeFile "Purifier.pb"
XIncludeFile "DebuggerGUI.pb"

; Plugins for LibraryViewer
XIncludeFile "Plugin_Image.pb"
XIncludeFile "Plugin_Xml.pb"

; include standalone only files
;
XIncludeFile "Standalone_Preferences.pb"
XIncludeFile "Standalone_ScintillaStuff.pb"
XIncludeFile "Standalone_GUI.pb"

Procedure FindBreakpoint(Line)
  ForEach BreakPoints()
    If Breakpoints() = Line
      ProcedureReturn 1
    EndIf
  Next Breakpoints()
  
  ProcedureReturn 0
EndProcedure

;- Detect Preference Paths
;
CompilerSelect #PB_Compiler_OS
    
  CompilerCase #PB_OS_Windows
    
    ; Mutex so the setup knows a PB program is running
    ; There is no CloseHandle_(), so the mutex stays open until the program ends
    CreateMutex_(#Null, #False, "PureBasic_Running")
    
    PureBasicPath$ = Space(#MAX_PATH)
    GetModuleFileName_(GetModuleHandle_(#Null$), @PureBasicPath$, #MAX_PATH)
    PureBasicPath$ = GetPathPart(PureBasicPath$)
    
    ; we are in the compilers directory, so cut the \Compilers\
    ;
    If UCase(Right(PureBasicPath$, 10)) = "COMPILERS\"
      PureBasicPath$ = Left(PureBasicPath$, Len(PureBasicPath$)-10)
    EndIf
    
    CurrentDirectory$ = Space(2000)
    GetCurrentDirectory_(2000, @CurrentDirectory$)
    If Trim(CurrentDirectory$) = ""
      CurrentDirectory$ = ""
    EndIf
    
    ; initialize the scintilla dll
    CompilerIf #PB_Compiler_Version < 610
      InitScintilla(PureBasicPath$+"Compilers\Scintilla.dll")
    CompilerEndIf
    
  CompilerDefault
    PureBasicPath$ = GetEnvironmentVariable("PUREBASIC_HOME")
    
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
        PureBasicPath$ = "/usr/share/purebasic/" ; absolute fallback
      EndIf
    EndIf
    ; Get the current directory
    ;
    CurrentDirectory$ = GetCurrentDirectory()
    
CompilerEndSelect


; Add the Compiler directory to the (library-)path, so the 3D engine and other
; libraries can be loaded by the exe
;
CompilerIf #CompileWindows
  PreviousPath$ = GetEnvironmentVariable("PATH")
  SetEnvironmentVariable("PATH", PureBasicPath$+"Compilers\;"+PreviousPath$)
CompilerEndIf

CompilerIf #CompileLinux
  PreviousPath$ = GetEnvironmentVariable("LD_LIBRARY_PATH")
  SetEnvironmentVariable("LD_LIBRARY_PATH", PureBasicPath$+"compilers/:"+PreviousPath$)
CompilerEndIf

CompilerIf #CompileMac
  PreviousPath$ = GetEnvironmentVariable("DYLD_LIBRARY_PATH")
  SetEnvironmentVariable("DYLD_LIBRARY_PATH", PureBasicPath$+"compilers/:"+PreviousPath$)
CompilerEndIf


;- startup


;
; Commandline:
;   pbdebugger <exefile> [<exe commandline>]
;   pbdebugger [-o <filename>] [<exefile>] [<exe commandline>]
;
; The -o option allows to pass a file to the debugger, which can be used to communicate
; stuff like breakpoints or watchlist objects to it.
;
; The format of the file is "KEYWORD OPTION" (separated by ONE space)
; The following options can be specified:
;
; Important: The file is UTF-8 encoded for compatibility between unicode debugger and ascii ide etc.
;
; PREFERENCES <filename>
;   allows to set the full path for the PureBasic.prefs from which the debugger loads its options
;
; EXEFILE <filename>
;   allows to specify the executable to execute in this file. if this is given,
;   the <exefile> option on the commandline will be ignored
;
; COMMANDLINE <string>
;   allows to specify the commandline for the executable in this file, the commandline
;   given to the debugger will be ignored
;
; SOURCEFILE <filename>
;   allows to overwrite the "Main Source" filename, as it is stored in the debugged executable.
;   This is useful for editors that store the main file in a temporary location before compiling.
;   This can be used to still display the correct filename
;   It must be a full path!
;
; WARNINGS <mode>
;   Set the warning mode for the debugger. If not set, the preferences default is used.
;   <mode> can be:
;     IGNORE   ignore all warnings
;     DISPLAY  display warnings (do not stop execution)
;     ERROR    treat warnings just like errors
;
; WATCH <watctlist item>
;   add one item to the watchlist. This is the variable name for global variables/Arrays/Lists
;   or "ProcedureName()>VariableName" for local variables.
;   Multiple WATCH statements are possible
;
; BREAK <linenumber> [,<filename>]
;   add one breakpoint. If the filename is not given, the specified line will be marked
;   in the main source. <filename> MUST contain a full path!
;   Do not specify the <filename> for the main file, it will not work.
;   <linenumber> is one based.
;
;   There can be BREAK statements for files that are not compiled with the main source,
;   these will just be ignored. So you can just add a break line for all open sources in
;   your editor, without the need to worry, which will actually get compiled
;
;   Multiple BREAK statements are possible
;
; PURIFIER <granularity>
;   Specify the purifier granularities (comma separated: Global, local, string, dynamic)
;   This is ignored if the purifier is not enabled
;   This will be set on shutdown if the purifier was enabled (to specify the chosen settings)
;
; At debugger end, the debugger will overwrite the file with the current set
; watchlist items and breakpoints.
; So after debugger quit, there will only be WATCH, BREAK and PURIFIER statements in the file,
; the others are not passed back.


;
;- Parse Commandline
ExeName$  = ProgramParameter()
ExeNameU$ = UCase(ExeName$)

PurifierSettings$ = ""

If ExenameU$ = "-O"  ; Check for the Parameter of the Option file
  OptionsFile$ = ProgramParameter()
  ExeName$ = ProgramParameter()
Else
  OptionsFile$ = ""
EndIf

; Read remaining commandline
;
CommandLine$ = ""
Repeat
  Parameter$ = ProgramParameter()
  If Parameter$ <> ""
    CommandLine$ + " " + Chr(34)+Parameter$+Chr(34) ; enclose all parameters in "" (they may contain spaces!)
  EndIf
Until Parameter$ = ""
CommandLine$ = LTrim(CommandLine$) ; remove that extra space

CompilerIf #PB_Compiler_Debugger
  ;
  ; do this after reading the commandline, so we don't mess up the index
  ;
  Debug "--- Standalone debugger commandline ---"
  For i = 0 To CountProgramParameters()-1
    Debug ProgramParameter(i)
  Next i
  Debug "--- End commandline ---"
CompilerEndIf

; The OSX "open" command cuts the commandline parameters, so we
; use a fixed filename for this case. Ugly, but works
;
CompilerIf #CompileMac
  If OptionsFile$ = "" And ExeName$ = ""
    OptionsFile$ = "/tmp/.pbstandalone.out"
  EndIf
CompilerEndIf

;- parse options file
;
CustomWarningMode = -1

; Ignore the default OS X file as well as it's empty anyway
If OptionsFile$ <> "" And OptionsFile$ <> "/tmp/.pbstandalone.out"
  If ReadFile(0, OptionsFile$)
    
    While Eof(0) = 0
      Line$ = ReadString(0, #PB_UTF8)
      Option$ = UCase(StringField(Line$, 1, " "))
      Value$  = Trim(Right(Line$, Len(Line$)-Len(Option$)))
      
      Select Option$
        Case "EXEFILE"    : ExeName$ = Value$
        Case "COMMANDLINE": Commandline$ = Value$
        Case "SOURCEFILE" : MainFileName$ = Value$
        Case "PREFERENCES": PreferenceFile$ = Value$
          
        Case "PURIFIER": PurifierSettings$ = Value$
          
          ; if this option is not set, we use the preferences default
        Case "WARNINGS"
          Select UCase(Value$)
            Case "IGNORE" : CustomWarningMode = 0
            Case "DISPLAY": CustomWarningMode = 1
            Case "ERROR"  : CustomWarningMode = 2
          EndSelect
          
          CompilerIf #CompileMac = 0 ; Recalling the watchlist and breakpoint makes the debugger crash :(. There is still something weird here
          Case "WATCH"
            AddElement(Watchlist())
            Watchlist() = Value$
          Case "BREAK"
            AddElement(BreakpointStrings())
            BreakpointStrings() = Value$
          CompilerEndIf
      EndSelect
    Wend
    
    CloseFile(0)
  Else
    ; Don't use Language() here, as it's not yet initialized
    MessageRequester("PureBasic Debugger","Can't read option file: "+OptionsFile$, #FLAG_Warning)
  EndIf
EndIf

If PreferenceFile$ = "" ; only set if not done through the options file
  CompilerIf #CompileWindows
    PreferenceFile$ = PureBasicConfigPath() + "PureBasic.prefs"
  CompilerElse
    PreferenceFile$ = PureBasicConfigPath() + "purebasic.prefs"
  CompilerEndIf
EndIf

;- init stuff

Standalone_LoadPreferences()
LoadLanguage() ; ide function

If CustomWarningMode <> -1
  WarningMode = CustomWarningMode
EndIf

If Standalone_CreateGUI() = 0
  MessageRequester("PureBasic Debugger","FATAL ERROR! Cannot create GUI.", #FLAG_Error)
  End
EndIf

SetupHighlighting()

EnsureWindowOnDesktop(#WINDOW_Main)
If IsDebuggerMaximized
  ShowWindowMaximized(#WINDOW_Main)
Else
  HideWindow(#WINDOW_Main, 0)
EndIf

Standalone_ResizeGUI()

;- start executable

If ExeName$ = ""
  MessageRequester("PureBasic Debugger",Language("StandaloneDebugger","Commandline"), #FLAG_Error)
  End
EndIf

; Here is a problem: On Mac, the current directory is always 'pbdebugger.app/Contents/MacOS', no matter
; where this was started from. This is a problem when the debugger is launched from commandline, as the
; exe to start is not found then!
; The PWD env var seems to remain correct, so use this instead here.
;
; When launched from the IDE, the PWD is the path of the external debugger (PBDebugger.app/Content/MacOS)
; so we use the path of the main file
;
CompilerIf #CompileMac
  If MainFileName$
    CurrentDirectory$ = GetPathPart(MainFileName$)
  Else
    CurrentDirectory$ = GetEnvironmentVariable("PWD")
    SetCurrentDirectory(CurrentDirectory$) ; needed, so RunProgram() finds a local file correctly!
  EndIf
CompilerEndIf

DebuggerUseFIFO = 0 ; no need for this here
*DebuggerData = Debugger_ExecuteProgram(ExeName$, CommandLine$, CurrentDirectory$)
If *DebuggerData = 0
  MessageRequester("PureBasic Debugger",ReplaceString(Language("StandaloneDebugger","ExecuteError"), "%filename%", ExeName$), #FLAG_Error)
  End
EndIf

Standalone_AddLog(Language("Debugger","Waiting"), Date())
StatusBarText(#STATUSBAR, 0, Language("Debugger","Waiting"))


;- Event processing

Procedure ProcessEvent(EventID)
  
  ; process the all-window shortcuts
  If EventID = #PB_Event_Menu
    Select EventMenu()
        
        ; Handle the "Quit" menu on OS X
        ;
        CompilerIf #CompileMac
        Case #PB_Menu_Quit
          Standalone_Quit = 1
        CompilerEndIf
        
      Case #MENU_Stop
        Command.CommandInfo\Command = #COMMAND_Stop
        SendDebuggerCommand(*DebuggerData, @Command)
        ; program state will be updated once the executable responds
        
      Case #MENU_Step
        Command.CommandInfo\Command = #COMMAND_Step
        Command\Value1 = Val(GetGadgetText(#GADGET_StepCount))
        SendDebuggerCommand(*DebuggerData, @Command)
        *DebuggerData\ProgramState = -2; step mode
        UpdateGadgetStates()
        
      Case #MENU_StepOver
        Command.CommandInfo\Command = #COMMAND_Step
        Command\Value1 = -1 ; step over
        SendDebuggerCommand(*DebuggerData, @Command)
        *DebuggerData\ProgramState = -2; step mode
        UpdateGadgetStates()
        
      Case #MENU_StepOut
        Command.CommandInfo\Command = #COMMAND_Step
        Command\Value1 = -2 ; step out
        SendDebuggerCommand(*DebuggerData, @Command)
        *DebuggerData\ProgramState = -2; step mode
        UpdateGadgetStates()
        
      Case #MENU_Run
        Command.CommandInfo\Command = #COMMAND_Run
        Command\Value1 = 1 ; asks the debugger to respond to with the "comtinued" message
        SendDebuggerCommand(*DebuggerData, @Command)
        ; program state will be updated once the executable responds
        
    EndSelect
  EndIf
  
  If EventWindow() = #WINDOW_Main
    
    If EventID = #PB_Event_CloseWindow
      If *DebuggerData\IsPurifier
        PurifierSettings$ =  GetPurifierOptions(*DebuggerData)
      EndIf
      Debugger_ForceDestroy(*DebuggerData)
      Standalone_Quit = 1
      
    ElseIf EventID = #PB_Event_SizeWindow
      Standalone_ResizeGUI()
      
    ElseIf EventID = #PB_Event_Gadget
      Select EventGadget()
          
        Case #GADGET_Minimize
          IsMiniDebugger = 1
          HideGadget(#GADGET_Minimize, 1)
          HideGadget(#GADGET_Log, 1)
          HideGadget(#GADGET_Maximize, 0)
          Standalone_ResizeGUI()
          
        Case #GADGET_Maximize
          IsMiniDebugger = 0
          HideGadget(#GADGET_Minimize, 0)
          HideGadget(#GADGET_Log, 0)
          HideGadget(#GADGET_Maximize, 1)
          If WindowHeight(#WINDOW_Main) < 260
            ResizeWindow(#WINDOW_Main, #PB_Ignore, #PB_Ignore, WindowWidth(#WINDOW_Main), 260)
          EndIf
          Standalone_ResizeGUI()
          
        Case #GADGET_Stop
          Command.CommandInfo\Command = #COMMAND_Stop
          SendDebuggerCommand(*DebuggerData, @Command)
          ; program state will be updated once the executable responds
          
        Case #GADGET_Run
          Command.CommandInfo\Command = #COMMAND_Run
          Command\Value1 = 1 ; asks the debugger to respond to with the "comtinued" message
          SendDebuggerCommand(*DebuggerData, @Command)
          ; program state will be updated once the executable responds
          
          
        Case #GADGET_Step
          Command.CommandInfo\Command = #COMMAND_Step
          Command\Value1 = Val(GetGadgetText(#GADGET_StepCount))
          SendDebuggerCommand(*DebuggerData, @Command)
          *DebuggerData\ProgramState = -2; step mode
          UpdateGadgetStates()
          
        Case #GADGET_StepOver
          Command.CommandInfo\Command = #COMMAND_Step
          Command\Value1 = -1
          SendDebuggerCommand(*DebuggerData, @Command)
          *DebuggerData\ProgramState = -2; step mode
          UpdateGadgetStates()
          
        Case #GADGET_StepOut
          Command.CommandInfo\Command = #COMMAND_Step
          Command\Value1 = -2
          SendDebuggerCommand(*DebuggerData, @Command)
          *DebuggerData\ProgramState = -2; step mode
          UpdateGadgetStates()
          
        Case #GADGET_Quit
          If *DebuggerData\IsPurifier
            PurifierSettings$ =  GetPurifierOptions(*DebuggerData)
          EndIf
          Debugger_ForceDestroy(*DebuggerData)
          Standalone_Quit = 1
          
        Case #GADGET_BreakSet   ; Now set/remove breakpoint
          If IsBreakPoint()
            Line = UnmarkBreakPoint() ; marks the point and returns the line number
            If Line <> -1 And FindBreakpoint(Line) = 1
              Command.CommandInfo\Command = #COMMAND_BreakPoint
              Command\Value1 = 2
              Command\Value2 = Line
              SendDebuggerCommand(*DebuggerData, @Command)
              DeleteElement(Breakpoints())
            EndIf
            
          Else
            Line = MarkBreakPoint() ; marks the point and returns the line number
            If Line <> -1 And FindBreakpoint(Line) = 0
              Command.CommandInfo\Command = #COMMAND_BreakPoint
              Command\Value1 = 1
              Command\Value2 = Line
              SendDebuggerCommand(*DebuggerData, @Command)
              AddElement(Breakpoints())
              Breakpoints() = Line
            EndIf
          EndIf
          
        Case #GADGET_BreakClear
          ClearBreakPoints() ; clears all marked breakpoints in the current file
          Command.CommandInfo\Command = #COMMAND_BreakPoint
          Command\Value1 = 3
          Command\Value2 = CurrentSource
          SendDebuggerCommand(*DebuggerData, @Command)
          ForEach Breakpoints()
            If DebuggerLineGetFile(Breakpoints()) = CurrentSource
              If ListIndex(Breakpoints()) = 1
                DeleteElement(Breakpoints())
                ResetList(Breakpoints())
              Else
                DeleteElement(Breakpoints())
              EndIf
            EndIf
          Next Breakpoints()
          
        Case #GADGET_SelectSource
          If GetGadgetState(#GADGET_SelectSource) <> CurrentSource
            If SourceFiles(CurrentSource)\IsLoaded
              HideGadget(SourceFiles(CurrentSource)\Gadget, 1)
            EndIf
            
            CurrentSource = GetGadgetState(#GADGET_SelectSource)
            If CurrentSource <> -1
              If SourceFiles(CurrentSource)\IsLoaded
                HideGadget(SourceFiles(CurrentSource)\Gadget, 0)
              Else
                SourceFiles(CurrentSource)\Gadget = LoadSource(SourceFiles(CurrentSource)\FileName$)
                If SourceFiles(CurrentSource)\Gadget
                  SourceFiles(CurrentSource)\IsLoaded = 1
                Else
                  HideGadget(#GADGET_Waiting, 0) ; display this again
                  If *DebuggerData\IsNetwork And *DebuggerData\ProgramState <> -1 And SourceFiles(CurrentSource)\IsRequested = 0
                    ; in network mode, try to receive the file from the exe if we cannot load it here
                    Command.CommandInfo\Command = #COMMAND_GetFile
                    Command\Value1 = CurrentSource
                    SendDebuggerCommand(*DebuggerData, @Command)
                    SourceFiles(CurrentSource)\IsRequested = 1
                  EndIf
                EndIf
              EndIf
              Standalone_ResizeGUI()
            Else
              CurrentSource = 0
            EndIf
          EndIf
          
        Case #GADGET_DataBreak
          If GetGadgetState(#GADGET_DataBreak)
            OpenDataBreakpointWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_DataBreakPoints], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Debug
          If GetGadgetState(#GADGET_Debug)
            OpenDebugWindow(*DebuggerData, #True)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Debug], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Watchlist
          If GetGadgetState(#GADGET_Watchlist)
            OpenWatchListWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Watchlist], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Variables
          If GetGadgetState(#GADGET_Variables)
            OpenVariableWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Variable], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Profiler
          If GetGadgetState(#GADGET_Profiler)
            OpenProfilerWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Profiler], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_History
          If GetGadgetState(#GADGET_History)
            OpenHistoryWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_History], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Memory
          If GetGadgetState(#GADGET_Memory)
            OpenMemoryViewerWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Memory], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Library
          If GetGadgetState(#GADGET_Library)
            OpenLibraryViewerWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Library], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Assembly
          If GetGadgetState(#GADGET_Assembly)
            OpenAsmWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Asm], #PB_Event_CloseWindow)
          EndIf
          
        Case #GADGET_Purifier
          If GetGadgetState(#GADGET_Purifier)
            OpenPurifierWindow(*DebuggerData)
          Else
            Debugger_ProcessEvents(*DebuggerData\Windows[#DEBUGGER_WINDOW_Purifier], #PB_Event_CloseWindow)
          EndIf
          
      EndSelect
      
    EndIf
    
  Else
    
    ; dispatch the event to the right procedure
    Debugger_ProcessEvents(EventWindow(), EventID)
    
    If EventID = #PB_Event_CloseWindow
      ; update the toggle buttons
      ; Note: On OSX, we can get this somehow when the debugger struct is already destroyed (when you end the
      ; program, close all debugger windows and then close the main one), so check this!
      ;
      If IsDebuggerValid(*DebuggerData)
        SetGadgetState(#GADGET_Debug, *DebuggerData\IsDebugOutputVisible)
        SetGadgetState(#GADGET_Watchlist, *DebuggerData\IsWatchlistVisible)
        SetGadgetState(#GADGET_Variables, *DebuggerData\Windows[#DEBUGGER_WINDOW_Variable])
        SetGadgetState(#GADGET_Profiler, *DebuggerData\Windows[#DEBUGGER_WINDOW_Profiler])
        SetGadgetState(#GADGET_History, *DebuggerData\Windows[#DEBUGGER_WINDOW_History])
        SetGadgetState(#GADGET_Memory, *DebuggerData\Windows[#DEBUGGER_WINDOW_Memory])
        SetGadgetState(#GADGET_Library, *DebuggerData\Windows[#DEBUGGER_WINDOW_Library])
        SetGadgetState(#GADGET_Assembly, *DebuggerData\Windows[#DEBUGGER_WINDOW_Asm])
        SetGadgetState(#GADGET_DataBreak, *DebuggerData\DataBreakpointsVisible)
        SetGadgetState(#GADGET_Purifier, *DebuggerData\Windows[#DEBUGGER_WINDOW_Purifier])
      EndIf
      
    EndIf
    
  EndIf
  
  ProcedureReturn EventID
EndProcedure

Procedure FlushEvents()
  While ProcessEvent(WindowEvent())
  Wend
EndProcedure

;- main loop
Standalone_Quit = 0
Repeat
  EventID = WindowEvent()
  
  If EventID = 0
    If Debugger_ProcessIncomingCommands() = 0 ; process debugger commands
      Delay(1)                                 ; delay only when no commands were incoming
    EndIf
  Else
    ProcessEvent(EventID)
  EndIf
Until Standalone_Quit <> 0

;- program end

If ListSize(RunningDebuggers()) <> 0
  Debugger_ForceDestroy(*DebuggerData)
EndIf

If DebuggerMemorizeWindows And IsWindowMinimized(#WINDOW_Main) = 0
  IsDebuggerMaximized = IsWindowMaximized(#WINDOW_Main)
  If IsDebuggerMaximized = 0
    DebuggerMainWindowX = WindowX(#WINDOW_Main)
    DebuggerMainWindowY = WindowY(#WINDOW_Main)
    DebuggerMainWindowWidth = WindowWidth(#WINDOW_Main)
    DebuggerMainWindowHeight = WindowHeight(#WINDOW_Main)
  EndIf
EndIf

Standalone_SavePreferences()

If OptionsFile$ <> ""
  If CreateFile(0, OptionsFile$)
    
    CompilerIf #CompileMac = 0
      ForEach Watchlist()
        WriteStringN(0, "WATCH "+Watchlist())
      Next Watchlist()
      
      ForEach Breakpoints()
        If DebuggerLineGetFile(Breakpoints()) = 0
          WriteStringN(0, "BREAK "+Str(DebuggerLineGetLine(Breakpoints()) + 1))
        Else
          WriteStringN(0, "BREAK "+Str(DebuggerLineGetLine(Breakpoints()) + 1) + ", " + SourceFiles(DebuggerLineGetFile(Breakpoints()))\FileName$)
        EndIf
      Next Breakpoints()
      
      If PurifierSettings$
        WriteStringN(0, "PURIFIER " + PurifierSettings$)
      EndIf
    CompilerEndIf
    
    CloseFile(0)
  EndIf
EndIf

End


; main debugger command callback
;
Procedure DebuggerCallback(*Debugger.DebuggerData)
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_FatalError  ; fatal communication error
      Select *Debugger\Command\Value1
        Case #ERROR_Memory
          Text$ = Language("Debugger", "MemoryError")
        Case #ERROR_Pipe
          Text$ = Language("Debugger", "PipeError")
        Case #ERROR_ExeQuit
          Text$ = Language("Debugger", "ExeQuitError")
        Case #ERROR_Timeout
          Text$ = Language("Debugger", "TimeoutError")
        Case #ERROR_Version
          Text$ = Language("Debugger", "VersionError")
        Case #ERROR_NetworkFail
          Text$ = Language("Debugger", "NetworkError")
      EndSelect
      
      Text$ = StringField(Text$, 1, Left(#NewLine, 1)) ; first line only
      Standalone_AddLog(Text$, *Debugger\Command\TimeStamp)
      StatusBarText(#STATUSBAR, 0, Text$)
      
      UpdateGadgetStates()
      Debugger_End(*Debugger)
      
      ; these may lead to a crash if activated now
      DisableGadget(#GADGET_Debug, 1)
      DisableGadget(#GADGET_Watchlist, 1)
      DisableGadget(#GADGET_Variables, 1)
      DisableGadget(#GADGET_Profiler, 1)
      DisableGadget(#GADGET_History, 1)
      DisableGadget(#GADGET_Memory, 1)
      DisableGadget(#GADGET_Library, 1)
      DisableGadget(#GADGET_Assembly, 1)
      DisableGadget(#GADGET_DataBreak, 1)
      
      
    Case #COMMAND_Init
      If *Debugger\IncludedFiles ; use the filename as stored in the exe
        SourcePath$   = PeekUTF8(*Debugger\IncludedFiles)
        RealFileName$ = PeekUTF8(*Debugger\IncludedFiles + MemoryAsciiLength(*Debugger\IncludedFiles) + 1)
        RealFileName$ = ResolveRelativePath(SourcePath$, RealFileName$) ; the stored main file is relative to the source path
      EndIf
      
      ; if real filename was passed, use this for displaying
      If MainFileName$ <> ""
        If *Debugger\IncludedFiles
          SourcePath$ = PeekUTF8(*Debugger\IncludedFiles) ; first is the source path
          *Debugger\FileName$ = CreateRelativePath(SourcePath$, MainFileName$)
        Else
          *Debugger\FileName$ = MainFileName$
        EndIf
      Else
        *Debugger\FileName$ = RealFileName$
      EndIf
      
      SetWindowTitle(#WINDOW_Main, "PureBasic Debugger - "+GetFilePart(*Debugger\FileName$))
      
      ; Do this to update the Filename for all "automatic open" windows (else it remains empty!)
      Debugger_UpdateWindowPreferences()
      
      NbSourceFiles = *Debugger\NbIncludedFiles
      CurrentSource = 0
      Global Dim SourceFiles.DisplayedSource(NbSourceFiles)
      
      ; add all file to the list
      For i = 0 To NbSourceFiles
        SourceFiles(i)\FileName$ = GetDebuggerFile(*Debugger, i << #DEBUGGER_DebuggerLineFileOffset)
        AddGadgetItem(#GADGET_SelectSource, -1, GetDebuggerRelativeFile(*Debugger, i << #DEBUGGER_DebuggerLineFileOffset))
      Next i
      
      ; translate the debugger breakpoint strings into line numbers
      ; (must be done before the main source is loaded, so its breakpoints get shown)
      ;
      ForEach BreakpointStrings()
        If FindString(BreakpointStrings(), ",", 1) <> 0
          x = FindString(BreakpointStrings(), ",", 1)
          FileName$ = Trim(Right(BreakpointStrings(), Len(BreakpointStrings())-x))
          
          ; For projects, even the main file could be given as "BREAK line, filename" because we do not
          ; check which file is the current target's main file. So we must check the "real file name" as well here
          ;
          If IsEqualFile(FileName$, RealFileName$)
            AddElement(Breakpoints())
            Breakpoints() = (Val(Trim(Left(BreakpointStrings(), x-1)))-1)
          Else
            For i = 0 To NbSourceFiles
              If IsEqualFile(FileName$, SourceFiles(i)\FileName$)
                AddElement(Breakpoints())
                Breakpoints() = MakeDebuggerLine(i, Val(Trim(Left(BreakpointStrings(), x-1)))-1)
                Break
              EndIf
            Next i
          EndIf
        Else
          AddElement(Breakpoints())
          Breakpoints() = Val(Trim(BreakpointStrings()))-1
        EndIf
        
      Next BreakpointStrings()
      ClearList(BreakpointStrings()) ; no longer needed
      
      ; set this so it is visible in case the files are not loadable (when network debugging for example)
      SetGadgetText(#GADGET_Waiting, Language("StandaloneDebugger","NoFile"))
      
      SourceFiles(0)\Gadget = LoadSource(RealFileName$) ; the main source is loaded by its real name, not the displayed one
      If SourceFiles(0)\Gadget
        SourceFiles(0)\IsLoaded = 1
        HideGadget(#GADGET_Waiting, 1)
      ElseIf *Debugger\IsNetwork
        ; in network mode, try to receive the file from the exe if we cannot load it here
        Command.CommandInfo\Command = #COMMAND_GetFile
        Command\Value1 = 0
        SendDebuggerCommand(*Debugger, @Command)
        SourceFiles(0)\IsRequested = 1
      EndIf
      SetGadgetState(#GADGET_SelectSource, 0) ; set current source
      CurrentSource = 0
      Standalone_ResizeGUI()
      
      ; at the init command, the windows that are set to autoopen are opened automatically
      ; so we update the toggle buttons accordingly
      ;
      SetGadgetState(#GADGET_Debug, AutoOpenDebugOutput)
      SetGadgetState(#GADGET_Watchlist, AutoOpenWatchlist)
      SetGadgetState(#GADGET_Variables, AutoOpenVariableViewer)
      SetGadgetState(#GADGET_Profiler, AutoOpenProfiler)
      SetGadgetState(#GADGET_History, AutoOpenHistory)
      SetGadgetState(#GADGET_Memory, AutoOpenMemoryViewer)
      SetGadgetState(#GADGET_Assembly, AutoOpenAsmWindow)
      SetGadgetState(#GADGET_Library, AutoOpenLibraryViewer)
      SetGadgetState(#GADGET_DataBreak, AutoOpenDataBreakpoints)
      SetGadgetState(#GADGET_Purifier, AutoOpenPurifier)
      
      ; Set the warning mode
      ;
      Command.CommandInfo\Command = #COMMAND_WarningMode
      Command\Value1 = WarningMode
      SendDebuggerCommand(*Debugger, @Command)
      
      ; Set purifier options (ignored if purifier is off)
      If PurifierSettings$
        ApplyDefaultPurifierOptions(*Debugger, PurifierSettings$)
      EndIf
      
    Case #COMMAND_File
      If *Debugger\Command\Value2 And *Debugger\CommandData ; indicates if the file was available
        Index = *Debugger\Command\Value1
        If SourceFiles(Index)\IsLoaded = 0
          
          ; Try to detect UTF-8 BOM if any
          ;
          If *Debugger\Command\DataSize > 3 And
             PeekA(*Debugger\CommandData)   = $EF And
             PeekA(*Debugger\CommandData+1) = $BB And
             PeekA(*Debugger\CommandData+2) = $BF
            Format = #PB_UTF8
          Else
            Format = #PB_Ascii
          EndIf
          
          SourceFiles(Index)\Gadget = LoadSourceBuffer(*Debugger\CommandData, *Debugger\Command\DataSize, Format)
          If SourceFiles(Index)\Gadget
            SourceFiles(Index)\IsLoaded = 1
            
            If Index <> CurrentSource
              HideGadget(SourceFiles(Index)\Gadget, 1)
            Else
              HideGadget(#GADGET_Waiting, 1) ; must be currently visible if Index=CurrentSource
            EndIf
            
            ; Apply any delayed actions to the file now that it is loaded
            ForEach DelayedActions()
              If DelayedActions()\FileIndex = Index
                SourceLineAction(DelayedActions()\Line, DelayedActions()\Action)
                DeleteElement(DelayedActions())
              EndIf
            Next DelayedActions()
            
            Standalone_ResizeGUI() ; resize it correctly
          EndIf
        EndIf
      EndIf
      
    Case #COMMAND_Procedures
      ; now transmit all breakpoints
      ForEach BreakPoints()
        Command.CommandInfo\Command = #COMMAND_BreakPoint
        Command\Value1 = 1 ; add
        Command\Value2 = Breakpoints()
        SendDebuggerCommand(*Debugger, @Command)
      Next Breakpoints()
      
      ; now transmit the watchlist objects
      ForEach Watchlist()
        If FindString(Watchlist(), ">", 1) = 0
          ProcIndex = -1
          Variable$ = Watchlist()
        Else
          ProcName$ = UCase(RemoveString(StringField(Watchlist(), 1, ">"), "()"))
          Variable$ = StringField(Watchlist(), 2, ">")
          
          ProcIndex = -1  ; get the index of this procedure in the list
          If *Debugger\Procedures
            *pointer = *Debugger\Procedures
            For i = 0 To *Debugger\NbProcedures-1
              Proc$ = UCase(PeekAscii(*pointer))
              *pointer + MemoryAsciiLength(*pointer) + 1
              ModName$ = UCase(PeekAscii(*pointer))
              *pointer + MemoryAsciiLength(*pointer) + 1
              
              If ModuleName(Proc$, ModName$) = ProcName$
                ProcIndex = i
                Break
              EndIf
            Next i
          EndIf
        EndIf
        
        ; Convert to UTF8 to correctly preserve Map keys (which may contain unicode chars)
        UTF8Length = StringByteLength(Variable$) + 1
        VariableUTF8$ = Space(UTF8Length)
        PokeS(@VariableUTF8$, Variable$, -1, #PB_UTF8)
        
        Command.CommandInfo\Command = #COMMAND_WatchlistAdd
        Command\Value1 = ProcIndex
        Command\Value2 = 0 ; report no errors!
        Command\DataSize = UTF8Length
        SendDebuggerCommandWithData(*Debugger, @Command, @VariableUTF8$)
      Next Watchlist()
      
      ; update the watchlist window
      Command.CommandInfo\Command = #COMMAND_GetWatchlist
      SendDebuggerCommand(*Debugger, @Command)
      
      ; tell the executable to start running
      Command.CommandInfo\Command = #COMMAND_Run
      Command\Value1 = 0
      SendDebuggerCommand(*Debugger, @Command)
      
      Standalone_AddLog(Language("Debugger","ExeStarted"), *Debugger\Command\TimeStamp)
      StatusBarText(#STATUSBAR, 0, Language("Debugger","ExeStarted"))
      UpdateGadgetStates()
      
      
    Case #COMMAND_End
      Standalone_AddLog(Language("Debugger","ExeEnded"), *Debugger\Command\TimeStamp)
      StatusBarText(#STATUSBAR, 0, Language("Debugger","ExeEnded"))
      UpdateGadgetStates()
      
      ; get these before Debugger_End(), as it may destroy the *Debugger struct!
      If *Debugger\IsPurifier
        PurifierSettings$ =  GetPurifierOptions(*Debugger)
      EndIf
      
      Debugger_End(*Debugger)
      
      If ListSize(RunningDebuggers()) = 0
        Standalone_Quit = 1
      Else
        DisableGadget(#GADGET_Debug, 1)
        DisableGadget(#GADGET_Watchlist, 1)
        DisableGadget(#GADGET_Variables, 1)
        DisableGadget(#GADGET_Profiler, 1)
        DisableGadget(#GADGET_History, 1)
        DisableGadget(#GADGET_Memory, 1)
        DisableGadget(#GADGET_Library, 1)
        DisableGadget(#GADGET_Assembly, 1)
        DisableGadget(#GADGET_Purifier, 1)
      EndIf
      
      
    Case #COMMAND_ExeMode
      Text$ = Language("Debugger","ExecutableType") + ": "
      
      Select (*Debugger\Command\Value2 >> 16) & $FFFF
        Case 1: Text$ + "Windows"
        Case 2: Text$ + "Linux"
        Case 3: Text$ + "MacOSX"
      EndSelect
      
      Select *Debugger\Command\Value2 & $FFFF
        Case 1: Text$ + " - x86"
        Case 2: Text$ + " - x64"
        Case 3: Text$ + " - ppc"
      EndSelect
      
      If *Debugger\Is64bit
        Text$ + "  (64bit"
      Else
        Text$ + "  (32bit"
      EndIf
      If *Debugger\IsUnicode: Text$ + ", Unicode": EndIf
      If *Debugger\IsThread : Text$ + ", Thread" : EndIf
      If *Debugger\IsPurifier: Text$ + ", Purifier": EndIf
      Text$ + ")"
      
      Standalone_AddLog(Text$, *Debugger\Command\TimeStamp)
      
      
    Case #COMMAND_Error
      Standalone_AddLog(Language("Debugger","LogError")+" "+GetDebuggerRelativeFile(*Debugger, *Debugger\Command\Value1) + " ("+Language("Misc","Line")+": " + Str(DebuggerLineGetLine(*Debugger\Command\Value1)+1)+")", *Debugger\Command\TimeStamp)
      Standalone_AddLog(Language("Debugger","LogError")+" "+PeekUTF8(*Debugger\CommandData), *Debugger\Command\TimeStamp)
      StatusBarText(#STATUSBAR, 0, Language("Misc","Line")+": " + Str(DebuggerLineGetLine(*Debugger\Command\Value1)+1) +" - " +  PeekUTF8(*Debugger\CommandData))
      UpdateGadgetStates()
      
      SetCurrentLine(*Debugger\Command\Value1)
      MarkError(*Debugger\Command\Value1)
      
      
    Case #COMMAND_Warning
      Standalone_AddLog(Language("Debugger","LogWarning")+" "+GetDebuggerRelativeFile(*Debugger, *Debugger\Command\Value1) + " ("+Language("Misc","Line")+": " + Str(DebuggerLineGetLine(*Debugger\Command\Value1)+1)+")", *Debugger\Command\TimeStamp)
      Standalone_AddLog(Language("Debugger","LogWarning")+" "+PeekUTF8(*Debugger\CommandData), *Debugger\Command\TimeStamp)
      StatusBarText(#STATUSBAR, 0, Language("Misc","Line")+": " + Str(DebuggerLineGetLine(*Debugger\Command\Value1)+1) +" - " +  PeekUTF8(*Debugger\CommandData))
      UpdateGadgetStates()
      
      ; just mark, do not change current line or stop program
      MarkWarning(*Debugger\Command\Value1)
      
      
    Case #COMMAND_Stopped
      Text$ = Language("Debugger","Stopped")
      
      Select *Debugger\Command\Value2
        Case 3: Text$ + " (CallDebugger)"
        Case 5: Text$ + " ("+Language("Debugger","BeforeEnd")+")"
        Case 7: Text$ + " ("+Language("Debugger","BreakPoint")+")"
        Case 8: Text$ + " ("+Language("Debugger","UserRequest")+")"
          
        Case 9
          ; The WatchList functions have processed the eariler #COMMAND_DataBreakPoint,
          ; so the matching Condition is marked in the breakpoint list
          Text$ + " (" + Language("Debugger","DataBreakpoint")
          *Point.DataBreakPoint = *Debugger\FirstDataBreakPoint
          While *Point
            If *Point\ConditionTrue
              Text$ + ": " + *Point\Condition$
              Break
            Else
              *Point = *Point\Next
            EndIf
          Wend
          Text$ + ")"
          
          If *Debugger\DataBreakpointsVisible
            SetWindowForeGround(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints])
          EndIf
          
      EndSelect
      
      If *Debugger\LastProgramState <> -2  ; don't log a stop after a Step command
        Standalone_AddLog(Text$, *Debugger\Command\TimeStamp)
      EndIf
      StatusBarText(#STATUSBAR, 0, Text$)
      UpdateGadgetStates()
      
      If *Debugger\Command\Value1 <> -1 ; try not to load a file when the line is invalid!
        SetCurrentLine(*Debugger\Command\Value1)
      EndIf
      
    Case #COMMAND_Continued
      Standalone_AddLog(Language("Debugger","Continued"), *Debugger\Command\TimeStamp)
      StatusBarText(#STATUSBAR, 0, Language("Debugger","Continued"))
      UpdateGadgetStates()
      SetCurrentLine(-1) ; remove the mark
      
      ; we look for the watchlist full update event and update our own
      ; watctlist LinkedList from it, so it stays always up to date
      ;
    Case #COMMAND_Watchlist
      ClearList(Watchlist())
      
      *Pointer = *Debugger\CommandData
      For i = 1 To *Debugger\Command\Value1
        type = PeekB(*Pointer)& ~(1<<6): *Pointer + 2 ; skip type and scope
        isvalid = PeekB(*Pointer): *Pointer + 1
        ProcedureIndex = PeekL(*Pointer)
        *Pointer + 4
        name$ = PeekS(*Pointer, -1, #PB_UTF8)
        *Pointer + MemoryUTF8LengthBytes(*Pointer) + 1
        
        AddElement(Watchlist()) ; add to our watchlist
        If ProcedureIndex = -1
          Watchlist() = name$
        Else
          Watchlist() = GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], ProcedureIndex+1, 0) + ">" + name$
        EndIf
        
        ; skip variable value
        If isvalid <> 0
          If type & $80 ; pointer
            *Pointer + 4
          ElseIf type = 1
            *Pointer + 1
          ElseIf type = 3
            *Pointer + 2
          ElseIf type = 5 Or type = 11
            *Pointer + 4
          ElseIf type = 8 Or type = 10
            *Pointer + MemoryStringLengthBytes(*Pointer) + #CharSize ; this is not ascii!
          ElseIf type = 9
            *Pointer + 4
          ElseIf type = 12 Or type = 13
            *Pointer + 8
          EndIf
        EndIf
        
      Next i
      
      
    Case #COMMAND_Debug
      If DebugOutputToErrorLog ; if set, this procedure is responsible for the debug output
        Message$ = "[Debug] "
        If *Debugger\Command\Value1 = 5 ; long
          If DebugIsHex
            Message$ + Hex(*Debugger\Command\Value2, #PB_Long)
          Else
            Message$ + Str(*Debugger\Command\Value2)
          EndIf
        ElseIf *Debugger\Command\Value1 = 8 ; string
          String$ = PeekS(*Debugger\CommandData, *Debugger\Command\DataSize)
          If Left(String$, 19) = "[OutputDebugString]"
            Message$ = String$ ; do not add the [Debug] from above
          Else
            Message$ + String$
          EndIf
        ElseIf *Debugger\Command\Value1 = 9 ; float
          Message$ + StrF_Debug(PeekF(@*Debugger\Command\Value2))
        EndIf
        
        ; Truncate the Message to avoid display problems on Windows, and because debugging
        ; such large things is no longer reasonably viewable anyway
        ;
        If Len(Message$) > 4096
          Message$ = Left(Message$, 4096) + " [...]"
        EndIf
        
        Standalone_AddLog(Message$, *Debugger\Command\Timestamp)
      Else
        SetGadgetState(#GADGET_Debug, *DebuggerData\IsDebugOutputVisible)
      EndIf
      
    Case #COMMAND_DebugDouble
      If DebugOutputToErrorLog ; if set, this procedure is responsible for the debug output
        Standalone_AddLog("[Debug] " + StrD_Debug(PeekD(@*Debugger\Command\Value1)), *Debugger\Command\Timestamp)
      Else
        SetGadgetState(#GADGET_Debug, *DebuggerData\IsDebugOutputVisible)
      EndIf
      
    Case #COMMAND_DebugQuad
      If DebugOutputToErrorLog ; if set, this procedure is responsible for the debug output
        Message$ = "[Debug] "
        If DebugIsHex
          Message$ + Hex(PeekQ(@*Debugger\Command\Value1), #PB_Quad)
        Else
          Message$ + Str(PeekQ(@*Debugger\Command\Value1))
        EndIf
        
        Standalone_AddLog(Message$, *Debugger\Command\Timestamp)
      Else
        SetGadgetState(#GADGET_Debug, *DebuggerData\IsDebugOutputVisible)
      EndIf
      
    Case #COMMAND_Expression
      
      ; expression evaluation for tooltips
      ; check if this message is for us (the debug output uses this message too)
      ;
      If *Debugger\Command\Value1 = AsciiConst('S','C','I','N') And *Debugger\CommandData And IsMouseDwelling = 1
        
        Select *Debugger\Command\Value2 ; result code
            
          Case 0 ; error
            Message$ = "Debugger: " + PeekUTF8(*Debugger\CommandData)
            
            ; Variable not found is common (place the cursor on a keyword etc),
            ; so display nothing if this happens.
            If IsVariableExpression = 0 Or (Left(Message$, 29) <> "Debugger: Variable not found:" And Left(Message$, 43) <> "Debugger: Array() / LinkedList() not found:" And Message$ <> "Debugger: Garbage at the end of the input.")
              ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
              ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, 9)
            EndIf
            
          Case 1 ; empty, do nothing
            
          Case 2 ; quad
            Name$    = PeekS(*Debugger\CommandData+8, (*Debugger\Command\DataSize-8) / SizeOf(Character))
            Message$ = Name$ + " = " + Str(PeekQ(*Debugger\CommandData))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, Len(Name$))
            
          Case 3 ; double
            Name$    = PeekS(*Debugger\CommandData+8, (*Debugger\Command\DataSize-8) / SizeOf(Character))
            Message$ = Name$ + " = " + StrD_Debug(PeekD(*Debugger\CommandData))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, Len(Name$))
            
          Case 4 ; string
            Message$ = PeekS(*Debugger\CommandData, (*Debugger\Command\DataSize) / SizeOf(Character))
            Name$    = PeekS(*Debugger\CommandData + (Len(Message$) + 1) * SizeOf(Character), (*Debugger\Command\DataSize) / SizeOf(Character) - Len(Message$) - 1)
            Message$ = Name$ + " = " + Chr(34) + Message$ + Chr(34)
            
            If Len(Message$) > 100
              Message$ = Left(Message$, 96) + "..."
            EndIf
            
            ; result buffer must be freed
            CodePage = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETCODEPAGE)
            *Buffer = StringToCodePage(CodePage, Message$)
            If *Buffer
              ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, *Buffer)
              ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, CodePageLength(CodePage, Name$))
              FreeMemory(*Buffer)
            EndIf
            
          Case 5 ; structure
            *Pointer = *Debugger\CommandData
            Message$ = ""
            
            Type$ = PeekS(*Pointer, -1, #PB_Ascii): *Pointer + Len(Type$) + 1
            Count = PeekL(*Pointer): *Pointer + 4
            
            ; Calculate the maximum number of lines to display the tooltip up or down.
            ;
            ; Currently, with MaxLine = 25 hardcoded, no possibility to display more lines for large structures if there is enough space.
            ; If there isn't enough space at the bottom or top, the tolltip isn't displayed at all. 
            ; Large structure tooltip is often not displayed when the cursor is on a middle line, no problem when the cursor is at the top or bottom.
            ;
            ; With the calculation below, the number of lines to be displayed is adjusted (with a 1 line margin to be on the safe side) to the available space, 
            ; And so make sure the tooltip is always displayed with the maximum number of structure fields displayed.
            ;
            ; Windows 10, 11 has thin invisible borders on left, right and bottom. It is used to grip the mouse for resizing. Use SPI_GETWORKAREA instead of OpenWindow
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
              SystemParametersInfo_(#SPI_GETWORKAREA, 0, @wr.RECT, 0)
              WorkAreaWidth  = wr\right - wr\left
              WorkAreaHeight = wr\bottom - wr\top
            CompilerElse
              DummyWindow = OpenWindow(#PB_Any,0,0,0,0,"",#PB_Window_Invisible | #PB_Window_Maximize | #PB_Window_MaximizeGadget | #PB_Window_NoActivate)
              WorkAreaWidth  = DesktopScaledX(WindowWidth(DummyWindow, #PB_Window_FrameCoordinate))
              WorkAreaHeight = DesktopScaledY(WindowHeight(DummyWindow, #PB_Window_FrameCoordinate))
              CloseWindow(DummyWindow)
            CompilerEndIf
            
            ; ToolTip width enlarged according to the available space between the mouse position and the right desktop border, rather than 100 hard-coded chars
            ; To be aligned with the mouse position. For a full ToolTip, adjusted to the desktop width, use: MaxLenLine = WorkAreaWidth  / ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_TEXTWIDTH, #STYLE_DEFAULT, ToAscii("A"))
            MaxLenLine = (WorkAreaWidth - DesktopMouseX()) / ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_TEXTWIDTH, #STYLE_DEFAULT, ToAscii("A")) +1   ; +1 for Chr(10), #LF$
            
            ; Number of lines from top: Remove a line for "Structure: " + Name$ and a second line to ensure that the tooltip is displayed with its borders.
            MaxLineTop = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_LINEFROMPOSITION, MouseDwellPosition, 0) - ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETFIRSTVISIBLELINE, 0, 0) - 2
            Debug "ToolTip - Line From Top = " + Str(MaxLineTop) + " = " + Str(ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_LINEFROMPOSITION, MouseDwellPosition, 0)) + " - " + Str(ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETFIRSTVISIBLELINE, 0, 0)) + " - 2"

            ; Number of lines to bottom : (from mouse position + height of 1 line) to bottom and remove a line for "Structure: " + Name$
            TextHeight = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_TEXTHEIGHT, 1, 0)
            MaxLineBottom = Round((WorkAreaHeight -  DesktopMouseY() - TextHeight) / TextHeight, #PB_Round_Down) - 1
            Debug "ToolTip - MaxLine To Bottom = " + Str(MaxLineBottom) + " = Round((" + Str(WorkAreaHeight) + " - " + Str(DesktopMouseY()) + " - " + Str(TextHeight) + ") / " + Str(TextHeight) + ", #PB_Round_Down) - 1"
            
            MaxLine = Max(MaxLineTop, MaxLineBottom)
            If Count > MaxLine
              MaxLine - 1
            EndIf
            
            For i = 1 To Count
              type        = PeekB(*Pointer): *Pointer + 1
              dynamictype = PeekB(*Pointer): *Pointer + 1
              sublevel    = PeekL(*Pointer): *Pointer + 4
              Name$       = PeekS(*Pointer, -1, #PB_Ascii): *Pointer + Len(Name$) + 1
              Line$       = Chr(10) + Space(sublevel*2 + 1) + "\" + Name$
              
              If IS_ARRAY(type)
                Line$ + "(" + PeekAscii(*Pointer) + ")" ; dimensions
                
              ElseIf IS_LINKEDLIST(type)
                Line$ + "()" ; ignore the current and size for now (looks better)
                
              ElseIf IS_MAP(type)
                Line$ + "()"
                
              ElseIf IS_POINTER(type) ; pointer
                If *Debugger\Is64bit
                  Line$ + " = " + Str(PeekQ(*Pointer))
                Else
                  Line$ + " = " + Str(PeekL(*Pointer))
                EndIf
              Else ; no pointer
                Select type
                  Case #TYPE_BYTE:      Line$ + " = " + Str(PeekB(*Pointer))
                  Case #TYPE_ASCII:     Line$ + " = " + StrU(PeekB(*Pointer), #PB_Byte)
                  Case #TYPE_WORD:      Line$ + " = " + Str(PeekW(*Pointer))
                  Case #TYPE_UNICODE:   Line$ + " = " + StrU(PeekW(*Pointer), #PB_Word)
                  Case #TYPE_LONG:      Line$ + " = " + Str(PeekL(*Pointer))
                  Case #TYPE_STRUCTURE: ; structure, do not add a =
                  Case #TYPE_FLOAT:     Line$ + " = " + StrF_Debug(PeekF(*Pointer))
                  Case #TYPE_DOUBLE:    Line$ + " = " + StrD_Debug(PeekD(*Pointer))
                  Case #TYPE_QUAD:      Line$ + " = " + Str(PeekQ(*Pointer))
                  Case #TYPE_CHARACTER: Line$ + " = " + Str(PeekL(*Pointer)) ; already transformed to int here
                    
                  Case #TYPE_INTEGER
                    If *Debugger\Is64bit
                      Line$ + " = " + Str(PeekQ(*Pointer))
                    Else
                      Line$ + " = " + Str(PeekL(*Pointer))
                    EndIf
                    
                  Case #TYPE_STRING, #TYPE_FIXEDSTRING
                    String$ = PeekS(*Pointer)
                    Line$ + " = " + Chr(34) + String$ + Chr(34)
                EndSelect
              EndIf
              
              *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
              
              ; do not display too large structures !
              If i <= MaxLine
                If Len(Line$) > MaxLenLine
                  Line$ = Left(Line$, MaxLenLine-4) + " ..."
                EndIf
                
                Message$ + Line$
              EndIf
            Next i
            
            If Count > MaxLine
              Message$ + Chr(10) + "..."
            EndIf
            
            Name$ = PeekS(*Pointer) ; request string
            
            Message$ = "Structure: " + Name$ + Message$
            
            ; result buffer must be freed
            CodePage = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETCODEPAGE)
            *Buffer = StringToCodePage(CodePage, Message$)
            If *Buffer
              ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, *Buffer)
              ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, CodePageLength(CodePage, Name$) + 11)
              FreeMemory(*Buffer)
            EndIf
            
          Case 6 ; long (ppc only)
            Name$    = PeekS(*Debugger\CommandData+4, (*Debugger\Command\DataSize-4) / SizeOf(Character))
            Message$ = Name$ + " = " + Str(PeekL(*Debugger\CommandData))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, Len(Name$))
            
          Case 7 ; float (ppc only)
            Name$    = PeekS(*Debugger\CommandData+4, (*Debugger\Command\DataSize-4) / SizeOf(Character))
            Message$ = Name$ + " = " + StrF_Debug(PeekF(*Debugger\CommandData))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_CALLTIPSETHLT, 0, Len(Name$))
            
        EndSelect
        
      EndIf
      
  EndSelect
  
  
EndProcedure

Procedure Debugger_AddShortcuts(Window)
  
  AddKeyboardShortcut(Window, Shortcut_Run, #MENU_Run)
  AddKeyboardShortcut(Window, Shortcut_Stop, #MENU_Stop)
  AddKeyboardShortcut(Window, Shortcut_Step, #MENU_Step)
  
EndProcedure