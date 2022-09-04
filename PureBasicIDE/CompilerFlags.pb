; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



; this file should contain constant definitions only
; here, compiler switches are set, both for customizing the compilation
; and for os specific values
;
; This is shared with the GUI Debugger

; NOTE: The three special constants (#DEMO, #GTKVersion, #DEBUG) are now set by the
; makefile via commandline, so no "MakeFlags.pb" is needed anymore.
;
; The following make targets are available:
;   make                (build the normal IDE)
;   make demo           (build a demo ide)
;   make debug          (build a debug ide) (with linenumbering/gtk debug)
;
;   make gtk2           (build the gtk2 version) (creates a purebasic_gtk2 file)
;   make demo_gtk2      (build the gtk2 demo)
;   make debug_gtk2     (build the gtk2 debug version)
;
; NOTE: To build the standalone debugger, you must run make for the IDE first, as it requires
; the MakeFlags.pb file too!
;
; Set to 1 to compile a demo IDE (debugger always set + messages for dlls)
CompilerIf Defined(DEMO, #PB_Constant) = 0
  #DEMO = 0
CompilerEndIf

; Set this to 1 to compile for Gtk1.2, or 2 for Gtk2.0 (remember to use the correct subsystem as well!)
CompilerIf Defined(GTKVersion, #PB_Constant) = 0
  #GTKVersion = 2 ; gtk2 is our default now...
CompilerEndIf

; Set this to 1 to include Functions for debugging (OnError on windows, and signal callbacks on linux)
; NOTE: On Windows you must enable "OnError lines support" for this to work correctly
; NOTE: On Linux, you MUST compile with the debugger (-d) for this to work
CompilerIf Defined(Debug, #PB_Constant) = 0
  #DEBUG = 0
CompilerEndIf


CompilerIf Not Defined(SpiderBasic, #PB_Constant)
  #SpiderBasic = 0
CompilerEndIf

CompilerIf #SpiderBasic
  #ProductName$ = "SpiderBasic"
  #ProductWebSite$ = "https://www.spiderbasic.com"
  #ProjectFileNamespace$ = "http://www.purebasic.com/namespace" ; SBP uses PBP namespace
  #UpdateCheckNamespace$ = "http://www.spiderbasic.com/namespace"
  
  #SourceFileExtension  = ".sb"
  #IncludeFileExtension = ".sbi"
  #ProjectFileExtension = ".sbp"
  #FormFileExtension    = ".sbf"
  
  #CatalogFileIDE = "SB_IDE"
CompilerElse
  #ProductName$ = "PureBasic"
  #ProductWebSite$ = "https://www.purebasic.com"
  #ProjectFileNamespace$ = "http://www.purebasic.com/namespace"
  #UpdateCheckNamespace$ = "http://www.purebasic.com/namespace"
  
  #SourceFileExtension  = ".pb"
  #IncludeFileExtension = ".pbi"
  #ProjectFileExtension = ".pbp"
  #FormFileExtension    = ".pbf"
  
  #CatalogFileIDE = "PB_IDE"
CompilerEndIf


;- Limitations:
;
#MAX_AddTools           = 100  ; reserves Menu entries
#MAX_RecentFiles        = 100  ; reserves Menu entries (also for recent projects)
#MAX_AddHelp            = 100  ; reserves Menu entries
#MAX_FindHistory        = 100  ; Allocates the Findhistory arrays
#MAX_MarkersPerFile     = 100  ; allocates the static array in the SourceFile structure
                               ;#MAX_ColorPickerHistory = 30   ; allocates the colorpicker array
#MAX_ToolbarButtons     = 50   ; allocates static arrays in ToolbarInfo structure
#MAX_FoldWords          = 100  ; allocates FoldStart, FoldEnd arrays
                               ;#MAX_CPUColors          = 50   ; max number of colors for CPU Monitor
#MAX_ErrorLog           = 256  ; max number of saved loglines (allocated in SourceFile structure)
#MAX_LineHistory        = 20   ; max number of remembered line positions (allocated in SourceFile structure) a much greater number does not make sense, as by editing the code, the lines change anyways
#MAX_Constants          = 32   ; allocates entries in SourceFile structure (use a 2^x number to align the structure (uses byte array))
#MAX_EpressionHistory   = 30   ; size of the history in the DebugOutput
#MAX_ThemePreview       = 17   ; Number of icons displayed in theme preview (allocated static image numbers)
#MAX_ConfigLines        = 300  ; Max lines of config stuff an the source end (allocates global array)
#MAX_ResourceFiles      = 20   ; Max number of resource files (allocated in CompileTarget structure)
#MAX_MenuTargets        = 100  ; Max number of project targets that can be shown in the menu (reserves menu entries)

; Processor specific switches (for lazy people :-))
;
CompilerSelect #PB_Compiler_Processor
  CompilerCase #PB_Processor_x86
    #CompileX86   = 1
    #CompileX64   = 0
    #CompilePPC   = 0
    #CompileArm64 = 0
    #CompileArm32 = 0
      
  CompilerCase #PB_Processor_x64
    #CompileX86   = 0
    #CompileX64   = 1
    #CompilePPC   = 0
    #CompileArm64 = 0
    #CompileArm32 = 0
      
  CompilerCase #PB_Processor_PowerPC
    #CompileX86   = 0
    #CompileX64   = 0
    #CompilePPC   = 1
    #CompileArm64 = 0
    #CompileArm32 = 0
  
  CompilerCase #PB_Processor_Arm64
    #CompileX86   = 0
    #CompileX64   = 0
    #CompilePPC   = 0
    #CompileArm64 = 1
    #CompileArm32 = 0
    
  CompilerCase #PB_Processor_Arm32
    #CompileX86   = 0
    #CompileX64   = 0
    #CompilePPC   = 0
    #CompileArm64 = 0
    #CompileArm32 = 1
  
  CompilerDefault
    CompilerError "Processor not supported"
    
CompilerEndSelect


Global DefaultEditorFontName$


; OS specific switches
;
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows ;- Windows
    #CompileWindows   = 1     ; this is for the lazy guys :)
    #CompileLinux     = 0
    #CompileMac       = 0
    #CompileMacCocoa  = 0
    #CompileMacCarbon = 0
    #CompileLinuxGtk1 = 0  ; to directly check for linux + gtk version, which is often needed
    #CompileLinuxGtk2 = 0
    
    #OS_PureBasic = "Windows"
    
    #Separator = "\"
    #NewLine   = Chr(13) + Chr(10)
    #NewLineLength = 2
    #PATH_CaseInSensitive = 1  ; are filenames case sensitive?
    
    
    ; Platform specific default values:
    ;
    #DEFAULT_BigButtons         = 0   ; 1 if all buttons MUST be 25px high.
    #DEFAULT_SplitterWidth      = 4
    
    #DEFAULT_DebuggerSource     = "..\PureBasicDebugger\"
    #DEFAULT_DebuggerStayOnTop  = 1  ; these are different, because stayontop doesn't work on linux
    #DEFAULT_DebuggerBringToTop = 0
    
    #DEFAULT_ListIconImageSize  = 16 ; on windows 16x16 is required to even display!
    #DEFAULT_ListIconImageOffset= 2  ; place to put the real 12x12 image
    
    #DEFAULT_VisualDesigner     = "Visual Designer.exe"
    #DEFAULT_CatalogPath        = "Catalogs\"
    #DEFAILT_LibraryViewerPlugin= "Debugger\"
    #DEFAULT_ThemePath          = "Themes\"
    
    #DEFAULT_HelpPath           = "Help\"
    
    If OSVersion() < #PB_OS_Windows_Vista
      DefaultEditorFontName$     = "Courier"
    Else
      DefaultEditorFontName$     = "Consolas" ; More modern than "Courier" on new Windows
    EndIf
    
    #DEFAULT_EditorFontSize     = 10
    
    #DEFAULT_FunctionFile       = "PBFunctionListing.txt"  ; related to Temp$ path
    #DEFAULT_ApiFile            = "Compilers\APIFunctionListing.txt" ; related to PB path
    #DEFAULT_NewLineType        = 0                                  ; crlf
    #DEFAULT_DLLExtension       = "dll"
    
    #DEFAULT_ImageBorder        = 0 ; for colorpicker
    
    #DEFAULT_CanWindowStayOnTop = 1 ; is the StayOnTop function implemented? (on gtk1 it isn't)
    
    #DEFAULT_PreferencesTreeWidth = 180 ; with of tree gadget in prefs
    
    #FLAG_Warning               = #MB_ICONWARNING
    #FLAG_Error                 = #MB_ICONERROR
    #FLAG_Question              = #MB_ICONQUESTION
    #FLAG_Info                  = #MB_ICONINFORMATION
    
    
    #PB_MessageRequester_ResultOk = 1
    
  CompilerCase #PB_OS_Linux ;- Linux
    #CompileWindows   = 0
    #CompileLinux     = 1
    #CompileMac       = 0
    #CompileMacCocoa  = 0
    #CompileMacCarbon = 0
    
    #CompileLinuxGtk2 = 1
    
    #OS_PureBasic = "Linux"
    
    #Separator     = "/"
    #NewLine       = Chr(10)
    #NewLineLength = 1
    #PATH_CaseInSensitive = 0  ; are filenames case sensitive?
    
    ; Platform specific default values:
    ;
    #DEFAULT_DebuggerSource     = "../PureBasicDebugger/"
    #DEFAULT_DebuggerStayOnTop  = 1
    #DEFAULT_DebuggerBringToTop = 1
    
    #DEFAULT_ListIconImageSize  = 12 ; 12x12 looks better on linux
    #DEFAULT_ListIconImageOffset= 0  ; place to put the real 12x12 image
    
    #DEFAULT_VisualDesigner     = ""     ; will remove the VD entry from the menu
    #DEFAULT_CatalogPath        = "catalogs/"
    #DEFAULT_HelpPath           = "help/"
    #DEFAILT_LibraryViewerPlugin= "debugger/"
    #DEFAULT_ThemePath          = "themes/"
    
    DefaultEditorFontName$      = "Monospace" ; "Misc Fixed" doesn't seems to exists anymore on modern distro
    #DEFAULT_SplitterWidth      = 6
    #DEFAULT_EditorFontSize     = 10
    
    #DEFAULT_FunctionFile       = "pbfunctions.txt"  ; related to Temp$ path
    #DEFAULT_ApiFile            = "compilers/apifunctions.txt" ; related to PB path
    
    #DEFAULT_NewLineType        = 1 ; lf
    #DEFAULT_DLLExtension       = "so"
    
    #DEFAULT_ImageBorder        = 0 ; for colorpicker
    
    #DEFAULT_CanWindowStayOnTop = 1
    #DEFAULT_BigButtons         = 1
    
    #DEFAULT_PreferencesTreeWidth = 300 ; Linux has bigger fonts, so increase this size
    
    #FLAG_Warning = 0                ; on Windows: #MB_ICONWARNING
    #FLAG_Error = 0                  ; on Windows: #MB_ICONERROR
    #FLAG_Question = 0               ; on Windows: #MB_ICONQUESTION
    #FLAG_Info = 0                   ; on windows: #MB_ICONINFORMATION
    
    #PB_MessageRequester_ResultOk = 6
    
  CompilerCase #PB_OS_MacOS ;- MacOS
    #CompileWindows   = 0
    #CompileLinux     = 0
    #CompileLinuxGtk1 = 0  ; to directly check for linux + gtk version, which is often needed
    #CompileLinuxGtk2 = 0
    
    #CompileMac       = 1
    
    CompilerIf Subsystem("carbon")
      #CompileMacCocoa  = 0
      #CompileMacCarbon = 1
    CompilerElse
      #CompileMacCocoa  = 1
      #CompileMacCarbon = 0
    CompilerEndIf
    
    #OS_PureBasic = "MacOSX"
    
    #Separator     = "/"
    #NewLine       = Chr(10) ; use unix style newline here too now
    #NewLineLength = 1
    #PATH_CaseInSensitive = 1  ; are filenames case sensitive?
    
    ; Platform specific default values:
    ;
    #DEFAULT_BigButtons         = 0
    #DEFAULT_SplitterWidth      = 4
    
    #DEFAULT_DebuggerSource     = "../PureBasicDebugger/"
    #DEFAULT_DebuggerStayOnTop  = 1
    #DEFAULT_DebuggerBringToTop = 1
    
    #DEFAULT_ListIconImageSize  = 12 ; 12x12 looks better on linux
    #DEFAULT_ListIconImageOffset= 0  ; place to put the real 12x12 image
    
    #DEFAULT_VisualDesigner     = ""     ; will remove the VD entry from the menu
    #DEFAULT_CatalogPath        = "catalogs/"
    #DEFAULT_HelpPath           = "help/"
    #DEFAILT_LibraryViewerPlugin= "debugger/"
    #DEFAULT_ThemePath          = "themes/"
    
    DefaultEditorFontName$      = "Monaco"
    #DEFAULT_EditorFontSize     = 14
    
    #DEFAULT_FunctionFile       = "pbfunctions.txt"  ; related to Temp$ path
    #DEFAULT_ApiFile            = "compilers/apifunctions.txt" ; related to PB path
    
    #DEFAULT_NewLineType        = 1 ; lf (on OS X, the norm is now lf, no more 'cr' https://www.purebasic.fr/english/viewtopic.php?f=24&t=55391)
    #DEFAULT_DLLExtension       = "so"
    
    #DEFAULT_ImageBorder        = 0 ; for colorpicker
    
    #DEFAULT_CanWindowStayOnTop = 1
    
    #DEFAULT_PreferencesTreeWidth = 180 ; with of tree gadget in prefs
    
    #FLAG_Warning = 0                ; on Windows: #MB_ICONWARNING
    #FLAG_Error = 0                  ; on Windows: #MB_ICONERROR
    #FLAG_Question = 0               ; on Windows: #MB_ICONQUESTION
    #FLAG_Info = 0                   ; on windows: #MB_ICONINFORMATION
    
    #PB_MessageRequester_ResultOk = 6
    
CompilerEndSelect



CompilerIf #SpiderBasic
  
  CompilerIf #CompileWindows
    #PreferenceFileName$ = "SpiderBasic.prefs"
  CompilerElse
    #PreferenceFileName$ = "spiderbasic.prefs"
  CompilerEndIf
  
CompilerElse
  
  CompilerIf #CompileWindows
    #PreferenceFileName$ = "PureBasic.prefs"
  CompilerElse
    #PreferenceFileName$ = "purebasic.prefs"
  CompilerEndIf
  
CompilerEndIf


CompilerIf #PB_Compiler_Unicode
  #CharSize = 2
CompilerElse
  #CharSize = 1
CompilerEndIf
