; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Change: Now *every* file in the source tree is included from this main file
; This will reduce the number of XIncludeFile's in each file, and there is no more need to check dependencies.
; Even platform specific files are always included. Whether their code is compiled
; is decided in each file.

XIncludeFile "CompilerFlags.pb"
XIncludeFile "Build/BuildInfo.pb"
XIncludeFile ".." + #Separator + "DialogManager" + #Separator + "Common.pb" ; must be before Common.pb
XIncludeFile "Common.pb"                                                    ; must be before DebuggerCommon.pb
XIncludeFile #DEFAULT_DebuggerSource + "DebuggerCommon.pb"                  ; must be before Declarations.pb
XIncludeFile "Declarations.pb"
XIncludeFile "Macro.pb"
XIncludeFile ".." + #Separator + "PureBasicConfigPath.pb" ; for the config directory
XIncludeFile "FormDesigner/declare.pb"
; must be here to affect all OpenWindow() calls with a macro
XIncludeFile "LinuxWindowIcon.pb"
XIncludeFile "ZLib.pb"

; include the TabBarGadget. Note: It has an EnableExplicit inside
XIncludeFile "TabBarGadget.pbi"
DisableExplicit

; dialog manager
; We need the explorer and scintilla support for it (for Templates window and Projects)
#DIALOG_USE_SCINTILLA = 1
#DIALOG_USE_EXPLORER  = 1

IncludePath ".." + #Separator + "DialogManager" + #Separator ; so that the dialog manager files are found
XIncludeFile "DialogManager.pb"
IncludePath ""

; debugging functions and macros (mostly active in debug mode only)
XIncludeFile "WindowsDebugging.pb"
XIncludeFile "LinuxDebugging.pb"

; should be before the debugger files, as they need some of this
XIncludeFile "WindowsExtensions.pb"
XIncludeFile "LinuxExtensions.pb"
XIncludeFile "MacExtensions.pb"

; debugger external files
XIncludeFile #DEFAULT_DebuggerSource + "Misc.pb"
XIncludeFile #DEFAULT_DebuggerSource + "VariableGadget.pb"
XIncludeFile #DEFAULT_DebuggerSource + "Communication_PipeWindows.pb"
XIncludeFile #DEFAULT_DebuggerSource + "Communication_PipeUnix.pb"
XIncludeFile #DEFAULT_DebuggerSource + "Communication.pb"
XIncludeFile #DEFAULT_DebuggerSource + "DebugOutput.pb"
XIncludeFile #DEFAULT_DebuggerSource + "AsmDebug.pb"
XIncludeFile #DEFAULT_DebuggerSource + "MemoryViewer.pb"
XIncludeFile #DEFAULT_DebuggerSource + "VariableDebug.pb"
XIncludeFile #DEFAULT_DebuggerSource + "History.pb"
XIncludeFile #DEFAULT_DebuggerSource + "WatchList.pb"
XIncludeFile #DEFAULT_DebuggerSource + "DataBreakPoints.pb"
XIncludeFile #DEFAULT_DebuggerSource + "Profiler.pb"
XIncludeFile #DEFAULT_DebuggerSource + "LibraryViewer.pb"
XIncludeFile #DEFAULT_DebuggerSource + "Purifier.pb"
XIncludeFile #DEFAULT_DebuggerSource + "DebuggerGUI.pb"


; Plugins for the LibraryViewer
XIncludeFile #DEFAULT_DebuggerSource + "Plugin_Image.pb"
XIncludeFile #DEFAULT_DebuggerSource + "Plugin_Xml.pb"


; debugger ide-files
XIncludeFile "IDEDebugger.pb"

