; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



; indicates that we are compiling IDE
; used for portable code like the HighlightingEngine.or the FormDesigner
;
#PUREBASIC_IDE = 1


CompilerIf #SpiderBasic
  
  Enumeration
    #AppFormatWeb
    #AppFormatiOS
    #AppFormatAndroid
  EndEnumeration
CompilerEndIf

;
;- Highlighting Colors
;
; Colors now managed in an array for easier extension and less code
;
; NOTE: The values of these constants must correspond to the keys in the
;       language section that display them. The order in which the settings
;       are displayed in the prefs is independent, as it can be set in the dialog xml
;       The first index must be 0 so #COLOR_Last+1 is the total number of colors
;
;       Also the order of the Keys and color sets at the bottom of Preferences.pb
;       must match this order
;
Enumeration 0
  #COLOR_ASMKeyword
  #COLOR_GlobalBackground ; #COLOR_BACKGROUND is a winapi constant!
  #COLOR_BasicKeyword
  #COLOR_Comment
  #COLOR_Constant
  #COLOR_Label
  #COLOR_NormalText
  #COLOR_Number
  #COLOR_Operator
  #COLOR_Pointer
  #COLOR_PureKeyword
  #COLOR_Separator
  #COLOR_String
  #COLOR_Structure
  #COLOR_LineNumber
  #COLOR_LineNumberBack
  #COLOR_Marker
  #COLOR_CurrentLine
  #COLOR_Selection
  #COLOR_SelectionFront
  #COLOR_Cursor
  #COLOR_DebuggerLine
  #COLOR_DebuggerLineSymbol
  #COLOR_DebuggerError
  #COLOR_DebuggerErrorSymbol
  #COLOR_DebuggerBreakPoint
  #COLOR_DebuggerBreakpointSymbol
  #COLOR_DisabledBack
  #COLOR_GoodBrace
  #COLOR_BadBrace
  #COLOR_ProcedureBack
  #COLOR_CustomKeyword
  #COLOR_DebuggerWarning
  #COLOR_DebuggerWarningSymbol
  #COLOR_Whitespace
  #COLOR_Module
  #COLOR_SelectionRepeat
  #COLOR_PlainBackground
  
  #COLOR_Last = #COLOR_PlainBackground
  
  ; Special cases beyond "Last"
  #COLOR_ToolsPanelFrontColor = #COLOR_Last + 1
  #COLOR_ToolsPanelBackColor
  #COLOR_Last_IncludingToolsPanel = #COLOR_Last + 2
EndEnumeration


;- Windows
;
Runtime Enumeration 1 ; 0 is reserved
  #WINDOW_Startup
  #WINDOW_Main
  #WINDOW_About
  #WINDOW_Preferences
  #WINDOW_FileViewer
  #WINDOW_Goto
  #WINDOW_Find
  #WINDOW_StructureViewer
  #WINDOW_Compiler
  #WINDOW_Option
  CompilerIf #SpiderBasic
    #WINDOW_CreateApp
  CompilerEndIf
  #WINDOW_Grep
  #WINDOW_GrepOutput
  #WINDOW_AddTools
  #WINDOW_EditTools
  #WINDOW_AutoComplete
  ;#WINDOW_SortSources
  ;#WINDOW_CPUMonitor
  #WINDOW_Template
  #WINDOW_MacroError
  #WINDOW_Warnings
  #WINDOW_ProjectOptions
  #WINDOW_Build
  #WINDOW_Help
  #WINDOW_Diff
  #WINDOW_DiffDirectory
  #WINDOW_DiffDialog
  #WINDOW_FileMonitor
  #WINDOW_EditHistory
  #WINDOW_EditHistoryShutdown
  #WINDOW_Updates
  #WINDOW_Form_Parent
  
  CompilerIf #DEBUG
    #WINDOW_Debugging ; for global use. all gadgets are #PB_Any on this window
  CompilerEndIf
EndEnumeration

