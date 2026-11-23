; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; All the IDE source files (and the debugger ones it uses), without any startup code.
; Included by PureBasic.pb, and by the unit tests (UnitTests/) to test the IDE code without starting it.
; Note: Procedures defined in PureBasic.pb itself (ShutdownIDE(), ...) must be defined by a test too.

; Change: Now *every* file in the source tree is included from this file (for PureBasic.pb)
; This will reduce the number of XIncludeFile's in each file, and there is no more need to check dependencies.
; Even platform specific files are always included. Whether their code is compiled
; is decided in each file.

XIncludeFile "CompilerFlags.pb"
XIncludeFile #BuildDirectory + "BuildInfo.pb"
XIncludeFile "Common.pb"                                                    ; must be before DebuggerCommon.pb
XIncludeFile "DialogLibrary.pb"                                             ; dialogs (with the Dialog library)
XIncludeFile #DEFAULT_DebuggerSource + "DebuggerCommon.pb"                  ; must be before Declarations.pb
XIncludeFile "Declarations.pb"
XIncludeFile "Macro.pb"
XIncludeFile ".." + #Separator + "PureBasicConfigPath.pb" ; for the config directory
XIncludeFile "FormDesigner/declare.pb"
; must be here to affect all OpenWindow() calls with a macro
XIncludeFile "LinuxWindowIcon.pb"

; include the TabBarGadget. Note: It has an EnableExplicit inside
XIncludeFile "TabBarGadget.pbi"
DisableExplicit

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
XIncludeFile "EditHistory.pb"
XIncludeFile "UpdateCheck.pb"
XIncludeFile "RadixTree.pb"

CompilerIf #SpiderBasic
  XIncludeFile "CreateApp.pb"
CompilerEndIf

; toolspanel plugins
XIncludeFile "AsciiTable.pb"
XIncludeFile "Explorer.pb"
XIncludeFile "ProjectPanel.pb"
XIncludeFile "ColorPicker.pb"
XIncludeFile "ProcedureBrowser.pb"
XIncludeFile "VariableViewer.pb"
CompilerIf #CompileLinuxGtk2 = 0 ; WebViewGadget needs webkit2gtk, which is GTK3 only and aborts a GTK2 process at startup
  XIncludeFile "HelpTool.pb"
CompilerEndIf
XIncludeFile "Issues.pb"
CompilerIf #SpiderBasic
  XIncludeFile "WebView.pb"
CompilerEndIf

; windows specific
XIncludeFile "WindowsMisc.pb"
XIncludeFile "WindowsHelp.pb"

; linux specific
XIncludeFile "LinuxMisc.pb"

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