XIncludeFile "CompilerInterface.pb"
XIncludeFile "Language.pb"
XIncludeFile "ZipManagement.pb"
XIncludeFile "ToolbarManagement.pb"
XIncludeFile "ThemeManagement.pb"
XIncludeFile "HighlightingEngine.pb"
XIncludeFile "HighlightingFunctions.pb"
XIncludeFile "ShortcutManagement.pb"
XIncludeFile "ProjectManagement.pb"
XIncludeFile "FormDesigner/grid.pbi"
XIncludeFile "FormDesigner/undoredo.pb"
XIncludeFile "FormDesigner/helpingfunctions.pb"
XIncludeFile "FormDesigner/gadgetitemswindow.pb"
XIncludeFile "FormDesigner/imageslistwindow.pb"
XIncludeFile "FormDesigner/splitterwindow.pb"
XIncludeFile "FormDesigner/codeviewer.pb"
XIncludeFile "FormDesigner/mainevents.pb"
XIncludeFile "FormDesigner/copypaste.pb"
XIncludeFile "FormDesigner/opensave.pb"
XIncludeFile "FormDesigner/mainwindow.pb"
XIncludeFile "FormDesigner/FormManagement.pb"
XIncludeFile "SourceManagement.pb"
XIncludeFile "SourceParser.pb"
XIncludeFile "UserInterface.pb"
XIncludeFile "Misc.pb"
XIncludeFile "FileSystem.pb"
XIncludeFile "IDEMisc.pb"
XIncludeFile "RecentFiles.pb"
XIncludeFile "AddTools.pb"
XIncludeFile "AboutWindow.pb"
XIncludeFile "FileViewer.pb"
XIncludeFile "GotoWindow.pb"
XIncludeFile "StructureViewer.pb"
XIncludeFile "StructureFunctions.pb"
XIncludeFile "FindWindow.pb"
XIncludeFile "GrepWindow.pb"
XIncludeFile "CompilerWindow.pb"
XIncludeFile "CompilerWarnings.pb"
XIncludeFile "CompilerOptions.pb"
XIncludeFile "AddHelpFiles.pb"
XIncludeFile "ColorSchemes.pb"
XIncludeFile "AutoComplete.pb"
XIncludeFile "Preferences.pb"
XIncludeFile "Preferences.pb"
XIncludeFile "StandaloneDebuggerControl.pb"
XIncludeFile "ErrorHandler.pb"
XIncludeFile "Commandline.pb"
XIncludeFile "DiffAlgorithm.pb"
XIncludeFile "DiffWindow.pb"
XIncludeFile "LinuxHelp.pb"
XIncludeFile "EditHistory.pb"
XIncludeFile "UpdateCheck.pb"
XIncludeFile "RadixTree.pb"

CompilerIf #SpiderBasic
  XIncludeFile "CreateApp.pb"
CompilerEndIf

; compiled dialogs
XIncludeFile "Build/Find.pb"
XIncludeFile "Build/Grep.pb"
XIncludeFile "Build/Diff.pb"
XIncludeFile "Build/Goto.pb"
XIncludeFile "Build/AddTools.pb"
XIncludeFile "Build/About.pb"
XIncludeFile "Build/Preferences.pb"
XIncludeFile "Build/Templates.pb"
XIncludeFile "Build/StructureViewer.pb"
XIncludeFile "Build/Projects.pb"
XIncludeFile "Build/Build.pb"
XIncludeFile "Build/FileMonitor.pb"
XIncludeFile "Build/History.pb"
XIncludeFile "Build/HistoryShutdown.pb"
XIncludeFile "Build/Updates.pb"

CompilerIf #SpiderBasic
  XIncludeFile "Build/CreateApp.pb"
CompilerEndIf