;- Gadgets
;
Runtime Enumeration 1 ; 0 is reserved for uninitialized #PB_Any
  #GADGET_FilesPanel     ; now a custom drawn CanvasGadget
  #GADGET_ToolsPanel
  #GADGET_ToolsPanelFake ; for hidden toolspanel
  #GADGET_ErrorLog
  
  #GADGET_ToolsSplitter
  #GADGET_LogSplitter
  #GADGET_SourceContainer
  #GADGET_LogDummy   ; dummy to put in the splitter when log is hidden (replaces the sourcecontainer)
  #GADGET_ToolsDummy ; dummy to put in when it is not used (to replace the seconds splitter)
  
  #GADGET_ProjectInfo
  #GADGET_ProjectInfo_FrameProject
  #GADGET_ProjectInfo_FrameFiles
  #GADGET_ProjectInfo_FrameTargets
  #GADGET_ProjectInfo_Info
  #GADGET_ProjectInfo_Files
  #GADGET_ProjectInfo_Targets
  #GADGET_ProjectInfo_OpenOptions
  #GADGET_ProjectInfo_OpenCompilerOptions
  
  #GADGET_Form
  #GADGET_Form_Canvas
  #GADGET_Form_ScrollH
  #GADGET_Form_ScrollV
  #Form_Prop
  #Form_PropObjList
  #Form_GridContainer
  #Form_WindowTabs
  #Form_ObjList
  #Form_SplitterInt
  #Form_Splitter_1st
  #Form_Splitter_2nd
  #Form_Splitter_OK
  #Form_Splitter_Cancel
  
  #GADGET_Form_Parent_Select_Text
  #GADGET_Form_Parent_Select
  #GADGET_Form_Parent_SelectItem
  #GADGET_Form_Parent_SelectItem_Text
  #GADGET_Form_Parent_OK
  #GADGET_Form_Parent_Cancel
  
  #GADGET_ProcedureBrowser
  ; Controls for the 'Multicolored Procedure List'
  #GADGET_ProcedureBrowser_FilterInput
  #GADGET_ProcedureBrowser_HideModuleNames
  #GADGET_ProcedureBrowser_HighlightProcedure
  #GADGET_ProcedureBrowser_ScrollProcedure
  #GADGET_ProcedureBrowser_EnableFolding
  #GADGET_ProcedureBrowser_BackColor
  #GADGET_ProcedureBrowser_FrontColor
  #GADGET_ProcedureBrowser_RestoreColor
  #GADGET_ProcedureBrowser_CopyClipboard
  #GADGET_ProcedureBrowser_SwitchButtons
  
  #GADGET_ProjectPanel
  
  #GADGET_Explorer
  #GADGET_Explorer_Pattern
  #GADGET_Explorer_Favorites
  #GADGET_Explorer_AddFavorite
  #GADGET_Explorer_RemoveFavorite
  #GADGET_Explorer_Splitter
  
  #GADGET_AsciiTable
  #GADGET_Ascii_InsertChar
  #GADGET_Ascii_InsertAscii
  #GADGET_Ascii_InsertHex
  #GADGET_Ascii_InsertHtml
  
  ; help viewer gadget (windows only right now)
  #GADGET_HelpTool_Viewer
  #GADGET_HelpTool_Back
  #GADGET_HelpTool_Forward
  #GADGET_HelpTool_Home
  #GADGET_HelpTool_Help
  
  CompilerIf #SpiderBasic
    #GADGET_WebView_Url
    #GADGET_WebView_OpenBrowser
    #GADGET_WebView_WebView
  CompilerEndIf
  
  #GADGET_Build_Targets
  #GADGET_Build_Log
  #GADGET_Build_WorkContainer
  #GADGET_Build_DoneContainer
  #GADGET_Build_CloseWhenDone
  #GADGET_Build_Abort
  #GADGET_Build_Copy
  #GADGET_Build_Save
  #GADGET_Build_Close
  
  #GADGET_Preferences_Tree
  #GADGET_Preferences_Ok
  #GADGET_Preferences_Cancel
  #GADGET_Preferences_Apply
  #GADGET_Preferences_PageUp    ; Not actually a gadget, for now, just a shortcut
  #GADGET_Preferences_PageDown  ; Not actually a gadget, for now, just a shortcut
  #GADGET_Preferences_MonitorFileChanges
  #GADGET_Preferences_SystemMessages
  #GADGET_Preferences_DebugToLog
  #GADGET_Preferences_ToolsPanelDelay
  #GADGET_Preferences_MemorizeMarkers
  #GADGET_Preferences_ColorSchemes
  #GADGET_Preferences_ColorSchemeSet
  #GADGET_Preferences_ExpShortcut
  #GADGET_Preferences_ExpToolbar
  #GADGET_Preferences_ExpColor
  #GADGET_Preferences_ExpFolding
  #GADGET_Preferences_ExportFile
  #GADGET_Preferences_GetExportFile
  #GADGET_Preferences_Export
  #GADGET_Preferences_ImpShortcut
  #GADGET_Preferences_ImpToolbar
  #GADGET_Preferences_ImpColor
  #GADGET_Preferences_ImpFolding
  #GADGET_Preferences_ImportFile
  #GADGET_Preferences_GetImportFile
  #GADGET_Preferences_OpenImport
  #GADGET_Preferences_Import
  #GADGET_Preferences_AutoHidePanel
  #GADGET_Preferences_NoSplashScreen
  #GADGET_Preferences_DisplayFullPath
  CompilerIf #CompileMac
    #GADGET_Preferences_DisplayDarkMode
  CompilerEndIf
  #GADGET_Preferences_EnableMenuIcons
  #GADGET_Preferences_DebuggerMode
  #GADGET_Preferences_AutoClearLog
  #GADGET_Preferences_DisplayErrorWindow
  #GADGET_Preferences_DebuggerMemorizeWindows ; first to auto-disable
  #GADGET_Preferences_WarningMode
  #GADGET_Preferences_KeepErrorMarks
  #GADGET_Preferences_DebuggerAlwaysOnTop
  #GADGET_Preferences_DebuggerBringToTop
  #GADGET_Preferences_DebuggerStopAtStart
  #GADGET_Preferences_DebuggerStopAtEnd
  #GADGET_Preferences_DebuggerLogTimeStamp
  #GADGET_Preferences_DebuggerTimeout
  #GADGET_Preferences_KillOnError
  #GADGET_Preferences_DebugOutUseFont
  #GADGET_Preferences_DebugOutFont
  #GADGET_Preferences_DebugIsHex
  #GADGET_Preferences_DebugOutTimeStamp
  #GADGET_Preferences_RegisterIsHex
  #GADGET_Preferences_StackIsHex
  #GADGET_Preferences_AutoStackUpdate
  #GADGET_Preferences_MemoryIsHex
  #GADGET_Preferences_MemoryOneColumn
  #GADGET_Preferences_VariableIsHex
  #GADGET_Preferences_ProfilerStartup
  #GADGET_Preferences_PurifierOpen
  #GADGET_Preferences_DataBreakpointsOpen
  #GADGET_Preferences_DebugWindowOpen
  #GADGET_Preferences_AsmWindowOpen
  #GADGET_Preferences_MemoryWindowOpen
  #GADGET_Preferences_VariableWindowOpen
  #GADGET_Preferences_ProfilerWindowOpen
  #GADGET_Preferences_HistoryWindowOpen
  #GADGET_Preferences_LibraryViewerWindowOpen
  #GADGET_Preferences_WatchlistWindowOpen  ; last auto-disabled
  #GADGET_Preferences_SaveProjectSettings
  #GADGET_Preferences_SelectToolsPanelFont
  #GADGET_Preferences_UseToolsPanelFont
  #GADGET_Preferences_UseToolsPanelColors
  #GADGET_Preferences_ToolsPanelFrontColor
  #GADGET_Preferences_ToolsPanelFrontColorText
  #GADGET_Preferences_ToolsPanelFrontColorSelect
  #GADGET_Preferences_ToolsPanelBackColor
  #GADGET_Preferences_ToolsPanelBackColorText
  #GADGET_Preferences_ToolsPanelBackColorSelect
  #GADGET_Preferences_NoIndependentToolsColors
  #GADGET_Preferences_KeywordList
  #GADGET_Preferences_KeywordText
  #GADGET_Preferences_KeywordAdd
  #GADGET_Preferences_KeywordRemove
  #GADGET_Preferences_KeywordFile
  #GADGET_Preferences_GetKeywordFile
  #GADGET_Preferences_EnableFolding
  #GADGET_Preferences_FoldStartList  ; first to autodisable
  #GADGET_Preferences_FoldStartText
  #GADGET_Preferences_FoldStartAdd
  #GADGET_Preferences_FoldStartRemove
  #GADGET_Preferences_FoldEndList
  #GADGET_Preferences_FoldEndText
  #GADGET_Preferences_FoldEndAdd
  #GADGET_Preferences_FoldEndRemove   ; last to autodisable
  #GADGET_Preferences_MemorizeWindow
  #GADGET_Preferences_RunOnce
  #GADGET_Preferences_ShowMainToolbar
  #GADGET_Preferences_FileHistorySize
  #GADGET_Preferences_FindHistorySize
  #GADGET_Preferences_AutoReload
  #GADGET_Preferences_AutoSave
  ;  #GADGET_Preferences_AutoSaveExe
  #GADGET_Preferences_AutoSaveAll
  #GADGET_Preferences_TabLength
  #GADGET_Preferences_RealTab
  #GADGET_Preferences_MemorizeCursor
  #GADGET_Preferences_SourcePath
  #GADGET_Preferences_GetSourcePath
  #GADGET_Preferences_AlwaysHideLog
  #GADGET_Preferences_Debugger
  #GADGET_Preferences_Purifier
  #GADGET_Preferences_ErrorLog
  #GADGET_Preferences_Optimizer
  #GADGET_Preferences_InlineASM
  #GADGET_Preferences_XPSkin
  #GADGET_Preferences_Wayland
  #GADGET_Preferences_VistaAdmin
  #GADGET_Preferences_VistaUser
  #GADGET_Preferences_DPIAware
  #GADGET_Preferences_DllProtection
  #GADGET_Preferences_SharedUCRT
  #GADGET_Preferences_Thread
  #GADGET_Preferences_OnError
  #GADGET_Preferences_CustomCompiler
  #GADGET_Preferences_SelectCustomCompiler
  #GADGET_Preferences_ExecutableFormat
  #GADGET_Preferences_CPU
  #GADGET_Preferences_NewLineType
  #GADGET_Preferences_Encoding
  #GADGET_Preferences_SubSystem
  #GADGET_Preferences_UseCompileCount
  #GADGET_Preferences_UseBuildCount
  #GADGET_Preferences_UseCreateExecutable
  #GADGET_Preferences_TemporaryExe
  #GADGET_Preferences_ToolsPanelSide
  #GADGET_Preferences_AvailableTools
  #GADGET_Preferences_UsedTools
  #GADGET_Preferences_AddTool
  #GADGET_Preferences_RemoveTool
  #GADGET_Preferences_MoveToolUp
  #GADGET_Preferences_MoveToolDown
  #GADGET_Preferences_ToolSettingsContainer
  #GADGET_Preferences_ToolSettingsScrollArea
  #GADGET_Preferences_ExplorerMode0
  #GADGET_Preferences_ExplorerMode1
  #GADGET_Preferences_ExplorerSavePath
  #GADGET_Preferences_ExplorerShowHidden
  #GADGET_Preferences_ProcedureBrowserSort
  #GADGET_Preferences_ProcedureBrowserGroup
  #GADGET_Preferences_ProcedureProtoType
  #GADGET_Preferences_ProcedureMulticolor
  ;  #GADGET_Preferences_ColorPickerHistory
  #GADGET_Preferences_Languages
  #GADGET_Preferences_LanguageInfo
  ;  #GADGET_Preferences_EnableColoring
  #GADGET_Preferences_EnableBolding
  #GADGET_Preferences_EnableCaseCorrection
  #GADGET_Preferences_EnableLineNumbers
  ;  #GADGET_Preferences_EnableMarkers
  #GADGET_Preferences_EnableAccessibility
  #GADGET_Preferences_ExtraWordChars
  #GADGET_Preferences_ShowWhiteSpace
  #GADGET_Preferences_ShowIndentGuides
  #GADGET_Preferences_UseTabIndentForSplittedLines
  #GADGET_Preferences_EnableBraceMatch
  #GADGET_Preferences_EnableKeywordMatch
  #GADGET_Preferences_SelectFont
  #GADGET_Preferences_CurrentFont
  #GADGET_Preferences_BoxWidth
  #GADGET_Preferences_BoxHeight
  #GADGET_Preferences_AutoPopup
  #GADGET_Preferences_AddBrackets
  #GADGET_Preferences_AddSpaces
  #GADGET_Preferences_AddEndKeywords
  ;  #GADGET_Preferences_NoComments
  ;  #GADGET_Preferences_NoStrings
  #GADGET_Preferences_AutoPopupLength
  #GADGET_Preferences_StructureItems
  #GADGET_Preferences_ModulePrefix
  #GADGET_Preferences_PBOptions
  #GADGET_Preferences_CodeOptions
  #GADGET_Preferences_SourceOnly
  #GADGET_Preferences_ProjectOnly
  #GADGET_Preferences_ProjectAllFiles
  #GADGET_Preferences_AllFiles
  #GADGET_Preferences_ShortcutBox
  #GADGET_Preferences_ShortcutList
  ;#GADGET_Preferences_ShortcutControl
  ;#GADGET_Preferences_ShortcutAlt
  ;#GADGET_Preferences_ShortcutShift
  ;#GADGET_Preferences_ShortcutCommand
  ;#GADGET_Preferences_ShortcutKey
  #GADGET_Preferences_SelectShortcut
  #GADGET_Preferences_ShortcutSet
  #GADGET_Preferences_ToolbarIconType
  #GADGET_Preferences_ToolbarIconList
  #GADGET_Preferences_ToolbarIconName
  #GADGET_Preferences_ToolbarOpenIcon
  #GADGET_Preferences_ToolbarActionType
  #GADGET_Preferences_ToolbarActionList
  #GADGET_Preferences_ToolbarMoveUp
  #GADGET_Preferences_ToolbarMoveDown
  #GADGET_Preferences_ToolbarAdd
  #GADGET_Preferences_ToolbarDelete
  #GADGET_Preferences_ToolbarSet
  #GADGET_Preferences_ToolbarClassic
  #GADGET_Preferences_ToolbarDefault
  #GADGET_Preferences_ToolbarList
  #GADGET_Preferences_FirstColor
  #GADGET_Preferences_LastColor       = #GADGET_Preferences_FirstColor + #COLOR_Last
  #GADGET_Preferences_FirstSelectColor
  #GADGET_Preferences_LastSelectColor = #GADGET_Preferences_FirstSelectColor + #COLOR_Last
  #GADGET_Preferences_FirstColorText
  #GADGET_Preferences_LastColorText   = #GADGET_Preferences_FirstColorText + #COLOR_Last
  #GADGET_Preferences_FirstColorCheck
  #GADGET_Preferences_LastColorCheck  = #GADGET_Preferences_FirstColorCheck + #COLOR_Last
  #GADGET_Preferences_TemplatesAskDelete
  #GADGET_Preferences_FirstContainer
  #GADGET_Preferences_LastContainer   = #GADGET_Preferences_FirstContainer + 24
  #GADGET_Preferences_ToolsPanelDelayText
  #GADGET_Preferences_ToolSettingsTitle
  #GADGET_Preferences_AutoPopupText
  #GADGET_Preferences_Themes
  #GADGET_Preferences_DefaultCompiler
  #GADGET_Preferences_CompilerList
  #GADGET_Preferences_AddCompiler
  #GADGET_Preferences_RemoveCompiler
  #GADGET_Preferences_ClearCompilers
  #GADGET_Preferences_CompilerExe
  #GADGET_Preferences_SelectCompiler
  #GADGET_Preferences_IndentNo        ; first of option group (IndentMode value)
  #GADGET_Preferences_IndentBlock
  #GADGET_Preferences_IndentSensitive ; last of option group (IndentMode value)
  #GADGET_Preferences_BackspaceUnindent
  #GADGET_Preferences_IndentList    ; first to auto disable
  #GADGET_Preferences_IndentKeyword
  #GADGET_Preferences_IndentBefore
  #GADGET_Preferences_IndentAfter
  #GADGET_Preferences_IndentAdd
  #GADGET_Preferences_IndentRemove  ; last to auto disable
  #GADGET_Preferences_UseHelpToolF1
  #GADGET_Preferences_FormVariable
  #GADGET_Preferences_FormVariableCaption
  #GADGET_Preferences_FormGrid
  #GADGET_Preferences_FormEventProcedure
  #GADGET_Preferences_FormGridSize
  #GADGET_Preferences_FormSkin
  #GADGET_Preferences_FormNotRecognizedCaption
  #GADGET_Preferences_FormNotRecognized
  #GADGET_Preferences_FormDowngradeCaption
  #GADGET_Preferences_FormDowngrade
  #GADGET_Preferences_FormUpgradeCaption
  #GADGET_Preferences_FormUpgrade
  #GADGET_Preferences_EnableHistory
  #GADGET_Preferences_HistoryTimer  ; first to auto disable
  #GADGET_Preferences_HistoryMaxFileSize
  #GADGET_Preferences_HistoryPurgeNever
  #GADGET_Preferences_HistoryPurgeByDays
  #GADGET_Preferences_HistoryPurgeByDays2
  #GADGET_Preferences_HistoryPurgeByCount
  #GADGET_Preferences_HistoryPurgeByCount2
  #GADGET_Preferences_HistoryDays
  #GADGET_Preferences_HistoryCount    ; last to auto disable
  #GADGET_Preferences_HistoryFile
  #GADGET_Preferences_FilesPanelMultiline
  #GADGET_Preferences_FilesPanelCloseButtons
  #GADGET_Preferences_FilesPanelNewButton
  #GADGET_Preferences_UpdateCheckInterval
  #GADGET_Preferences_UpdateCheckVersions
  #GADGET_Preferences_IssueList
  #GADGET_Preferences_NewIssue
  #GADGET_Preferences_UpdateIssue
  #GADGET_Preferences_DeleteIssue
  #GADGET_Preferences_IssueName  ; first in loop
  #GADGET_Preferences_IssueExpr
  #GADGET_Preferences_IssuePriority
  #GADGET_Preferences_IssueColor
  #GADGET_Preferences_SelectIssueColor
  #GADGET_Preferences_IssueCodeNoColor
  #GADGET_Preferences_IssueCodeBack
  #GADGET_Preferences_IssueCodeLine
  #GADGET_Preferences_IssueInTool
  #GADGET_Preferences_IssueInBrowser ; last in loop
  #GADGET_Preferences_CodeFileExtensions
  
  CompilerIf #SpiderBasic
    #GADGET_Preferences_WebBrowser
    #GADGET_Preferences_SelectWebBrowser
    #GADGET_Preferences_WebServerPort
    #GADGET_Preferences_JDK
    #GADGET_Preferences_SelectJDK
    #GADGET_Preferences_AppleTeamID
  CompilerEndIf
  
  #GADGET_FileMonitor_Text
  #GADGET_FileMonitor_Reload
  #GADGET_FileMonitor_Cancel
  #GADGET_FileMonitor_ViewDiff
  
  #GADGET_Goto_Line
  #GADGET_Goto_Cancel
  #GADGET_Goto_Ok
  
  #GADGET_Find_FindWord
  #GADGET_Find_ReplaceWord
  #GADGET_Find_DoReplace
  #GADGET_Find_Case
  #GADGET_Find_WholeWord
  #GADGET_Find_SelectionOnly
  #GADGET_Find_AutoWrap
  #GADGET_Find_NoComments
  #GADGET_Find_NoStrings
  #GADGET_Find_FindNext
  #GADGET_Find_FindPrevious
  #GADGET_Find_Replace
  #GADGET_Find_ReplaceAll
  #GADGET_Find_Close
  
  #GADGET_StructureViewer_Panel
  #GADGET_StructureViewer_List
  #GADGET_StructureViewer_Parent
  #GADGET_StructureViewer_Name
  #GADGET_StructureViewer_Ok
  #GADGET_StructureViewer_Cancel
  #GADGET_StructureViewer_OnTop
  #GADGET_StructureViewer_InsertName
  #GADGET_StructureViewer_InsertStruct
  #GADGET_StructureViewer_InsertCopy
  #GADGET_StructureViewer_Char0
  #GADGET_StructureViewer_Char27 = #GADGET_StructureViewer_Char0 + 27
  
  #GADGET_Grep_FindWord
  #GADGET_Grep_Directory
  #GADGET_Grep_SelectDirectory
  #GADGET_Grep_UseCurrentDirectory
  #GADGET_Grep_Pattern
  #GADGET_Grep_MatchCase
  #GADGET_Grep_Recurse
  #GADGET_Grep_NoComments
  #GADGET_Grep_NoStrings
  #GADGET_Grep_WholeWord
  #GADGET_Grep_Cancel
  #GADGET_Grep_Stop
  #GADGET_Grep_Find
  
  #GADGET_GrepOutput_List
  #GADGET_GrepOutput_Close
  #GADGET_GrepOutput_Clear
  #GADGET_GrepOutput_Current
  
  #GADGET_Compiler_Text
  #GADGET_Compiler_Details
  #GADGET_Compiler_List
  #GADGET_Compiler_Progress
  #GADGET_Compiler_Abort
  
  #GADGET_Option_UseMainFile
  #GADGET_Option_MainFile         ; also for inputfile in project mode
  #GADGET_Option_SelectMainFile
  #GADGET_Option_OutputFileLabel  ; only in project mode (hidden in SpiderBasic)
  #GADGET_Option_OutputFile       ; only in project mode (hidden in SpiderBasic)
  #GADGET_Option_SelectOutputFile ; only in project mode (hidden in SpiderBasic)
  #GADGET_Option_Debugger
  #GADGET_Option_Purifier
  #GADGET_Option_SelectDebugger
  #GADGET_Option_DebuggerMode
  #GADGET_Option_SelectWarning
  #GADGET_Option_WarningMode
  
  #GADGET_Option_UseCompiler  ; First to be disabled/enabled in "Main file" loop
  #GADGET_Option_SelectCompiler
  #GADGET_Option_Optimizer
  #GADGET_Option_DPIAware
  CompilerIf #SpiderBasic
    #GADGET_Option_WindowTheme
    #GADGET_Option_SelectWindowTheme
    #GADGET_Option_GadgetTheme
    #GADGET_Option_SelectGadgetTheme
    #GADGET_Option_WebServerAddress
  CompilerElse
    #GADGET_Option_UseIcon
    #GADGET_Option_SelectIcon
    #GADGET_Option_IconName
    #GADGET_Option_EnableThread
    #GADGET_Option_EnableXP
    #GADGET_Option_EnableWayland
    #GADGET_Option_EnableAdmin
    #GADGET_Option_EnableUser
    #GADGET_Option_DllProtection
    #GADGET_Option_SharedUCRT
    #GADGET_Option_EnableOnError
    #GADGET_Option_ExecutableFormat
    #GADGET_Option_EnableASM
    #GADGET_Option_CPU
    #GADGET_Option_Linker
    #GADGET_Option_GetLinker
  CompilerEndIf
  #GADGET_Option_SubSystem
  #GADGET_Option_UseCompileCount
  #GADGET_Option_UseBuildCount
  #GADGET_Option_UseCreateExe
  #GADGET_Option_BuildCount
  #GADGET_Option_CompileCount
  #GADGET_Option_ConstantList
  #GADGET_Option_ConstantAdd
  #GADGET_Option_ConstantSet
  #GADGET_Option_ConstantRemove
  #GADGET_Option_ConstantClear
  #GADGET_Option_ConstantLine  ; Last label to be disabled/enabled in the 'Main file' loop
  #GADGET_Option_CommandLine
  #GADGET_Option_CurrentDir
  #GADGET_Option_SelectCurrentDir
  #GADGET_Option_TemporaryExe
  #GADGET_Option_ToolsList
  #GADGET_Option_Ok
  #GADGET_Option_Cancel
  #GADGET_Option_Panel
  #GADGET_Option_IncludeVersion
  #GADGET_Option_VersionText0
  #GADGET_Option_VersionText17 = #GADGET_Option_VersionText0 + 17
  #GADGET_Option_VersionValue0
  #GADGET_Option_VersionValue23 = #GADGET_Option_VersionValue0 + 23
  #GADGET_Option_RequiredFields
  #GADGET_Option_Tokens
  #GADGET_Option_ResourceList
  #GADGET_Option_ResourceAdd
  #GADGET_Option_ResourceRemove
  #GADGET_Option_ResourceClear
  #GADGET_Option_ResourceFile
  #GADGET_Option_ResourceSelectFile
  #GADGET_Option_AddTarget
  #GADGET_Option_EditTarget
  #GADGET_Option_CopyTarget
  #GADGET_Option_RemoveTarget
  #GADGET_Option_TargetUp
  #GADGET_Option_TargetDown
  #GADGET_Option_TargetList
  #GADGET_Option_DefaultTarget
  #GADGET_Option_TargetEnabled
  #GADGET_Option_DefaultTargetMenu ; not real gadgets, but needed to know the difference between gadget and popupmenu action
  #GADGET_Option_TargetEnabledMenu
  #GADGET_Option_OpenProject
  
  #GADGET_AddTools_List ; must be the first (for loop processing)
  #GADGET_AddTools_New
  #GADGET_AddTools_Edit
  #GADGET_AddTools_Delete
  #GADGET_AddTools_Up
  #GADGET_AddTools_Down
  #GADGET_AddTools_OK     ; last loop processed item
  #GADGET_AddTools_Cancel ; this one never gets disabled
  
  #GADGET_EditTools_CommandLine
  #GADGET_EditTools_ChooseCommandLine
  #GADGET_EditTools_Arguments
  #GADGET_EditTools_ArgumentsInfo
  #GADGET_EditTools_WorkingDir
  #GADGET_EditTools_ChooseWorkingDir
  #GADGET_EditTools_MenuEntry
  #GADGET_EditTools_Trigger
  #GADGET_EditTools_Ok
  #GADGET_EditTools_Cancel
  #GADGET_EditTools_RunHidden  ; first for loop processing
                               ;   #GADGET_EditTools_ShortcutControl
                               ;   #GADGET_EditTools_ShortcutAlt
                               ;   #GADGET_EditTools_ShortcutShift
                               ;   #GADGET_EditTools_ShortcutCommand
                               ;   #GADGET_EditTools_ShortcutKey
  #GADGET_EditTools_Shortcut
  #GADGET_EditTools_HideEditor
  #GADGET_EditTools_Reload
  #GADGET_EditTools_ReloadNew
  #GADGET_EditTools_ReloadOld
  #GADGET_EditTools_WaitForQuit
  #GADGET_EditTools_ConfigLine
  #GADGET_EditTools_SourceSpecific
  #GADGET_EditTools_HideFromMenu ; last for loop processing
  
  
  
  ;   #GADGET_SortSources_List
  ;   #GADGET_SortSources_MoveUp
  ;   #GADGET_SortSources_MoveDown
  ;   #GADGET_SortSources_OK
  ;   #GADGET_SortSources_Cancel
  
  #GADGET_FileViewer_Panel
  #GADGET_Startup_Image
  
  #GADGET_About_Ok
  #GADGET_About_Image
  #GADGET_About_Editor
  
  #GADGET_AutoComplete_List
  #GADGET_AutoComplete_Abort
  #GADGET_AutoComplete_Ok
  
  ;   #GADGET_CPU_Graph
  ;   #GADGET_CPU_List
  ;   #GADGET_CPU_OnTop
  ;   #GADGET_CPU_Text
  ;   #GADGET_CPU_Interval
  ;   #GADGET_CPU_Set
  
  #GADGET_Template_Add     ; first to auto-disable
  #GADGET_Template_Edit
  #GADGET_Template_Remove
  #GADGET_Template_AddDir
  #GADGET_Template_RemoveDir
  #GADGET_Template_Up
  #GADGET_Template_Down
  #GADGET_Template_Tree     ; last to auto-disable
  #GADGET_Template_Comment
  #GADGET_Template_Frame1
  #GADGET_Template_Frame2
  #GADGET_Template_Editor
  #GADGET_Template_SetComment
  #GADGET_Template_Save
  #GADGET_Template_Cancel
  #GADGET_Template_Rename ; not real gadgets, but used for wrappers of the menu
  #GADGET_Template_Use
  #GADGET_Template_Splitter
  
  #GADGET_Color_RGB     ; first handled in loop
  #GADGET_Color_HSV
  #GADGET_Color_HSL
  #GADGET_Color_Wheel
  #GADGET_Color_Palette
  #GADGET_Color_Name    ; last handled in loop
  #GADGET_Color_Canvas1
  #GADGET_Color_Canvas2
  #GADGET_Color_Canvas3
  #GADGET_Color_Label1
  #GADGET_Color_Label2
  #GADGET_Color_Label3
  #GADGET_Color_Scheme
  #GADGET_Color_Scroll
  #GADGET_Color_Filter
  #GADGET_Color_UseAlpha
  #GADGET_Color_CanvasAlpha
  #GADGET_Color_Current
  #GADGET_Color_Input0 ; for R, G, B, A, H, S, L, handled in loops
  #GADGET_Color_Input1
  #GADGET_Color_Input2
  #GADGET_Color_Input3
  #GADGET_Color_Input4
  #GADGET_Color_Input5
  #GADGET_Color_Input6
  #GADGET_Color_Text0
  #GADGET_Color_Text1
  #GADGET_Color_Text2
  #GADGET_Color_Text3
  #GADGET_Color_Text4
  #GADGET_Color_Text5
  #GADGET_Color_Text6
  #GADGET_Color_Hex
  #GADGET_Color_Insert
  #GADGET_Color_InsertRGB
  #GADGET_Color_Save
  #GADGET_Color_History
  
  #GADGET_Project_Panel
  #GADGET_Project_File
  #GADGET_Project_FileStatic
  #GADGET_Project_ChooseFile
  #GADGET_Project_Name
  #GADGET_Project_Comments
  #GADGET_Project_SetDefault
  #GADGET_Project_CloseAllFiles
  #GADGET_Project_OpenLoadLast
  #GADGET_Project_OpenLoadAll
  #GADGET_Project_OpenLoadDefault
  #GADGET_Project_OpenLoadMain
  #GADGET_Project_OpenLoadNone
  #GADGET_Project_AddFile
  #GADGET_Project_NewFile
  #GADGET_Project_OpenFile
  #GADGET_Project_RemoveFile
  #GADGET_Project_ViewFile
  #GADGET_Project_Explorer
  #GADGET_Project_ExplorerCombo
  #GADGET_Project_ExplorerPattern ; not present on OSX
  #GADGET_Project_FileList
  #GADGET_Project_FileLoad
  #GADGET_Project_FileScan
  #GADGET_Project_FileWarn
  #GADGET_Project_FilePanel
  #GADGET_Project_Ok
  #GADGET_Project_Cancel
  #GADGET_Project_OpenOptions
  
  #GADGET_MacroError_Scintilla
  #GADGET_MacroError_Close
  
  #GADGET_Warnings_List
  #GADGET_Warnings_Close
  
  #GADGET_Diff_Busy
  #GADGET_Diff_File1
  #GADGET_Diff_File2
  #GADGET_Diff_Title1
  #GADGET_Diff_Title2
  #GADGET_Diff_Container1
  #GADGET_Diff_Container2
  #GADGET_Diff_Splitter
  #GADGET_Diff_Splitter2
  #GADGET_Diff_Files
  #GADGET_Diff_FileTitle
  
  #GADGET_DiffDialog_File1       ; first to process in loop
  #GADGET_DiffDialog_File2
  #GADGET_DiffDialog_Directory1
  #GADGET_DiffDialog_Directory2
  #GADGET_DiffDialog_Pattern     ; last to process in loop
  #GADGET_DiffDialog_ChooseFile1
  #GADGET_DiffDialog_ChooseFile2
  #GADGET_DiffDialog_ChooseDirectory1
  #GADGET_DiffDialog_ChooseDirectory2
  #GADGET_DiffDialog_CurrentDirectory1
  #GADGET_DiffDialog_CurrentDirectory2
  #GADGET_DiffDialog_Recurse
  #GADGET_DiffDialog_CompareFiles
  #GADGET_DiffDialog_CompareDirectories
  #GADGET_DiffDialog_IgnoreCase
  #GADGET_DiffDialog_IgnoreSpaceAll
  #GADGET_DiffDialog_IgnoreSpaceLeft
  #GADGET_DiffDialog_IgnoreSpaceRight
  #GADGET_DiffDialog_Cancel
  
  #GADGET_History_Panel
  #GADGET_History_Source
  #GADGET_History_Splitter
  #GADGET_History_SessionCombo
  #GADGET_History_SessionTree
  #GADGET_History_FileCombo
  #GADGET_History_FileList
  #GADGET_HistoryShutdown_Progress
  
  #GADGET_Updates_Message
  #GADGET_Updates_Website
  #GADGET_Updates_Settings
  #GADGET_Updates_Ok
  
  #GADGET_Issues_List
  #GADGET_Issues_Filter
  #GADGET_Issues_SingleFile
  #GADGET_Issues_MultiFile
  #GADGET_Issues_Export
  
  ; Help viewer for Linux and OSX
  #GADGET_Help_Panel
  #GADGET_Help_Tree
  #GADGET_Help_Index
  #GADGET_Help_IndexText
  #GADGET_Help_SearchValue
  #GADGET_Help_SearchGo
  #GADGET_Help_SearchResults
  #GADGET_Help_Forward
  #GADGET_Help_Back
  #GADGET_Help_Home
  #GADGET_Help_Next
  #GADGET_Help_Previous
  #GADGET_Help_Viewer
  #GADGET_Help_Container
  #GADGET_Help_Splitter
  
  ; Linux only
  #GADGET_Help_Editor
  #GADGET_Help_Parent
  
  CompilerIf #SpiderBasic
    #GADGET_WebApp_Name
    #GADGET_WebApp_Icon
    #GADGET_WebApp_SelectIcon
    #GADGET_WebApp_HtmlFilename
    #GADGET_WebApp_SelectHtmlFilename
    #GADGET_WebApp_JavaScriptFilename
    #GADGET_WebApp_JavaScriptPath
    #GADGET_WebApp_EnableResourceDirectory
    #GADGET_WebApp_ResourceDirectory
    #GADGET_WebApp_CopyJavaScriptLibrary
    #GADGET_WebApp_EnableDebugger
    #GADGET_WebApp_SelectResourceDirectory
    #GADGET_WebApp_ExportCommandLine
    #GADGET_WebApp_ExportArguments
    
    #GADGET_AndroidApp_Name
    #GADGET_AndroidApp_Icon
    #GADGET_AndroidApp_SelectIcon
    #GADGET_AndroidApp_Version
    #GADGET_AndroidApp_Code
    #GADGET_AndroidApp_PackageID
    #GADGET_AndroidApp_IAPKey
    #GADGET_AndroidApp_Orientation
    #GADGET_AndroidApp_FullScreen
    #GADGET_AndroidApp_AutoUpload
    #GADGET_AndroidApp_Output
    #GADGET_AndroidApp_SelectOutput
    #GADGET_AndroidApp_StartupImage
    #GADGET_AndroidApp_SelectStartupImage
    #GADGET_AndroidApp_StartupColor
    #GADGET_AndroidApp_SelectStartupColor
    #GADGET_AndroidApp_EnableResourceDirectory
    #GADGET_AndroidApp_ResourceDirectory
    #GADGET_AndroidApp_SelectResourceDirectory
    #GADGET_AndroidApp_EnableDebugger
    #GADGET_AndroidApp_KeepAppDirectory
    #GADGET_AndroidApp_InsecureFileMode
    #GADGET_AndroidApp_CheckInstall
    
    #GADGET_iOSApp_Name
    #GADGET_iOSApp_Icon
    #GADGET_iOSApp_SelectIcon
    #GADGET_iOSApp_Version
    #GADGET_iOSApp_PackageID
    #GADGET_iOSApp_Orientation
    #GADGET_iOSApp_FullScreen
    #GADGET_iOSApp_AutoUpload
    #GADGET_iOSApp_Output
    #GADGET_iOSApp_SelectOutput
    #GADGET_iOSApp_StartupImage
    #GADGET_iOSApp_SelectStartupImage
    #GADGET_iOSApp_EnableResourceDirectory
    #GADGET_iOSApp_ResourceDirectory
    #GADGET_iOSApp_SelectResourceDirectory
    #GADGET_iOSApp_EnableDebugger
    #GADGET_iOSApp_KeepAppDirectory
    #GADGET_iOSApp_CheckInstall
    
    #GADGET_App_Panel
    #GADGET_App_OK
    #GADGET_App_Create
    #GADGET_App_Cancel
  CompilerEndIf
  
