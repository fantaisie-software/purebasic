; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; The debugger engine and its windows, without any host: included by StandaloneDebugger.pb (and
; by the unit tests in UnitTests/), which define the procedures declared for the host in DebuggerCommon.pb
; (DebuggerCallback(), Debugger_ShowLine(), FlushEvents()...). The IDE includes these files itself.

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
XIncludeFile ".." + #Separator + "GetRequiredSize.pb"

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