; Here is the trick:
;   We need two slightly different versions of the Compiler options dialog,
;   so to not duplicate all the stuff, we generate the file once from the xml
;   and then include it here twice, with the #IDE_ProjectCompilerOptions defined
;   for only one of them to make the few changes.
;
;   To not get a duplicate label error, the generated label in the file is actually
;   a macro which is replaced with the real label on compilation
;
Macro Dialog_CompilerOptionsMacro()
  CompilerIf Defined(IDE_ProjectCompilerOptions, #PB_Constant)
    Dialog_ProjectCompilerOptions:
  CompilerElse
    Dialog_CompilerOptions:
  CompilerEndIf
EndMacro

IncludeFile "Build/CompilerOptions.pb"
#IDE_ProjectCompilerOptions = 1
IncludeFile "Build/CompilerOptions.pb"


; toolspanel plugins
XIncludeFile "AsciiTable.pb"
XIncludeFile "Explorer.pb"
XIncludeFile "ProjectPanel.pb"
XIncludeFile "ColorPicker.pb"
XIncludeFile "ProcedureBrowser.pb"
XIncludeFile "VariableViewer.pb"
XIncludeFile "HelpTool.pb"
XIncludeFile "Issues.pb"
CompilerIf #SpiderBasic
  XIncludeFile "WebView.pb"
CompilerEndIf

; windows specific
XIncludeFile "WindowsMisc.pb"
XIncludeFile "WindowsHelp.pb"

; linux specific
XIncludeFile "LinuxMisc.pb"
XIncludeFile "HelpViewer.pb"

; macos specific
XIncludeFile "MacMisc.pb"

; highlighting files
XIncludeFile "ScintillaHighlighting.pb"
XIncludeFile "CodeViewer.pb"
XIncludeFile "DisplayMacroError.pb"
XIncludeFile "Templates.pb"
XIncludeFile "ToolsPanel.pb"

; crossplatform debugging helpers
XIncludeFile "Debugging.pb"

;W__time.q = ElapsedMilliseconds()

;- Editor Start

; This must be before anything else, as it affects path settings and such
;
ParseCommandline()

If CommandlineBuild
  OpenConsole()
EndIf

If OSStartupCode() = 0
  End
EndIf

InitToolbar()       ; must be before LoadPreferences() !
InitSyntaxCheckArrays() ; must be before LoadPreferences() ! (as it calls BuildFoldingVT() which needs this)
LoadPreferences()

CompilerIf #CompileMac
  ; Avoid to be run from the image disk, as some feature won't work.
  ;
  If FindString(LCase(PureBasicPath$), "/apptranslocation/")
    MessageRequester("Error", #ProductName$ + " can't be run directly from the dmg disk, it needs to be drag'n'dropped in Application or in any other place.", #FLAG_Error)
    OSEndCode()
    End 1
  EndIf
CompilerEndIf

CompilerIf #CompileMac
  If OSVersion() >= #PB_OS_MacOSX_10_14
    ; Force Appearance Aqua
    If Not DisplayDarkMode
      NSApp.i = CocoaMessage(0, 0, "NSApplication sharedApplication")
      NSAppearanceAqua = CocoaMessage(0, 0, "NSAppearance appearanceNamed:$", @"NSAppearanceNameAqua")
      CocoaMessage(0, NSApp, "setAppearance:", NSAppearanceAqua)
    EndIf
    ; Init Apperance Observer
    InitAppearanceObserver()
  EndIf
CompilerEndIf

If Editor_RunOnce And CommandlineBuild = 0
  ; New RunOnce handling, all in one OS-specifc routine
  ; to allow a better method to be used on Windows (maybe also Linux)
  ;
  If RunOnce_Startup(InitialSourceLine) ; Returns true when IDE should close
    OSEndCode()
    End
  EndIf
EndIf

LoadLanguage()  ; must be before StartCompiler()
StartCompiler(@DefaultCompiler) ; gets the compiler version for the splash screen

Procedure CloseSplashScreen()
  Static IsClosed = 0
  
  If IsClosed = 0 And NoSplashScreen = 0
    IsClosed = 1
    CompilerIf #PB_Compiler_Debugger
      ; Prevent debugger errors when missing Scintilla.dll causes early exit
      If IsWindow(#WINDOW_Startup)
        CloseWindow(#WINDOW_Startup)
      EndIf
      If IsImage(#IMAGE_Startup)
        FreeImage(#IMAGE_Startup)
      EndIf
    CompilerElse
      CloseWindow(#WINDOW_Startup)
      FreeImage(#IMAGE_Startup)
    CompilerEndIf
  EndIf
EndProcedure

If CommandlineBuild = 0 And NoSplashScreen = 0
  
  ; display the startup logo, as loading could take a little on slower systems..
  ; especially when lots of sources are reloaded.
  If OpenWindow(#WINDOW_Startup, 0, 0, 500, 200, #ProductName$ + " loading...", #PB_Window_ScreenCentered|#PB_Window_BorderLess|#PB_Window_Invisible)
    If CatchImage(#IMAGE_Startup, ?Image_Startup)
      
      ; Image is HDPI with twice the wanted size. So resize it according to current screen DPI.
      ;
      ResizeImage(#IMAGE_Startup, DesktopScaledX(ImageWidth(#IMAGE_Startup)/2), DesktopScaledY(ImageHeight(#IMAGE_Startup)/2))
      
      If StartDrawing(ImageOutput(#IMAGE_Startup))
        DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
        
        CompilerIf #SpiderBasic
          FrontColor($777777) ; SpiderBasic splash screen background is white, so change the font color to a dark one
          OffsetX = DesktopScaledX(130) ; Spider has a logo at the left of the window, so shift the text display
        CompilerElse
          FrontColor($FFFFFF)
          OffsetX = 0
        CompilerEndIf  
        
        CompilerIf #CompileWindows
          DrawingFont(GetGadgetFont(#PB_Default)) ; The default GFX font on Windows is a bit ugly, so use the gadget one
        CompilerEndIf
        
        ; on linux, this string is too long, so move the copyright to a second line
        Version$ = DefaultCompiler\VersionString$
        If TextWidth(Version$) > 480 And FindString(Version$, "- (c)", 1) <> 0
          CopyRight$ = Trim(Right(Version$, Len(Version$) - FindString(Version$, "- (c)", 1))) ; will still include the (c)
          Version$   = Trim(Left(Version$, FindString(Version$, "- (c)", 1) - 1))
          DrawText((OutputWidth()-TextWidth(Version$)-OffsetX) / 2 + OffsetX, DesktopScaledY(145), Version$)
          DrawText((OutputWidth()-TextWidth(CopyRight$)-OffsetX) / 2 + OffsetX, DesktopScaledY(145) + TextHeight(Version$) + 1, CopyRight$)
        Else
          DrawText((OutputWidth()-TextWidth(Version$)-OffsetX) / 2 + OffsetX, DesktopScaledY(145), Version$)
          DrawText((OutputWidth()-TextWidth("00/00/0000")-OffsetX) / 2 + OffsetX, DesktopScaledY(145) + TextHeight(Version$) + 1, FormatDate("%mm/%dd/%yyyy", #PB_Compiler_Date))
        EndIf
        
        StopDrawing()
      EndIf
      
      ImageGadget(#GADGET_Startup_Image, 0, 0, 500, 200, ImageID(#IMAGE_Startup))
      SetWindowStayOnTop(#WINDOW_Startup, #True) ; force the window to the top ! Note: every messagerequester are now wrapped to MessageRequesterSafe() and will close this splash screen if still opened
      HideWindow(#WINDOW_Startup, #False)
      
      FlushEvents()
    EndIf
  EndIf
  
EndIf

If CommandlineBuild = 0
  LoadTheme()
  If NoSplashScreen = 0: FlushEvents(): EndIf
EndIf

AddTools_Init() ; those must be before CreateGUI()
If CommandlineBuild = 0 And NoSplashScreen = 0: FlushEvents(): EndIf

AddHelpFiles_Init()
If CommandlineBuild = 0 And NoSplashScreen = 0: FlushEvents(): EndIf

; CPUMonitor_Init() ; before creategui!

;- Commandline Project building
If CommandlineBuild
  CommandlineProjectBuild()
  
  ; commandline building should not affect IDE prefs, so no need to save them
  KillCompiler()
  DeleteRegisteredFiles()
  CompilerCleanup()
  OSEndCode()
  CloseConsole()
  
  If CommandlineBuildSuccess
    End 0
  Else
    End 1
  EndIf
EndIf

;- GUI creation
If CreateGUI() = 0
  MessageRequester(#ProductName$,"Critical Error! Can't create GUI!")
  End
EndIf
If NoSplashScreen = 0: FlushEvents(): EndIf

FlushEvents()
If NoSplashScreen = 0: FlushEvents(): EndIf

CreateAutoCompleteWindow() ; prepare the autocomplete window (hidden)

EnsureWindowOnDesktop(#WINDOW_Main)
If IsWindowMaximized
  ShowWindowMaximized(#WINDOW_Main)
Else
  HideWindow(#WINDOW_Main, 0)
EndIf

FlushEvents() ; flush events even if no splashscreen is there, because of the main gui

; setup the timer for the file changes monitor
SetupFileMonitor()

; Calculate the hidden width of the toolspanel (for autohide)
; Can be done only after the gadget is displayed
CompilerIf #CompileLinux
  ToolsPanelHiddenWidth = GetGadgetAttribute(#GADGET_ToolsPanel, #PB_Panel_TabHeight)
  If ToolsPanelVisible = 0
    ResizeMainWindow()
  EndIf
CompilerEndIf

; apply the splitter positions now, as before all gadgets are 0 in size.
;
If ErrorLogVisible
  SetGadgetState(#GADGET_LogSplitter, GadgetHeight(#GADGET_LogSplitter)-ErrorLogHeight)
Else
  ErrorLogHeight_Hidden = ErrorLogHeight ; simply set the "hidden" value to the prefs one
EndIf

If ToolsPanelVisible
  If ToolsPanelSide = 0
    SetGadgetState(#GADGET_ToolsSplitter, GadgetWidth(#GADGET_ToolsSplitter)-ToolsPanelWidth)
  Else
    SetGadgetState(#GADGET_ToolsSplitter, ToolsPanelWidth)
  EndIf
Else
  ToolsPanelWidth_Hidden = ToolsPanelWidth
EndIf

If ToolsPanelAutoHide Or ToolsPanelMode = 0 ; hide the panel if we do not need it
  ToolsPanel_Hide()
EndIf

; Initialize history session (do this before opening any files)
;
StartHistorySession()

; Now we can directly handle the OSX "open document" event
;
CompilerIf #CompileMac
  ReadyForDocumentEvent = 1
CompilerEndIf

; First try to load a project if provided on the commandline
; Do this before opening the last open project!
; Note: if there are multiple projects, only open the last one (we can only have one project open at a time)
CommandLineProject$ = ""
ForEach OpenFilesCommandLine()
  If IsProjectFile(OpenFilesCommandLine())
    CommandLineProject$ = OpenFilesCommandLine()
    DeleteElement(OpenFilesCommandLine())
  EndIf
Next OpenFilesCommandLine()
If CommandLineProject$ <> ""
  LoadProject(CommandLineProject$)
EndIf

; Now load the default project (or LastOpen one) (only if there was not a project loaded from commandline)
; Always load the project first, so it does look better as all project files are also saved as opened file
;
If IsProject = 0
  ; The last opened only if there is no default project!
  If AutoReload And LastOpenProjectFile$ And DefaultProjectFile$ = ""
    LoadProject(LastOpenProjectFile$)
  ElseIf DefaultProjectFile$ <> ""
    If LoadProject(DefaultProjectFile$) = 0
      DefaultProjectFile$ = "" ; do not try again next time
    EndIf
  EndIf
  
  ; switch back to the last commandline source, if the -l option was present
  If *LastLoadedSource And *LastLoadedSource <> *ActiveSource
    ChangeCurrentElement(FileList(), *LastLoadedSource)
    ChangeActiveSourceCode()
  EndIf
EndIf
LastOpenProjectFile$ = "" ; reset after loading

; Now load any sourcefiles (both from commandline and preferences)
;
If AutoReload
  ForEach OpenFiles()
    LoadSourceFile(OpenFiles())
    
    ; Flush events. So when many sources are opened at once, the User can see a bit the
    ; progress, instead of just an unresponsive window for quite a while.
    ; There is almost no flicker anymore, so it actually looks quite good.
    ;
    ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
    FlushEvents()
  Next OpenFiles()
EndIf
ClearList(OpenFiles()) ; reset after loading

ForEach OpenFilesCommandLine()
  LoadSourceFile(OpenFilesCommandLine())
  
  ; Flush events. So when many sources are opened at once, the User can see a bit the
  ; progress, instead of just an unresponsive window for quite a while.
  ; There is almost no flicker anymore, so it actually looks quite good.
  ;
  ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
  FlushEvents()
Next OpenFilesCommandLine()
ClearList(OpenFilesCommandLine())

; apply the -l option (do this before opening the default project
;
If *ActiveSource And InitialSourceLine > 0 And InitialSourceLine < GetLinesCount(*ActiveSource)
  ChangeActiveLine(InitialSourceLine, -5)
  *LastLoadedSource = *ActiveSource
Else
  *LastLoadedSource = 0
EndIf

; Open a new source if nothing was loaded
;
If ListSize(FileList()) = 0 Or (ListSize(FileList()) = 1 And *ProjectInfo)
  NewSource("", #True)
  HistoryEvent(*ActiveSource, #HISTORY_Create)
EndIf
FlushEvents()

CloseSplashScreen()

FlushEvents()

CompilerIf #Demo
  DemoText$ = "This is the free version of "+DefaultCompiler\VersionString$+#NewLine
  DemoText$ + "Please have a look at the 'Examples' folder for test programs."+#NewLine+#NewLine
  DemoText$ + "Free version limitations:"+#NewLine
  CompilerIf #SpiderBasic
    DemoText$ + "- Program size limited to about 800 lines."+#NewLine+#NewLine
  CompilerElse
    CompilerIf #CompileWindows
      DemoText$ + "- No DLL creation"+#NewLine
    CompilerEndIf
    DemoText$ + "- Code size limitation (about 800 lines)"+#NewLine+#NewLine
  CompilerEndIf
  DemoText$ + "Thanks a lot for using " + #ProductName$ + " !"+#NewLine+#NewLine
  DemoText$ + "The Fantaisie Software Team."
  MessageRequester("Information", DemoText$, #FLAG_INFO)
  FlushEvents()
CompilerEndIf

StartupCheckScreenReader()

AddTools_Execute(#TRIGGER_EditorStart, 0)

;MessageRequester("startup time", Str(ElapsedMilliseconds()-__time))

; Detect possible crashed session and display info if so
DetectCrashedHistorySession()

; Wait for the compiler to be loaded. (calls FlushEvents(), so the user can already start editing)
WaitForCompilerReady()

CompilerIf #CompileMacCocoa
  ; Oddly enough, the main window isn't activated on Cocoa after loading all the files
  ActivateMainWindow()
CompilerEndIf


; Check for updates
; Do this after the WaitForCompilerReady() so we know the compiler version for the check!
CheckForUpdatesSchedule()

; Display a warm welcome :)
;
AddGadgetItem(#GADGET_ErrorLog, -1, Language("Misc", "Welcome"))

;- Main loop

QuitIDE = 0
Repeat
  DispatchEvent(WaitWindowEvent())
  EventLoopCallback()
  
  ; On Linux x64 and Cocoa, opening the files from the RunOnce message filter causes the IDE to lock up
  ; So check for new files in this list (a ListSize() is a really fast check, so this is ok)
  ;
  CompilerIf #CompileLinux | #CompileMacCocoa
    If ListSize(OpenFilesCommandLine()) > 0
      ForEach OpenFilesCommandLine()
        FileName$ = OpenFilesCommandLine()
        
        If Left(FileName$, 7) = "--LINE "
          ; apply the current line commandline option
          InitialSourceLine = Val(Right(FileName$, Len(FileName$)-7))
          If InitialSourceLine > 0 And InitialSourceLine < GetLinesCount(*ActiveSource) ; apply the -l option
            ChangeActiveLine(InitialSourceLine, -5)
          EndIf
        ElseIf FileName$ <> ""
          LoadSourceFile(FileName$)
          
          ; Flush events. So when many sources are opened at once, the User can see a bit the
          ; progress, instead of just an unresponsive window for quite a while.
          ; There is almost no flicker anymore, so it actually looks quite good.
          ;
          ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
          FlushEvents()
        EndIf
      Next OpenFilesCommandLine()
      
      ; Empty list and make sure the IDE is in the foreground now
      ;
      ClearList(OpenFilesCommandLine())
      SetWindowForeground(#WINDOW_Main)
      ResizeMainWindow()
    EndIf
  CompilerEndIf
  
Until QuitIDE

;- Editor end
ShutdownIDE()

End




Procedure ShutdownIDE()
  ; This is now packed in a procedure, so the #WM_ENDSESSION message
  ; can call it as well for an orderly shutdown.
  ; (maybe this can be implemented for #SIGTERM on unix as well)
  
  AddTools_Execute(#TRIGGER_EditorEnd, 0)
  
  ; make sure the project is saved and all related windows closed
  ;
  If IsProject
    LastOpenProjectFile$ = ProjectFile$
  EndIf
  CloseProject(#True)
  
  ; Write close events for any remaining open files
  HistoryShutdownEvents()
  
  ; make sure all window settings are saved by closing them if they are open
  ;
  If IsWindow(#WINDOW_FileViewer)
    FileViewerWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_Find)
    FindWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_StructureViewer)
    StructureViewerWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_Grep)
    GrepWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_GrepOutput)
    GrepOutputWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_EditTools)
    AddTools_EditWindowEvents(#PB_Event_CloseWindow)  ; close this one before the AddTools Window!
  EndIf
  
  If IsWindow(#WINDOW_AddTools)
    AddTools_WindowEvents(#PB_Event_CloseWindow)
  EndIf
  ;
  ;   If IsWindow(#WINDOW_CPUMonitor)
  ;     CPUMonitorWindowEvents(#PB_Event_CloseWindow)
  ;   EndIf
  
  If IsWindow(#WINDOW_Template)
    TemplateWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_MacroError)
    MacroErrorWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_Warnings)
    WarningWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_Diff)
    DiffWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_DiffDialog)
    DiffDialogWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_FileMonitor)
    FileMonitorWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  ; OptionWindow is closed when the source is closed
  
  CompilerIf #CompileLinux | #CompileMac
    If IsWindow(#WINDOW_Help)
      HelpWindowevents(#PB_Event_CloseWindow)
    EndIf
  CompilerEndIf
  
  ; call the destroy function for all ToolsPanel items that have one
  ;
  ForEach UsedPanelTools()
    *PanelToolData.ToolsPanelEntry = UsedPanelTools()
    If *PanelToolData\NeedDestroyFunction
      PanelTool.ToolsPanelInterface = UsedPanelTools()
      PanelTool\DestroyFunction()
    EndIf
  Next UsedPanelTools()
  
  ; Close any tools in external tool windows
  ;
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\IsSeparateWindow
      If AvailablePanelTools()\NeedDestroyFunction
        Tool.ToolsPanelInterface = @AvailablePanelTools()
        Tool\DestroyFunction()
      EndIf
      
      If MemorizeWindow And IsWindowMinimized(AvailablePanelTools()\ToolWindowID) = 0
        Window = AvailablePanelTools()\ToolWindowID
        AvailablePanelTools()\ToolWindowX      = WindowX(Window)
        AvailablePanelTools()\ToolWindowY      = WindowY(Window)
        AvailablePanelTools()\ToolWindowWidth  = WindowWidth(Window)
        AvailablePanelTools()\ToolWindowHeight = WindowHeight(Window)
      EndIf
      CloseWindow(AvailablePanelTools()\ToolWindowID)
      AvailablePanelTools()\ToolWindowID = -1
      AvailablePanelTools()\IsSeparateWindow = 0
    EndIf
  Next AvailablePanelTools()
  
  ; memorize main window settings
  ;
  If MemorizeWindow And IsWindowMinimized(#Window_Main) = 0
    IsWindowMaximized = IsWindowMaximized(#WINDOW_Main)
    
    EditorWindowWidth  = Save_EditorWidth
    EditorWindowHeight = Save_EditorHeight
    EditorWindowX      = Save_EditorX
    EditorWindowY      = Save_EditorY
    
  Else
    EditorWindowWidth  = Memorize_EditorWidth
    EditorWindowHeight = Memorize_EditorHeight
  EndIf
  
  ; Save the splitter positions if the PB splitters are used.
  ; This is done also when MemorizeWindow is off, to be the same as the non-PB splitters
  ;
  If ErrorLogVisible
    ErrorLogHeight = GadgetHeight(#GADGET_LogSplitter) - GetGadgetState(#GADGET_LogSplitter)
  Else
    ErrorLogHeight = ErrorLogHeight_Hidden
  EndIf
  
  If ToolsPanelVisible
    If ToolsPanelSide = 0
      ToolsPanelWidth = GadgetWidth(#GADGET_ToolsSplitter) - GetGadgetState(#GADGET_ToolsSplitter)
    Else
      ToolsPanelWidth = GetGadgetState(#GADGET_ToolsSplitter)
    EndIf
  Else
    ToolsPanelWidth = ToolsPanelWidth_Hidden
  EndIf
  
  ; Close main window, macOS hide window (Fix IDE Crash)
  CompilerIf #CompileMac
    HideWindow(#WINDOW_Main, #True)
  CompilerElse
    CloseWindow(#WINDOW_Main)
  CompilerEndIf
  
  ; Fix IDE crash on macOS Big Sur
  CompilerIf #CompileMac
    FlushEvents()
  CompilerEndIf
  
  ; end history session. this could take a bit if many files were open (will display a small wait screen if so)
  EndHistorySession()
  
  Debugger_Quit()     ; kills all running debugger programs (should be before SavePreferences())
  LibraryViewer_End() ; unload all libraryviewer plugin dlls
  
  SavePreferences()
  KillCompiler()
  
  DeleteRegisteredFiles()
  CompilerCleanup()
  OSEndCode()
  
EndProcedure


DataSection
  
  Image_Startup:
    CompilerIf #SpiderBasic
      IncludeBinary "data/SpiderBasic/SplashScreen_hdpi.png"
    CompilerElse
      IncludeBinary "data/startuplogo_hdpi.png"
    CompilerEndIf
  
EndDataSection