EndEnumeration

;- Menu
;
Enumeration 0
  #MENU_New     ; first item that can have a shortcut assigned in the preferences. Must have value 0!!
  #MENU_Open
  #MENU_Save
  #MENU_SaveAs
  #MENU_SaveAll
  #MENU_Reload
  #MENU_Close
  #MENU_CloseAll
  #MENU_DiffCurrent
  #MENU_EncodingPlain
  #MENU_EncodingUtf8
  #MENU_NewlineWindows
  #MENU_NewlineLinux
  #MENU_NewlineMacOS
  ;#MENU_SortSources
  #MENU_ShowInFolder
  
  CompilerIf #CompileMac
    #MENU_PreferenceNotUsed
    #MENU_EditHistory
    #MENU_ExitNotUsed
  CompilerElse
    #MENU_Preference
    #MENU_EditHistory
    #MENU_Exit
  CompilerEndIf
  
  #MENU_Undo                 ; first to AutoDisable (UpdateMenuStates())
  #MENU_Redo
  #MENU_Cut
  #MENU_Copy
  #MENU_Paste
  #MENU_PasteAsComment
  #MENU_CommentSelection
  #MENU_UnCommentSelection
  #MENU_AutoIndent
  #MENU_SelectAll
  #MENU_Goto
  #MENU_JumpToKeyword
  #MENU_LastViewedLine
  #MENU_ToggleThisFold
  #MENU_ToggleFolds
  #MENU_AddMarker
  #MENU_JumpToMarker
  #MENU_ClearMarkers
  #MENU_Find
  #MENU_FindNext
  #MENU_FindPrevious       ; last to AutoDisable
  #MENU_FindInFiles
  #MENU_Replace
  
  #MENU_NewProject
  #MENU_OpenProject
  #MENU_CloseProject
  #MENU_ProjectOptions
  #MENU_AddProjectFile
  #MENU_RemoveProjectFile
  #MENU_OpenProjectFolder
  
  ; Form menu constants
  #MENU_NewForm
  #MENU_FormSwitch
  #MENU_Duplicate
  #MENU_FormImageManager
  
  #MENU_CompileRun
  #MENU_RunExe
  #MENU_SyntaxCheck
  #MENU_DebuggerCompile
  #MENU_NoDebuggerCompile
  #MENU_RestartCompiler
  #MENU_CompilerOption
  #MENU_CreateExecutable
  #MENU_BuildAllTargets
  
  #MENU_Debugger
  #MENU_Stop
  #MENU_Run
  #MENU_Step
  #MENU_StepX
  #MENU_StepOver
  #MENU_StepOut
  #MENU_Kill
  #MENU_BreakPoint
  #MENU_BreakClear
  #MENU_DataBreakPoints
  #MENU_ShowLog
  #MENU_ClearLog
  #MENU_CopyLog
  #MENU_ClearErrorMarks
  #MENU_DebugOutput
  #MENU_Watchlist
  #MENU_VariableList
  #MENU_Profiler
  #MENU_History
  #MENU_Memory
  #MENU_LibraryViewer
  #MENU_DebugAsm
  #MENU_Purifier
  ;#MENU_CPUMonitor
  
  #MENU_VisualDesigner
  #MENU_StructureViewer
  #MENU_FileViewer
  #MENU_VariableViewer
  #MENU_ColorPicker
  #MENU_AsciiTable
  #MENU_Explorer
  #MENU_ProcedureBrowser
  #MENU_Issues
  #MENU_ProjectPanel
  #MENU_Templates
  #MENU_Diff
  #MENU_WebView
  #MENU_AddTools
  
  #MENU_Help
  #MENU_UpdateCheck
  
  CompilerIf #CompileMac
    #MENU_AboutNotUsed
  CompilerElse
    #MENU_About
  CompilerEndIf
  
  #MENU_NextOpenedFile
  #MENU_PreviousOpenedFile
  
  #MENU_ShiftCommentRight
  #MENU_ShiftCommentLeft
  
  #MENU_SelectBlock
  #MENU_DeselectBlock
  
  #MENU_MoveLinesUp
  #MENU_MoveLinesDown
  
  #MENU_DeleteLines
  #MENU_DuplicateSelection
  
  #MENU_UpperCase
  #MENU_LowerCase
  #MENU_InvertCase
  #MENU_SelectWord
  
  #MENU_ZoomIn
  #MENU_ZoomOut
  #MENU_ZoomDefault
  
  #MENU_AutoComplete
  #MENU_AutoComplete_OK ; can now have a custom shortcut too
  #MENU_AutoComplete_Abort
  
  #MENU_ProcedureListUpdate
  
  #MENU_LastShortcutItemDummy ; to avoid changing #MENU_LastShortcutItem every time
  #MENU_LastShortcutItem = #MENU_LastShortcutItemDummy-1
  
  #MENU_Form_AddItem
  #MENU_Form_EditItems
  #MENU_DeleteFormObj
  #MENU_Rename
  #MENU_RemoveColor
  #MENU_RemoveFont
  #MENU_RemoveEventFile
  #MENU_AlignLeft
  #MENU_AlignTop
  #MENU_AlignWidth
  #MENU_AlignHeight
  #MENU_Columns
  #MENU_ToolbarButton
  #MENU_ToolbarToggleButton
  #MENU_ToolbarSeparator
  #MENU_ToolbarDelete
  #MENU_ToolbarDeleteItem
  #MENU_StatusImage
  #MENU_StatusLabel
  #MENU_StatusProgressBar
  #MENU_StatusDelete
  #MENU_StatusDeleteItem
  #MENU_Menu_Item
  #MENU_Menu_Separator
  #MENU_Menu_Delete
  #MENU_Menu_DeleteItem  ; Last Item that can have a Shortcut assigned in the prefs
  
  #MENU_FileViewer_Open
  #MENU_FileViewer_Close
  #MENU_FileViewer_Next
  #MENU_FileViewer_Previous
  
  #MENU_Diff_Open1
  #MENU_Diff_Open2
  #MENU_Diff_Refresh
  #MENU_Diff_Colors
  #MENU_Diff_Swap
  #MENU_Diff_Vertical
  #MENU_Diff_HideFiles
  #MENU_Diff_ShowTool
  #MENU_Diff_Up
  #MENU_Diff_Down
  #MENU_Diff_ShowFiles ; shortcut only
  
  #MENU_RecentFiles_Start
  #MENU_RecentFiles_End    = #MENU_RecentFiles_Start + (#MAX_RecentFiles * 2)
  
  #MENU_AddTools_Start
  #MENU_AddTools_End       = #MENU_AddTools_Start + #MAX_AddTools
  
  #MENU_AddHelpFiles_Start
  #MENU_AddHelpFiles_End   = #MENU_AddHelpFiles_Start + #MAX_AddHelp
  
  #MENU_DefaultTarget_Start
  #MENU_DefaultTarget_End    = #MENU_DefaultTarget_Start + #MAX_MenuTargets
  
  #MENU_BuildTarget_Start
  #MENU_BuildTarget_End    = #MENU_BuildTarget_Start + #MAX_MenuTargets
  
  
  #MENU_Help_Enter
  
  CompilerIf #CompileWindows | #CompileMac | #CompileLinuxQt; to handle autocomplete in scintilla
    #MENU_Scintilla_Enter
    #MENU_Scintilla_Tab
    #MENU_Scintilla_ShiftTab
  CompilerEndIf
  
  CompilerIf #CompileLinux
    #MENU_ProcedureBrowser_Filter_Enter
  CompilerEndIf
  
  #MENU_Template_Use
  #MENU_Template_New
  #MENU_Template_Edit
  #MENU_Template_Remove
  #MENU_Template_NewDir
  #MENU_Template_RemoveDir
  #MENU_Template_Rename
  #MENU_Template_Up
  #MENU_Template_Down
  
  #MENU_ProjectPanel_Open         ; first in Case ... To ...
  #MENU_ProjectPanel_OpenViewer
  #MENU_ProjectPanel_OpenExplorer
  #MENU_ProjectPanel_Rescan
  #MENU_ProjectPanel_Add
  #MENU_ProjectPanel_Remove       ; last in Case ... To ...
  
  #MENU_ProjectInfo_EditTarget
  #MENU_ProjectInfo_DefaultTarget
  #MENU_ProjectInfo_EnableTarget
  
  ;   #MENU_TemplateEdit_Cut
  ;   #MENU_TemplateEdit_Copy
  ;   #MENU_TemplateEdit_Paste
  ;   #MENU_TemplateEdit_SelectAll
  
  #MENU_MacroError_Close
  #MENU_Warnings_Close
  
  CompilerIf #DEBUG
    #MENU_Debugging
  CompilerEndIf
  
  CompilerIf #CompileMacCocoa
    #MENU_AutocompleteUp   ; keyboard shortcuts for the autocomplete window on Cocoa
    #MENU_AutocompleteDown
    #MENU_AutocompleteEscape
  CompilerEndIf
  
  ; For the "Space" option in the Toolbar, we add an empty icon.
  ; however, for the DisableToolBarButton() to work, each "space button" requires its own
  ; unique ID. So the IDs after this one are used for that.
  ;
  #MENU_FirstUnused
  
  ; Menu entries used by the FilesPanel menu
  ;
  #MENU_FirstOpenFile = #MENU_FirstUnused + 1000
