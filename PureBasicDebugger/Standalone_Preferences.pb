; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure Standalone_LoadPreferences()
  Protected NewList TempList.s()
  
  ; we only load those preferences that we need from the
  ; IDE preferences. Make sure any changes to the prefs functions there
  ; are reflected here.
  ;
  ; we cannot simply reuse the IDE preference load code, as it is too complex, and
  ; requires many Arrays/LinkedLists from other files. Also all ToolsPanel plugin codes
  ; would be required for their data to be handled correctly
  ;
  OpenPreferences(PreferenceFile$)
  
  PreferenceGroup("Global")
  CurrentLanguage$            = ReadPreferenceString("CurrentLanguage"   , "English")
  LanguageFile$               = ReadPreferenceString("LanguageFile", "")
  EnableKeywordBolding        = ReadPreferenceLong  ("EnableKeywordBolding", 1)
  TabLength                   = ReadPreferenceLong  ("TabLength"         , 2)
  DisplayFullPath             = ReadPreferenceLong  ("DisplayFullPath", 0)
  ShowWhiteSpace              = ReadPreferenceLong  ("ShowWhiteSpace"    , 0)
  ShowIndentGuides            = ReadPreferenceLong  ("ShowIndentGuides"  , 0)
  
  
  PreferenceGroup("Editor")
  BackgroundColor     = ReadPreferenceLong("BackgroundColor"  ,  $DFFFFF)
  NormalTextColor     = ReadPreferenceLong("NormalTextColor"  ,  0)
  CursorColor         = ReadPreferenceLong("CursorColor"      , 0)
  SelectionColor      = ReadPreferenceLong("SelectionColor"   , $C0C0C0)
  SelectionFrontColor = ReadPreferenceLong("SelectionFrontColor", $000000)
  
  If ReadPreferenceLong("ASMKeywordColor_Disabled", 0) = 0
    ASMKeywordColor   = ReadPreferenceLong("ASMKeywordColor", $724B92)
  Else
    ASMKeywordColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("BasicKeywordColor_Disabled", 0) = 0
    BasicKeywordColor   = ReadPreferenceLong("BasicKeywordColor", $666600)
  Else
    BasicKeywordColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("CustomKeywordColor_Disabled", 0) = 0
    CustomKeywordColor   = ReadPreferenceLong("CustomKeywordColor", $666600)
  Else
    CustomKeywordColor   = BasicKeywordColor
  EndIf
  
  If ReadPreferenceLong("CommentColor_Disabled", 0) = 0
    CommentColor   = ReadPreferenceLong("CommentColor", $AAAA00)
  Else
    CommentColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("ConstantColor_Disabled", 0) = 0
    ConstantColor   = ReadPreferenceLong("ConstantColor", $724B92)
  Else
    ConstantColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("LabelColor_Disabled", 0) = 0
    LabelColor   = ReadPreferenceLong("LabelColor", 0)
  Else
    LabelColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("NumberColor_Disabled", 0) = 0
    NumberColor   = ReadPreferenceLong("NumberColor", 0)
  Else
    NumberColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("OperatorColor_Disabled", 0) = 0
    OperatorColor   = ReadPreferenceLong("OperatorColor", 0)
  Else
    OperatorColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("PointerColor_Disabled", 0) = 0
    PointerColor   = ReadPreferenceLong("PointerColor", 0)
  Else
    PointerColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("PureKeywordColor_Disabled", 0) = 0
    PureKeywordColor   = ReadPreferenceLong("PureKeywordColor", $666600)
  Else
    PureKeywordColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("SeparatorColor_Disabled", 0) = 0
    SeparatorColor   = ReadPreferenceLong("SeparatorColor", 0)
  Else
    SeparatorColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("StringColor_Disabled", 0) = 0
    StringColor   = ReadPreferenceLong("StringColor", 0)
  Else
    StringColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("StructureColor_Disabled", 0) = 0
    StructureColor   = ReadPreferenceLong("StructureColor", 0)
  Else
    StructureColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("LineNumberColor_Disabled", 0) = 0
    LineNumberColor   = ReadPreferenceLong("LineNumberColor", $808080)
  Else
    LineNumberColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("LineNumberBackColor_Disabled", 0) = 0
    LineNumberBackColor   = ReadPreferenceLong("LineNumberBackColor", $D7FFFF)
  Else
    LineNumberBackColor   = BackgroundColor
  EndIf
  
  If ReadPreferenceLong("CurrentLineColor_Disabled", 0) = 0
    CurrentLineColor   = ReadPreferenceLong("CurrentLineColor", $B7FFFF)
  Else
    CurrentLineColor   = BackgroundColor
  EndIf
  
  If ReadPreferenceLong("Debugger_LineColor_Disabled", 0) = 0
    DebuggerLineColor   = ReadPreferenceLong("Debugger_LineColor", $FFE8E8)
  Else
    DebuggerLineColor   = BackgroundColor
  EndIf
  
  If ReadPreferenceLong("Debugger_ErrorColor_Disabled", 0) = 0
    DebuggerErrorColor   = ReadPreferenceLong("Debugger_ErrorColor", $0000FF)
  Else
    DebuggerErrorColor   = BackgroundColor
  EndIf
  
  If ReadPreferenceLong("Debugger_BreakPointColor_Disabled", 0) = 0
    DebuggerBreakPointColor   = ReadPreferenceLong("Debugger_BreakPointColor", $00D0FF)
  Else
    DebuggerBreakPointColor   = BackgroundColor
  EndIf
  
  If ReadPreferenceLong("Debugger_LineSymbolColor_Disabled", 0) = 0
    DebuggerLineSymbolColor   = ReadPreferenceLong("Debugger_LineSymbolColor", $FFE8E8)
  Else
    DebuggerLineSymbolColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("Debugger_ErrorSymbolColor_Disabled", 0) = 0
    DebuggerErrorSymbolColor   = ReadPreferenceLong("Debugger_ErrorSymbolColor", $0000FF)
  Else
    DebuggerErrorSymbolColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("Debugger_BreakpoinSymbolColor_Disabled", 0) = 0
    DebuggerBreakpointSymbolColor   = ReadPreferenceLong("Debugger_BreakpoinSymbolColor", $00D0FF)
  Else
    DebuggerBreakpointSymbolColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("Debugger_WarningColor_Disabled", 0) = 0
    DebuggerWarningColor   = ReadPreferenceLong("Debugger_WarningColor", $00D0FF)
  Else
    DebuggerWarningColor   = BackgroundColor
  EndIf
  
  If ReadPreferenceLong("Debugger_WarningSymbolColor_Disabled", 0) = 0
    DebuggerWarningSymbolColor   = ReadPreferenceLong("Debugger_WarningSymbolColor", $00D0FF)
  Else
    DebuggerWarningSymbolColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("IndentColor_Disabled", 0) = 0
    WhitespaceColor = ReadPreferenceLong("IndentColor", $AAAA00)
  Else
    WhitespaceColor = CommentColor
  EndIf
  
  If ReadPreferenceLong("ModuleColor_Disabled", 0) = 0
    ModuleColor   = ReadPreferenceLong("ModuleColor", $000000)
  Else
    ModuleColor   = NormalTextColor
  EndIf
  
  If ReadPreferenceLong("BadBraceColor_Disabled", 0) = 0
    BadBraceColor   = ReadPreferenceLong("BadBraceColor", $000000)
  Else
    BadBraceColor   = SeparatorColor
  EndIf
  
  EditorFontName$   = ReadPreferenceString("EditorFontName", DefaultEditorFontName$)
  EditorFontSize    = ReadPreferenceLong  ("EditorFontSize", 10)
  EditorFontStyle$  = ReadPreferenceString("EditorFontStyle","None")
  
  EditorFontStyle = 0
  If FindString(UCase(EditorFontStyle$),"BOLD",1)
    EditorFontStyle | #PB_Font_Bold
  EndIf
  If FindString(UCase(EditorFontStyle$),"ITALIC",1)
    EditorFontStyle | #PB_Font_Italic
  EndIf
  
  ; lets load this font immediately
  EditorFontID = LoadFont(0, EditorFontName$, EditorFontSize, EditorFontStyle)
  
  PreferenceGroup("Shortcuts")
  Shortcut_Run      = ReadPreferenceLong("Run", #PB_Shortcut_F7)
  Shortcut_Stop     = ReadPreferenceLong("Stop", #PB_Shortcut_F6)
  Shortcut_Step     = ReadPreferenceLong("Step", #PB_Shortcut_F8)
  Shortcut_StepOver = ReadPreferenceLong("StepOver", #PB_Shortcut_F10)
  Shortcut_StepOut  = ReadPreferenceLong("StepOut", #PB_Shortcut_F11)
  
  PreferenceGroup("Debugger")
  DebuggerMemorizeWindows    = ReadPreferenceLong("MemorizeWindows", 1)
  IsDebuggerMaximized        = ReadPreferenceLong("IsDebuggerMaximized", 0)
  DebuggerOnTop              = ReadPreferenceLong("StayOnTop", #DEFAULT_DebuggerStayOnTop)
  DebuggerBringToTop         = ReadPreferenceLong("AutoBringToTop", #DEFAULT_DebuggerBringToTop)
  CallDebuggerOnStart        = ReadPreferenceLong("CallOnStart", 0)
  CallDebuggerOnEnd          = ReadPreferenceLong("CallOnEnd", 0)
  LogTimeStamp               = ReadPreferenceLong("LogTimeStamp", 1)
  WarningMode                = ReadPreferenceLong("WarningMode", 1)
  DebuggerTimeout            = ReadPreferenceLong("StartupTimeout", 10000)
  
  DebugTimeStamp             = ReadPreferenceLong("DebugTimeStamp", 0)
  DebugIsHex                 = ReadPreferenceLong("DebugIsHex", 0)
  DebugSystemMessages        = ReadPreferenceLong("DebugSystemMessages", 0)
  DebugOutputToErrorLog      = ReadPreferenceLong("DebugOutputToErrorLog", 0)
  DebugOutUseFont            = ReadPreferenceLong("DebugOutUseFont", 0)
  DebugOutFont$              = ReadPreferenceString("DebugOutFont", "")
  DebugOutFontSize           = ReadPreferenceLong("DebugOutFontSize", 12)
  DebugOutFontStyle$         = ReadPreferenceString("DebugOutFontStyle", "None")
  DebugWindowX               = ReadPreferenceLong("DebugWindowX", 50)
  DebugWindowY               = ReadPreferenceLong("DebugWindowY", 50)
  DebugWindowWidth           = ReadPreferenceLong("DebugWindowWidth", 300)
  DebugWindowHeight          = ReadPreferenceLong("DebugWindowHeight", 300)
  DebugWindowMaximize        = ReadPreferenceLong("DebugWindowMaximize", 0)
  
  DebugOutFontStyle = 0
  If FindString(UCase(DebugOutFontStyle$),"BOLD",1)
    DebugOutFontStyle | #PB_Font_Bold
  EndIf
  If FindString(UCase(DebugOutFontStyle$),"ITALIC",1)
    DebugOutFontStyle | #PB_Font_Italic
  EndIf
  
  If DebugOutFont$ = "" Or DebugOutUseFont = 0
    DebugOutFontID = #PB_Default
  Else
    DebugOutFontID = FontID(LoadFont(#PB_Any, DebugOutFont$, DebugOutFontSize, DebugOutFontStyle))
  EndIf
  
  RegisterIsHex              = ReadPreferenceLong("RegisterIsHex", 0)
  StackIsHex                 = ReadPreferenceLong("StackIsHex", 0)
  AutoStackUpdate            = ReadPreferenceLong("AutoStackUpdate", 1)
  AsmWindowX                 = ReadPreferenceLong("AsmWindowX", 50)
  AsmWindowY                 = ReadPreferenceLong("AsmWindowY", 50)
  AsmWindowWidth             = ReadPreferenceLong("AsmWindowWidth", 370)
  AsmWindowHeight            = ReadPreferenceLong("AsmWindowHeight", 370)
  AsmWindowMaximize          = ReadPreferenceLong("AsmWindowMaximize", 0)
  
  MemoryDisplayType          = ReadPreferenceLong("MemoryDisplayType", 0)
  MemoryIsHex                = ReadPreferenceLong("MemoryIsHex", 0)
  MemoryOneColumnOnly        = ReadPreferenceLong("MemoryOneColumnOnly", 0)
  MemoryViewerX              = ReadPreferenceLong("MemoryViewerX", 50)
  MemoryViewerY              = ReadPreferenceLong("MemoryViewerY", 50)
  MemoryViewerWidth          = ReadPreferenceLong("MemoryViewerWidth", 700)
  MemoryViewerHeight         = ReadPreferenceLong("MemoryViewerHeight", 300)
  MemoryViewerMaximize       = ReadPreferenceLong("MemoryViewerMaximize", 0)
  
  VariableIsHex              = ReadPreferenceLong("VariableIsHex", 0)
  VariableWindowX            = ReadPreferenceLong("VariableWindowX", 100)
  VariableWindowY            = ReadPreferenceLong("VariableWindowY", 100)
  VariableWindowWidth        = ReadPreferenceLong("VariableWindowWidth", 600)
  VariableWindowHeight       = ReadPreferenceLong("VariableWindowHeight", 400)
  VariableViewerMaximize     = ReadPreferenceLong("VariableViewerMaximize", 0)
  
  HistoryWindowX             = ReadPreferenceLong("HistoryWindowX", 80)
  HistoryWindowY             = ReadPreferenceLong("HistoryWindowY", 80)
  HistoryWindowWidth         = ReadPreferenceLong("HistoryWindowWidth", 500)
  HistoryWindowHeight        = ReadPreferenceLong("HistoryWindowHeight", 500)
  HistoryMaximize            = ReadPreferenceLong("HistoryMaximize", 0)
  
  WatchListWindowX           = ReadPreferenceLong("WatchListWindowX", 50)
  WatchListWindowY           = ReadPreferenceLong("WatchListWindowY", 50)
  WatchListWindowWidth       = ReadPreferenceLong("WatchListWindowWidth", 700)
  WatchListWindowHeight      = ReadPreferenceLong("WatchListWindowHeight", 300)
  WatchListWindowMaximize    = ReadPreferenceLong("WatchListWindowMaximize", 0)
  
  LibraryViewerX             = ReadPreferenceLong("LibraryViewerX", 20)
  LibraryViewerY             = ReadPreferenceLong("LibraryViewerY", 20)
  LibraryViewerWidth         = ReadPreferenceLong("LibraryViewerWidth", 600)
  LibraryViewerHeight        = ReadPreferenceLong("LibraryViewerHeight", 440)
  LibraryViewerSplitter2     = ReadPreferenceLong("LibraryViewerSplitter1", 300)
  LibraryViewerSplitter3     = ReadPreferenceLong("LibraryViewerSplitter2", 130)
  LibraryViewerMaximize      = ReadPreferenceLong("LibraryViewerMaximize", 0)
  
  IsMiniDebugger             = ReadPreferenceLong("IsMiniDebugger", 0)
  DebuggerMainWindowX        = ReadPreferenceLong("DebuggerMainWindowX", 80)
  DebuggerMainWindowY        = ReadPreferenceLong("DebuggerMainWindowY", 80)
  DebuggerMainWindowWidth    = ReadPreferenceLong("DebuggerMainWindowWidth", 600)
  DebuggerMainWindowHeight   = ReadPreferenceLong("DebuggerMainWindowHeight", 500)
  
  AutoOpenDebugOutput        = ReadPreferenceLong("AutoOpenDebugOutput", 0)
  AutoOpenAsmWindow          = ReadPreferenceLong("AutoOpenAsmWindow", 0)
  AutoOpenMemoryViewer       = ReadPreferenceLong("AutoOpenMemoryViewer", 0)
  AutoOpenVariableViewer     = ReadPreferenceLong("AutoOpenVariableViewer", 0)
  AutoOpenHistory            = ReadPreferenceLong("AutoOpenHistory", 0)
  AutoOpenWatchlist          = ReadPreferenceLong("AutoOpenWatchlist", 0)
  AutoOpenLibraryViewer      = ReadPreferenceLong("AutoOpenLibraryViewer", 0)
  AutoOpenDataBreakpoints    = ReadPreferenceLong("AutoOpenDataBreakpoints", 0)
  AutoOpenPurifier           = ReadPreferenceLong("AutoOpenPurifier", 0)
  
  AutoOpenProfiler           = ReadPreferenceLong("AutoOpenProfiler", 0)
  ProfilerRunAtStart         = ReadPreferenceLong("ProfilerRunAtStart", 1)
  ProfilerX                  = ReadPreferenceLong("ProfilerX", 50)
  ProfilerY                  = ReadPreferenceLong("ProfilerY", 50)
  ProfilerWidth              = ReadPreferenceLong("ProfilerWidth", 600)
  ProfilerHeight             = ReadPreferenceLong("ProfilerHeight", 400)
  ProfilerSplitter           = ReadPreferenceLong("ProfilerSplitter", 340)
  ProfilerMaximize           = ReadPreferenceLong("ProfilerMaximize", 0)
  
  DataBreakpointWindowX      = ReadPreferenceLong("DataBreakpointWindowX", 75)
  DataBreakpointWindowY      = ReadPreferenceLong("DataBreakpointWindowY", 75)
  DataBreakpointWindowWidth  = ReadPreferenceLong("DataBreakpointWindowWidth", 700)
  DataBreakpointWindowHeight = ReadPreferenceLong("DataBreakpointWindowHeight", 300)
  DataBreakpointWindowMaximize = ReadPreferenceLong("DataBreakpointWindowMaximize", 0)
  
  PurifierWindowX            = ReadPreferenceLong("PurifierWindowX", 50)
  PurifierWindowY            = ReadPreferenceLong("PurifierWindowY", 50)
  
  ; Read the custom keywords and directly build the HT etc
  PreferenceGroup("CustomKeywords")
  CustomKeywordFile$         = ReadPreferenceString("File", "")
  Count                      = ReadPreferenceLong  ("Count", 0)
  
  ClearList(CustomKeywordList())
  For i = 1 To count
    AddElement(CustomKeywordList())
    CustomKeywordList() = ReadPreferenceString("W"+Str(i), "")
  Next i
  
  BuildCustomKeywordTable()
  
  
  ClosePreferences()
  
EndProcedure

Procedure Standalone_SavePreferences()
  
  ; we save only the Debugger specific values, stuff like Coloring can only
  ; be changed from the IDE
  ;
  If OpenPreferences(PreferenceFile$) ; no Create... to not overwrite the old values
    
    PreferenceGroup("Debugger")
    
    WritePreferenceLong("MemorizeWindows",  DebuggerMemorizeWindows)
    WritePreferenceLong("IsDebuggerMaximized", IsDebuggerMaximized)
    WritePreferenceLong("StayOnTop",        DebuggerOnTop)
    WritePreferenceLong("AutoBringToTop",   DebuggerBringToTop)
    WritePreferenceLong("CallOnStart",      CallDebuggerOnStart)
    WritePreferenceLong("CallOnEnd",        CallDebuggerOnEnd)
    WritePreferenceLong("LogTimeStamp",     LogTimeStamp)
    
    WritePreferenceLong("DebugTimeStamp",   DebugTimeStamp)
    WritePreferenceLong("DebugIsHex",       DebugIsHex)
    WritePreferenceLong("DebugSystemMessages", DebugSystemMessages)
    WritePreferenceLong("DebugOutputToErrorLog", DebugOutputToErrorLog)
    WritePreferenceLong("DebugWindowX",     DebugWindowX)
    WritePreferenceLong("DebugWindowY",     DebugWindowY)
    WritePreferenceLong("DebugWindowWidth", DebugWindowWidth)
    WritePreferenceLong("DebugWindowHeight",DebugWindowHeight)
    WritePreferenceLong("DebugWindowMaximize", DebugWindowMaximize)
    
    WritePreferenceLong("RegisterIsHex",    RegisterIsHex)
    WritePreferenceLong("StackIsHex",       StackIsHex)
    WritePreferenceLong("AutoStackUpdate",  AutoStackUpdate)
    WritePreferenceLong("AsmWindowX",       AsmWindowX)
    WritePreferenceLong("AsmWindowY",       AsmWindowY)
    WritePreferenceLong("AsmWindowWidth",   AsmWindowWidth)
    WritePreferenceLong("AsmWindowHeight",  AsmWindowHeight)
    WritePreferenceLong("AsmWindowMaximize", AsmWindowMaximize)
    
    WritePreferenceLong("MemoryDisplayType",   MemoryDisplayType)
    WritePreferenceLong("MemoryIsHex",         MemoryIsHex)
    WritePreferenceLong("MemoryOneColumnOnly", MemoryOneColumnOnly)
    WritePreferenceLong("MemoryViewerX",       MemoryViewerX)
    WritePreferenceLong("MemoryViewerY",       MemoryViewerY)
    WritePreferenceLong("MemoryViewerWidth",   MemoryViewerWidth)
    WritePreferenceLong("MemoryViewerHeight",  MemoryViewerHeight)
    WritePreferenceLong("MemoryViewerMaximize",MemoryViewerMaximize)
    
    WritePreferenceLong("VariableIsHex",       VariableIsHex)
    WritePreferenceLong("VariableWindowX",     VariableWindowX)
    WritePreferenceLong("VariableWindowY",     VariableWindowY)
    WritePreferenceLong("VariableWindowWidth", VariableWindowWidth)
    WritePreferenceLong("VariableWindowHeight",VariableWindowHeight)
    WritePreferenceLong("VariableViewerMaximize",VariableViewerMaximize)
    
    WritePreferenceLong("HistoryWindowX",      HistoryWindowX)
    WritePreferenceLong("HistoryWindowY",      HistoryWindowY)
    WritePreferenceLong("HistoryWindowWidth",  HistoryWindowWidth)
    WritePreferenceLong("HistoryWindowHeight", HistoryWindowHeight)
    WritePreferenceLong("HistoryMaximize",     HistoryMaximize)
    
    WritePreferenceLong("WatchListWindowX",      WatchListWindowX)
    WritePreferenceLong("WatchListWindowY",      WatchListWindowY)
    WritePreferenceLong("WatchListWindowWidth",  WatchListWindowWidth)
    WritePreferenceLong("WatchListWindowHeight", WatchListWindowHeight)
    WritePreferenceLong("WatchListWindowMaximize", WatchListWindowMaximize)
    
    WritePreferenceLong("LibraryViewerX",         LibraryViewerX)
    WritePreferenceLong("LibraryViewerY",         LibraryViewerY)
    WritePreferenceLong("LibraryViewerWidth",     LibraryViewerWidth)
    WritePreferenceLong("LibraryViewerHeight",    LibraryViewerHeight)
    WritePreferenceLong("LibraryViewerSplitter1", LibraryViewerSplitter1)
    WritePreferenceLong("LibraryViewerSplitter2", LibraryViewerSplitter2)
    WritePreferenceLong("LibraryViewerMaximize",  LibraryViewerMaximize)
    
    If DebuggerMemorizeWindows ; only modify this value when the memorize option is on
      WritePreferenceLong("IsMiniDebugger", IsMiniDebugger)
    EndIf
    WritePreferenceLong("DebuggerMainWindowX",   DebuggerMainWindowX)
    WritePreferenceLong("DebuggerMainWindowY",   DebuggerMainWindowY)
    WritePreferenceLong("DebuggerMainWindowWidth",  DebuggerMainWindowWidth)
    WritePreferenceLong("DebuggerMainWindowHeight", DebuggerMainWindowHeight)
    
    WritePreferenceLong("AutoOpenDebugOutput",    AutoOpenDebugOutput)
    WritePreferenceLong("AutoOpenAsmWindow",      AutoOpenAsmWindow)
    WritePreferenceLong("AutoOpenMemoryViewer",   AutoOpenMemoryViewer)
    WritePreferenceLong("AutoOpenVariableViewer", AutoOpenVariableViewer)
    WritePreferenceLong("AutoOpenHistory",        AutoOpenHistory)
    WritePreferenceLong("AutoOpenWatchlist",      AutoOpenWatchlist)
    WritePreferenceLong("AutoOpenLibraryViewer",  AutoOpenLibraryViewer)
    WritePreferenceLong("AutoOpenDataBreakpoints",AutoOpenDataBreakpoints)
    WritePreferenceLong("AutoOpenPurifier",       AutoOpenPurifier)
    
    WritePreferenceLong("AutoOpenProfiler",       AutoOpenProfiler)
    WritePreferenceLong("ProfilerRunAtStart",     ProfilerRunAtStart)
    WritePreferenceLong("ProfilerX",              ProfilerX)
    WritePreferenceLong("ProfilerY",              ProfilerY)
    WritePreferenceLong("ProfilerWidth",          ProfilerWidth)
    WritePreferenceLong("ProfilerHeight",         ProfilerHeight)
    WritePreferenceLong("ProfilerSplitter",       ProfilerSplitter)
    WritePreferenceLong("ProfilerMaximize",       ProfilerMaximize)
    
    WritePreferenceLong("DataBreakpointWindowX",       DataBreakpointWindowX)
    WritePreferenceLong("DataBreakpointWindowY",       DataBreakpointWindowY)
    WritePreferenceLong("DataBreakpointWindowWidth",   DataBreakpointWindowWidth)
    WritePreferenceLong("DataBreakpointWindowHeight",  DataBreakpointWindowHeight)
    WritePreferenceLong("DataBreakpointWindowMaximize", DataBreakpointWindowMaximize)
    
    WritePreferenceLong("PurifierWindowX",             PurifierWindowX)
    WritePreferenceLong("PurifierWindowY",             PurifierWindowY)
    
    ClosePreferences()
  Else
    MessageRequester("PureBasic Debugger", ReplaceString(Language("Misc","PreferenceError"), "%filename%", PreferenceFile$, 1), #FLAG_Error)
  EndIf
  
EndProcedure