EndEnumeration


CompilerIf #CompileMac
  ; Warning, these are negative values
  #MENU_Preference = #PB_Menu_Preferences
  #MENU_Exit  = #PB_Menu_Quit
  #MENU_About = #PB_Menu_About
CompilerEndIf


;- Files
;
Enumeration 1 ; 0 is reserved for uninitialized #PB_Any objects
  #FILE_LoadSource
  #FILE_SaveSource
  #FILE_FileViewer
  #FILE_CompilerInfo
  #FILE_Compile
  #FILE_LoadFunctions
  #FILE_LoadAPI
  #FILE_LoadLanguage
  #FILE_StructureViewer
  #FILE_RunOnce
  #FILE_Grep
  #FILE_AutoComplete
  #FILE_ReadConfig
  #FILE_SaveConfig
  ;#FILE_CPUInfo
  #FILE_StandaloneDebugger
  #FILE_Resources
  #FILE_Template
  #FILE_MacroError
  #FILE_CheckProject
  #FILE_ScanSource
  #FILE_Theme
  #FILE_HelpSearch
  #FILE_Diff
  #FILE_Database
  #FILE_ExportIssues
EndEnumeration

;- Fonts
;
Enumeration 1 ; 0 is reserved for uninitialized #PB_Any objects
  #FONT_Editor
  #FONT_Editor_Bold
  #FONT_Preferences_CurrentFont
  #FONT_ToolsPanel
  #FONT_DebugOut
  
  CompilerIf #CompileWindows
    #FONT_ToolsPanelFake
  CompilerEndIf
  
  CompilerIf #CompileLinux
    #FONT_Help_Text
    #FONT_Help_Title
    #FONT_Help_Bold
    #FONT_Help_Example
  CompilerEndIf
EndEnumeration

;- XML Objects
;
Enumeration 1
  #XML_CheckProject
  #XML_LoadProject
  #XML_SaveProject
  #XML_Help ; for help viewer
  #XML_ColorTable
  #XML_UpdateCheck
EndEnumeration

;
;- Editing history events
;
Enumeration
  #HISTORY_Create
  #HISTORY_Open
  #HISTORY_Close
  #HISTORY_Save
  #HISTORY_SaveAs
  #HISTORY_Reload
  #HISTORY_Edit
  
  #HISTORY_Last = #HISTORY_Edit ; highest event num
EndEnumeration

;- Images
;
Enumeration 1 ; 0 is reserved for uninitialized #PB_Any objects
  #IMAGE_Startup
  #IMAGE_PureBasicLogo
  
  #IMAGE_ToolsPanelLeft
  #IMAGE_ToolsPanelRight
  
  #IMAGE_FileViewer_Open
  #IMAGE_FileViewer_Close
  #IMAGE_FileViewer_Left
  #IMAGE_FileViewer_Right
  
  #IMAGE_Preferences_FirstColor
  #IMAGE_Preferences_LastColor = #IMAGE_Preferences_FirstColor + #COLOR_Last
  
  #IMAGE_Preferences_ToolsPanelFrontColor
  #IMAGE_Preferences_ToolsPanelBackColor
  
  #IMAGE_Preferences_IssueColor
  
  #IMAGE_FilePanel_New
  #IMAGE_FilePanel_Project
  
  CompilerIf #CompileLinux
    #IMAGE_LinuxWindowIcon
  CompilerEndIf
  
  ;   #IMAGE_CPU_Real
  ;   #IMAGE_CPU_Temp
  
  #IMAGE_Template_Add
  #IMAGE_Template_Edit
  #IMAGE_Template_Remove
  #IMAGE_Template_AddDir
  #IMAGE_Template_RemoveDir
  #IMAGE_Template_Template
  #IMAGE_Template_Dir
  #IMAGE_Template_Up
  #IMAGE_Template_Down
  
  #IMAGE_Option_AddTarget
  #IMAGE_Option_EditTarget
  #IMAGE_Option_CopyTarget
  #IMAGE_Option_RemoveTarget
  #IMAGE_Option_TargetUp
  #IMAGE_Option_TargetDown
  #IMAGE_Option_DefaultTarget
  #IMAGE_Option_NormalTarget
  #IMAGE_Option_DisabledTarget
  
  #IMAGE_ProjectPanel_InternalFiles ; first in loop
  #IMAGE_ProjectPanel_ExternalFiles
  #IMAGE_ProjectPanel_Directory
  #IMAGE_ProjectPanel_File
  #IMAGE_ProjectPanel_FileScanned
  #IMAGE_ProjectPanel_Open
  #IMAGE_ProjectPanel_AddFile
  #IMAGE_ProjectPanel_RemoveFile
  #IMAGE_ProjectPanel_RescanFile ; last in loop
  
  #IMAGE_IssueSingleFile
  #IMAGE_IssueMultiFile
  #IMAGE_IssueExport
  #IMAGE_AllIssues
  #IMAGE_Priority0  ; first in loop
  #IMAGE_Priority1
  #IMAGE_Priority2
  #IMAGE_Priority3
  #IMAGE_Priority4  ; last in loop
  
  #IMAGE_FormIcons_Cursor
  #IMAGE_FormIcons_Button
  #IMAGE_FormIcons_ButtonImage
  #IMAGE_FormIcons_Calendar
  #IMAGE_FormIcons_Canvas
  #IMAGE_FormIcons_CheckBox
  #IMAGE_FormIcons_ComboBox
  #IMAGE_FormIcons_Container
  #IMAGE_FormIcons_Date
  #IMAGE_FormIcons_Editor
  #IMAGE_FormIcons_ExplorerCombo
  #IMAGE_FormIcons_ExplorerList
  #IMAGE_FormIcons_ExplorerTree
  #IMAGE_FormIcons_Frame3D
  #IMAGE_FormIcons_HyperLink
  #IMAGE_FormIcons_Image
  #IMAGE_FormIcons_IPAddress
  #IMAGE_FormIcons_ListIcon
  #IMAGE_FormIcons_ListView
  #IMAGE_FormIcons_Menu
  #IMAGE_FormIcons_Option
  #IMAGE_FormIcons_Panel
  #IMAGE_FormIcons_ProgressBar
  #IMAGE_FormIcons_ScrollArea
  #IMAGE_FormIcons_ScrollBar
  #IMAGE_FormIcons_Spin
  #IMAGE_FormIcons_Splitter
  #IMAGE_FormIcons_Status
  #IMAGE_FormIcons_String
  #IMAGE_FormIcons_Text
  #IMAGE_FormIcons_ToolBar
  #IMAGE_FormIcons_TrackBar
  #IMAGE_FormIcons_Tree
  #IMAGE_FormIcons_Web
  
  #IMAGE_WebView_OpenBrowser
  
  ; Form images
  #Img_Up
  #Img_Down
  #Img_Delete
  #Img_Combo
  #Img_Spin
  #Img_Date
  #Img_ArrowDown
  
  #Img_MacCheckbox
  #Img_MacCheckboxSel
  #Img_MacOption
  #Img_MacOptionSel
  #Img_MacTrackbar
  #Img_MacTrackbarV
  
  #Img_MacDis
  #Img_MacClose
  #Img_MacMin
  #Img_MacMax
  #Img_MacSubMenu
  
  #Img_Win7MinDis
  #Img_Win7MaxDis
  #Img_Win7Close
  #Img_Win7Min
  #Img_Win7Max
  
  #Img_Win7Checkbox
  #Img_Win7CheckboxSel
  #Img_Win7Option
  #Img_Win7OptionSel
  #Img_Win7Trackbar
  #Img_Win7TrackbarV
  
  #Img_Win8Close
  #Img_Win8Min
  #Img_Win8Max
  #Img_Win8Checkbox
  #Img_Win8CheckboxSel
  #Img_Win8Option
  #Img_Win8OptionSel
  #Img_Win8Spin
  #Img_Win8ArrowDown
  #Img_Win8ScrollLeft
  #Img_Win8ScrollRight
  #Img_Win8ScrollUp
  #Img_Win8ScrollDown
  
  #Img_LinuxClose
  #Img_LinuxMin
  #Img_LinuxMax
  
  #Img_WindowsIcon
  #Img_ScrollLeft
  #Img_ScrollRight
  #Img_ScrollUp
  #Img_ScrollDown
  
  #Img_Plus
  
  #Drawing_Img
  #TDrawing_Img
  
  
  #IMAGE_Build_TargetNotDone
  #IMAGE_Build_TargetOK
  #IMAGE_Build_TargetError
  #IMAGE_Build_TargetWarning
  
  #IMAGE_ToolBar_Space
  #IMAGE_ToolBar_Missing
  
  #IMAGE_Help_Back
  #IMAGE_Help_Forward
  #IMAGE_Help_Home
  #IMAGE_Help_Previous
  #IMAGE_Help_Next
  #IMAGE_Help_OpenHelp
  
  #IMAGE_Diff_Open1
  #IMAGE_Diff_Open2
  #IMAGE_Diff_Refresh
  #IMAGE_Diff_Colors
  #IMAGE_Diff_Swap
  #IMAGE_Diff_Vertical
  #IMAGE_Diff_HideFiles
  #IMAGE_Diff_Up
  #IMAGE_Diff_Down
  #IMAGE_Diff_ShowTool
  #IMAGE_Diff_Equal ; first in loop
  #IMAGE_Diff_Add
  #IMAGE_Diff_Delete
  #IMAGE_Diff_Modify ; last in loop
  
  #IMAGE_Color_Content1
  #IMAGE_Color_Content2
  
  #IMAGE_Explorer_AddFavorite
  #IMAGE_Explorer_RemoveFavorite
  #IMAGE_Explorer_File
  #IMAGE_Explorer_FilePB
  #IMAGE_Explorer_Directory
  
  #IMAGE_ProcedureBrowser_BackColor
  #IMAGE_ProcedureBrowser_CopyClipboard
  #IMAGE_ProcedureBrowser_EnableFolding
  #IMAGE_ProcedureBrowser_FilterClear
  #IMAGE_ProcedureBrowser_FrontColor
  #IMAGE_ProcedureBrowser_HideModuleNames
  #IMAGE_ProcedureBrowser_HighlightProcedure
  #IMAGE_ProcedureBrowser_RestoreColor
  #IMAGE_ProcedureBrowser_ScrollProcedure
  #IMAGE_ProcedureBrowser_SwitchButtons
  
  #IMAGE_CreateApp_StartupColor
  
  #IMAGE_History_Session
  #IMAGE_History_File
  #IMAGE_History_First
  #IMAGE_History_Last = #IMAGE_History_First + #HISTORY_Last
  
  #IMAGE_FirstThemePreview ; for loading individual icons. the composed preview images are #PB_Any
  #IMAGE_LastThemePreview  = #IMAGE_FirstThemePreview + #MAX_ThemePreview
  
EndEnumeration

Enumeration 1
  #REGEX_HexNumber
  #REGEX_BinNumber
  #REGEX_DecNumber
  #REGEX_FloatNumber
  #REGEX_ScienceNumber
EndEnumeration

;
;- Databases
;
Enumeration 1
  #DB_History
EndEnumeration

;
;- Timers
;
Enumeration 1
  #TIMER_FileMonitor
  #TIMER_History
  #TIMER_DebuggerProcessing
  #TIMER_UpdateCheck
  #TIMER_ToolPanelAutoHide
  ; Timer for the 'Multicolored Procedure List' for automatic selection of the procedure according to the cursor position in the editor.
  #TIMER_ProcedureBrowser
EndEnumeration

;- Custom PostEvent event types
;
Enumeration #PB_EventType_FirstCustomValue
  #EVENTTYPE_WordUpdate       ; Linux specific
  #EVENTTYPE_LoadHelpPage     ; Linux specific
EndEnumeration
  
;- Some predefined color values
;
#COLOR_FilePanelFront  = $000000 ; text color for FilePanel tabs with non-OS color
#COLOR_ProjectInfo     = $D5ABAD ; color for projectinfo tab
#COLOR_ProjectFile     = $D5ABAD ; color for files in project
#COLOR_FormFile        = $9EBA9E ; color for form tabs
#COLOR_FormProjectFile = $BDBB97 ; color for form tabs inside project

;
;- Values for MatchCompilerVersion()
;
#MATCH_OS        = 1 << 0 ; OS must match
#MATCH_Version   = 1 << 1 ; Version must match (4.40 etc)
#MATCH_VersionUp = 1 << 2 ; Version and any higher minor versions match (4.40 = 4.41, but not 4.40=4.50)
#MATCH_Beta      = 1 << 3 ; Alpha/Beta version must match
#MATCH_BetaUp    = 1 << 4 ; Alpha/Beta versions >= the input match (including final version)
#MATCH_Processor = 1 << 5 ; Processor must match

#MATCH_Exact  = #MATCH_OS|#MATCH_Version|#MATCH_Beta|#MATCH_Processor

;
;- Values for "Save Settings to" preference (variable is SaveProjectSettings)
;
;  Never modify existing values, because these are saved to prefs files as numbers!
;
#SAVESETTINGS_EndOfFile    = 0
#SAVESETTINGS_PerFileCfg   = 1
#SAVESETTINGS_PerFolderCfg = 2
#SAVESETTINGS_DoNotSave    = 3

;
;- Values for DragPrivate()
;
Enumeration
  ;#DRAG_Profiler = 0  - reserved for debugger
  #DRAG_SortSources = 1
  #DRAG_Preferences_Toolbar
  #DRAG_Preferences_ToolsFromAvailable
  #DRAG_Preferences_ToolsFromUsed
  #DRAG_AddTools
  #DRAG_Templates
EndEnumeration

;
;- AddTools Triggers
;

Enumeration ; AddTools Trigger values
  #TRIGGER_Menu
  #TRIGGER_EditorStart
  #TRIGGER_EditorEnd
  #TRIGGER_BeforeCompile
  #TRIGGER_AfterCompile
  #TRIGGER_ProgramRun
  #TRIGGER_BeforeCreateExe
  #TRIGGER_AfterCreateExe
  #TRIGGER_SourceLoad
  #TRIGGER_SourceSave
  #TRIGGER_FileViewer_All
  #TRIGGER_FileViewer_Unknown
  #TRIGGER_FileViewer_Special
  #TRIGGER_SourceClose
  #TRIGGER_NewSource
  #TRIGGER_OpenFile_Special
  #TRIGGER_OpenFile_nonPB_Binary
  #TRIGGER_OpenFile_nonPB_Text
EndEnumeration



; These constants are no longer used for the AutoComplete management (#ITEM_XXX is used instead)
; These are just still here for the backward compatibility Prefs loading
;
Enumeration 0
  #AUTOCOMPLETE_PBKeywords
  #AUTOCOMPLETE_ASMKeywords
  #AUTOCOMPLETE_PBFunctions
  #AUTOCOMPLETE_APIFunctions
  #AUTOCOMPLETE_CurrentFileFunctions
  #AUTOCOMPLETE_AllFilesFunctions
  #AUTOCOMPLETE_Structures
  #AUTOCOMPLETE_CurrentFileStructures
  #AUTOCOMPLETE_AllFileStructures
  #AUTOCOMPLETE_Interfaces
  #AUTOCOMPLETE_CurrentFileInterfaces
  #AUTOCOMPLETE_AllFileInterfaces
  #AUTOCOMPLETE_Constants
  #AUTOCOMPLETE_CurrentFileConstants
  #AUTOCOMPLETE_AllFileConstants
  #AUTOCOMPLETE_CurrentFileVariables
  #AUTOCOMPLETE_AllFileVariables
  #AUTOCOMPLETE_CurrentFileArrays
  #AUTOCOMPLETE_AllFileArrays
  #AUTOCOMPLETE_CurrentFileLists
  #AUTOCOMPLETE_AllFileLists
  #AUTOCOMPLETE_CurrentFileMacros
  #AUTOCOMPLETE_AllFileMacros
  #AUTOCOMPLETE_CurrentFileImports
  #AUTOCOMPLETE_AllFileImports
EndEnumeration

;- SourceParser data
;
; Note: MUST be kept in sync with the data section and ParserData structures below!
;
Enumeration 0
  ; The first entries correspond to the Sorted[] array in the ParserData structure
  ; These entries also correspond to the AutoCompleteOptions()/VariableViewerOptions() array.
  #ITEM_Variable      ; variable, but could also be item in Structure def etc
  #ITEM_Array
  #ITEM_LinkedList
  #ITEM_Map
  #ITEM_Procedure
  #ITEM_Macro         ; A FunctionMacro can be known by the Prototype$ field, so no need to separate those
  #ITEM_Import        ; Not used in code data, only in sorted data (actual items are all #ITEM_UnknownBraced)
  #ITEM_Constant
  #ITEM_DeclareModule ; used for module tracking and also for autocomplete of module names
  #ITEM_Prototype
  #ITEM_Structure
  #ITEM_Interface
  #ITEM_Label
  #ITEM_Declare
  #ITEM_InlineASM     ; EnableJS / EnableC / EnableASM blocks
  
  ; Items following are not in the Sorted[] array
  #ITEM_FoldStart      ; for the folding only
  #ITEM_FoldEnd
  #ITEM_MacroEnd       ; so we know what stuff to ignore later on
  #ITEM_ProcedureEnd   ; for procedure background color
  #ITEM_InlineASMEnd   
  #ITEM_Define
  #ITEM_Keyword
  #ITEM_CommentMark    ; ";-" marks
  #ITEM_Issue          ; code issues markers in comments
  #ITEM_UnknownBraced  ; could be array, list or function call. needs to be resolved later
  
  ; Module boundaries (separate items for fast search)
  #ITEM_EndDeclareModule
  #ITEM_Module
  #ITEM_EndModule
  #ITEM_UseModule
  #ITEM_UnuseModule
  
  #ITEM_Last
EndEnumeration

#ITEM_LastSorted  = #ITEM_Declare ; last item in "sorted source data"
#ITEM_LastOption  = #ITEM_Label   ; last item in prefs options
#ITEM_Unknown     = -1            ; possible result of ResolveItemType()

; Settings for the AutocompletePBOptions() array
;
Enumeration
  #PBITEM_Keyword
  #PBITEM_ASMKeyword
  #PBITEM_Function
  #PBITEM_APIFunction
  #PBITEM_Constant
  #PBITEM_Structure
  #PBITEM_Interface
EndEnumeration

#PBITEM_Last = #PBITEM_Interface

; - Map the Items to names. (this is for Prefs, Language, debugging)
; - Set default values for the items in preferences
;
; Must be in sync with the #ITEM and #PBITEM enums of course
;
DataSection
  
  SourceItem_Names:
  Data$ "Variable"
  Data$ "Array"
  Data$ "List"
  Data$ "Map"
  Data$ "Procedure"
  Data$ "Macro"
  Data$ "Import"
  Data$ "Constant"
  Data$ "Module"
  Data$ "Prototype"
  Data$ "Structure"
  Data$ "Interface"
  Data$ "Label"
  
  SourceItem_Defaults:
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #True
  Data.l #False
  Data.l #False
  Data.l #False
  Data.l #False
  
  
  PBItem_Names:
  Data$ "PBKeywords"
  Data$ "ASMKeywords"
  Data$ "PBFunctions"
  Data$ "APIFunctions"
  Data$ "PBConstants"
  Data$ "PBStructures"
  Data$ "PBInterfaces"
  
  PBItem_Defaults:
  Data.l #True
  Data.l #False
  Data.l #True
  Data.l #False
  Data.l #True
  Data.l #False
  Data.l #False
  
EndDataSection


; Represents data held for the SourceParser.pb code
; (used by SourceFile and ProjectFile structures)
;
Structure SourceItem
  *Next.SourceItem       ; Linked list per Source Line
  *Previous.SourceItem
  
  *NextSorted.SourceItem ; TODO: Only used by ParserData.SortedIssues anymore. To be removed
  SortedLine.l           ; line number (only valid for sorted code items!)
  
  Type.w
  Position.w   ; Character position in source line (only for code items, -1 if unused)
  Length.w     ; Character length (only for code items)
  FullLength.w ; length including the call prototype (for #ITEM_UnknownBraced + Import detection + structure+extends combinations)
  
  Name$
  ModulePrefix$; the module prefix (if any)
  
  ; Item specific String data
  StructureUnion
    StringData$ ; generic name (for item comparing)
    Prototype$  ; Procedure, Macro, Declare, Prototype
    Type$       ; Variable, Array, Linkedlist. Can be separated: <parsed type><chr(10)><guessed type>, so always use StringField here
    Content$    ; Structure, Interface: extended interface/structure +  Chr(10) separated list of entries stored only for Project files, parsed directly when needed else
  EndStructureUnion
  
  ; Item specific numeric data
  StructureUnion
    NumericData.i  ; generic name (for item comparing)
    Keyword.i      ; Keywords
    Scope.i        ; VAriables etc (uses #SCOPE_XXX from the debugger)
    IsDefinition.i ; Labels: #true if it is the def, #fals if it is ?LabelName
    IsAssignment.i ; Constants: #true if the constant is followed by a =
    Issue.i        ; Issues: index in the Issues() list
  EndStructureUnion
EndStructure

Structure RadixNode
  Chars$            ; Incoming prefix for this node (stored in uppercase)
  *Child.RadixNode  ; First child node (if any)
  *Next.RadixNode   ; Next sibling node in same parent (single linked list, sorted by prefix)
  *Value            ; Stored value or null
EndStructure

Structure RadixTree
  *Node             ; First child of the root node (other children are under Child\Next). Null for an empty tree
EndStructure

; special scope value (in addition to the debugger ones)
#SCOPE_UNKNOWN = -1

; To represent a SourcItem with its associated line number
;
Structure SourceItemPair
  *Item.SourceItem
  Line.l
EndStructure

Structure SortedData
  Variables.RadixTree
  Arrays.RadixTree
  LinkedLists.RadixTree
  Maps.RadixTree
  Procedures.RadixTree
  Macros.RadixTree
  Imports.RadixTree
  Constants.RadixTree
  Modules.RadixTree
  Prototypes.RadixTree
  Structures.RadixTree
  Interfaces.RadixTree
  Labels.RadixTree
  Declares.RadixTree
EndStructure

CompilerIf SizeOf(SortedData) <> (SizeOf(RadixTree) * (#ITEM_LastSorted+1))
  CompilerError "Parser Structures out of sync with constants"
CompilerEndIf

Structure ParsedLine
  *First.SourceItem
  *Last.SourceItem
EndStructure

Structure ParsedLines
  Line.ParsedLine[0]
EndStructure


; Sorted parser data for a specific module
; The module "" identifies the global scope
Structure SortedModule
  Name$ ; module name in proper case (without and "IMPL::" prefix)
  StructureUnion
    Indexed.RadixTree[#ITEM_LastSorted+1]   ; indexed access per #ITEM_...
    Sorted.SortedData                       ; named access per \Arrays
  EndStructureUnion
EndStructure

Structure ParserData
  ; Per-line scanned data
  ;
  *SourceItemArray.ParsedLines ; new list for procedure/autocomplete stuff
  SourceItemCount.l            ; currently used array entries (= LineNumber count)
  SourceItemSize.l             ; allocated size of the array
  
  Encoding.l      ; 0 = ascii, 1 = utf-8
  
  ; Sorted index data per module. A module name prefixed with "IMPL::" contains the info
  ; inside a Module/EndModule block. All module names here are uppercase
  ;
  ; These are pointers to the SourceItems linked above, so they only stay valid
  ; until another scan is done (even for a line). 'SortedValid' indicates this
  ;
  ; The data is only sorted by first char, the rest is unsorted
  ;
  SortedValid.l
  Map Modules.SortedModule()
  *MainModule.SortedModule         ; points inside the Modules() map
  
  ; The Issues are not sorted by name, but simply by line for fast access
  ; Note that we still use the *NextSorted and SortedLine fields for this list
  *SortedIssues.SourceItem
EndStructure


;- Marker constants

; NOTE: the values of the markers determine their position when being drawn.
; (higher number = drawn on top)
;

; duplicates of the real folding markers, but with a lower priority than the other ones, so our own are on top
#MARKER_FoldVLine         = 0
#MARKER_FoldVCorner       = 1
#MARKER_FoldTCorner       = 2

#MARKER_ProcedureStart    = 3 ; line with a procedure start
#MARKER_ProcedureBack     = 4 ; procedure background setting (lower priority than other background settings!)

; space for ISSUE markers (lower priority than the debugger ones, but above procedure background stuff)
; note: leave some speace for future internal use (marker range is only 0-24)
#MARKER_FirstIssue        = 5
#MARKER_LastIssue         = 10
#MAX_IssueMarkers         = #MARKER_LastIssue - #MARKER_FirstIssue + 1

#MARKER_InlineASM         = 11 ; To detect when we are in an inline ASM block

#MARKER_Breakpoint        = 15
#MARKER_CurrentLine       = 16 ; line backgrounds
#MARKER_Warning           = 17
#MARKER_Error             = 18

#MARKER_WarningSymbol     = 19
#MARKER_ErrorSymbol       = 20 ; merker symbols
#MARKER_BreakpointSymbol  = 21
#MARKER_Marker            = 22 ; line markers
#MARKER_CurrentLineSymbol = 23


;- Styling related constants

; Note: styles can go up to 255 now, so no need to impose a max limit on the issue styles
#STYLE_FirstIssue         = #STYLE_LASTPREDEFINED + 1

;- Indicator constants

#INDICATOR_KeywordMatch    = 0
#INDICATOR_KeywordMismatch = 1
#INDICATOR_SelectionRepeat = 2

;- UpdateCheck

Enumeration
  #UPDATE_Interval_Start
  #UPDATE_Interval_Weekly
  #UPDATE_Interval_Monthly
  #UPDATE_Interval_Never
EndEnumeration

Enumeration
  #UPDATE_Version_All
  #UPDATE_Version_Final
  #UPDATE_Version_LTS
EndEnumeration

;
;- Misc Constants
;

#TOOLBAR   = 0
#TOOLBAR_FileViewer = 1
#TOOLBAR_Diff = 2

#STATUSBAR = 0
#STATUSBAR_FileViewer = 1

#MENU      = 0
#POPUPMENU = 1
;#POPUPMENU_Help = 2 ; for linux
;#POPUPMENU_VariableViewer = 3  ; debugger ( reserve this value!)
;#POPUPMENU_ArrayViewer = 4     ; debugger ( reserve this value!)
#POPUPMENU_Template = 5
;#POPUPMENU_TemplateEdit = 6    ; not used
;#POPUPMENU_Profiler = 7        ; debugger (reserved)
#POPUPMENU_Options = 8          ; for Project targets in CompilerOptions
#POPUPMENU_ProjectPanel = 9     ; used in ProjectPanel and ProjectInfo
#POPUPMENU_Targets = 10         ; ProjectInfo list
#POPUPMENU_FilesPanel = 11
#POPUPMENU_ErrorLog = 12
#POPUPMENU_TabBar = 13

#PB_MessageRequester_Yes    = 6
#PB_MessageRequester_No     = 7
#PB_MessageRequester_Cancel = 2
#PB_MessageRequester_OkCancel = 1

#INDENT_None      = 0
#INDENT_Block     = 1
#INDENT_Sensitive = 2

#ZOOM_Default = 0

#WORDCHARS_Default = "$#*%"

Enumeration
  #TOOLBARICONTYPE_Separator
  #TOOLBARICONTYPE_Space
  #TOOLBARICONTYPE_Internal
  #TOOLBARICONTYPE_External
EndEnumeration




;
;- Structures
;
Structure PTR
  StructureUnion
    a.a[0]
    b.b[0] ; even when declaring with an array like this, we still
    c.c[0] ; can use the single \b, which is perfect for a universal
    w.w[0] ; pointer variable
    u.u[0]
    l.l[0]
    f.f[0]
    q.q[0]
    d.d[0]
    i.i[0]
    *p.PTR[0]
  EndStructureUnion
EndStructure

;- Compile target structure

; Note: we do a structure copy on this one often, so do not put any
;   allocated buffers etc in there. (strings are ok, as they are copied properly)
;
Structure CompileTarget
  ID.i           ; unique ID to identify this target (unique while the IDE runs)
  IsProject.l    ; true if not from a sourcefile
  IsForm.i       ; not null if this is a form (pointer to FormWindow())
  FileName$      ; source filename
  
  ; Only for project targets
  ;
  IsEnabled.l
  IsDefault.l
  
  Name$          ; target name
  OutputFile$    ; target filename
  
  ; Use of the "filename" related fields
  ;
  ; Project:
  ; - MainFile$       - The "InputFile" option in the target options (relative to project file) (relative path)
  ; - FileName$       - Holds the full inputfile filename+path (for compilation)
  ; - OutputFile$     - The "OutputFile" option (if empty, a requester appears on compilation) (relative path)
  ; - ExecutableName$ - the last created output file from this target (if OutputFile is empty, a requester still apprears, but this is set even without a requester) (full path)
  ;
  ; No Project:
  ; - MainFile$       - stores classic "mainfile" option filename (relative path)
  ; - FileName$       - the real (full) filename of the actual sourcefile
  ; - OutputFile$     - not used
  ; - ExecutableName$ - the last input from the "create executable" requester (full path)
  
  CompilerIf #SpiderBasic
    AppFormat.l
    
    WindowTheme$
    GadgetTheme$
    WebServerAddress$
    
    ; Web
    WebAppName$
    WebAppIcon$
    HtmlFilename$
    JavaScriptFilename$
    JavaScriptPath$
    CopyJavaScriptLibrary.l
    ExportCommandLine$
    ExportArguments$
    EnableResourceDirectory.l
    ResourceDirectory$
    WebAppEnableDebugger.l
    
    ; iOS
    iOSAppName$
    iOSAppIcon$
    iOSAppVersion$
    iOSAppPackageID$
    iOSAppStartupImage$
    iOSAppOrientation.l
    iOSAppFullScreen.l
    iOSAppOutput$
    iOSAppAutoUpload.l
    iOSAppEnableResourceDirectory.l
    iOSAppResourceDirectory$
    iOSAppEnableDebugger.l
    iOSAppKeepAppDirectory.l
    
    ; Android
    AndroidAppName$
    AndroidAppIcon$
    AndroidAppVersion$
    AndroidAppCode.l
    AndroidAppPackageID$
    AndroidAppIAPKey$
    AndroidAppStartupImage$
    AndroidAppStartupColor$
    AndroidAppOrientation.l
    AndroidAppFullScreen.l
    AndroidAppOutput$
    AndroidAppAutoUpload.l
    AndroidAppEnableResourceDirectory.l
    AndroidAppResourceDirectory$
    AndroidAppEnableDebugger.l
    AndroidAppKeepAppDirectory.l
    AndroidAppInsecureFileMode.l
    
  CompilerEndIf
  
  ; Compiler options
  ;
  Optimizer.l
  EnableASM.l
  EnableThread.l
  EnableXP.l
  EnableWayland.l
  EnableAdmin.l
  EnableUser.l
  DPIAware.l
  DllProtection.l
  SharedUCRT.l
  EnableOnError.l
  
  ; For backward compatibility in project files (only read/stored in project files)
  ; Note: For source files, the "EnableUnicode" stuff will be kept in the UnknownIDEOptionsList$() list
  EnableUnicode.l
  
  Debugger.l
  UseMainFile.l
  MainFile$
  SubSystem$
  UseIcon.l
  ExecutableFormat.l
  CPU.l
  IconName$
  LinkerOptions$
  
  CustomCompiler.l    ; true or false
  CompilerVersion$    ; version string (without copyright notice)
  
  CustomDebugger.l
  DebuggerType.l
  CustomWarning.l
  WarningMode.l
  ExecutableName$
  CommandLine$
  CurrentDirectory$
  TemporaryExePlace.l
  EnabledTools$
  UseCompileCount.l
  UseBuildCount.l
  UseCreateExe.l
  CompileCount.l
  BuildCount.l
  
  EnablePurifier.l
  PurifierGranularity$      ; granularity options "Local, Global, String, dynamic"
  
  VersionInfo.l
  VersionField$[24]
  NbResourceFiles.l
  ResourceFiles$[#MAX_ResourceFiles]
  
  NbConstants.l
  Constant$[#MAX_Constants]
  ConstantEnabled.b[#MAX_Constants]
  
  ; Information for the "Run" command
  RunExecutable$      ; name of the compiled exe
  RunExeFormat.l      ; executable format of exe (needed for linux/osx)
  RunEnableAdmin.l    ; vista admin option on compilation
  RunDebuggerMode.l   ; debugger mode of exe
  RunMainFileUsed.l   ; if the mainfile option was used
  RunSourceFileName$  ; name of the source file which was compiled
  RunCompilerPath$    ; path of the compiler used
  RunCompilerVersion.l; numeric version of the compiler used
  
  LastCompiledLines.l ; total number of last compiled lines for estimation
  
  ; Debugger specific
  ;
  Watchlist$      ; variables to add to the watchlist. (ProcedureName()>VariableName,...)
  
  ExpressionHistorySize.l
  ExpressionHistory$[#MAX_EpressionHistory]
  
EndStructure


;- SourceFile structure
Structure SourceFile Extends CompileTarget
  NewLineType.l   ; 0 = windows (crlf), 1 = linux (lf)
  IsCode.l        ; 1 for PB files, 0 else
  
  ExistsOnDisk.l   ; if 0, the file was never saved, or deleted while open (so report it as modified, and do not monitor it further)
  LastWriteDate.l  ; last modified date for changes monitor
  DiskFileSize.l   ; do we need .q to store the size of a source code?? :p
  DiskChecksum.s   ; MD5 sum of the file on disk
  
  EditorGadget.i         ; depending on edit control used, usually #PB_Any value
  LineNumbers.i          ; depending on edit control
  LineNumbersWidth.l     ; depending on edit control
  LineNumbersCount.l     ; depending on edit control
  
  CurrentLine.l
  CurrentLineOld.l
  ParserDataChanged.l    ; set to true if an update of ProcedureBrowser etc is needed
  
  CurrentColumnBytes.l   ; current cursor position in bytes      (one UTF-8 char can have multiple bytes)
  CurrentColumnChars.l   ; current cursor position in characters (tab = 1 char and one UTF-8 char = 1 char)
  CurrentColumnDisplay.l ; current cursor position in columns    (tab = TabLength chars, only useful for display)
  ProcedureBrowserScroll.l ; last scroll position in procedure browser
  
  Parser.ParserData      ; parsed source data
  
  List UnknownIDEOptionsList$() ; buffer with strings that are unknown in the project settings block.
  
  ; Modified flag for source status. This is needed, because in Scintilla you can only set
  ; the source to be "clean", but it cannot be explicitly set "dirty" without doing a change
  ; (which would be recorded in the undo log)
  ; See Get/SetSourceModified()
  ScintillaModified.l
  
  ; Modified flag, as displayed in the sources panel title. This is maintained to reduce the
  ; number of updates needed to the source status display
  ; See UpdateSourceStatus()
  DisplayModified.l
  
  ; Flag to know if modifications where done since last update of
  ; procedure list and parser data
  ModifiedSinceUpdate.l
  
  ToggleFolds.l ; last state of the "toggle folds" menu command
  
  LineHistory.l[#MAX_LineHistory] ; history of recently edited lines
  
  ; debugger specific stuff
  ;
  ErrorLog.l     ; debugger log used?
  LogSize.l
  LogLines$[#MAX_ErrorLog]
  
  DebuggerID.i    ; unique ID of the debugger launched from this source (0 if none)
                  ;DebuggerData.i ; pointer to a DebuggerData Structure (0 if not connected)
  
  ProjectFile.i   ; pointer to a ProjectFile Structure (0 if not part of the open project)
  FormFile.i
  
  ; history information
  HistoryName.s       ; either the filename or a unique id string for unsaved files
  ExcludeFromHistory.l; exclude from history (too large size)
  FreshFile.l         ; true if the file was new and not saved yet
EndStructure

;- ProjectFile structure

; All settings that also affect the config dialog are in here (so we can make a backup)
; The main ProjectFile structure extends this structure
;
Structure ProjectFileConfig
  FileName$        ; full filename
  
  AutoLoad.l       ; load on project startup
  AutoScan.l       ; Should the file be scanned for autocomplete ?
  ShowPanel.l      ; show in panel
  ShowWarning.l    ; show warning if file changes
  SortIndex.l      ; for sorting
  
  PanelState$      ; string of "0"/"1" for every parent directory of the file to indicate whether it is expanded in panel (empty if ShowPanel=0)
EndStructure

Structure ProjectFile Extends ProjectFileConfig
  ; Only if the file is currently loaded
  *Source.SourceFile
  
  ; Only if the file is currently NOT loaded
  Parser.ParserData    ; parsed source data
  
  LastOpen.l     ; valid while saving/closing a project
  Md5$           ; the md5 associated to the file when it was last saved
EndStructure

Structure Compiler
  Executable$     ; full path to exe
  MD5$            ; MD5 checksum of the compiler exe (to notice updates etc)
  VersionString$  ; full version string
  VersionNumber.l ; numeric version (431, 440, etc)
  Validated.l     ; The given compiler passed the GetCompilerVersion() test (or the MD5 matched)
  SortIndex.l     ; For sorting
EndStructure


Structure CompilerWarning
  File$
  RelativeFile$
  Line.l
  Message$
EndStructure

Structure BuildLogInfo
  File$
  Line.l
  IsWarning.l ; warning or error ?
EndStructure

Structure ColorSetting
  Enabled.l      ; Is the color enabled or disabled ?
  UserValue.l    ; Value as set by the user (even if disabled)
  PrefsValue.l   ; Temp storage while prefs window is open
  DisplayValue.l ; Actual value currently in use (when color is disabled, this is the fallback actually used)
EndStructure

Structure ProcedureInfo
  Name$
  Line.l ; 1 based!
  Type.l ; 0= Procedure, 1=Macro, 2=marker, 3=issue
  Prototype$
  ; For the 'Multicolored Procedure List' and automatic selection of the procedure or macro according to the cursor position in the editor.
  LineEnd.l
EndStructure




Structure ToolsData
  CommandLine$
  Arguments$
  WorkingDir$
  MenuItemName$
  Shortcut.l
  ConfigLine$
  Trigger.l
  Flags.l
  ReloadSource.l
  HideEditor.l
  HideFromMenu.l
  SourceSpecific.l
  DeactivateTool.l
EndStructure

Structure ToolbarItem
  Name$
  Action$
  Image.i
EndStructure

Structure IndentEntry
  Keyword$
  Length.l ; updated in BuildIndentVT()
  Before.l ; indent units before this keyword
  After.l  ; units after the keyword
EndStructure

Structure Issue
  ; config info
  Name$
  Expression$
  Priority.l
  Color.l
  CodeMode.l ; 0=no color, 1=background, 2=line background
  InTool.l
  InBrowser.l
  
  ; info used during runtime
  Regex.i    ; compiled regex (#PB_Any)
  Style.l    ; code style (if ColorMode=1) -1 if not used
  Marker.l   ; code marker (if ColorMode=2) -1 if not used
EndStructure

Structure FoundIssue
  Text$
  Position.l  ; 1-based position in comment
  Length.l
  Priority.l  ; from the Issue structure
  Issue.l     ; index in Issues() list
  Style.l     ; code style or -1
EndStructure

Structure SelectedBlock
  StartPosition.l
  EndPosition.l
EndStructure

;
;- ToolsPanel Plugin Stuff
;

Interface ToolsPanelInterface
  CreateFunction()               ; called when the panelitem was created. The current gadgetlist is the panel item or tool window
  DestroyFunction()              ; called when the item is destroyed
  
  ResizeHandler(PanelWidth, PanelHeight)   ; called after the panel is resized
  EventHandler(EventGadgetID)              ; called for unhandled events in the main window (isn't necessarily an event for this item, so always check)
  
  PreferenceLoad()    ; called when the preferences are loaded (each tool should have it's own group!)
  PreferenceSave()    ; called when the preferences are saved to file
  
  PreferenceStart()   ; called when the preferences window is opened.. you should make a copy of all preferences and work with them from now on, so after a 'Cancel' nothing will be changed
  PreferenceApply()   ; called when 'Ok' or 'Apply' is hit.. you should apply the temporary preferences options to the real ones. Note: the tool will be destroyed/recreated to refresh it, so no need to do that.
  PreferenceCreate()  ; this item is selected for configuration.. create the needed gadgets (in the current gadgetlist)
  PreferenceDestroy() ; another item is selected for configuration.. save changes and destroy the gadgets
  PreferenceEvents(EventGadgetID) ; unhandled gadget events of the Prefs window are passed here to be handled
  PreferenceChanged(IsConfigOpen) ; must return 1 if any changes were done to this tools preference settings
EndInterface

Structure ToolsPanelFunctions
  CreateFunction.i
  DestroyFunction.i
  
  ResizeHandler.i
  EventHandler.i
  
  PreferenceLoad.i
  PreferenceSave.i
  
  PreferenceStart.i
  PreferenceApply.i
  PreferenceCreate.i
  PreferenceDestroy.i
  PreferenceEvents.i
  PreferenceChanged.i
EndStructure


Structure ToolsPanelEntry
  *FunctionsVT   ; VirtualTable of ToolsPanelFunctions
  
  ; values setup by the Plugin Manager. They should never be changed by the plugin!
  ;
  ExternalPlugin.i    ; set to the #PB_Any value of the dll of an external plugin.. don't change!
  IsSeparateWindow.l
  ToolWindowID.i
  ToolWindowX.l
  ToolWindowY.l
  ToolWindowWidth.l
  ToolWindowHeight.l
  ToolMinWindowWidth.l
  ToolMinWindowHeight.l
  ToolStayOnTop.i        ; a #PB_Any Gadget
  IsToolStayOnTop.l
  
  ; values set up in the init procedure
  ;
  NeedPreferences.l      ; set to 1 if the PreferenceLoad/Save() functions are implemented
  NeedConfiguration.l    ; set to 1 if the tool has any options in the Preferences Window (PreferenceCreate, PReferenceDestroy, Preferenceevents functions)
  NeedDestroyFunction.l  ; set to 1 if the DestroyFunction() function is implemented
                         ; all other functions MUST be implemented for each tool!
  
  PreferencesWidth.l  ; required with to put the preferences gadgets
  PreferencesHeight.l ; required height to put the preferences gadgets
  ToolID$             ; a string that identifies the tool (must be unique! (case doesn't matter))
  
  ; language identifyer strings (to be set by the init function)
  ; these are needed to create the panel and in the preferences window
  ; for external plugins, these should be set to the real strings
  ;
  PanelTitle$        ; title in the PanelGadget
  ToolName$          ; tool name (used in the Preferences)
  
  ; PanelTabOrder must be > 0 for tools available in the Tool Panel (ProcedureBrowser, ProjectPanel, Explorer, Form and WebView)
  ; This defines the default tab (tool) order in the Tool Panel when a new fresh PureBasic is installed or without PureBasic.prefs
  ; Once PureBasic.prefs is used, the tabs (tools) order is defined using KeyName: Tool_1,2,..,5
  ;
  PanelTabOrder.l
EndStructure


; The ToolsPanelEntry_Real structure is used everywhere in the Main program
; this allows the Tools to create their own structure which extends "ToolsPanelEntry",
; and add up to 400 bytes of custom data that is still handled by the main program
;
Structure ToolsPanelEntry_Real Extends ToolsPanelEntry
  CustomData.b[400]
EndStructure

Structure ZipEntry
  Name$
  *Content
  Crc32.l
  Compression.l
  Compressed.l
  Uncompressed.l
EndStructure

;- Diff Implementation
;

; Possible Flags for the Diff() procedure
EnumerationBinary
  #DIFF_IgnoreCase        ; ignore case
  #DIFF_IgnoreSpaceAll    ; ignore all space changes (also inside of lines)
  #DIFF_IgnoreSpaceLeft   ; ignore space changes on the left of a line (indentation)
  #DIFF_IgnoreSpaceRight  ; ignore space changes on the right of a line
EndEnumeration

; Possible values for DiffEdit\Op
Enumeration
  #DIFF_Match = 1
  #DIFF_Insert
  #DIFF_Delete
EndEnumeration

; A line in the parsed diff file
Structure DiffLine
  Checksum.l  ; Crc32 of the line
  Length.l    ; Line length including newline
  *Start      ; Line start in original buffer
EndStructure

; One edit command
; Note that the line information refers to file A for Match/Delete and file B for Insets
Structure DiffEdit
  Op.l
  StartLine.l ; 0 based line start
  Lines.l     ; number of lines
  Length.l    ; size in bytes
  *Start      ; Start in original buffer
EndStructure

; Result of a Diff computation
Structure DiffContext
  Array A.DiffLine(1000)  ; Parsed lines of file A (Array may be larger than total number of lines!)
  Array B.DiffLine(1000)  ; Parsed lines of file B
  LineCountA.l            ; Actual lines in file A
  LineCountB.l            ; Actual lines in file B
  
  List Edits.DiffEdit()   ; Edit script (diff result)
  
  Array FV.l(0)           ; For internal use. Freed before Diff() returns
  Array RV.l(0)
EndStructure

; NOTE: Each Tool must add itself to the AvailablePanelTools() list and fill the required
; structure data to work.

;
;- Global Data
;

; OS dependent values:
;
Global ToolbarHeight, ToolbarTopOffset, StatusbarHeight, MenuHeight, ButtonBackgroundColor
Global ProjectInfoFrameHeight

; Path Settings:
;
Global PureBasicPath$, PreferencesFile$, SourcePath$, TempPath$, ExplorerPath$
Global FileViewerPath$, RunOnceFile$, CurrentDirectory$, AddToolsFile$, BookmarksFile$
Global TemplatesFile$, SourcePathSet, UpdateCheckFile$

; Editor Settings:
;
Global EditorWindowX, EditorWindowY, EditorWindowWidth, EditorWindowHeight, IsWindowMaximized
Global Memorize_EditorWidth, Memorize_EditorHeight, Save_EditorWidth, Save_EditorHeight, Save_EditorX, Save_EditorY
Global AutoReload, MemorizeWindow, CurrentLanguage$, EnableColoring, EnableCaseCorrection, EnableKeywordBolding
Global AutoSave, AutoSaveAll, Editor_RunOnce, ShowMainToolbar, TabLength, MemorizeCursor, VisualDesigner$
Global ToolsPanelMode, ToolsPanelWidth, ToolsPanelSide, SplitterMoving, SplitterCursor, SelectedFilePattern
Global FileViewerX, FileViewerY, FileViewerWidth, FileViewerHeight, FileViewerPattern, FileViewerMaximize
Global HelpWindowX, HelpWindowY, HelpWindowWidth, HelpWindowHeight, HelpWindowMaximized, HelpWindowSplitter
Global ProcedureBrowserMode, ProcedureBrowserSort, RealTab, EnableFolding, NbFoldStartWords, NbFoldEndWords
Global ToolbarItemCount.l, PreferenceToolbarCount.l, ToolbarPreferenceMode, ToolbarPreferenceAction
Global SaveProjectSettings
Global EnableMenuIcons, AutoClearLog, DisplayFullPath, DisplayDarkMode, NoSplashScreen, DisplayProtoType, DisplayErrorWindow
Global InitialSourceLine, MemorizeMarkers, LanguageFile$, ToolsPanelWidth_Hidden, ErrorLogHeight_Hidden
Global EnableBraceMatch, EnableKeywordMatch, ShowWhiteSpace, ShowIndentGuides, MonitorFileChanges
Global FormVariable, FormVariableCaption, FormGrid, FormGridSize, FormEventProcedure, FormSkin, FormSkinVersion, FormVersionWarnings
Global FilesPanelMultiline, FilesPanelCloseButtons, FilesPanelNewButton
Global CurrentZoom, SynchronizingZoom
Global ExtraWordChars$
Global UseTabIndentForSplittedLines
Global NbSchemes
Global ScreenReaderChecked
Global ProcedureMulticolor

; Dialog Window data
;
Global FindWindowDialog.DialogWindow, FindWindowPosition.DialogPosition
Global FindDoReplace, FindCaseSensitive, FindWholeWord, FindSelectionOnly, FindNoComments, FindNoStrings
Global FindAutoWrap
Global FindHistorySize, FindSearchString$, FindReplaceString$
Global WarningWindowPosition.DialogPosition
Global *WarningWindowSource.SourceFile
Global FileMonitorWindowDialog.DialogWindow

Global DiffWindowPosition.DialogPosition
Global DiffDirectoryWindowPosition.DialogPosition
Global DiffDialogWindowPosition.DialogPosition
Global DiffDirectoryWindowDialog.DialogWindow, DiffDialogWindowDialog.DialogWindow
Global DiffVertical, DiffShowColors
Global DiffIgnoreCase, DiffIgnoreSpaceAll, DiffIgnoreSpaceLeft, DiffIgnoreSpaceRight, DiffRecurse

Global GrepWindowDialog.DialogWindow, GrepWindowPosition.DialogPosition
Global GrepOutputDialog.DialogWindow, GrepOutputPosition.DialogPosition
Global GrepCaseSensitive, GrepWholeWord, GrepNoComments, GrepNoStrings, GrepRecurse
Global NbGrepFiles

Global BuildWindowDialog.DialogWindow, BuildWindowPosition.DialogPosition

Global StructureViewerDialog.DialogWindow, StructureViewerPosition.DialogPosition
Global StructureViewerStayOnTop

Global GotoWindowDialog.DialogWindow
Global SortSourcesWindowDialog.DialogWindow, SortSourcesWindowPosition.DialogPosition
Global AddToolsWindowDialog.DialogWindow, AddToolsWindowPosition.DialogPosition
Global EditToolsWindowDialog.DialogWindow, EditToolsWindowPosition.DialogPosition
Global AboutWindowDialog.DialogWindow, AboutWindowPosition.DialogPosition
Global PreferenceWindowDialog.DialogWindow, PreferenceWindowPosition.DialogPosition
Global UpdateWindowDialog.DialogWindow, UpdateWindowPosition.DialogPosition

CompilerIf #SpiderBasic
  Global CreateAppWindowDialog.DialogWindow, CreateAppWindowPosition.DialogPosition
CompilerEndIf

Global OptionWindowDialog.DialogWindow, OptionWindowPosition.DialogPosition, ProjectOptionWindowPosition.DialogPosition
Global OptionDebugger, OptionPurifier, OptionOptimizer, OptionInlineASM, OptionXPSkin, OptionWayland, OptionVistaAdmin, OptionVistaUser, OptionDPIAware, OptionDllProtection, OptionSharedUCRT, OptionThread, OptionOnError, OptionExeFormat, OptionCPU
Global OptionNewLineType, OptionSubSystem$, OptionErrorLog, OptionEncoding
Global OptionUseCompileCount, OptionUseBuildCount, OptionUseCreateExe, OptionTemporaryExe
Global OptionCustomCompiler, OptionCompilerVersion$

CompilerIf #SpiderBasic
  Global OptionWebBrowser$, OptionWebServerPort, OptionJDK$, OptionAppleTeamID$
  
  ; WebView related globals
  Global WebViewOpen
CompilerEndIf


; Global CPUMonitorActive, LastCPUUpdate, NextCPUUpdate, CPUUpdateInterval, CPUStayOnTop
; Global CPUWindowX, CPUWindowY, CPUWindowWidth, CPUWindowHeight, IsCPUMonitorInitialized
; Global DisplayCPUTotal, DisplayCPUFree, NBCPUColors

Global MacroErrorWindowWidth, MacroErrorWindowHeight ; no x/y position as it is always centered

; UpdateCheck
Global UpdateCheckInterval, UpdateCheckVersions, LastUpdateCheck


; Hilighgtning:
;
Global EditorFontName$, EditorFontSize, EditorFontStyle, EditorFontStyle$, EditorFontID, EditorBoldFontID
Global IsHighlightingReady, HighlightGadgetID, LineNumbersCursor, EditorBoldFontName$
Global MarkProcedureBackground


Global ToolsPanelFontName$, ToolsPanelFontSize, ToolsPanelFontStyle, ToolsPanelFontID
Global ToolsPanelFrontColor, ToolsPanelBackColor, NoIndependentToolsColors
Global ToolsPanelAutoHide, ToolsPanelVisible, ToolsPanelHideTime.q, ToolsPanelHideDelay, ToolsPanelHiddenWidth
Global FakeToolsPanelID ; for the windows vertical toolspanel (only non-XP windows versions!)
Global AlwaysHideLog, ErrorLogVisible
Global CustomKeywordFile$
Global ToolsPanelUseFont, ToolsPanelUseColors
Global PreferenceToolsPanelFrontColor, PreferenceToolsPanelBackColor

; OS specific highlighting color representation:
;
Global *ASMKeywordColor, *BackgroundColor, *BasicKeywordColor, *CommentColor, *ConstantColor, *LabelColor
Global *NormalTextColor, *NumberColor, *OperatorColor, *PointerColor, *PureKeywordColor, *SeparatorColor, *CustomKeywordColor
Global *StringColor, *StructureColor, *LineNumberColor, *LineNumberBackColor, *MarkerColor, *CurrentLineColor, *CursorColor, *SelectionColor, *SelectionFrontColor
Global *ModuleColor, *BadEscapeColor

; Misc Values
;
Global *MainMenu, *MainToolbar, *MainStatusBar, *ActiveSource.SourceFile, CompilerReady, *DebuggerMenuItem, *ErrorLogMenuItem
Global ExplorerMode, ExplorerPattern, ExplorerPatternStrings$, ExplorerSavePath, ExplorerShowHidden, ExplorerSplitter
Global FilesHistorySize, DisplayedRecentFiles, DisplayedRecentProjects, CompilerReady, CompilerBusy
Global EnableLineNumbers, EnableMarkers, EnableAccessibility
Global AddTools_CompiledFile$, AddTools_PatternStrings$, AddTools_File$
Global AddTools_RunFileViewer, AddHelpFiles_Count, AddTools_ExecutableName$
Global CurrentTheme$, CodeFileExtensions$

Global AutoCompleteAddBrackets, AutoCompleteAddSpaces, AutoCompleteAddEndKeywords
Global AutoCompleteWindowWidth
Global AutoCompleteWindowHeight, AutoCompleteWindowOpen, AutoCompleteKeywordInserted
Global AutoCompleteNoStrings, AutoCompleteNoComments, AutoCompletePopupLength
Global AutoCompleteProject, AutoCompleteAllFiles
Global AutoPopupNormal, AutoPopupStructures, AutoPopupModules
Global CtrlDoubleClickHappened

Global UseHelpToolF1, HelpToolOpen
Global IssueMultiFile, IssueToolOpen, SelectedIssue, IssuesCol1, IssuesCol2, IssuesCol3, IssuesCol4, IssuesCol5

Global CurrentTool.ToolsPanelInterface, CurrentPreferenceTool.ToolsPanelInterface
Global *CurrentPreferenceToolData.ToolsPanelEntry

Global QuitIDE
Global AutoCompleteWindowReady = 0

Global ShowCompilerProgress
Global CompilerProgram, CompilationAborted
Global DefaultCompiler.Compiler
Global *CurrentCompiler.Compiler = @DefaultCompiler

Global EditHistoryPosition.DialogPosition, EditHistoryDialog.DialogWindow
Global HistoryDatabaseFile$, EnableHistory, HistoryActive, EditHistorySplitter
Global HistoryTimer, MaxSessionCount, MaxSessionDays, HistoryPurgeMode ; 0=off, 1=count, 2=days
Global HistoryMaxFileSize

Global StructureListSize, InterfaceListSize, ConstantListSize

; debugger stuff
;
Global ErrorLogHeight, SplitterCursor2
Global DebuggerMode ; 1=internal, 2=external, 3=console
Global WarningMode  ; 0=ignore, 1=display, 2=error
                    ; Global DebuggerLineColor, DebuggerErrorColor, DebuggerBreakPointColor
                    ; Global DebuggerLineSymbolColor, DebuggerErrorSymbolColor, DebuggerBreakpointSymbolColor
Global DebuggerKillOnError, DebuggerKeepErrorMarks
Global DebugOutUseFont, DebugOutFont$, DebugOutFontSize, DebugOutFontStyle, DebugOutFontID
Global IsDebuggerTimer

Global ForceDebugger, ForceNoDebugger ; when compiled with the special menu item

Global TemplatePlugin.ToolsPanelInterface ; needed for the template menu wrapper

Global CompileSource.SourceFile     ; must be global (for Windows (where the structure is referenced after the compiler-response too))

; Special variable to indicate that 'EndMacro' is a folding keyword
; as all folding is ignored until AFTER EndMacro, so it will not be detected otherwise!
;
Global IsMacroFolding
Global IsMouseDwelling, MouseDwellPosition, IsVariableExpression ; for IDE debugger and #SCN_DWELLSTART handling

CompilerIf #PB_Compiler_Unicode
  #MaxSizeHT = 65535
CompilerElse
  #MaxSizeHT = 255
CompilerEndIf

Global Dim IndentKeywords.IndentEntry(0)
Global Dim IndentKeywordVT.l(#MaxSizeHT)
Global NbIndentKeywords, IndentMode, BackspaceUnindent

;
;- Project related global data
;

Global ProjectOptionsDialog.DialogWindow, ProjectOptionsPosition.DialogPosition
Global IsProject = 0, IsProjectCreation = 0, NewProjectFile$
Global IsProjectBusy = 0
Global ProjectFile$, ProjectName$, ProjectComments$, DefaultProjectFile$, LastOpenProjectFile$
Global ProjectExplorerPattern, ProjectExplorerPath$
Global ProjectCloseFiles.l
Global ProjectOpenMode.l, ProjectShowLog.l, AutoCloseBuildWindow.l
Global ProjectLastOpenDate, ProjectLastOpenHost$, ProjectLastOpenUser$, ProjectLastOpenEditor$
Global *DefaultTarget.CompileTarget
Global *ProjectInfo.SourceFile ; the fake sourcefile in the File tab
Global ProjectDebuggerID       ; unique ID of the current debugger for the project
Global UseProjectBuildWindow
Global CommandlineBuild, QuietBuild, CommandlineBuildSuccess

Global NewList ProjectFiles.ProjectFile()
Global NewList ProjectConfig.ProjectFileConfig()    ; project files during configuration
Global NewList ProjectTargets.CompileTarget()
Global NewList ProjectOptionTargets.CompileTarget() ; target list during options
Global NewList ProjectLog.s()                       ; project specific error log

;
;- Form Designer related data
;
Global *FormInfo.SourceFile ; the fake sourcefile in the File tab
                            ;
                            ;- Arrays And Lists
                            ;

; this is as large as there are #ITEM_x, so we can just stick any item type in it and not get an error
Global Dim AutocompleteOptions.l(#ITEM_Last)
Global Dim AutocompletePBOptions.l(#PBITEM_Last)

Global NewList AvailablePanelTools.ToolsPanelEntry_Real()
Global NewList UsedPanelTools.i() ; only a list of pointers to the AvailablePanelTools list
Global NewList NewUsedPanelTools.i() ; for preference change

Global NewList ProcedureList.ProcedureInfo()
Global NewList FileList.SourceFile()
Global NewList TempList.s()

Global NewList ToolsList.ToolsData()
Global NewList ToolsList_Edit.ToolsData()

Global Dim ValidCharacters.b(#MaxSizeHT)  ; used by Syntax Highlighting and Structure Viewer

Global Dim FindSearchHistory.s(#MAX_FindHistory)
Global Dim FindReplaceHistory.s(#MAX_FindHistory)
Global Dim GrepFindHistory.s(#MAX_FindHistory)
Global Dim GrepDirectoryHistory.s(#MAX_FindHistory)
Global Dim GrepExtensionHistory.s(#MAX_FindHistory)
Global Dim DiffDialogHistory.s(4, #MAX_FindHistory) ; 0=file1, 1=file2, 2=dir1, 3=dir2, 4=pattern

; Global Dim CPUColors.l(#MAX_CPUColors)
; Global Dim CPUImages.i(#MAX_CPUColors)


Global Dim RecentFiles.s(#MAX_RecentFiles*2) ; for recent files & projects

Global NewList OpenFiles.s()
Global NewList OpenFilesCommandline.s() ; different from openfiles to fix a bug in RunOnce feature

Global Dim HelpFiles.s(#MAX_AddHelp)

Global Dim Toolbar.ToolbarItem(#MAX_ToolbarButtons)
Global Dim PreferenceToolbar.ToolbarItem(#MAX_ToolbarButtons)

Global Dim FoldStart$(#MAX_FoldWords)
Global Dim FoldEnd$(#MAX_FoldWords)

Global Dim ConfigLines$(#MAX_ConfigLines) ; for temporary storage of source settings while loading/saving

#NbShortcutKeys  = 107


Global Dim ShortcutNames.s(#NbShortcutKeys)
Global Dim ShortcutValues.l(#NbShortcutKeys)

Global Dim KeyboardShortcuts.l(#MENU_LastShortcutItem)
Global Dim Prefs_KeyboardShortcuts.l(#MENU_LastShortcutItem)

; for Brace check. we allocate it globally for speed reasons
Global NewList BraceStack.l()

Global Dim Colors.ColorSetting(#COLOR_Last)

Global NewList CustomKeywordList.s()


; We store all SourceItem structures in a global LinkedList,
; This way we do not need to care about freeing strings in the structure etc.
; Since we only do AddElement(), DeleteElement(), ChangeCurrentElement(), there
; is no speed concern here
;
; Note: When scanning all open files, it is not enough to simply walk this
;  list, as we need to track whether stuff is inside a macro and for that
;  we need to walk the items in order!
;
Global NewList SourceItemHeap.SourceItem()

; All possible matches for keywords:
; - ForwardMatches(#Keyword, 0) - number of matches for this keyword
; - ForwardMatches(#Keyword, x) - keyword match number x
; These are filled by the BuildFoldingVT() function.
Global Dim ForwardMatches.l(0, 0)
Global Dim BackwardMatches.l(0, 0)

Global NewList Warnings.CompilerWarning()
Global NewList BuildInfo.BuildLogInfo()

Global NewList Compilers.Compiler()

Global NewList Issues.Issue()
Global NewList PreferenceIssues.Issue()

Global NewList BlockSelectionStack.SelectedBlock()
Global BlockSelectionUpdated

; useful mini procedures

CompilerIf Defined(Max, #PB_Procedure) = 0
  Procedure Max(a, b)
    If a > b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
  EndProcedure
CompilerEndIf

CompilerIf Defined(Min, #PB_Procedure) = 0
  Procedure Min(a, b)
    If a < b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
  EndProcedure
CompilerEndIf

; Speed improvement:
; Use the PB internal CRC32 function rather than using the Fingerprint() command to avoid conversion to/from strings
; This makes a noticable difference when computing file Diffs
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Import ""
    PB_Cipher_CalculateCRC32(*buf, len, crc)
  EndImport
CompilerElse
  ImportC ""
    PB_Cipher_CalculateCRC32(*buf, len, crc)
  EndImport
CompilerEndIf

Macro CRC32Fingerprint(Buffer, Length)
  PB_Cipher_CalculateCRC32(Buffer, Length, 0)
EndMacro

CompilerIf #PB_Compiler_Debugger
  ; Useful to ensures a ProcessEvent() is NEVER called in the debugger callback as it can generate very weird bug
  ; (new debugger event is processed While being in a debugger event. It is wrong, As it can changes the display order, and creates weird bug).
  ;
  Global InDebuggerCallback = #False
  ; Useful to ensures WindowEvent() is NEVER called in the MainWindowCallback WM_DropFiles event when débugging as it crash
  ; (WindowEvent() can Not be called from a 'binded' event callback) 
  ; 
  Global InDragDropCallback = #False
CompilerEndIf

UseMD5Fingerprint()
UseCRC32Fingerprint()
