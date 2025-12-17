; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Global SelectedLanguage, PreferenceFontName$, PreferenceFontSize, PreferenceFontStyle
Global PreferenceToolsPanelFrontColor, PreferenceToolsPanelBackColor, PreferenceToolsPanelFont$
Global PreferenceToolsPanelFontSize, PreferenceToolsPanelFontStyle
Global PreferenceDebugOutFont$, PreferenceDebugOutFontSize, PreferenceDebugOutFontStyle
Global PreferenceIssueColor

Global Preferences_ImportFile$, Preferences_ExportFile$
Global PreferenceCurrentPage, IsApplyPreferences

Global NewList PreferenceCompilers.Compiler()


Procedure LoadDialogPosition(*Position.DialogPosition, x=-1, y=-1, Width=0, Height=0, Prefix$="")
  *Position\x           = ReadPreferenceLong(Prefix$+"X", x)
  *Position\y           = ReadPreferenceLong(Prefix$+"Y", y)
  *Position\Width       = ReadPreferenceLong(Prefix$+"Width", Width)
  *Position\Height      = ReadPreferenceLong(Prefix$+"Height", Height)
  *Position\IsMaximized = ReadPreferenceLong(Prefix$+"IsMaximized", 0)
EndProcedure

; SaveType: 0-save position only, 1-include width/height, 2-include maximize state
;
Procedure SaveDialogPosition(*Position.DialogPosition, SaveType=0, Prefix$="")
  WritePreferenceLong(Prefix$+"X", *Position\x)
  WritePreferenceLong(Prefix$+"Y", *Position\y)
  If SaveType > 0
    WritePreferenceLong(Prefix$+"Width", *Position\Width)
    WritePreferenceLong(Prefix$+"Height", *Position\Height)
    If SaveType > 1
      WritePreferenceLong(Prefix$+"IsMaximized", *Position\IsMaximized)
    EndIf
  EndIf
EndProcedure


Procedure UpdateImageColorGadget(Gadget, Image, Color)
  If StartDrawing(ImageOutput(Image))
    Width = OutputWidth()    ; Don't use hardcoded value to be DPI compliant
    Height = OutputHeight()
    
    Box(0, 0, Width, Height, $000000)
    Box(1, 1, Width-2, Height-2, Color)
    StopDrawing()
    
    ; Update the gadget containing this image
    SetGadgetState(Gadget, ImageID(Image))
  EndIf
EndProcedure


Procedure UpdatePreferenceSyntaxColor(ColorIndex, Color)
  UpdateImageColorGadget(#GADGET_Preferences_FirstColor+ColorIndex, #IMAGE_Preferences_FirstColor+ColorIndex, Color)
EndProcedure



Procedure LoadPreferences()
  
  InitColorSchemes()
  
  OpenPreferences(PreferencesFile$)
  
  ;- - Global
  PreferenceGroup("Global")
  PrefsVersion                = ReadPreferenceLong  ("Version", 0)
  AutoReload                  = ReadPreferenceLong  ("AutoReload"        , 1)
  MemorizeWindow              = ReadPreferenceLong  ("MemorizeWindow"    , 1)
  CurrentLanguage$            = ReadPreferenceString("CurrentLanguage"   , "English")
  LanguageFile$               = ReadPreferenceString("LanguageFile"      , "")
  CurrentTheme$               = ReadPreferenceString("CurrentTheme"      , "SilkTheme.zip")
  EnableBraceMatch            = ReadPreferenceLong  ("EnableBraceMatch"  , 1)
  EnableKeywordMatch          = ReadPreferenceLong  ("EnableKeywordMatch", 1)
  EnableKeywordBolding        = ReadPreferenceLong  ("EnableKeywordBolding", 1)
  EnableCaseCorrection        = ReadPreferenceLong  ("EnableCaseCorrection", 1)
  EnableLineNumbers           = ReadPreferenceLong  ("EnableLineNumbers" ,  1)
  EnableAccessibility         = ReadPreferenceLong  ("EnableAccessibility" ,  0)
  ShowWhiteSpace              = ReadPreferenceLong  ("ShowWhiteSpace"    , 0)
  ShowIndentGuides            = ReadPreferenceLong  ("ShowIndentGuides"  , 0)
  UseTabIndentForSplittedLines = ReadPreferenceLong ("UseTabIndentForSplittedLines", 0)
  AutoSave                    = ReadPreferenceLong  ("AutoSave"          , 1)
  AutoSaveAll                 = ReadPreferenceLong  ("AutoSaveAll"       , 1)
  SaveProjectSettings         = ReadPreferenceLong  ("SaveSettingsMode"  , #SAVESETTINGS_EndOfFile)
  Editor_RunOnce              = ReadPreferenceLong  ("RunOnce"           , 1)
  ShowMainToolbar             = ReadPreferenceLong  ("ShowToolbar"       , 1)
  TabLength                   = ReadPreferenceLong  ("TabLength"         , 2)
  RealTab                     = ReadPreferenceLong  ("RealTab"           , 0)
  MemorizeCursor              = ReadPreferenceLong  ("MemorizeCursor"    , 1)
  MemorizeMarkers             = ReadPreferenceLong  ("MemorizeMarkers"   , 1)
  SelectedFilePattern         = ReadPreferenceLong  ("LastFilePattern"   , 0)
  DisplayFullPath             = ReadPreferenceLong  ("DisplayFullPath"   , 0)
  DisplayDarkMode             = ReadPreferenceLong  ("DisplayDarkMode"   , 1)
  NoSplashScreen              = ReadPreferenceLong  ("NoSplashScreen"    , 0)
  AlwaysHideLog               = ReadPreferenceLong  ("AlwaysHideLog"     , 0)
  ShowCompilerProgress        = ReadPreferenceLong  ("ShowCompilerProgress", 0)
  UseHelpToolF1               = ReadPreferenceLong  ("UseHelpToolF1"     , 1)
  MonitorFileChanges          = ReadPreferenceLong  ("MonitorFileChanges", 1)
  
  UpdateCheckInterval         = ReadPreferenceLong  ("UpdateCheckInterval", #UPDATE_Interval_Weekly)
  UpdateCheckVersions         = ReadPreferenceLong  ("UpdateCheckVersions", #UPDATE_Version_Final)
  LastUpdateCheck             = ReadPreferenceLong  ("LastUpdateCheck", 0)
  EnableMenuIcons             = ReadPreferenceLong  ("EnableMenuIcons", 1)
  ScreenReaderChecked         = ReadPreferenceLong  ("ScreenReaderChecked", 0)
  
  ; Force a default starting zoom
  CurrentZoom = #ZOOM_Default
  
  ; Removed options: always enabled now (todo: remove the old code later)
  EnableColoring = 1
  EnableMarkers = 1
  
  If SourcePathSet = 0 ; only load this if not already set by commandline
    CompilerIf #SpiderBasic
      If PrefsVersion > 541 Or #CompileWindows = 0 ; We changed the default example path on Windows for SpiderBasic 2.00, so we invalidate previous pref to update it
        SourcePath$ = ReadPreferenceString("SourceDirectory", SourcePath$)
      EndIf
    CompilerElse
      SourcePath$ = ReadPreferenceString("SourceDirectory", SourcePath$)
    CompilerEndIf
  EndIf
  
  ;- - Editor
  PreferenceGroup("Editor")
  CompilerIf #CompileLinux
    IsWindowMaximized  = ReadPreferenceLong("IsWindowMaximized" , 0) ; On Raspberry and some X server, maximize doesn't work as expected and loop (and crash)
  CompilerElse
    IsWindowMaximized  = ReadPreferenceLong("IsWindowMaximized" , 1) ; Default to maximized window, so we have a clean launch if no pref file exists
  CompilerEndIf
  EditorWindowX      = ReadPreferenceLong("X"     , 80)            ; to not be directly at the OSX menubar!
  EditorWindowY      = ReadPreferenceLong("Y"     , 80)
  EditorWindowWidth  = ReadPreferenceLong("Width" , 600)
  EditorWindowHeight = ReadPreferenceLong("Height", 420)
  
  Memorize_EditorWidth  = EditorWindowWidth  ; save the values, as they get changed on resizing
  Memorize_EditorHeight = EditorWindowHeight ; for the MemorizeWindow setting
  Save_EditorWidth      = EditorWindowWidth  ; for the MAximized saving fix
  Save_EditorHeight     = EditorWindowHeight
  Save_EditorX          = EditorWindowX
  Save_EditorY          = EditorWindowY
  
  FilesPanelMultiline    = ReadPreferenceLong("FilesPanelMultiline", #False)
  FilesPanelCloseButtons = ReadPreferenceLong("FilesPanelCloseButtons", #True)
  FilesPanelNewButton    = ReadPreferenceLong("FilesPanelNewButton", #False)
  
  CodeFileExtensions$ = ReadPreferenceString("CodeFileExtensions", "")
  
  ExtraWordChars$ = ReadPreferenceString("ExtraWordChars", #WORDCHARS_Default)
  
  ; Init the color values with the PB defaults
  ;
  Restore DefaultColorSchemes
  Read.s SchemeName$
  Read.l ToolsPanelFrontColor
  Read.l ToolsPanelBackColor
  
  For i = 0 To #COLOR_Last
    Read.l Colors(i)\UserValue
  Next i
  
  CompilerIf #CompileWindows
    ; On Windows, default to the system colors for this, as Screen readers rely on it.
    ; NOTE: The Accessibility color scheme uses -1 here to indicate that the syscolors
    ; should always be used.
    ;
    ; If EnableAccessibility is set then it also forces the sys colors
    ;
    Colors(#COLOR_Selection)\UserValue      = GetSysColor_(#COLOR_HIGHLIGHT)
    Colors(#COLOR_SelectionFront)\UserValue = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
  CompilerEndIf
  
  ; Load the real color values
  ;
  Restore ColorKeys
  For i = 0 To #COLOR_Last
    Read.s ColorKey$
    Colors(i)\UserValue = ReadPreferenceLong(ColorKey$, Colors(i)\UserValue)
    
    ; this key only exists for disabled colors, so to have the defaultvalue at 0 is important
    If ReadPreferenceLong(ColorKey$+"_Disabled", 0)
      Colors(i)\Enabled = 0
      ;
      ; NOTE: This test is BAD, as when no preferences are present, no keys are there,
      ;       so all colors are disabled for new installations which is not good.
      ;
      ; ElseIf ReadPreferenceString(ColorKey$, "---missing---") = "---missing---" ; test if this even exists (read as a string for a bullitproof test)
      ;   Colors(i)\Enabled = 0 ; color is not yet present at all (old prefs file)
    Else
      Colors(i)\Enabled = 1
    EndIf
  Next i
  
  ; calc which colors are actually used for display
  CalculateHighlightingColors()
  
  EditorFontName$   = ReadPreferenceString("EditorFontName", DefaultEditorFontName$)
  EditorFontSize    = ReadPreferenceLong  ("EditorFontSize", #DEFAULT_EditorFontSize)
  EditorFontStyle$  = ReadPreferenceString("EditorFontStyle","None")
  
  CompilerIf #CompileMac
    ; While the font setting was ignored, this stored the GdkFont value because nobody ever changed it
    ; So if we find this setting, set it to the default so we have a good default font in these cases
    If EditorFontName$ = "-*-fixed-medium-r-normal-*-*-120-*-*-*-*-*-*"
      EditorFontName$ = DefaultEditorFontName$
      EditorFontSize  = #DEFAULT_EditorFontSize
    EndIf
  CompilerEndIf
  
  EditorFontStyle = 0
  If FindString(UCase(EditorFontStyle$),"BOLD",1)
    EditorFontStyle | #PB_Font_Bold
  EndIf
  If FindString(UCase(EditorFontStyle$),"ITALIC",1)
    EditorFontStyle | #PB_Font_Italic
  EndIf
  
  
  ;- - Folding
  PreferenceGroup("Folding")
  EnableFolding    = ReadPreferenceLong("EnableFolding",  1)
  
  ; default
  
  NbFoldStartWords = 11
  NbFoldEndWords = 8
  FoldStart$(1) = ";{"
  FoldStart$(2) = "Macro"
  FoldStart$(3) = "Procedure"
  FoldStart$(4) = "ProcedureC"
  FoldStart$(5) = "ProcedureDLL"
  FoldStart$(6) = "ProcedureCDLL"
  FoldStart$(7) = "Module"
  FoldStart$(8) = "DeclareModule"
  FoldStart$(9) = "CompilerIf"
  CompilerIf #SpiderBasic 
    FoldStart$(10) = "EnableJS" 
  CompilerElse 
    FoldStart$(10) = "EnableASM" 
  CompilerEndIf
  FoldStart$(11) = "HeaderSection" 
  
  FoldEnd$(1) = ";}"
  FoldEnd$(2) = "EndMacro"
  FoldEnd$(3) = "EndProcedure"
  FoldEnd$(4) = "EndModule"
  FoldEnd$(5) = "EndDeclareModule"
  FoldEnd$(6) = "CompilerEndIf"
  CompilerIf #SpiderBasic 
    FoldEnd$(7) = "DisableJS"
  CompilerElse 
    FoldEnd$(7) = "DisableASM"
  CompilerEndIf
  FoldEnd$(8) = "EndHeaderSection"
  
  NbFoldStartWords = ReadPreferenceLong("StartWords", NbFoldStartWords)
  NbFoldEndWords = ReadPreferenceLong("EndWords", NbFoldEndWords)
  For i = 1 To NbFoldStartWords
    FoldStart$(i) = ReadPreferenceString("Start_"+Str(i), FoldStart$(i))
  Next i
  For i = 1 To NbFoldEndWords
    FoldEnd$(i)   = ReadPreferenceString("End_"+Str(i), FoldEnd$(i))
  Next i
  
  ; If new keywords are added to the language, they should be handled like this:
  ; So the previous list by the user is properly extended
  If PrefsVersion > 0 And PrefsVersion < 520 ; Only add this if there was a pref file, if not it's already in the default arrays
                                             ; Module, DeclareModule added in 5.20
    NbFoldStartWords+1 : FoldStart$(NbFoldStartWords) = "Module"
    NbFoldStartWords+1 : FoldStart$(NbFoldStartWords) = "DeclareModule"
    NbFoldEndWords+1   : FoldEnd$(NbFoldEndWords) = "EndModule"
    NbFoldEndWords+1   : FoldEnd$(NbFoldEndWords) = "EndDeclareModule"
  EndIf
  
  BuildFoldingVT()
  
  ;- - Indentation
  PreferenceGroup("Indentation")
  IndentMode        = ReadPreferenceLong("IndentMode", #INDENT_Sensitive)
  BackspaceUnindent = ReadPreferenceLong("BackspaceUnindent", 1)
  NbIndentKeywords  = ReadPreferenceLong("NbKeywords", 0)
  
  If PrefsVersion < 450 Or NbIndentKeywords = 0
    ; The feature was added in 4.50, so add our default list here
    Restore DefaultIndentList
    Read.l NbIndentKeywords
    Dim IndentKeywords.IndentEntry(NbIndentKeywords)
    
    For i = 0 To NbIndentKeywords-1
      Read.s IndentKeywords(i)\Keyword$
      Read.l IndentKeywords(i)\Before
      Read.l IndentKeywords(i)\After
    Next i
    
  Else
    ; Load existing list
    Dim IndentKeywords.IndentEntry(NbIndentKeywords)
    
    ; Note: we need to exclude all duplicate keywords (can happens if an old PB version is used with the same pref (new keywords will be added again)
    ;
    ;
    NbUniqueIndentKeywords = 0
    For i = 0 To NbIndentKeywords-1
      IndentKeyword$ = ReadPreferenceString("Keyword_"+Str(i), "")
      If LCase(IndentKeyword$) <> LCase(PreviousIndentKeyword$)
        IndentKeywords(NbUniqueIndentKeywords)\Keyword$ = IndentKeyword$
        IndentKeywords(NbUniqueIndentKeywords)\Before   = ReadPreferenceLong("Before_"+Str(i), 0)
        IndentKeywords(NbUniqueIndentKeywords)\After    = ReadPreferenceLong("After_"+Str(i), 0)
        
        PreviousIndentKeyword$ = IndentKeyword$
        NbUniqueIndentKeywords+1
      EndIf
    Next i
    
    NbIndentKeywords = NbUniqueIndentKeywords
    ReDim IndentKeywords(NbIndentKeywords+1)
  EndIf
  
  ; If new keywords are added to the language, they should be handled like this:
  ; So the previous list by the user is properly extended
  If PrefsVersion < 510
    ; CompilerElseIf added in 5.10
    ReDim IndentKeywords.IndentEntry(NbIndentKeywords+1)
    IndentKeywords(NbIndentKeywords)\Keyword$ = "CompilerElseIf"
    IndentKeywords(NbIndentKeywords)\Before = -1
    IndentKeywords(NbIndentKeywords)\After  = 1
    NbIndentKeywords+1
  EndIf
  
  If PrefsVersion < 520
    ; CompilerElseIf added in 5.20
    ReDim IndentKeywords.IndentEntry(NbIndentKeywords+4)
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "DeclareModule"
    IndentKeywords(NbIndentKeywords)\Before = 0
    IndentKeywords(NbIndentKeywords)\After  = 1
    NbIndentKeywords+1
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "EndDeclareModule"
    IndentKeywords(NbIndentKeywords)\Before = -1
    IndentKeywords(NbIndentKeywords)\After  = 0
    NbIndentKeywords+1
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "Module"
    IndentKeywords(NbIndentKeywords)\Before = 0
    IndentKeywords(NbIndentKeywords)\After  = 1
    NbIndentKeywords+1
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "EndModule"
    IndentKeywords(NbIndentKeywords)\Before = -1
    IndentKeywords(NbIndentKeywords)\After  = 0
    NbIndentKeywords+1
  EndIf
  
  If PrefsVersion < 540
    ReDim IndentKeywords.IndentEntry(NbIndentKeywords+1)
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "EnumerationBinary"
    IndentKeywords(NbIndentKeywords)\Before = 0
    IndentKeywords(NbIndentKeywords)\After  = 1
    NbIndentKeywords+1
  EndIf
  
  CompilerIf #SpiderBasic
    If PrefsVersion < 621
  CompilerElse
    If PrefsVersion < 630
  CompilerEndIf
    ReDim IndentKeywords.IndentEntry(NbIndentKeywords+2)
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "HeaderSection"
    IndentKeywords(NbIndentKeywords)\Before = 0
    IndentKeywords(NbIndentKeywords)\After  = 1
    NbIndentKeywords+1
    
    IndentKeywords(NbIndentKeywords)\Keyword$ = "EndHeaderSection"
    IndentKeywords(NbIndentKeywords)\Before = -1
    IndentKeywords(NbIndentKeywords)\After  = 0
    NbIndentKeywords+1
  EndIf
    
  ; Sort and index the values
  BuildIndentVT()
  
  ;- - Projects
  PreferenceGroup("Projects")
  DefaultProjectFile$ = ReadPreferenceString("DefaultProject", "")
  
  LoadDialogPosition(@ProjectOptionsPosition, -1, -1, 0, 0, "ProjectOptions") ; will get a minimum size anyway, so no default w/h
  
  ;- - Form
  PreferenceGroup("Form")
  FormVariable = ReadPreferenceLong("Variable", 1)
  FormVariableCaption = ReadPreferenceLong("VariableCaption", 0)
  FormGrid = ReadPreferenceLong("Grid", 1)
  FormGridSize = ReadPreferenceLong("GridSize", 10)
  FormEventProcedure = ReadPreferenceLong("EventProcedure", 1)
  FormSkin = ReadPreferenceLong("FormSkin", #PB_Compiler_OS)
  
  Select OSVersion()
    Case #PB_OS_Windows_Future
      FormSkinVersion = ReadPreferenceLong("FormSkinVersion", 8)
      
    Default
      FormSkinVersion = ReadPreferenceLong("FormSkinVersion", 7)
  EndSelect
  
  FormVersionWarnings = ReadPreferenceLong("VersionWarnings",  #FDI_Warn_Default)
    
  ;- - EditHistory
  PreferenceGroup("EditHistory")
  EnableHistory      = ReadPreferenceLong("Enable", 1)
  HistoryTimer       = ReadPreferenceLong("Timer", 5)
  HistoryMaxFileSize = ReadPreferenceLong("MaxFileSize", 2*1024*1024) ; 2mb max
  HistoryPurgeMode   = ReadPreferenceLong("PurgeMode", 2)             ; purge by days
  MaxSessionDays     = ReadPreferenceLong("MaxDays", 30)
  MaxSessionCount    = ReadPreferenceLong("MaxCount", 20)
  LoadDialogPosition(@EditHistoryPosition, -1, -1, 800, 600, "Window")
  EditHistorySplitter = ReadPreferenceLong("WindowSplitter", 300)
  
  ;- - Issues
  PreferenceGroup("Issues")
  IssueMultiFile = ReadPreferenceLong("MultiFile", 1)
  SelectedIssue  = ReadPreferenceLong("Selected",  0) ; means display all issues
  IssuesCol1     = ReadPreferenceLong("ColSize1", 60)
  IssuesCol2     = ReadPreferenceLong("ColSize2", 250)
  IssuesCol3     = ReadPreferenceLong("ColSize3", 50)
  IssuesCol4     = ReadPreferenceLong("ColSize4", 120)
  IssuesCol5     = ReadPreferenceLong("ColSize5", 80)
  IssueCount     = ReadPreferenceLong("Count", -1)
  
  ClearList(Issues())
  If IssueCount < 0
    ; no issues defined yet: create a default list
    AddElement(Issues())
    Issues()\Name$       = "Todo"
    Issues()\Expression$ = "\bTODO\b.*"
    Issues()\Priority    = 4 ; info
    Issues()\Color       = Colors(#COLOR_DebuggerWarning)\UserValue
    Issues()\CodeMode    = 1 ; mark the backgroundo of the regex only
    Issues()\InTool      = 1
    Issues()\InBrowser   = 0
    
    AddElement(Issues())
    Issues()\Name$       = "Fixme"
    Issues()\Expression$ = "\bFIXME\b.*"
    Issues()\Priority    = 1 ; high
    Issues()\Color       = Colors(#COLOR_DebuggerError)\UserValue
    Issues()\CodeMode    = 1 ; mark the backgroundo of the regex only
    Issues()\InTool      = 1
    Issues()\InBrowser   = 0
    
  Else
    
    For i = 1 To IssueCount
      AddElement(Issues())
      Issues()\Name$       = ReadPreferenceString("Name_" + i, "")
      Issues()\Expression$ = ReadPreferenceString("Expr_" + i, "")
      Issues()\Priority    = ReadPreferenceLong("Prio_" + i, 2)
      Issues()\Color       = ReadPreferenceLong("Color_" + i, $FFFFFF)
      Issues()\CodeMode    = ReadPreferenceLong("Mode_" + i, 0)
      Issues()\InTool      = ReadPreferenceLong("InTool_" + i, 1)
      Issues()\InBrowser   = ReadPreferenceLong("InBrowser_" + i, 0)
      
      ; sanitize these values
      If Issues()\Priority < 0
        Issues()\Priority = 0
      ElseIf Issues()\Priority > 4
        Issues()\Priority = 4
      EndIf
    Next i
    
  EndIf
  
  InitIssueList()
  
  ;- - MiscWindows
  PreferenceGroup("MiscWindows")
  LoadDialogPosition(@PreferenceWindowPosition,  -1, -1,   0,   0, "Preference")
  LoadDialogPosition(@AboutWindowPosition,       -1, -1,   0,   0, "About")
  LoadDialogPosition(@SortSourcesWindowPosition, -1, -1,   0,   0, "SortSources")
  LoadDialogPosition(@WarningWindowPosition,     -1, -1, 470, 180, "Warning")
  LoadDialogPosition(@BuildWindowPosition,       -1, -1, 550, 350, "Build")
  LoadDialogPosition(@UpdateWindowPosition,      -1, -1,   0,   0, "Updates")
  
  ;- - Shortcuts
  PreferenceGroup("Shortcuts")
  Restore ShortcutItems
  For i = 0 To #MENU_LastShortcutItem
    Read.s MenuTitle$
    Read.s MenuItem$
    Read.l DefaultShortcut
    KeyboardShortcuts(i) = ReadPreferenceLong(MenuItem$, DefaultShortcut)
  Next i
  
  ; a little fix to not have a shortcut twice, since i switched two shortcut values in the defaults
  If KeyboardShortcuts(#MENU_ToggleFolds) = KeyboardShortcuts(#MENU_ToggleThisFold) And KeyboardShortcuts(#MENU_ToggleThisFold) = #SHORTCUT_ToggleThisFold
    KeyboardShortcuts(#MENU_ToggleFolds) = #SHORTCUT_ToggleFolds
  EndIf
  
  
  ;- - Toolbar
  
  ; The 4.40+ toolbar format is saved in "ToolbarNew", to not mess up the IDE when
  ; the user runs an older version after a newer one with the same prefs file.
  ; If this happens, the user will simply get the default toolbar this way
  ;
  If PreferenceGroup("ToolbarNew") = 0
    ; fall back to the old group if no new data is present (the layout will be properly converted)
    PreferenceGroup("Toolbar")
  EndIf
  
  ToolbarItemCount = ReadPreferenceLong("ItemCount", ToolbarItemCount)
  For i = 1 To ToolbarItemCount
    Toolbar(i)\Name$   = ConvertToolbarIconName(ReadPreferenceString("Icon_"+Str(i), Toolbar(i)\Name$)) ; convert old files to new format
    Toolbar(i)\Action$ = ReadPreferenceString("Action_"+Str(i), Toolbar(i)\Action$)
  Next i
  
  ;- - FindWindow
  PreferenceGroup("FindWindow")
  LoadDialogPosition(@FindWindowPosition)
  FindHistorySize            = ReadPreferenceLong("HistorySize", 10)
  FindDoReplace              = ReadPreferenceLong("DoReplace", 0)
  FindCaseSensitive          = ReadPreferenceLong("CaseSensitive", 0)
  FindWholeWord              = ReadPreferenceLong("WholeWord", 0)
  FindSelectionOnly          = ReadPreferenceLong("SelectionOnly", 0)
  FindAutoWrap               = ReadPreferenceLong("AutoWrap", 0)
  FindNoComments             = ReadPreferenceLong("NoComments", 0)
  FindNoStrings              = ReadPreferenceLong("NoStrings", 0)
  
  If FindHistorySize > #MAX_FindHistory
    FindHistorySize = #MAX_FindHistory
  EndIf
  
  For i = 1 To FindHistorySize
    FindSearchHistory(i)     = ReadPreferenceString("SearchHistory_"+Str(i), "")
    FindReplaceHistory(i)    = ReadPreferenceString("ReplaceHistory_"+Str(i), "")
  Next i
  
  ;- - DiffWindow
  PreferenceGroup("DiffWindow")
  LoadDialogPosition(@DiffWindowPosition, -1, -1, 700, 450, "Output")
  LoadDialogPosition(@DiffDirectoryWindowPosition, -1, -1, 500, 400, "Directory")
  LoadDialogPosition(@DiffDialogWindowPosition, -1, -1, 0, 0, "Dialog")
  DiffVertical    = ReadPreferenceLong("Vertical", 0)
  DiffShowColors  = ReadPreferenceLong("Colors", 1)
  DiffIgnoreCase  = ReadPreferenceLong("IgnoreCase", 0)
  DiffIgnoreSpaceAll   = ReadPreferenceLong("IgnoreSpaceAll", 0)
  DiffIgnoreSpaceLeft  = ReadPreferenceLong("IgnoreSpaceLeft", 0)
  DiffIgnoreSpaceRight = ReadPreferenceLong("IgnoreSpaceRight", 0)
  DiffRecurse          = ReadPreferenceLong("Recurse", 0)
  
  For j = 0 To 4
    For i = 1 To FindHistorySize
      DiffDialogHistory(j, i) = ReadPreferenceString("History_"+Str(j)+"_"+Str(i), "")
    Next i
  Next j
  
  ;- - GrepWindow
  PreferenceGroup("GrepWindow")
  LoadDialogPosition(@GrepWindowPosition)
  GrepCaseSensitive          = ReadPreferenceLong("CaseSensitive", 0)
  GrepWholeWord              = ReadPreferenceLong("WholeWord", 0)
  GrepNoComments             = ReadPreferenceLong("NoComments", 0)
  GrepNoStrings              = ReadPreferenceLong("NoStrings", 0)
  GrepRecurse                = ReadPreferenceLong("Recurse", 0)
  
  For i = 1 To FindHistorySize
    GrepFindHistory(i)       = ReadPreferenceString("FindHistory_"+Str(i), "")
    GrepDirectoryHistory(i)  = ReadPreferenceString("DirectoryHistory_"+Str(i), "")
    GrepExtensionHistory(i)  = ReadPreferenceString("ExtensionHistory_"+Str(i), "")
  Next i
  
  ;- - GrepOutput
  PreferenceGroup("GrepOutput")
  LoadDialogPosition(@GrepOutputPosition, 100, 100, 430, 300)
  
  ;     ;- - CPUMonitor
  ;     PreferenceGroup("CPUMonitor")
  ;       CPUWindowX            = ReadPreferenceLong("X",            0)
  ;       CPUWindowY            = ReadPreferenceLong("Y",            0)
  ;       CPUWindowWidth        = ReadPreferenceLong("Width",      500)
  ;       CPUWindowHeight       = ReadPreferenceLong("Height",     400)
  ;       CPUUpdateInterval     = ReadPreferenceLong("Intervall", 1000) ; DO NOT FIX TYPO: Intervall
  ;       CPUStayOnTop          = ReadPreferenceLong("OnTop",        1)
  ;       DisplayCPUTotal       = ReadPreferenceLong("DisplayTotal", #PB_ListIcon_Checked)
  ;       DisplayCPUFree        = ReadPreferenceLong("DisplayFree",  0)
  ;
  ;       Restore CPUMonitorColors
  ;       index = 0
  ;       Repeat
  ;         Read.l CPUColors(index)
  ;         index + 1
  ;       Until CPUColors(index-1) = -1
  ;
  ;       NBCPUColors           = ReadPreferenceLong("NbColors", index)
  ;
  ;       For index = 0 To NbCPUColors-1
  ;         CPUColors(index) = ReadPreferenceLong("Color_"+Str(index), CPUColors(index))
  ;       Next index
  
  ;- - ToolsPanel
  PreferenceGroup("ToolsPanel")
  ToolsPanelWidth            = ReadPreferenceLong("Width", 220)
  ToolsPanelSide             = ReadPreferenceLong("Side", 0) ; Side: 0 = Right, 1 = Left
  ToolsPanelUseFont          = ReadPreferenceLong("UseFont", 0)
  ToolsPanelUseColors        = ReadPreferenceLong("UseColors", 1)
  ToolsPanelFontName$        = ReadPreferenceString("Font", "")
  ToolsPanelFontSize         = ReadPreferenceLong("FontSize", 12)
  ToolsPanelFontStyle$       = ReadPreferenceString("FontStyle", "None")
  ToolsPanelFrontColor       = ReadPreferenceLong("FrontColor", $000000)
  CompilerIf #SpiderBasic
    ToolsPanelBackColor        = ReadPreferenceLong("BackColor", $FFFFFF)
  CompilerElse
    ToolsPanelBackColor        = ReadPreferenceLong("BackColor", $DFFFFF)
  CompilerEndIf
  NoIndependentToolsColors   = ReadPreferenceLong("NoIndependantColors", 1) ; DO NOT FIX TYPO: NoIndependantColors
  ToolsPanelAutoHide         = ReadPreferenceLong("AutoHide", 0)
  
  
  CompilerIf #CompileWindows
    ToolsPanelHideDelay        = ReadPreferenceLong("HideDelay", 2500)
  CompilerElse
    ToolsPanelHideDelay = 0 ; no timer on linux/mac, so the delay must be 0
  CompilerEndIf
  
  ToolsPanelFontStyle = 0
  If FindString(UCase(ToolsPanelFontStyle$),"BOLD",1)
    ToolsPanelFontStyle | #PB_Font_Bold
  EndIf
  If FindString(UCase(ToolsPanelFontStyle$),"ITALIC",1)
    ToolsPanelFontStyle | #PB_Font_Italic
  EndIf
  
  If ToolsPanelFontName$ = "" Or ToolsPanelUseFont = 0
    ToolsPanelFontID = #PB_Default
  Else
    ToolsPanelFontID = LoadFont(#FONT_ToolsPanel, ToolsPanelFontName$, ToolsPanelFontSize, ToolsPanelFontStyle)
  EndIf
  
  ActiveToolsCount = ReadPreferenceLong("ActiveTools", -1)
  
  ; read the ID's of the enabled tools
  ;
  If ActiveToolsCount = -1 ; value doesn't exist, use the default setup
    SortStructuredList(AvailablePanelTools(), #PB_Sort_Ascending, OffsetOf(ToolsPanelEntry\PanelTabOrder), TypeOf(ToolsPanelEntry\PanelTabOrder))
    ForEach AvailablePanelTools()
      If AvailablePanelTools()\PanelTabOrder   ; If Name$ = "PROCEDUREBROWSER" Or Name$ = "FORM" Or Name$ = "PROJECTPANEL" Or Name$ = "EXPLORER" Or Name$ = "WEBVIEW"
        AddElement(UsedPanelTools())  ; add the tool to the active list
        UsedPanelTools() = @AvailablePanelTools()
      EndIf
    Next AvailablePanelTools()
    
  Else
    FormPresent = 0
    ClearList(UsedPanelTools())
    For i = 1 To ActiveToolsCount
      Name$ = UCase(ReadPreferenceString("Tool_"+Str(i), ""))
      ForEach AvailablePanelTools()
        If Name$ = UCase(AvailablePanelTools()\ToolID$)
          AddElement(UsedPanelTools())  ; add the tool to the active list
          UsedPanelTools() = @AvailablePanelTools()
          Break
        EndIf
      Next AvailablePanelTools()
      If Name$ = "FORM"
        FormPresent = 1
      EndIf
    Next i
    
    ; automatically add the form designer tool if upgrading from an older preferences file
    If PrefsVersion < 510 And FormPresent = 0
      ForEach AvailablePanelTools()
        Name$ = UCase(AvailablePanelTools()\ToolID$)
        If Name$ = "FORM"
          AddElement(UsedPanelTools())  ; add the tool to the active list
          UsedPanelTools() = @AvailablePanelTools()
          Break
        EndIf
      Next AvailablePanelTools()
    EndIf
    
  EndIf
  
  ;- - ToolsPanelMetrics
  PreferenceGroup("ToolsPanelMetrics")
  ; Now Read the window settings for all available tools
  ;
  ForEach AvailablePanelTools()
    AvailablePanelTools()\ToolWindowX      = ReadPreferenceLong(AvailablePanelTools()\ToolName$+"_X", 0)
    AvailablePanelTools()\ToolWindowY      = ReadPreferenceLong(AvailablePanelTools()\ToolName$+"_Y", 0)
    AvailablePanelTools()\ToolWindowWidth  = ReadPreferenceLong(AvailablePanelTools()\ToolName$+"_Width", 250)
    AvailablePanelTools()\ToolWindowHeight = ReadPreferenceLong(AvailablePanelTools()\ToolName$+"_Height", 460)
    AvailablePanelTools()\IsToolStayOnTop  = ReadPreferenceLong(AvailablePanelTools()\ToolName$+"_Top", 0)
  Next AvailablePanelTools()
  
  If ListSize(UsedPanelTools()) = 0
    ToolsPanelMode = 0 ; do not display the Panel at all
  Else
    ToolsPanelMode = 1
  EndIf
  
  ; now read the configuration for all available tools
  ;
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\NeedPreferences
      PanelTool.ToolsPanelInterface = @AvailablePanelTools()
      PanelTool\PreferenceLoad()
    EndIf
  Next AvailablePanelTools()
  
  ;- - FileViewer
  PreferenceGroup("FileViewer")
  FileViewerX                = ReadPreferenceLong  ("X", 50)
  FileViewerY                = ReadPreferenceLong  ("Y", 50)
  FileViewerWidth            = ReadPreferenceLong  ("Width", 500)
  FileViewerHeight           = ReadPreferenceLong  ("Height", 400)
  FileViewerMaximize         = ReadPreferenceLong  ("IsMaximized", 0)
  FileViewerPath$            = ReadPreferenceString("Path", SourcePath$)
  FileViewerPattern          = ReadPreferenceLong  ("Pattern", 0)
  
  ;- - MacroErrorWindow
  PreferenceGroup("MacroErrorWindow")
  MacroErrorWindowWidth      = ReadPreferenceLong("Width",  450)
  MacroErrorWindowHeight     = ReadPreferenceLong("Height", 300)
  
  ;- - StructureViewer
  PreferenceGroup("StructureViewer")
  LoadDialogPosition(@StructureViewerPosition, 100, 100, 400, 400)
  StructureViewerStayOnTop   = ReadPreferenceLong("StayOnTop", 1)
  
  ;- - MoreCompilers
  PreferenceGroup("MoreCompilers")
  Count = ReadPreferenceLong("Count", 0)
  For i = 1 To Count
    AddElement(Compilers())
    Compilers()\Executable$    = ReadPreferenceString("Compiler"+Str(i)+"_Exe", "")
    Compilers()\MD5$           = ReadPreferenceString("Compiler"+Str(i)+"_Md5", "")
    Compilers()\VersionString$ = ReadPreferenceString("Compiler"+Str(i)+"_Version", "Unknown")
    
    If Compilers()\MD5$ <> "" And FileFingerprint(Compilers()\Executable$, #PB_Cipher_MD5) = Compilers()\MD5$
      ; the compiler is still there and has not been updated
      Compilers()\Validated     = #True
      Compilers()\VersionNumber = Val(LSet(RemoveString(StringField(Compilers()\VersionString$, 2, " "), "."), 3, "0"))
    Else
      ; will try to get the info from the exe (and set it to validated)
      GetCompilerVersion(Compilers()\Executable$, @Compilers())
    EndIf
  Next i
  
  ; Ensures the C backend compiler is automatically added to the list for the PureBasic version which have one
  ;
  CompilerIf (#CompileWindows Or #CompileLinux) And (#CompileX86 Or #CompileX64)
    CompilerIf #CompileWindows
      CompilerExecutable$ = PureBasicPath$ + "Compilers\pbcompilerc.exe"
    CompilerElse ; Linux
      CompilerExecutable$ = PureBasicPath$ + "compilers/pbcompilerc"
    CompilerEndIf
    
    Found = #False
    ForEach Compilers()
      If IsEqualFile(CompilerExecutable$, Compilers()\Executable$)
        Found = #True
        Break
      EndIf
    Next
    
    ; Not found in the additional compiler list, we can add it
    If Not Found
      AddElement(Compilers())
      Compilers()\Executable$ = CompilerExecutable$
      ; will try to get the info from the exe (and set it to validated)
      GetCompilerVersion(Compilers()\Executable$, @Compilers())
    EndIf
  CompilerEndIf
  
  SortCompilers()
    
  ;- - CompilerDefaults
  PreferenceGroup("CompilerDefaults")
  LoadDialogPosition(@OptionWindowPosition)
  LoadDialogPosition(@ProjectOptionWindowPosition, -1, -1, 0, 0, "ProjectOption")
  OptionDebugger             = ReadPreferenceLong("Debugger",  1)
  OptionPurifier             = ReadPreferenceLong("Purifier",  0)
  OptionOptimizer            = ReadPreferenceLong("Optimizer", 0)
  OptionInlineASM            = ReadPreferenceLong("InlineASM", 0)
  OptionXPSkin               = ReadPreferenceLong("XPSkin",    1)
  OptionWayland              = ReadPreferenceLong("Wayland",   0)
  OptionVistaAdmin           = ReadPreferenceLong("VistaAdmin",0)
  OptionVistaUser            = ReadPreferenceLong("VistaUser", 0)
  OptionDPIAware             = ReadPreferenceLong("DPIAware",  1)
  OptionDllProtection        = ReadPreferenceLong("DllProtection", 0)
  OptionSharedUCRT           = ReadPreferenceLong("SharedUCRT", 0)
  OptionThread               = ReadPreferenceLong("Thread",    0)
  OptionOnError              = ReadPreferenceLong("OnError",   0)
  OptionCPU                  = ReadPreferenceLong("CPU",       0)
  OptionExeFormat            = ReadPreferenceLong("ExeFormat", 0)
  OptionNewLineType          = ReadPreferenceLong("NewLineType", #DEFAULT_NewLineType)
  OptionSubSystem$           = ReadPreferenceString("SubSystem", "")
  OptionErrorLog             = ReadPreferenceLong("ShowErrorLog", 1)
  OptionEncoding             = ReadPreferenceLong("TextEncoding", 1) ; UTF8 text is default
  OptionUseCompileCount      = ReadPreferenceLong("UseCompileCount", 0)
  OptionUseBuildCount        = ReadPreferenceLong("UseBuildCount", 0)
  OptionUseCreateExe         = ReadPreferenceLong("UseCreateExe", 0)
  OptionCustomCompiler       = ReadPreferenceLong("CustomCompiler", 0)
  OptionCompilerVersion$     = ReadPreferenceString("CompilerVersion", "")
  CompilerIf #SpiderBasic
    LoadDialogPosition(@CreateAppWindowPosition, -1, -1, 0, 0, "CreateApp")
    OptionTemporaryExe       = #True ; Always create the output in the source directory as we launch a webserver and don't want to launch it in temp
    OptionWebBrowser$        = ReadPreferenceString("WebBrowser", "")
    OptionWebServerPort      = ReadPreferenceLong("WebServerPort", 19080)
    OptionJDK$               = ReadPreferenceString("JDK", "")
    OptionAppleTeamID$       = ReadPreferenceString("AppleTeamID", "")
  CompilerElse
    OptionTemporaryExe       = ReadPreferenceLong("TemporaryExe", 0)
  CompilerEndIf
  
  ;- - Custom Keywords
  PreferenceGroup("CustomKeywords")
  CustomKeywordFile$         = ReadPreferenceString("File", "")
  Count                      = ReadPreferenceLong  ("Count", 0)
  
  ClearList(CustomKeywordList())
  For i = 1 To count
    AddElement(CustomKeywordList())
    CustomKeywordList() = ReadPreferenceString("W"+Str(i), "")
  Next i
  
  SortList(CustomKeywordList(), 2)
  BuildCustomKeywordTable()
  
  ;- - AddTools
  PreferenceGroup("AddTools")
  LoadDialogPosition(@AddToolsWindowPosition, -1, -1, 400, 300)
  EditToolsWindowPosition\x = ReadPreferenceLong("EditX",    -1)
  EditToolsWindowPosition\y = ReadPreferenceLong("EditY",    -1)
  
  
  ;- - AutoComplete
  PreferenceGroup("AutoComplete")
  AutoCompleteAddBrackets     = ReadPreferenceLong("AddBrackets",        0)
  AutoCompleteAddSpaces       = ReadPreferenceLong("AddSpaces",          0)
  AutoCompleteAddEndKeywords  = ReadPreferenceLong("AddEndKeyWords",     0)
  AutoCompleteWindowWidth     = ReadPreferenceLong("Width",            230) ; 150 is way too small on Linux
  AutoCompleteWindowHeight    = ReadPreferenceLong("Height",           300)
  AutoPopupNormal             = ReadPreferenceLong("AutoPopup",          1)
  ;AutoCompleteNoStrings       = ReadPreferenceLong("NoStrings",          1)
  ;AutoCompleteNoComments      = ReadPreferenceLong("NoComments",         1)
  AutoCompletePopupLength     = ReadPreferenceLong("AutoPopupLength",    3)
  AutoPopupStructures         = ReadPreferenceLong("CompleteStructures", 1)
  AutoPopupModules            = ReadPreferenceLong("CompleteModules",    1)
  AutoCompleteProject         = ReadPreferenceLong("ProjectItems",       1)
  AutoCompleteAllFiles        = ReadPreferenceLong("AllFileItems",       0)
  
  ; removed options
  AutoCompleteNoStrings = 1
  AutoCompleteNoComments = 1
  
  OldOptions = ReadPreferenceLong("Options", 0)
  If OldOptions
    ; translate the old preferences options to the new format
    AutocompleteOptions(#ITEM_Variable)   = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileVariables)|(1<<#AUTOCOMPLETE_AllFileVariables))
    AutocompleteOptions(#ITEM_Array)      = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileArrays)|(1<<#AUTOCOMPLETE_AllFileArrays))
    AutocompleteOptions(#ITEM_LinkedList) = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileLists)|(1<<#AUTOCOMPLETE_AllFileLists))
    AutocompleteOptions(#ITEM_Map)        = AutocompleteOptions(#ITEM_LinkedList) ; just re-use that
    AutocompleteOptions(#ITEM_Procedure)  = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileFunctions)|(1<<#AUTOCOMPLETE_AllFilesFunctions))
    AutocompleteOptions(#ITEM_Macro)      = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileMacros)|(1<<#AUTOCOMPLETE_AllFileMacros))
    AutocompleteOptions(#ITEM_Import)     = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileImports)|(1<<#AUTOCOMPLETE_AllFileImports))
    AutocompleteOptions(#ITEM_Constant)   = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileConstants)|(1<<#AUTOCOMPLETE_AllFileConstants))
    AutocompleteOptions(#ITEM_Prototype)  = #False
    AutocompleteOptions(#ITEM_Structure)  = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileStructures)|(1<<#AUTOCOMPLETE_AllFileStructures))
    AutocompleteOptions(#ITEM_Interface)  = OldOptions & ((1<<#AUTOCOMPLETE_CurrentFileInterfaces)|(1<<#AUTOCOMPLETE_AllFileInterfaces))
    AutocompleteOptions(#ITEM_Label)      = #False
    
    AutocompletePBOptions(#PBITEM_Keyword)     = OldOptions & (1<<#AUTOCOMPLETE_PBKeywords)
    AutocompletePBOptions(#PBITEM_ASMKeyword)  = OldOptions & (1<<#AUTOCOMPLETE_ASMKeywords)
    AutocompletePBOptions(#PBITEM_Function)    = OldOptions & (1<<#AUTOCOMPLETE_PBFunctions)
    AutocompletePBOptions(#PBITEM_APIFunction) = OldOptions & (1<<#AUTOCOMPLETE_APIFunctions)
    AutocompletePBOptions(#PBITEM_Constant)    = OldOptions & (1<<#AUTOCOMPLETE_Constants)
    AutocompletePBOptions(#PBITEM_Structure)   = OldOptions & (1<<#AUTOCOMPLETE_Structures)
    AutocompletePBOptions(#PBITEM_Interface)   = OldOptions & (1<<#AUTOCOMPLETE_Interfaces)
    
    If OldOptions & (#AUTOCOMPLETE_AllFileVariables|#AUTOCOMPLETE_AllFileArrays|#AUTOCOMPLETE_AllFileLists|#AUTOCOMPLETE_AllFilesFunctions|#AUTOCOMPLETE_AllFileMacros|#AUTOCOMPLETE_AllFileImports|#AUTOCOMPLETE_AllFileConstants|#AUTOCOMPLETE_CurrentFileStructures|#AUTOCOMPLETE_AllFileInterfaces)
      AutoCompleteAllFiles = #True
    Else
      AutoCompleteAllFiles = #False
    EndIf
    
  Else
    ; read the new format prefs data
    
    ; read defaults, then read the settings
    Restore SourceItem_Defaults
    For i = 0 To #ITEM_LastOption
      Read.l AutocompleteOptions(i)
    Next i
    
    Restore SourceItem_Names
    For i = 0 To #ITEM_LastOption
      Read.s ItemName$
      AutocompleteOptions(i) = ReadPreferenceLong(ItemName$, AutocompleteOptions(i))
    Next i
    
    Restore PBItem_Defaults
    For i = 0 To #PBITEM_Last
      Read.l AutocompletePBOptions(i)
    Next i
    
    Restore PBItem_Names
    For i = 0 To #PBITEM_Last
      Read.s ItemName$
      AutocompletePBOptions(i) = ReadPreferenceLong(ItemName$, AutocompletePBOptions(i))
    Next i
  EndIf
  
  ;- - RecentFiles
  PreferenceGroup("RecentFiles")
  FilesHistorySize           = ReadPreferenceLong("HistorySize", 10)
  If FilesHistorySize > #MAX_RecentFiles
    FilesHistorySize = #MAX_RecentFiles
  EndIf
  
  For i = 1 To FilesHistorySize
    RecentFiles(i) = ReadPreferenceString("RecentFile_"+Str(i), "")
  Next i
  
  For i = 1 To FilesHistorySize
    RecentFiles(#MAX_RecentFiles+i) = ReadPreferenceString("RecentProject_"+Str(i), "")
  Next i
  
  ;- - OpenedFiles
  PreferenceGroup("OpenedFiles")
  OpenFilesCount = ReadPreferenceLong("Count", 0)
  ResetList(OpenFiles()) ; insert all names at the front, this loads the last closed one first (and all these before the commandline files)
  
  For i = 1 To OpenFilesCount
    InsertElement(OpenFiles()) ; insert all at the start
    OpenFiles() = ReadPreferenceString("OpenedFile_"+Str(i), "")
  Next i
  
  LastOpenProjectFile$ = ReadPreferenceString("OpenedProject", "")
  
  CompilerIf #CompileLinux | #CompileMac
    ;- - Help
    PreferenceGroup("Help")
    HelpWindowX                = ReadPreferenceLong("X", -1)
    HelpWindowY                = ReadPreferenceLong("Y", -1)
    HelpWindowWidth            = ReadPreferenceLong("Width", 600)
    HelpWindowHeight           = ReadPreferenceLong("Height", 400)
    HelpWindowSplitter         = ReadPreferenceLong("Splitter", 180)
    HelpWindowMaximized        = ReadPreferenceLong("IsMaximized", 0)
  CompilerEndIf
  
  ;- - Debugger
  PreferenceGroup("Debugger")
  DebuggerMode               = ReadPreferenceLong("DebuggerMode", 1)
  
  ;         CompilerIf #CompileMac ; OSX-debug
  ;           If DebuggerMode = 1
  ;             DebuggerMode = 2
  ;           EndIf
  ;         CompilerEndIf
  
  DebuggerMemorizeWindows    = ReadPreferenceLong("MemorizeWindows", 1)
  DebuggerKeepErrorMarks     = ReadPreferenceLong("KeepErrorMarks", 1)
  IsDebuggerMaximized        = ReadPreferenceLong("IsDebuggerMaximized", 0)
  DebuggerOnTop              = ReadPreferenceLong("StayOnTop", #DEFAULT_DebuggerStayOnTop)
  DebuggerBringToTop         = ReadPreferenceLong("AutoBringToTop", #DEFAULT_DebuggerBringToTop)
  CallDebuggerOnStart        = ReadPreferenceLong("CallOnStart", 0)
  CallDebuggerOnEnd          = ReadPreferenceLong("CallOnEnd", 0)
  LogTimeStamp               = ReadPreferenceLong("LogTimeStamp", 1)
  ErrorLogHeight             = ReadPreferenceLong("ErrorLogHeight", 150)
  DebuggerKillOnError        = ReadPreferenceLong("KillOnError", 0)
  
  CompilerIf #SpiderBasic
    DebuggerKillOnError = 1
  CompilerEndIf
  
  AutoClearLog               = ReadPreferenceLong("AutoClearLog", 0)
  DisplayErrorWindow         = ReadPreferenceLong("DisplayErrorWindow", 1)
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
    DebugOutFontID = LoadFont(#FONT_DebugOut, DebugOutFont$, DebugOutFontSize, DebugOutFontStyle)
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
  MemoryViewerWidth          = ReadPreferenceLong("MemoryViewerWidth", 600)
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
  
  LibraryViewerX             = ReadPreferenceLong("LibraryViewerX", 120)
  LibraryViewerY             = ReadPreferenceLong("LibraryViewerY", 120)
  LibraryViewerWidth         = ReadPreferenceLong("LibraryViewerWidth", 600)
  LibraryViewerHeight        = ReadPreferenceLong("LibraryViewerHeight", 440)
  LibraryViewerSplitter1     = ReadPreferenceLong("LibraryViewerSplitter1", 300)
  LibraryViewerSplitter2     = ReadPreferenceLong("LibraryViewerSplitter2", 130)
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
  
  ClosePreferences()
  
EndProcedure

Procedure SavePreferences()
  
  If CreatePreferences(PreferencesFile$)
    PreferenceComment(" PureBasic IDE Preference File")
    PreferenceComment("")
    
    ;- - Global
    PreferenceComment("")
    PreferenceGroup("Global")
    WritePreferenceLong  ("Version", #PB_Compiler_Version) ; to know when to add new features
    WritePreferenceLong  ("AutoReload",           AutoReload)
    WritePreferenceLong  ("MemorizeWindow",       MemorizeWindow)
    WritePreferenceString("CurrentLanguage",      CurrentLanguage$)
    WritePreferenceString("LanguageFile",         LanguageFile$)
    WritePreferenceString("CurrentTheme",         CurrentTheme$)
    WritePreferenceString("SourceDirectory",      SourcePath$)
    ;WritePreferenceLong  ("EnableColoring",       EnableColoring)
    WritePreferenceLong  ("EnableBraceMatch",     EnableBraceMatch)
    WritePreferenceLong  ("EnableKeywordMatch",   EnableKeywordMatch)
    WritePreferenceLong  ("EnableKeywordBolding", EnableKeywordBolding)
    WritePreferenceLong  ("EnableCaseCorrection", EnableCaseCorrection)
    WritePreferenceLong  ("EnableLineNumbers",    EnableLineNumbers)
    WritePreferenceLong  ("EnableAccessibility",  EnableAccessibility)
    ;WritePreferenceLong  ("EnableMarkers",        EnableMarkers)
    WritePreferenceLong  ("ShowWhiteSpace",       ShowWhiteSpace)
    WritePreferenceLong  ("UseTabIndentForSplittedLines", UseTabIndentForSplittedLines)
    WritePreferenceLong  ("ShowIndentGuides",     ShowIndentGuides)
    WritePreferenceLong  ("AutoSave",             AutoSave)
    WritePreferenceLong  ("AutoSaveAll",          AutoSaveAll)
    WritePreferenceLong  ("SaveSettingsMode",     SaveProjectSettings)
    WritePreferenceLong  ("RunOnce",              Editor_RunOnce)
    WritePreferenceLong  ("ShowToolbar",          ShowMainToolbar)
    WritePreferenceLong  ("TabLength",            TabLength)
    WritePreferenceLong  ("RealTab",              RealTab)
    WritePreferenceLong  ("MemorizeCursor",       MemorizeCursor)
    WritePreferenceLong  ("MemorizeMarkers",      MemorizeMarkers)
    WritePreferenceLong  ("LastFilePattern",      SelectedFilePattern)
    WritePreferenceLong  ("EnableMenuIcons",      EnableMenuIcons)
    WritePreferenceLong  ("DisplayFullPath",      DisplayFullPath)
    WritePreferenceLong  ("DisplayDarkMode",      DisplayDarkMode)
    WritePreferenceLong  ("NoSplashScreen",       NoSplashScreen)
    WritePreferenceLong  ("AlwaysHideLog",        AlwaysHideLog)
    WritePreferenceLong  ("ShowCompilerProgress", ShowCompilerProgress)
    WritePreferenceLong  ("UseHelpToolF1",        UseHelpToolF1)
    WritePreferenceLong  ("MonitorFileChanges",   MonitorFileChanges)
    
    WritePreferenceLong  ("UpdateCheckInterval",  UpdateCheckInterval)
    WritePreferenceLong  ("UpdateCheckVersions",  UpdateCheckVersions)
    WritePreferenceLong  ("LastUpdateCheck",      LastUpdateCheck)
    WritePreferenceLong  ("ScreenReaderChecked",  ScreenReaderChecked)
    
    ;- - Editor
    PreferenceComment("")
    PreferenceGroup("Editor")
    WritePreferenceLong  ("IsWindowMaximized",    IsWindowMaximized)
    WritePreferenceLong  ("X",                    EditorWindowX)
    WritePreferenceLong  ("Y",                    EditorWindowY)
    WritePreferenceLong  ("Width",                EditorWindowWidth)
    WritePreferenceLong  ("Height",               EditorWindowHeight)
    
    WritePreferenceLong  ("FilesPanelMultiline",    FilesPanelMultiline)
    WritePreferenceLong  ("FilesPanelCloseButtons", FilesPanelCloseButtons)
    WritePreferenceLong  ("FilesPanelNewButton",    FilesPanelNewButton)
    
    WritePreferenceString("CodeFileExtensions", CodeFileExtensions$)
    
    WritePreferenceString("ExtraWordChars", ExtraWordChars$)
    
    ; Save the color values
    ;
    Restore ColorKeys
    For i = 0 To #COLOR_Last
      Read.s ColorKey$
      WritePreferenceLong(ColorKey$, Colors(i)\UserValue)
      
      ; we only write this extra key for disabled colors. for the rest,
      ; the default is to use them
      If Colors(i)\Enabled = 0
        WritePreferenceLong(ColorKey$+"_Disabled", 1)
      EndIf
    Next i
    
    EditorFontStyle$ = ""
    If EditorFontStyle & #PB_Font_Bold
      EditorFontStyle$ + "Bold,"
    EndIf
    If EditorFontStyle & #PB_Font_Italic
      EditorFontStyle$ + "Italic,"
    EndIf
    
    WritePreferenceString("EditorFontName",       EditorFontName$)
    WritePreferenceLong  ("EditorFontSize",       EditorFontSize)
    WritePreferenceString("EditorFontStyle",      EditorFontStyle$)
    
    ;- - Projects
    PreferenceGroup("Projects")
    PreferenceComment("")
    WritePreferenceString("DefaultProject", DefaultProjectFile$)
    
    SaveDialogPosition(@ProjectOptionsPosition, 1, "ProjectOptions")
    
    
    ;- - Folding
    PreferenceComment("")
    PreferenceGroup("Folding")
    WritePreferenceLong("EnableFolding", EnableFolding)
    
    NbSavedWords = 0
    For i = 1 To NbFoldStartWords
      ; Avoid writing duplicate (https://www.purebasic.fr/english/viewtopic.php?f=4&t=55717)
      If i = 1  Or FoldStart$(i) <> FoldStart$(i-1)
        NbSavedWords+1
        WritePreferenceString("Start_"+Str(NbSavedWords), FoldStart$(i))
      EndIf
    Next i
    WritePreferenceLong("StartWords", NbSavedWords)
    
    NbSavedWords = 0
    For i = 1 To NbFoldEndWords
      ; Avoid writing duplicate (https://www.purebasic.fr/english/viewtopic.php?f=4&t=55717)
      If i = 1  Or FoldEnd$(i) <> FoldEnd$(i-1)
        NbSavedWords+1
        WritePreferenceString("End_"+Str(NbSavedWords), FoldEnd$(i))
      EndIf
    Next i
    WritePreferenceLong("EndWords", NbSavedWords)
    
    ;- - Indentation
    PreferenceGroup("Indentation")
    WritePreferenceLong("IndentMode",        IndentMode)
    WritePreferenceLong("BackspaceUnindent", BackspaceUnindent)
    WritePreferenceLong("NbKeywords",        NbIndentKeywords)
    
    For i = 0 To NbIndentKeywords-1
      WritePreferenceString("Keyword_"+Str(i), IndentKeywords(i)\Keyword$)
      WritePreferenceLong("Before_"+Str(i), IndentKeywords(i)\Before)
      WritePreferenceLong("After_"+Str(i), IndentKeywords(i)\After)
    Next i
    
    ;- - Form
    PreferenceGroup("Form")
    WritePreferenceLong("Variable",         FormVariable)
    WritePreferenceLong("VariableCaption",  FormVariableCaption)
    WritePreferenceLong("Grid",             FormGrid)
    WritePreferenceLong("GridSize",         FormGridSize)
    WritePreferenceLong("EventProcedure",   FormEventProcedure)
    WritePreferenceLong("FormSkin",         FormSkin)
    WritePreferenceLong("FormSkinVersion",  FormSkinVersion)
    WritePreferenceLong("VersionWarnings",  FormVersionWarnings)
    
    ;- - EditHistory
    PreferenceGroup("EditHistory")
    WritePreferenceLong("Enable", EnableHistory)
    WritePreferenceLong("Timer", HistoryTimer)
    WritePreferenceLong("MaxFileSize", HistoryMaxFileSize)
    WritePreferenceLong("PurgeMode", HistoryPurgeMode)
    WritePreferenceLong("MaxDays", MaxSessionDays)
    WritePreferenceLong("MaxCount", MaxSessionCount)
    SaveDialogPosition(@EditHistoryPosition, 2, "Window")
    WritePreferenceLong("WindowSplitter", EditHistorySplitter)
    
    
    ;- - Issues
    PreferenceComment("")
    PreferenceGroup("Issues")
    WritePreferenceLong("MultiFile", IssueMultiFile)
    WritePreferenceLong("Selected", SelectedIssue)
    WritePreferenceLong("ColSize1", IssuesCol1)
    WritePreferenceLong("ColSize2", IssuesCol2)
    WritePreferenceLong("ColSize3", IssuesCol3)
    WritePreferenceLong("ColSize4", IssuesCol4)
    WritePreferenceLong("ColSize5", IssuesCol5)
    WritePreferenceLong("Count", ListSize(Issues()))
    
    ForEach Issues()
      i = ListIndex(Issues()) + 1
      WritePreferenceString("Name_" + i,    Issues()\Name$)
      WritePreferenceString("Expr_" + i,    Issues()\Expression$)
      WritePreferenceLong("Prio_" + i,      Issues()\Priority)
      WritePreferenceLong("Color_" + i,     Issues()\Color)
      WritePreferenceLong("Mode_" + i,      Issues()\CodeMode)
      WritePreferenceLong("InTool_" + i,    Issues()\InTool)
      WritePreferenceLong("InBrowser_" + i, Issues()\InBrowser)
    Next Issues()
    
    
    ;- - MiscWindows
    PreferenceComment("")
    PreferenceGroup("MiscWindows")
    SaveDialogPosition(@PreferenceWindowPosition,  0, "Preference")
    SaveDialogPosition(@AboutWindowPosition,       0, "About")
    SaveDialogPosition(@SortSourcesWindowPosition, 0, "SortSources")
    SaveDialogPosition(@WarningWindowPosition,     1, "Warning")
    SaveDialogPosition(@BuildWindowPosition,       1, "Build")
    SaveDialogPosition(@UpdateWindowPosition,      0, "Updates")
    
    ;- - Shortcuts
    PreferenceComment("")
    PreferenceGroup("Shortcuts")
    Restore ShortcutItems
    For i = 0 To #MENU_LastShortcutItem
      Read.s MenuTitle$
      Read.s MenuItem$
      Read.l DefaultShortcut
      WritePreferenceLong(MenuItem$, KeyboardShortcuts(i))
    Next i
    
    
    ;- - Toolbar
    PreferenceComment("")
    PreferenceGroup("ToolbarNew") ; save as "ToolbarNew" to avoid conflict with old versions
    WritePreferenceLong("ItemCount", ToolbarItemCount)
    For i = 1 To ToolbarItemCount
      WritePreferenceString("Icon_"+Str(i), Toolbar(i)\Name$)
      WritePreferenceString("Action_"+Str(i), Toolbar(i)\Action$)
    Next i
    
    
    
    ;- - FindWindow
    PreferenceComment("")
    PreferenceGroup("FindWindow")
    SaveDialogPosition(@FindWindowPosition)
    WritePreferenceLong  ("HistorySize",   FindHistorySize)
    WritePreferenceLong  ("DoReplace",     FindDoReplace)
    WritePreferenceLong  ("CaseSensitive", FindCaseSensitive)
    WritePreferenceLong  ("WholeWord",     FindWholeWord)
    WritePreferenceLong  ("SelectionOnly", FindSelectionOnly)
    WritePreferenceLong  ("AutoWrap",      FindAutoWrap)
    WritePreferenceLong  ("NoComments",    FindNoComments)
    WritePreferenceLong  ("NoStrings",     FindNoStrings)
    
    For i = 1 To FindHistorySize
      If FindSearchHistory(i) <> ""
        WritePreferenceString("SearchHistory_"+Str(i), FindSearchHistory(i))
      EndIf
    Next i
    
    For i = 1 To FindHistorySize
      If FindReplaceHistory(i) <> ""
        WritePreferenceString("ReplaceHistory_"+Str(i), FindReplaceHistory(i))
      EndIf
    Next i
    
    ;- - DiffWindow
    PreferenceComment("")
    PreferenceGroup("DiffWindow")
    SaveDialogPosition(@DiffWindowPosition, 2, "Output")
    SaveDialogPosition(@DiffDirectoryWindowPosition, 2, "Directory")
    SaveDialogPosition(@DiffDialogWindowPosition, 0, "Dialog")
    WritePreferenceLong("Vertical",    DiffVertical)
    WritePreferenceLong("Colors",      DiffShowColors)
    WritePreferenceLong("IgnoreCase",  DiffIgnoreCase)
    WritePreferenceLong("IgnoreSpaceAll",   DiffIgnoreSpaceAll)
    WritePreferenceLong("IgnoreSpaceLeft",  DiffIgnoreSpaceLeft)
    WritePreferenceLong("IgnoreSpaceRight", DiffIgnoreSpaceRight)
    WritePreferenceLong("Recurse",          DiffRecurse)
    
    For j = 0 To 4
      For i = 1 To FindHistorySize
        If DiffDialogHistory(j, i) <> ""
          WritePreferenceString("History_"+Str(j)+"_"+Str(i), DiffDialogHistory(j, i))
        EndIf
      Next i
    Next j
    
    ;- - GrepWindow
    PreferenceComment("")
    PreferenceGroup("GrepWindow")
    SaveDialogPosition(@GrepWindowPosition)
    WritePreferenceLong  ("CaseSensitive" , GrepCaseSensitive)
    WritePreferenceLong  ("WholeWord"     , GrepWholeWord)
    WritePreferenceLong  ("NoComments"    , GrepNoComments)
    WritePreferenceLong  ("NoStrings"     , GrepNoStrings)
    WritePreferenceLong  ("Recurse"       , GrepRecurse)
    
    For i = 1 To FindHistorySize
      If GrepFindHistory(i) <> ""
        WritePreferenceString("FindHistory_"+Str(i), GrepFindHistory(i))
      EndIf
    Next i
    
    For i = 1 To FindHistorySize
      If GrepDirectoryHistory(i) <> ""
        WritePreferenceString("DirectoryHistory_"+Str(i), GrepDirectoryHistory(i))
      EndIf
    Next i
    
    For i = 1 To FindHistorySize
      If GrepExtensionHistory(i) <> ""
        WritePreferenceString("ExtensionHistory_"+Str(i), GrepExtensionHistory(i))
      EndIf
    Next i
    
    ;- - GrepOutput
    PreferenceComment("")
    PreferenceGroup("GrepOutput")
    SaveDialogPosition(@GrepOutputPosition, 1)
    
    
    ;     ;- - CPUMonitor
    ;     PreferenceComment("")
    ;     PreferenceGroup("CPUMonitor")
    ;       WritePreferenceLong("X",         CPUWindowX)
    ;       WritePreferenceLong("Y",         CPUWindowY)
    ;       WritePreferenceLong("Width",     CPUWindowWidth)
    ;       WritePreferenceLong("Height",    CPUWindowHeight)
    ;       WritePreferenceLong("Intervall", CPUUpdateInterval) ; DO NOT FIX TYPO: Intervall
    ;       WritePreferenceLong("OnTop",     CPUStayOnTop)
    ;       WritePreferenceLong("DisplayTotal",DisplayCPUTotal)
    ;       WritePreferenceLong("DisplayFree", DisplayCPUFree)
    ;       WritePreferenceLong("NbColors",  NBCPUColors)
    ;       For index = 0 To NbCPUColors-1
    ;         WritePreferenceLong("Color_" + Str(index), CPUColors(index))
    ;       Next index
    
    ;- - ToolsPanel
    PreferenceComment("")
    PreferenceGroup("ToolsPanel")
    ToolsPanelFontStyle$ = ""
    If ToolsPanelFontStyle & #PB_Font_Bold
      ToolsPanelFontStyle$ + "Bold,"
    EndIf
    If ToolsPanelFontStyle & #PB_Font_Italic
      ToolsPanelFontStyle$ + "Italic,"
    EndIf
    
    WritePreferenceLong  ("Width",            ToolsPanelWidth)
    WritePreferenceLong  ("Side",             ToolsPanelSide)
    WritePreferenceLong  ("UseFont",          ToolsPanelUseFont)
    WritePreferenceLong  ("UseColors",        ToolsPanelUseColors)
    WritePreferenceString("Font",             ToolsPanelFontName$)
    WritePreferenceLong  ("Fontsize",         ToolsPanelFontSize)
    WritePreferenceString("FontStyle",        ToolsPanelFontStyle$)
    WritePreferenceLong  ("FrontColor",       ToolsPanelFrontColor)
    WritePreferenceLong  ("BackColor",        ToolsPanelBackColor)
    WritePreferenceLong  ("NoIndependantColors", NoIndependentToolsColors) ; DO NOT FIX TYPO: NoIndependantColors
    WritePreferenceLong  ("AutoHide",         ToolsPanelAutoHide)
    WritePreferenceLong  ("HideDelay",        ToolsPanelHideDelay)
    WritePreferenceLong  ("ActiveTools",      ListSize(UsedPanelTools()))
    
    i = 0
    ForEach UsedPanelTools()
      i + 1
      *ToolData.ToolsPanelEntry = UsedPanelTools()
      WritePreferenceString("Tool_"+Str(i), *ToolData\ToolID$)
    Next UsedPanelTools()
    
    ;- - ToolsPanelMetrics
    PreferenceComment("")
    PreferenceGroup("ToolsPanelMetrics")
    ; Now write the window settings for all available tools
    ;
    ForEach AvailablePanelTools()
      WritePreferenceLong(AvailablePanelTools()\ToolName$+"_X", AvailablePanelTools()\ToolWindowX)
      WritePreferenceLong(AvailablePanelTools()\ToolName$+"_Y", AvailablePanelTools()\ToolWindowY)
      WritePreferenceLong(AvailablePanelTools()\ToolName$+"_Width", AvailablePanelTools()\ToolWindowWidth)
      WritePreferenceLong(AvailablePanelTools()\ToolName$+"_Height", AvailablePanelTools()\ToolWindowHeight)
      WritePreferenceLong(AvailablePanelTools()\ToolName$+"_Top", AvailablePanelTools()\IsToolStayOnTop)
    Next AvailablePanelTools()
    
    ; save all available tools preferences
    ;
    ForEach AvailablePanelTools()
      If AvailablePanelTools()\NeedPreferences
        PanelTool.ToolsPanelInterface = @AvailablePanelTools()
        PanelTool\PreferenceSave()
      EndIf
    Next AvailablePanelTools()
    
    ;- - FileViewer
    PreferenceComment("")
    PreferenceGroup("FileViewer")
    WritePreferenceLong  ("X",                FileViewerX)
    WritePreferenceLong  ("Y",                FileViewerY)
    WritePreferenceLong  ("Width",            FileViewerWidth)
    WritePreferenceLong  ("Height",           FileViewerHeight)
    WritePreferenceLong  ("IsMaximized",      FileViewerMaximize)
    WritePreferenceString("Path",             FileViewerPath$)
    WritePreferenceLong  ("Pattern",          FileViewerPattern)
    
    ;- - MacroErrorWindow
    PreferenceGroup("MacroErrorWindow")
    WritePreferenceLong("Width",  MacroErrorWindowWidth)
    WritePreferenceLong("Height", MacroErrorWindowHeight)
    
    
    ;- - StructureViewer
    PreferenceComment("")
    PreferenceGroup("StructureViewer")
    SaveDialogPosition(@StructureViewerPosition, 1)
    WritePreferenceLong  ("StayOnTop",        StructureViewerStayOnTop)
    
    
    ;- - MoreCompilers
    PreferenceComment("")
    PreferenceGroup("MoreCompilers")
    WritePreferenceLong("Count", ListSize(Compilers()))
    ForEach Compilers()
      Index$ = "Compiler"+Str(ListIndex(Compilers())+1)
      WritePreferenceString(Index$+"_Exe",     Compilers()\Executable$)
      If Compilers()\Validated
        WritePreferenceString(Index$+"_Md5",   Compilers()\MD5$)
      Else
        WritePreferenceString(Index$+"_Md5",   "-invalid-")
      EndIf
      WritePreferenceString(Index$+"_Version", Compilers()\VersionString$)
    Next Compilers()
    
    ;- - CompilerDefaults
    PreferenceComment("")
    PreferenceGroup("CompilerDefaults")
    SaveDialogPosition(@OptionWindowPosition)
    SaveDialogPosition(@ProjectOptionWindowPosition, 0, "ProjectOption")
    WritePreferenceLong  ("Debugger",           OptionDebugger)
    WritePreferenceLong  ("Purifier",           OptionPurifier)
    WritePreferenceLong  ("Optimizer",          OptionOptimizer)
    WritePreferenceLong  ("InlineASM",          OptionInlineASM)
    WritePreferenceLong  ("XPSkin",             OptionXPSkin)
    WritePreferenceLong  ("Wayland",            OptionWayland)
    WritePreferenceLong  ("VistaAdmin",         OptionVistaAdmin)
    WritePreferenceLong  ("VistaUser",          OptionVistaUser)
    WritePreferenceLong  ("DPIAware",           OptionDPIAware)
    WritePreferenceLong  ("DllProtection",      OptionDllProtection)
    WritePreferenceLong  ("SharedUCRT",         OptionSharedUCRT)
    WritePreferenceLong  ("Thread",             OptionThread)
    WritePreferenceLong  ("OnError",            OptionOnError)
    WritePreferenceLong  ("CPU",                OptionCPU)
    WritePreferenceLong  ("ExeFormat",          OptionExeFormat)
    WritePreferenceLong  ("NewLineType",        OptionNewLineType)
    WritePreferenceString("SubSystem",          OptionSubSystem$)
    WritePreferenceLong  ("ShowErrorLog",       OptionErrorLog)
    WritePreferenceLong  ("TextEncoding",       OptionEncoding)
    WritePreferenceLong  ("UseCompileCount",    OptionUseCompileCount)
    WritePreferenceLong  ("UseBuildCount",      OptionUseBuildCount)
    WritePreferenceLong  ("UseCreateExe",       OptionUseCreateExe)
    WritePreferenceLong  ("TemporaryExe",       OptionTemporaryExe)
    WritePreferenceLong  ("CustomCompiler",     OptionCustomCompiler)
    WritePreferenceString("CompilerVersion",    OptionCompilerVersion$)
    
    CompilerIf #SpiderBasic
      SaveDialogPosition(@CreateAppWindowPosition, 0, "CreateApp")
      WritePreferenceString("WebBrowser", OptionWebBrowser$)
      WritePreferenceLong("WebServerPort", OptionWebServerPort)
      WritePreferenceString("JDK", OptionJDK$)
      WritePreferenceString("AppleTeamID", OptionAppleTeamID$)
    CompilerEndIf
    
    
    ;- - Custom Keywords
    PreferenceComment("")
    PreferenceGroup("CustomKeywords")
    WritePreferenceString("File", CustomKeywordFile$)
    WritePreferenceLong  ("Count", ListSize(CustomKeywordList()))
    
    ForEach CustomKeywordList()
      WritePreferenceString("W"+Str(ListIndex(CustomKeywordList())+1), CustomKeywordList())
    Next CustomKeywordList()
    
    
    ;- - AddTools
    PreferenceComment("")
    PreferenceGroup("AddTools")
    SaveDialogPosition(@AddToolsWindowPosition, 1) ; save width/height as well
    WritePreferenceLong("EditX", EditToolsWindowPosition\x)
    WritePreferenceLong("EditY", EditToolsWindowPosition\y)
    
    ;- - AutoComplete
    PreferenceComment("")
    PreferenceGroup("AutoComplete")
    WritePreferenceLong  ("AddBrackets",        AutoCompleteAddBrackets)
    WritePreferenceLong  ("AddSpaces",          AutoCompleteAddSpaces)
    WritePreferenceLong  ("AddEndKeywords",     AutoCompleteAddEndKeywords)
    WritePreferenceLong  ("Width",              AutoCompleteWindowWidth)
    WritePreferenceLong  ("Height",             AutoCompleteWindowHeight)
    WritePreferenceLong  ("AutoPopup",          AutoPopupNormal)
    ;WritePreferenceLong  ("NoStrings",          AutoCompleteNoStrings)
    ;WritePreferenceLong  ("NoComments",         AutoCompleteNoComments)
    WritePreferenceLong  ("CompleteStructures", AutoPopupStructures)
    WritePreferenceLong  ("CompleteModules",    AutoPopupModules)
    WritePreferenceLong  ("ProjectItems",       AutoCompleteProject)
    WritePreferenceLong  ("AllFileItems",       AutoCompleteAllFiles)
    WritePreferenceLong  ("AutoPopupLength",    AutoCompletePopupLength)
    
    Restore SourceItem_Names
    For i = 0 To #ITEM_LastOption
      Read.s ItemName$
      WritePreferenceLong(ItemName$, AutocompleteOptions(i))
    Next i
    
    Restore PBItem_Names
    For i = 0 To #PBITEM_Last
      Read.s ItemName$
      WritePreferenceLong(ItemName$, AutocompletePBOptions(i))
    Next i
    
    
    ;- - RecentFiles
    PreferenceComment("")
    PreferenceGroup("RecentFiles")
    WritePreferenceLong  ("HistorySize",      FilesHistorySize)
    
    For i = 1 To FilesHistorySize
      If Trim(RecentFiles(i)) = ""
        Break
      EndIf
      WritePreferenceString("RecentFile_"+Str(i), RecentFiles(i))
    Next i
    
    For i = 1 To FilesHistorySize
      If Trim(RecentFiles(#MAX_RecentFiles+i)) = ""
        Break
      EndIf
      WritePreferenceString("RecentProject_"+Str(i), RecentFiles(#MAX_RecentFiles+i))
    Next i
    
    
    ;- - OpenedFiles
    PreferenceComment("")
    PreferenceGroup("OpenedFiles")
    WritePreferenceLong  ("Count", ListSize(OpenFiles()))
    ForEach OpenFiles()
      WritePreferenceString("OpenedFile_"+Str(ListIndex(OpenFiles())+1), OpenFiles())
    Next OpenFiles()
    
    WritePreferenceString("OpenedProject", LastOpenProjectFile$)
    
    ;- - Help
    CompilerIf #CompileLinux | #CompileMac
      PreferenceComment("")
      PreferenceGroup("Help")
      WritePreferenceLong("X",           HelpWindowX)
      WritePreferenceLong("Y",           HelpWindowY)
      WritePreferenceLong("Width",       HelpWindowWidth)
      WritePreferenceLong("Height",      HelpWindowHeight)
      WritePreferenceLong("Splitter",    HelpWindowSplitter)
      WritePreferenceLong("IsMaximized", HelpWindowMaximized)
    CompilerEndIf
    
    ;- - Debugger
    PreferenceComment("")
    PreferenceGroup("Debugger")
    WritePreferenceLong("DebuggerMode",     DebuggerMode)
    WritePreferenceLong("KeepErrorMarks",   DebuggerKeepErrorMarks)
    WritePreferenceLong("MemorizeWindows",  DebuggerMemorizeWindows)
    WritePreferenceLong("IsDebuggerMaximized", IsDebuggerMaximized)
    WritePreferenceLong("StayOnTop",        DebuggerOnTop)
    WritePreferenceLong("AutoBringToTop",   DebuggerBringToTop)
    WritePreferenceLong("CallOnStart",      CallDebuggerOnStart)
    WritePreferenceLong("CallOnEnd",        CallDebuggerOnEnd)
    WritePreferenceLong("LogTimeStamp",     LogTimeStamp)
    WritePreferenceLong("ErrorLogHeight",   ErrorLogHeight)
    WritePreferenceLong("KillOnError",      DebuggerKillOnError)
    WritePreferenceLong("AutoClearLog",     AutoClearLog)
    WritePreferenceLong("DisplayErrorWindow", DisplayErrorWindow)
    WritePreferenceLong("WarningMode",      WarningMode)
    WritePreferenceLong("StartupTimeout",   DebuggerTimeout)
    
    DebugOutFontStyle$ = ""
    If DebugOutFontStyle & #PB_Font_Bold
      DebugOutFontStyle$ + "Bold,"
    EndIf
    If DebugOutFontStyle & #PB_Font_Italic
      DebugOutFontStyle$ + "Italic,"
    EndIf
    
    WritePreferenceLong("DebugTimeStamp",   DebugTimeStamp)
    WritePreferenceLong("DebugIsHex",       DebugIsHex)
    WritePreferenceLong("DebugSystemMessages", DebugSystemMessages)
    WritePreferenceLong("DebugOutputToErrorLog", DebugOutputToErrorLog)
    WritePreferenceLong("DebugOutUseFont",  DebugOutUseFont)
    WritePreferenceString("DebugOutFont",     DebugOutFont$)
    WritePreferenceLong("DebugOutFontSize", DebugOutFontSize)
    WritePreferenceString("DebugOutFontStyle", DebugOutFontStyle$)
    WritePreferenceLong("DebugWindowX",     DebugWindowX)
    WritePreferenceLong("DebugWindowY",     DebugWindowY)
    WritePreferenceLong("DebugWindowWidth", DebugWindowWidth)
    WritePreferenceLong("DebugWindowHeight",DebugWindowHeight)
    WritePreferenceLong("DebugWindowMaximize",DebugWindowMaximize)
    
    WritePreferenceLong("RegisterIsHex",    RegisterIsHex)
    WritePreferenceLong("StackIsHex",       StackIsHex)
    WritePreferenceLong("AutoStackUpdate",  AutoStackUpdate)
    WritePreferenceLong("AsmWindowX",       AsmWindowX)
    WritePreferenceLong("AsmWindowY",       AsmWindowY)
    WritePreferenceLong("AsmWindowWidth",   AsmWindowWidth)
    WritePreferenceLong("AsmWindowHeight",  AsmWindowHeight)
    WritePreferenceLong("AsmWindowMaximize",  AsmWindowMaximize)
    
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
    
    WritePreferenceLong("IsMiniDebugger",        IsMiniDebugger)
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
    WritePreferenceLong("DataBreakpointWindowMaximize",  DataBreakpointWindowMaximize)
    
    WritePreferenceLong("PurifierWindowX",             PurifierWindowX)
    WritePreferenceLong("PurifierWindowY",             PurifierWindowY)
    
    ClosePreferences()
  Else
    
    MessageRequester(#ProductName$, LanguagePattern("Misc","PreferenceError", "%filename%", PreferencesFile$), #FLAG_Error)
  EndIf
  
EndProcedure


Procedure IsPreferenceChanged()
  
  If EditorFontName$ <> PreferenceFontName$: ProcedureReturn 1: EndIf
  If EditorFontSize  <> PreferenceFontSize : ProcedureReturn 1: EndIf
  If EditorFontStyle <> PreferenceFontStyle: ProcedureReturn 1: EndIf
  
  For i = 0 To #COLOR_Last
    If Colors(i)\PrefsValue <> Colors(i)\UserValue
      ProcedureReturn 1
    ElseIf Colors(i)\Enabled <> GetGadgetState(#GADGET_Preferences_FirstColorCheck+i)
      ProcedureReturn 1
    EndIf
  Next i
  
  If OptionCustomCompiler   <> GetGadgetState(#GADGET_Preferences_CustomCompiler): ProcedureReturn 1: EndIf
  If OptionCompilerVersion$ <> GetGadgetText(#GADGET_Preferences_SelectCustomCompiler): ProcedureReturn 1: EndIf
  
  CompilerIf #SpiderBasic
    If OptionWebBrowser$ <> GetGadgetText(#GADGET_Preferences_WebBrowser): ProcedureReturn 1: EndIf
    If OptionWebServerPort <> Val(GetGadgetText(#GADGET_Preferences_WebServerPort)): ProcedureReturn 1: EndIf
    If OptionJDK$ <> GetGadgetText(#GADGET_Preferences_JDK): ProcedureReturn 1: EndIf
    If OptionAppleTeamID$ <> GetGadgetText(#GADGET_Preferences_AppleTeamID): ProcedureReturn 1: EndIf
  CompilerElse
    If OptionPurifier        <> GetGadgetState(#GADGET_Preferences_Purifier): ProcedureReturn 1: EndIf
    If OptionInlineASM       <> GetGadgetState(#GADGET_Preferences_InlineASM): ProcedureReturn 1: EndIf
    If OptionXPSkin          <> GetGadgetState(#GADGET_Preferences_XPSkin): ProcedureReturn 1: EndIf
    If OptionWayland         <> GetGadgetState(#GADGET_Preferences_Wayland): ProcedureReturn 1: EndIf
    If OptionVistaAdmin      <> GetGadgetState(#GADGET_Preferences_VistaAdmin): ProcedureReturn 1: EndIf
    If OptionVistaUser       <> GetGadgetState(#GADGET_Preferences_VistaUser): ProcedureReturn 1: EndIf
    If OptionDPIAware        <> GetGadgetState(#GADGET_Preferences_DPIAware): ProcedureReturn 1: EndIf
    If OptionDllProtection   <> GetGadgetState(#GADGET_Preferences_DllProtection): ProcedureReturn 1: EndIf
    If OptionSharedUCRT      <> GetGadgetState(#GADGET_Preferences_SharedUCRT): ProcedureReturn 1: EndIf
    If OptionThread          <> GetGadgetState(#GADGET_Preferences_Thread): ProcedureReturn 1: EndIf
    If OptionOptimizer       <> GetGadgetState(#GADGET_Preferences_Optimizer): ProcedureReturn 1: EndIf
    If OptionOnError         <> GetGadgetState(#GADGET_Preferences_OnError): ProcedureReturn 1: EndIf
    If OptionExeFormat       <> GetGadgetState(#GADGET_Preferences_ExecutableFormat): ProcedureReturn 1: EndIf
    If OptionCPU             <> GetGadgetState(#GADGET_Preferences_CPU): ProcedureReturn 1: EndIf
    If OptionUseCreateExe    <> GetGadgetState(#GADGET_Preferences_UseCreateExecutable): ProcedureReturn 1: EndIf
    If OptionTemporaryExe    <> GetGadgetState(#GADGET_Preferences_TemporaryExe): ProcedureReturn 1: EndIf
  CompilerEndIf
  
  If DebugOutputToErrorLog <> GetGadgetState(#GADGET_Preferences_DebugToLog): ProcedureReturn 1: EndIf
  ;If DebugSystemMessages   <> GetGadgetState(#GADGET_Preferences_SystemMessages): ProcedureReturn 1: EndIf
  If ToolsPanelHideDelay   <> Val(GetGadgetText(#GADGET_Preferences_ToolsPanelDelay)): ProcedureReturn 1: EndIf
  If AutoCompletePopupLength <> Val(GetGadgetText(#GADGET_Preferences_AutoPopupLength)): ProcedureReturn 1: EndIf
  If MemorizeMarkers       <> GetGadgetState(#GADGET_Preferences_MemorizeMarkers): ProcedureReturn 1: EndIf
  If ToolsPanelAutoHide    <> GetGadgetState(#GADGET_Preferences_AutoHidePanel): ProcedureReturn 1: EndIf
  ;  If AutoCompleteNoComments<> GetGadgetState(#GADGET_Preferences_NoComments): ProcedureReturn 1: EndIf
  ;  If AutoCompleteNoStrings <> GetGadgetState(#GADGET_Preferences_NoStrings): ProcedureReturn 1: EndIf
  If NoSplashScreen        <> GetGadgetState(#GADGET_Preferences_NoSplashScreen): ProcedureReturn 1: EndIf
  If DisplayFullPath       <> GetGadgetState(#GADGET_Preferences_DisplayFullPath): ProcedureReturn 1: EndIf
  If EnableAccessibility   <> GetGadgetState(#GADGET_Preferences_EnableAccessibility): ProcedureReturn 1: EndIf
  CompilerIf #CompileMac
    If DisplayDarkMode       <> GetGadgetState(#GADGET_Preferences_DisplayDarkMode): ProcedureReturn 1: EndIf
  CompilerEndIf
  If EnableMenuIcons       <> GetGadgetState(#GADGET_Preferences_EnableMenuIcons): ProcedureReturn 1: EndIf
  If AutoReload            <> GetGadgetState(#GADGET_Preferences_AutoReload): ProcedureReturn 1: EndIf
  If MemorizeWindow        <> GetGadgetState(#GADGET_Preferences_MemorizeWindow): ProcedureReturn 1: EndIf
  If CurrentLanguage$      <> GetGadgetText(#GADGET_Preferences_Languages): ProcedureReturn 1: EndIf
  ;  If EnableColoring        <> GetGadgetState(#GADGET_Preferences_EnableColoring): ProcedureReturn 1: EndIf
  If EnableCaseCorrection  <> GetGadgetState(#GADGET_Preferences_EnableCaseCorrection): ProcedureReturn 1: EndIf
  If EnableKeywordBolding  <> GetGadgetState(#GADGET_Preferences_EnableBolding): ProcedureReturn 1: EndIf
  If AutoSave              <> GetGadgetState(#GADGET_Preferences_AutoSave): ProcedureReturn 1: EndIf
  If AutoSaveAll           <> GetGadgetState(#GADGET_Preferences_AutoSaveAll): ProcedureReturn 1: EndIf
  If Editor_RunOnce        <> GetGadgetState(#GADGET_Preferences_RunOnce): ProcedureReturn 1: EndIf
  If ShowMainToolbar       <> GetGadgetState(#GADGET_Preferences_ShowMainToolbar): ProcedureReturn 1: EndIf
  If TabLength             <> Val(GetGadgetText(#GADGET_Preferences_TabLength)): ProcedureReturn 1: EndIf
  If MemorizeCursor        <> GetGadgetState(#GADGET_Preferences_MemorizeCursor): ProcedureReturn 1: EndIf
  If ToolsPanelSide        <> GetGadgetState(#GADGET_Preferences_ToolsPanelSide): ProcedureReturn 1: EndIf
  If FindHistorySize       <> Val(GetGadgetText(#GADGET_Preferences_FindHistorySize)): ProcedureReturn 1: EndIf
  If AlwaysHideLog         <> GetGadgetState(#GADGET_Preferences_AlwaysHideLog): ProcedureReturn 1: EndIf
  If OptionDebugger        <> GetGadgetState(#GADGET_Preferences_Debugger): ProcedureReturn 1: EndIf
  If OptionSubSystem$      <> GetGadgetText(#GADGET_Preferences_SubSystem): ProcedureReturn 1: EndIf
  If OptionNewLineType     <> GetGadgetState(#GADGET_Preferences_NewLineType): ProcedureReturn 1: EndIf
  If OptionEncoding        <> GetGadgetState(#GADGET_Preferences_Encoding): ProcedureReturn 1: EndIf
  If OptionUseCompileCount <> GetGadgetState(#GADGET_Preferences_UseCompileCount): ProcedureReturn 1: EndIf
  If OptionUseBuildCount   <> GetGadgetState(#GADGET_Preferences_UseBuildCount): ProcedureReturn 1: EndIf
  If SourcePath$           <> GetGadgetText(#GADGET_Preferences_SourcePath): ProcedureReturn 1: EndIf
  If FilesHistorySize      <> Val(GetGadgetText(#GADGET_Preferences_FileHistorySize)): ProcedureReturn 1: EndIf
  If EnableLineNumbers     <> GetGadgetState(#GADGET_Preferences_EnableLineNumbers): ProcedureReturn 1: EndIf
  ;  If EnableMarkers         <> GetGadgetState(#GADGET_Preferences_EnableMarkers): ProcedureReturn 1: EndIf
  If ExtraWordChars$       <> GetGadgetText(#GADGET_Preferences_ExtraWordChars) : ProcedureReturn 1 : EndIf
  If ShowWhiteSpace        <> GetGadgetState(#GADGET_Preferences_ShowWhiteSpace): ProcedureReturn 1: EndIf
  If ShowIndentGuides      <> GetGadgetState(#GADGET_Preferences_ShowIndentGuides): ProcedureReturn 1: EndIf
  If UseTabIndentForSplittedLines <> GetGadgetState(#GADGET_Preferences_UseTabIndentForSplittedLines): ProcedureReturn 1: EndIf
  If EnableBraceMatch      <> GetGadgetState(#GADGET_Preferences_EnableBraceMatch): ProcedureReturn 1: EndIf
  If EnableKeywordMatch    <> GetGadgetState(#GADGET_Preferences_EnableKeywordMatch): ProcedureReturn 1: EndIf
  If EnableFolding         <> GetGadgetState(#GADGET_Preferences_EnableFolding): ProcedureReturn 1: EndIf
  If AutoCompleteWindowWidth   <> Val(GetGadgetText(#GADGET_Preferences_BoxWidth)): ProcedureReturn 1: EndIf
  If AutoCompleteWindowHeight  <> Val(GetGadgetText(#GADGET_Preferences_BoxHeight)): ProcedureReturn 1: EndIf
  If AutoCompleteAddBrackets   <> GetGadgetState(#GADGET_Preferences_AddBrackets): ProcedureReturn 1: EndIf
  If AutoCompleteAddSpaces     <> GetGadgetState(#GADGET_Preferences_AddSpaces): ProcedureReturn 1: EndIf
  If AutoCompleteAddEndKeywords<> GetGadgetState(#GADGET_Preferences_AddEndKeywords): ProcedureReturn 1: EndIf
  If AutoPopupStructures       <> GetGadgetState(#GADGET_Preferences_StructureItems): ProcedureReturn 1: EndIf
  If AutoPopupModules          <> GetGadgetState(#GADGET_Preferences_ModulePrefix): ProcedureReturn 1: EndIf
  If RealTab                   <> GetGadgetState(#GADGET_Preferences_RealTab): ProcedureReturn 1: EndIf
  If AutoPopupNormal           <> GetGadgetState(#GADGET_Preferences_AutoPopup): ProcedureReturn 1: EndIf
  If SaveProjectSettings       <> GetGadgetState(#GADGET_Preferences_SaveProjectSettings): ProcedureReturn 1: EndIf
  If OptionErrorLog            <> GetGadgetState(#GADGET_Preferences_ErrorLog): ProcedureReturn 1: EndIf
  ;   CompilerIf #CompileMac ; OSX-debug
  ;   If DebuggerMode              <> GetGadgetState(#GADGET_Preferences_DebuggerMode)+2: ProcedureReturn 1: EndIf
  ;   CompilerElse
  If DebuggerMode              <> GetGadgetState(#GADGET_Preferences_DebuggerMode)+1: ProcedureReturn 1: EndIf
  ;   CompilerEndIf
  If WarningMode               <> GetGadgetState(#GADGET_Preferences_WarningMode): ProcedureReturn 1: EndIf
  If DebuggerMemorizeWindows   <> GetGadgetState(#GADGET_Preferences_DebuggerMemorizeWindows): ProcedureReturn 1: EndIf
  If DebuggerOnTop             <> GetGadgetState(#GADGET_Preferences_DebuggerAlwaysOnTop): ProcedureReturn 1: EndIf
  If DebuggerBringToTop        <> GetGadgetState(#GADGET_Preferences_DebuggerBringToTop): ProcedureReturn 1: EndIf
  If CallDebuggerOnStart       <> GetGadgetState(#GADGET_Preferences_DebuggerStopAtStart): ProcedureReturn 1: EndIf
  If CallDebuggerOnEnd         <> GetGadgetState(#GADGET_Preferences_DebuggerStopAtEnd): ProcedureReturn 1: EndIf
  If LogTimeStamp              <> GetGadgetState(#GADGET_Preferences_DebuggerLogTimeStamp): ProcedureReturn 1: EndIf
  If DebugTimeStamp            <> GetGadgetState(#GADGET_Preferences_DebugOutTimeStamp): ProcedureReturn 1: EndIf
  If DebuggerKeepErrorMarks    <> GetGadgetState(#GADGET_Preferences_KeepErrorMarks): ProcedureReturn 1: EndIf
  If DebuggerKillOnError       <> GetGadgetState(#GADGET_Preferences_KillOnError): ProcedureReturn 1: EndIf
  If DebugIsHex                <> GetGadgetState(#GADGET_Preferences_DebugIsHex): ProcedureReturn 1: EndIf
  If RegisterIsHex             <> GetGadgetState(#GADGET_Preferences_RegisterIsHex): ProcedureReturn 1: EndIf
  If StackIsHex                <> GetGadgetState(#GADGET_Preferences_StackIsHex): ProcedureReturn 1: EndIf
  If AutoStackUpdate           <> GetGadgetState(#GADGET_Preferences_AutoStackUpdate): ProcedureReturn 1: EndIf
  If MemoryIsHex               <> GetGadgetState(#GADGET_Preferences_MemoryIsHex): ProcedureReturn 1: EndIf
  If MemoryOneColumnOnly       <> GetGadgetState(#GADGET_Preferences_MemoryOneColumn): ProcedureReturn 1: EndIf
  If VariableIsHex             <> GetGadgetState(#GADGET_Preferences_VariableIsHex): ProcedureReturn 1: EndIf
  If AutoOpenDataBreakpoints   <> GetGadgetState(#GADGET_Preferences_DataBreakpointsOpen): ProcedureReturn 1: EndIf
  If AutoOpenDebugOutput       <> GetGadgetState(#GADGET_Preferences_DebugWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenAsmWindow         <> GetGadgetState(#GADGET_Preferences_AsmWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenMemoryViewer      <> GetGadgetState(#GADGET_Preferences_MemoryWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenVariableViewer    <> GetGadgetState(#GADGET_Preferences_VariableWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenProfiler          <> GetGadgetState(#GADGET_Preferences_ProfilerWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenHistory           <> GetGadgetState(#GADGET_Preferences_HistoryWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenWatchlist         <> GetGadgetState(#GADGET_Preferences_WatchlistWindowOpen): ProcedureReturn 1: EndIf
  If AutoOpenPurifier          <> GetGadgetState(#GADGET_Preferences_PurifierOpen): ProcedureReturn 1: EndIf
  If AutoOpenLibraryViewer     <> GetGadgetState(#GADGET_Preferences_LibraryViewerWindowOpen): ProcedureReturn 1: EndIf
  If AutoClearLog              <> GetGadgetState(#GADGET_Preferences_AutoClearLog): ProcedureReturn 1: EndIf
  If DisplayErrorWindow        <> GetGadgetState(#GADGET_Preferences_DisplayErrorWindow): ProcedureReturn 1: EndIf
  If ProfilerRunAtStart        <> GetGadgetState(#GADGET_Preferences_ProfilerStartup): ProcedureReturn 1: EndIf
  If MonitorFileChanges        <> GetGadgetState(#GADGET_Preferences_MonitorFileChanges): ProcedureReturn 1: EndIf
  If FormVariable              <> GetGadgetState(#GADGET_Preferences_FormVariable): ProcedureReturn 1: EndIf
  If FormVariableCaption       <> GetGadgetState(#GADGET_Preferences_FormVariableCaption): ProcedureReturn 1: EndIf
  If FormGrid                  <> GetGadgetState(#GADGET_Preferences_FormGrid): ProcedureReturn 1: EndIf
  If FormGridSize              <> Val(GetGadgetText(#GADGET_Preferences_FormGridSize)): ProcedureReturn 1: EndIf
  If FormEventProcedure        <> GetGadgetState(#GADGET_Preferences_FormEventProcedure): ProcedureReturn 1: EndIf
  If EnableHistory             <> GetGadgetState(#GADGET_Preferences_EnableHistory): ProcedureReturn 1: EndIf
  If HistoryTimer              <> Val(GetGadgetText(#GADGET_Preferences_HistoryTimer)): ProcedureReturn 1: EndIf
  If HistoryMaxFileSize        <> Val(GetGadgetText(#GADGET_Preferences_HistoryMaxFileSize))*1024: ProcedureReturn 1: EndIf
  If MaxSessionDays            <> Val(GetGadgetText(#GADGET_Preferences_HistoryDays)): ProcedureReturn 1: EndIf
  If MaxSessionCount           <> Val(GetGadgetText(#GADGET_Preferences_HistoryCount)): ProcedureReturn 1: EndIf
  If FilesPanelMultiline       <> GetGadgetState(#GADGET_Preferences_FilesPanelMultiline): ProcedureReturn 1: EndIf
  If FilesPanelCloseButtons    <> GetGadgetState(#GADGET_Preferences_FilesPanelCloseButtons): ProcedureReturn 1: EndIf
  If FilesPanelNewButton       <> GetGadgetState(#GADGET_Preferences_FilesPanelNewButton): ProcedureReturn 1: EndIf
  If UpdateCheckInterval       <> GetGadgetState(#GADGET_Preferences_UpdateCheckInterval): ProcedureReturn 1: EndIf
  If UpdateCheckVersions       <> GetGadgetState(#GADGET_Preferences_UpdateCheckVersions): ProcedureReturn 1: EndIf
  If CodeFileExtensions$       <> GetGadgetText(#GADGET_Preferences_CodeFileExtensions): ProcedureReturn 1: EndIf
  
  Select GetGadgetState(#GADGET_Preferences_FormSkin)
    Case 0 ; OSX
      TempFormSkin = #PB_OS_MacOS
      
    Case 1 ; Win7
      TempFormSkin = #PB_OS_Windows
      TempFormSkinVersion = 7
      
    Case 2 ; Win8
      TempFormSkin = #PB_OS_Windows
      TempFormSkinVersion = 8
      
    Case 3 ; Linux
      TempFormSkin = #PB_OS_Linux
      TempFormSkinVersion = 7
      
  EndSelect
  
  If FormSkin <> TempFormSkin: ProcedureReturn 1: EndIf
  If FormSkinVersion <> TempFormSkinVersion: ProcedureReturn 1: EndIf
  
  TempFormNotRecognized = FormVersionWarnings & #FDI_Warn_NotRecognized
  If GetGadgetState(#GADGET_Preferences_FormNotRecognized) <> TempFormNotRecognized : ProcedureReturn 1: EndIf
  TempFormDowngrade = FormVersionWarnings & #FDI_Warn_DowngradeAlways
  ; If GetGadgetState(#)
  
  If (FormVersionWarnings & #FDI_Warn_UpgradeBreaking) = #FDI_Warn_UpgradeBreaking And GetGadgetState(#GADGET_Preferences_FormUpgrade) <> 1
    ProcedureReturn 1
  EndIf
  If (FormVersionWarnings & #FDI_Warn_UpgradeAlways) = #FDI_Warn_UpgradeAlways And GetGadgetState(#GADGET_Preferences_FormUpgrade) <> 2
    ProcedureReturn 1
  EndIf
  
  If GetGadgetState(#GADGET_Preferences_HistoryPurgeNever)
    TempPurgeMode = 0
  ElseIf GetGadgetState(#GADGET_Preferences_HistoryPurgeByCount)
    TempPurgeMode = 1
  Else
    TempPurgeMode = 2
  EndIf
  
  If HistoryPurgeMode <> TempPurgeMode
    ProcedureReturn 1
  EndIf
  
  If DebugOutUseFont           <> GetGadgetState(#GADGET_Preferences_DebugOutUseFont): ProcedureReturn 1: EndIf
  If DebugOutFont$      <> PreferenceDebugOutFont$: ProcedureReturn 1: EndIf
  If DebugOutFontSize   <> PreferenceDebugOutFontSize: ProcedureReturn 1: EndIf
  If DebugOutFontStyle  <> PreferenceDebugOutFontStyle: ProcedureReturn 1: EndIf
  If Val(GetGadgetText(#GADGET_Preferences_DebuggerTimeout)) <> DebuggerTimeout: ProcedureReturn 1: EndIf
  
  For i = 0 To #ITEM_LastOption
    If GetGadgetItemState(#GADGET_Preferences_CodeOptions, i) & #PB_ListIcon_Checked
      If AutocompleteOptions(i) = 0
        ProcedureReturn 1
      EndIf
    Else
      If AutocompleteOptions(i)
        ProcedureReturn 1
      EndIf
    EndIf
  Next i
  
  For i = 0 To #PBITEM_Last
    If GetGadgetItemState(#GADGET_Preferences_PBOptions, i) & #PB_ListIcon_Checked
      If AutocompletePBOptions(i) = 0
        ProcedureReturn 1
      EndIf
    Else
      If AutocompletePBOptions(i)
        ProcedureReturn 1
      EndIf
    EndIf
  Next i
  
  If GetGadgetState(#GADGET_Preferences_SourceOnly)
    If AutoCompleteProject Or AutoCompleteAllFiles: ProcedureReturn 1: EndIf
  ElseIf GetGadgetState(#GADGET_Preferences_ProjectOnly)
    If AutoCompleteProject = 0 Or AutoCompleteAllFiles: ProcedureReturn 1: EndIf
  ElseIf GetGadgetState(#GADGET_Preferences_ProjectAllFiles)
    If AutoCompleteProject = 0 Or AutoCompleteAllFiles = 0: ProcedureReturn 1: EndIf
  Else
    If AutoCompleteProject Or AutoCompleteAllFiles = 0: ProcedureReturn 1: EndIf
  EndIf
  
  If CustomKeywordFile$ <> GetGadgetText(#GADGET_Preferences_KeywordFile): ProcedureReturn 1: EndIf
  If ListSize(CustomKeywordList()) <> CountGadgetItems(#GADGET_Preferences_KeywordList): ProcedureReturn 1: EndIf
  ForEach CustomKeywordList()
    If CustomKeywordList() <> GetGadgetItemText(#GADGET_Preferences_KeywordList, ListIndex(CustomKeywordList()), 0): ProcedureReturn 1: EndIf
  Next CustomKeywordList()
  
  If NbFoldStartWords <> CountGadgetItems(#GADGET_Preferences_FoldStartList): ProcedureReturn 1: EndIf
  For i = 1 To NbFoldStartWords
    If FoldStart$(i) <> GetGadgetItemText(#GADGET_Preferences_FoldStartList, i-1, 0): ProcedureReturn 1: EndIf
  Next i
  
  If NbFoldEndWords <> CountGadgetItems(#GADGET_Preferences_FoldEndList): ProcedureReturn 1: EndIf
  For i = 1 To NbFoldEndWords
    If FoldEnd$(i) <> GetGadgetItemText(#GADGET_Preferences_FoldEndList, i-1, 0): ProcedureReturn 1: EndIf
  Next i
  
  If BackspaceUnindent   <> GetGadgetState(#GADGET_Preferences_BackspaceUnindent): ProcedureReturn 1: EndIf
  If GetGadgetState(#GADGET_Preferences_IndentNo+IndentMode) = 0
    ; its an option, the selected gadget has state 1
    ProcedureReturn 1
  EndIf
  
  If CountGadgetItems(#GADGET_Preferences_IndentList) <> NbIndentKeywords
    ProcedureReturn 1
  EndIf
  
  For i = 0 To NbIndentKeywords-1
    If GetGadgetItemText(#GADGET_Preferences_IndentList, i, 0) <> IndentKeywords(i)\Keyword$
      ProcedureReturn 1
    EndIf
    If Val(GetGadgetItemText(#GADGET_Preferences_IndentList, i, 1)) <> IndentKeywords(i)\Before
      ProcedureReturn 1
    EndIf
    If Val(GetGadgetItemText(#GADGET_Preferences_IndentList, i, 2)) <> IndentKeywords(i)\After
      ProcedureReturn 1
    EndIf
  Next i
  
  If PrefsThemeChanged()
    ProcedureReturn 1
  EndIf
  
  For item = 0 To #MENU_LastShortcutItem
    If KeyboardShortcuts(item) <> Prefs_KeyboardShortcuts(item)
      ProcedureReturn 1
    EndIf
  Next item
  
  If ToolbarItemCount <> PreferenceToolbarCount: ProcedureReturn 1: EndIf
  For i = 1 To ToolbarItemCount
    If Toolbar(i)\Name$ <> PreferenceToolbar(i)\Name$ Or Toolbar(i)\Action$ <> PreferenceToolbar(i)\Action$
      ProcedureReturn 1
    EndIf
  Next i
  
  If ToolsPanelUseFont    <> GetGadgetState(#GADGET_Preferences_UseToolsPanelFont): ProcedureReturn 1: EndIf
  If ToolsPanelFontName$  <> PreferenceToolsPanelFont$: ProcedureReturn 1: EndIf
  If ToolsPanelFontSize   <> PreferenceToolsPanelFontSize: ProcedureReturn 1: EndIf
  If ToolsPanelFontStyle  <> PreferenceToolsPanelFontStyle: ProcedureReturn 1: EndIf
  
  ; Toolspanel cloring not working on Linux/OSX
  If ToolsPanelUseColors  <> GetGadgetState(#GADGET_Preferences_UseToolsPanelColors): ProcedureReturn 1: EndIf
  If NoIndependentToolsColors <> GetGadgetState(#GADGET_Preferences_NoIndependentToolsColors): ProcedureReturn 1: EndIf
  If ToolsPanelFrontColor <> PreferenceToolsPanelFrontColor: ProcedureReturn 1: EndIf
  If ToolsPanelBackColor  <> PreferenceToolsPanelBackColor: ProcedureReturn 1: EndIf
  
  If ListSize(UsedPanelTools()) <> ListSize(NewUsedPanelTools())
    ProcedureReturn 1
  EndIf
  
  ResetList(UsedPanelTools())
  ResetList(NewUsedPanelTools())
  While NextElement(UsedPanelTools()) And NextElement(NewUsedPanelTools()) ; both have same length (tested above)
    If UsedPanelTools() <> NewUsedPanelTools()
      ProcedureReturn 1
    EndIf
  Wend
  
  
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\NeedConfiguration
      PanelTool.ToolsPanelInterface = @AvailablePanelTools()
      If PanelTool = CurrentPreferenceTool
        IsOpen = 1
      Else
        IsOpen = 0
      EndIf
      If PanelTool\PreferenceChanged(IsOpen)
        ProcedureReturn 1
      EndIf
    EndIf
  Next AvailablePanelTools()
  
  If ListSize(Compilers()) <> ListSize(PreferenceCompilers())
    ProcedureReturn 1
  Else
    match = 0
    ForEach Compilers()
      ForEach PreferenceCompilers()
        If IsEqualFile(Compilers()\Executable$, PreferenceCompilers()\Executable$)
          match + 1
          ; no break. we want to see if every element has exactly one match
        EndIf
      Next PreferenceCompilers()
    Next Compilers()
    
    If match <> ListSize(Compilers())
      ProcedureReturn 1
    EndIf
  EndIf
  
  If ListSize(Issues()) <> ListSize(PreferenceIssues())
    ProcedureReturn 1
  Else
    ; compare with order (there is no way to re-order the defined issues anyway)
    ResetList(Issues())
    ResetList(PreferenceIssues())
    While NextElement(Issues()) And NextElement(PreferenceIssues())
      If Issues()\Name$ <> PreferenceIssues()\Name$ Or
         Issues()\Expression$ <> PreferenceIssues()\Expression$ Or
         Issues()\Priority <> PreferenceIssues()\Priority Or
         Issues()\Color <> PreferenceIssues()\Color Or
         Issues()\CodeMode <> PreferenceIssues()\CodeMode Or
         Issues()\InTool <> PreferenceIssues()\InTool Or
         Issues()\InBrowser <> PreferenceIssues()\InBrowser
        
        ProcedureReturn 1
      EndIf
    Wend
  EndIf
  
  ProcedureReturn 0
EndProcedure

Procedure ApplyPreferences()
  
  If IsPreferenceChanged() = 0 Or IsApplyPreferences ; Ensures there is not a recursive call as we are processing event in the apply
    ProcedureReturn
  EndIf
  
  IsApplyPreferences = #True
  
  StartFlickerFix(#WINDOW_Main)
  
  ; make sure unused entries in the Arrays are empty.. in case the max values get changed
  ;
  For i = FilesHistorySize + 1 To #MAX_RecentFiles
    RecentFiles(i) = ""
    RecentFiles(#MAX_RecentFiles+i) = "" ; recent projects
  Next i
  
  For i = FindHistorySize + 1 To #MAX_FindHistory
    FindSearchHistory(i) = ""
    FindReplaceHistory(i) = ""
    GrepFindHistory(i) = ""
    GrepDirectoryHistory(i) = ""
    GrepExtensionHistory(i) = ""
    For j = 0 To 4
      DiffDialogHistory(j, i) = ""
    Next j
  Next i
  
  ; read values from the Gadgets
  ;
  EditorFontName$ = PreferenceFontName$
  EditorFontSize  = PreferenceFontSize
  EditorFontStyle = PreferenceFontStyle
  
  For i = 0 To #COLOR_Last
    Colors(i)\UserValue = Colors(i)\PrefsValue
    Colors(i)\Enabled   = GetGadgetState(#GADGET_Preferences_FirstColorCheck+i)
  Next i
  
  DebugOutputToErrorLog = GetGadgetState(#GADGET_Preferences_DebugToLog)
  ;DebugSystemMessages   = GetGadgetState(#GADGET_Preferences_SystemMessages)
  ToolsPanelHideDelay   = Val(GetGadgetText(#GADGET_Preferences_ToolsPanelDelay))
  AutoCompletePopupLength = Val(GetGadgetText(#GADGET_Preferences_AutoPopupLength))
  MemorizeMarkers       = GetGadgetState(#GADGET_Preferences_MemorizeMarkers)
  ToolsPanelAutoHide    = GetGadgetState(#GADGET_Preferences_AutoHidePanel)
  ;  AutoCompleteNoComments= GetGadgetState(#GADGET_Preferences_NoComments)
  ;  AutoCompleteNoStrings = GetGadgetState(#GADGET_Preferences_NoStrings)
  NoSplashScreen        = GetGadgetState(#GADGET_Preferences_NoSplashScreen)
  DisplayFullPath       = GetGadgetState(#GADGET_Preferences_DisplayFullPath)
  EnableAccessibility   = GetGadgetState(#GADGET_Preferences_EnableAccessibility)
  CompilerIf #CompileMac
    DisplayDarkMode       = GetGadgetState(#GADGET_Preferences_DisplayDarkMode)
  CompilerEndIf
  EnableMenuIcons       = GetGadgetState(#GADGET_Preferences_EnableMenuIcons)
  AutoReload            = GetGadgetState(#GADGET_Preferences_AutoReload)
  MemorizeWindow        = GetGadgetState(#GADGET_Preferences_MemorizeWindow)
  ;  EnableColoring        = GetGadgetState(#GADGET_Preferences_EnableColoring)
  EnableCaseCorrection  = GetGadgetState(#GADGET_Preferences_EnableCaseCorrection)
  EnableKeywordBolding  = GetGadgetState(#GADGET_Preferences_EnableBolding)
  AutoSave              = GetGadgetState(#GADGET_Preferences_AutoSave)
  AutoSaveAll           = GetGadgetState(#GADGET_Preferences_AutoSaveAll)
  Editor_RunOnce        = GetGadgetState(#GADGET_Preferences_RunOnce)
  ShowMainToolbar       = GetGadgetState(#GADGET_Preferences_ShowMainToolbar)
  TabLength             = Val(GetGadgetText(#GADGET_Preferences_TabLength))
  MemorizeCursor        = GetGadgetState(#GADGET_Preferences_MemorizeCursor)
  ToolsPanelSide        = GetGadgetState(#GADGET_Preferences_ToolsPanelSide)
  FindHistorySize       = Val(GetGadgetText(#GADGET_Preferences_FindHistorySize))
  AlwaysHideLog         = GetGadgetState(#GADGET_Preferences_AlwaysHideLog)
  OptionCustomCompiler  = GetGadgetState(#GADGET_Preferences_CustomCompiler)
  OptionCompilerVersion$= GetGadgetText(#GADGET_Preferences_SelectCustomCompiler)
  CompilerIf #SpiderBasic
    OptionWebBrowser$   = GetGadgetText(#GADGET_Preferences_WebBrowser)
    OptionWebServerPort = Val(GetGadgetText(#GADGET_Preferences_WebServerPort))
    OptionJDK$          = GetGadgetText(#GADGET_Preferences_JDK)
    OptionAppleTeamID$  = GetGadgetText(#GADGET_Preferences_AppleTeamID)
  CompilerElse
    OptionPurifier        = GetGadgetState(#GADGET_Preferences_Purifier)
    OptionInlineASM       = GetGadgetState(#GADGET_Preferences_InlineASM)
    OptionXPSkin          = GetGadgetState(#GADGET_Preferences_XPSkin)
    OptionWayland         = GetGadgetState(#GADGET_Preferences_Wayland)
    OptionVistaAdmin      = GetGadgetState(#GADGET_Preferences_VistaAdmin)
    OptionVistaUser       = GetGadgetState(#GADGET_Preferences_VistaUser)
    OptionDPIAware        = GetGadgetState(#GADGET_Preferences_DPIAware)
    OptionDllProtection   = GetGadgetState(#GADGET_Preferences_DllProtection)
    OptionSharedUCRT      = GetGadgetState(#GADGET_Preferences_SharedUCRT)
    OptionThread          = GetGadgetState(#GADGET_Preferences_Thread)
    OptionOptimizer       = GetGadgetState(#GADGET_Preferences_Optimizer)
    OptionOnError         = GetGadgetState(#GADGET_Preferences_OnError)
    OptionExeFormat       = GetGadgetState(#GADGET_Preferences_ExecutableFormat)
    OptionCPU             = GetGadgetState(#GADGET_Preferences_CPU)
    OptionUseCreateExe    = GetGadgetState(#GADGET_Preferences_UseCreateExecutable)
    OptionTemporaryExe    = GetGadgetState(#GADGET_Preferences_TemporaryExe)
  CompilerEndIf
  OptionDebugger        = GetGadgetState(#GADGET_Preferences_Debugger)
  OptionSubSystem$      = GetGadgetText(#GADGET_Preferences_SubSystem)
  OptionNewLineType     = GetGadgetState(#GADGET_Preferences_NewLineType)
  OptionEncoding        = GetGadgetState(#GADGET_Preferences_Encoding)
  OptionUseCompileCount = GetGadgetState(#GADGET_Preferences_UseCompileCount)
  OptionUseBuildCount   = GetGadgetState(#GADGET_Preferences_UseBuildCount)
  SourcePath$           = GetGadgetText(#GADGET_Preferences_SourcePath)
  FilesHistorySize      = Val(GetGadgetText(#GADGET_Preferences_FileHistorySize))
  EnableLineNumbers     = GetGadgetState(#GADGET_Preferences_EnableLineNumbers)
  ;  EnableMarkers         = GetGadgetState(#GADGET_Preferences_EnableMarkers)
  ExtraWordChars$       = GetGadgetText(#GADGET_Preferences_ExtraWordChars)
  ShowWhiteSpace        = GetGadgetState(#GADGET_Preferences_ShowWhiteSpace)
  ShowIndentGuides      = GetGadgetState(#GADGET_Preferences_ShowIndentGuides)
  UseTabIndentForSplittedLines = GetGadgetState(#GADGET_Preferences_UseTabIndentForSplittedLines)
  EnableBraceMatch      = GetGadgetState(#GADGET_Preferences_EnableBraceMatch)
  EnableKeywordMatch    = GetGadgetState(#GADGET_Preferences_EnableKeywordMatch)
  EnableFolding         = GetGadgetState(#GADGET_Preferences_EnableFolding)
  AutoCompleteWindowWidth   = Val(GetGadgetText(#GADGET_Preferences_BoxWidth))
  AutoCompleteWindowHeight  = Val(GetGadgetText(#GADGET_Preferences_BoxHeight))
  AutoCompleteAddBrackets   = GetGadgetState(#GADGET_Preferences_AddBrackets)
  AutoCompleteAddSpaces     = GetGadgetState(#GADGET_Preferences_AddSpaces)
  AutoCompleteAddEndKeywords= GetGadgetState(#GADGET_Preferences_AddEndKeywords)
  AutoPopupStructures       = GetGadgetState(#GADGET_Preferences_StructureItems)
  AutoPopupModules          = GetGadgetState(#GADGET_Preferences_ModulePrefix)
  RealTab                   = GetGadgetState(#GADGET_Preferences_RealTab)
  AutoPopupNormal           = GetGadgetState(#GADGET_Preferences_AutoPopup)
  SaveProjectSettings       = GetGadgetState(#GADGET_Preferences_SaveProjectSettings)
  OptionErrorLog            = GetGadgetState(#GADGET_Preferences_ErrorLog)
  DebuggerMode              = GetGadgetState(#GADGET_Preferences_DebuggerMode)+1
  ;   CompilerIf #CompileMac ; OSX-debug
  ;     DebuggerMode+1
  ;   CompilerEndIf
  WarningMode               = GetGadgetState(#GADGET_Preferences_WarningMode)
  DebuggerMemorizeWindows   = GetGadgetState(#GADGET_Preferences_DebuggerMemorizeWindows)
  DebuggerOnTop             = GetGadgetState(#GADGET_Preferences_DebuggerAlwaysOnTop)
  DebuggerBringToTop        = GetGadgetState(#GADGET_Preferences_DebuggerBringToTop)
  CallDebuggerOnStart       = GetGadgetState(#GADGET_Preferences_DebuggerStopAtStart)
  CallDebuggerOnEnd         = GetGadgetState(#GADGET_Preferences_DebuggerStopAtEnd)
  LogTimeStamp              = GetGadgetState(#GADGET_Preferences_DebuggerLogTimeStamp)
  DebugTimeStamp            = GetGadgetState(#GADGET_Preferences_DebugOutTimeStamp)
  DebuggerKeepErrorMarks    = GetGadgetState(#GADGET_Preferences_KeepErrorMarks)
  DebuggerKillOnError       = GetGadgetState(#GADGET_Preferences_KillOnError)
  DebugIsHex                = GetGadgetState(#GADGET_Preferences_DebugIsHex)
  RegisterIsHex             = GetGadgetState(#GADGET_Preferences_RegisterIsHex)
  StackIsHex                = GetGadgetState(#GADGET_Preferences_StackIsHex)
  AutoStackUpdate           = GetGadgetState(#GADGET_Preferences_AutoStackUpdate)
  MemoryIsHex               = GetGadgetState(#GADGET_Preferences_MemoryIsHex)
  MemoryOneColumnOnly       = GetGadgetState(#GADGET_Preferences_MemoryOneColumn)
  VariableIsHex             = GetGadgetState(#GADGET_Preferences_VariableIsHex)
  AutoOpenDataBreakpoints   = GetGadgetState(#GADGET_Preferences_DataBreakpointsOpen)
  AutoOpenDebugOutput       = GetGadgetState(#GADGET_Preferences_DebugWindowOpen)
  AutoOpenAsmWindow         = GetGadgetState(#GADGET_Preferences_AsmWindowOpen)
  AutoOpenMemoryViewer      = GetGadgetState(#GADGET_Preferences_MemoryWindowOpen)
  AutoOpenVariableViewer    = GetGadgetState(#GADGET_Preferences_VariableWindowOpen)
  AutoOpenProfiler          = GetGadgetState(#GADGET_Preferences_ProfilerWindowOpen)
  AutoOpenHistory           = GetGadgetState(#GADGET_Preferences_HistoryWindowOpen)
  AutoOpenWatchlist         = GetGadgetState(#GADGET_Preferences_WatchlistWindowOpen)
  AutoOpenPurifier          = GetGadgetState(#GADGET_Preferences_PurifierOpen)
  AutoOpenLibraryViewer     = GetGadgetState(#GADGET_Preferences_LibraryViewerWindowOpen)
  AutoClearLog              = GetGadgetState(#GADGET_Preferences_AutoClearLog)
  DisplayErrorWindow        = GetGadgetState(#GADGET_Preferences_DisplayErrorWindow)
  ProfilerRunAtStart        = GetGadgetState(#GADGET_Preferences_ProfilerStartup)
  MonitorFileChanges        = GetGadgetState(#GADGET_Preferences_MonitorFileChanges)
  FormVariable              = GetGadgetState(#GADGET_Preferences_FormVariable)
  FormVariableCaption       = GetGadgetState(#GADGET_Preferences_FormVariableCaption)
  FormGrid                  = GetGadgetState(#GADGET_Preferences_FormGrid)
  FormGridSize              = Val(GetGadgetText(#GADGET_Preferences_FormGridSize))
  FormEventProcedure        = GetGadgetState(#GADGET_Preferences_FormEventProcedure)
  FormEventProcedure        = GetGadgetState(#GADGET_Preferences_FormEventProcedure)
  FilesPanelMultiline       = GetGadgetState(#GADGET_Preferences_FilesPanelMultiline)
  FilesPanelCloseButtons    = GetGadgetState(#GADGET_Preferences_FilesPanelCloseButtons)
  FilesPanelNewButton       = GetGadgetState(#GADGET_Preferences_FilesPanelNewButton)
  UpdateCheckInterval       = GetGadgetState(#GADGET_Preferences_UpdateCheckInterval)
  UpdateCheckVersions       = GetGadgetState(#GADGET_Preferences_UpdateCheckVersions)
  CodeFileExtensions$       = GetGadgetText(#GADGET_Preferences_CodeFileExtensions)
  
  ; free old issue data, copy prefs back and then init it again
  ClearIssueList()
  CopyList(PreferenceIssues(), Issues())
  InitIssueList()
  
  Select GetGadgetState(#GADGET_Preferences_FormSkin)
    Case 0 ; OSX
      FormSkin = #PB_OS_MacOS
      
    Case 1 ; Win7
      FormSkin = #PB_OS_Windows
      FormSkinVersion = 7
      
    Case 2 ; Win8
      FormSkin = #PB_OS_Windows
      FormSkinVersion = 8
      
    Case 3 ; Linux
      FormSkin = #PB_OS_Linux
  EndSelect
  
  CallDebugger
  Debug GetGadgetState(#GADGET_Preferences_FormNotRecognized)
  Select GetGadgetState(#GADGET_Preferences_FormNotRecognized)
    Case 0
      FormVersionWarnings & ~#FDI_Warn_NotRecognized
    Case 1
      FormVersionWarnings | #FDI_Warn_NotRecognized
  EndSelect
  
  Debug GetGadgetState(#GADGET_Preferences_FormDowngrade)
  Select GetGadgetState(#GADGET_Preferences_FormDowngrade)
    Case 0
      FormVersionWarnings & ~#FDI_Warn_DowngradeAlways 
    Case 1
      FormVersionWarnings | #FDI_Warn_DowngradeAlways
  EndSelect
  
  Debug GetGadgetState(#GADGET_Preferences_FormUpgrade)
  Select GetGadgetState(#GADGET_Preferences_FormUpgrade)
    Case 0
      FormVersionWarnings & ~#FDI_Warn_UpgradeBreaking 
      FormVersionWarnings & ~#FDI_Warn_UpgradeAlways
    Case 1
      FormVersionWarnings | #FDI_Warn_UpgradeBreaking
      FormVersionWarnings & ~#FDI_Warn_UpgradeAlways
    Case 2
      FormVersionWarnings & ~#FDI_Warn_UpgradeBreaking
      FormVersionWarnings | #FDI_Warn_UpgradeAlways
  EndSelect
  
  ; Reload specific form skin variables and fonts
  InitVars()
  
  ; Note: EnableHistory needs a restart to take effect
  EnableHistory = GetGadgetState(#GADGET_Preferences_EnableHistory)
  
  HistoryTimer = Val(GetGadgetText(#GADGET_Preferences_HistoryTimer))
  If HistoryTimer < 1
    HistoryTimer = 1
  ElseIf HistoryTimer > 24*60
    HistoryTimer = 24*60
  EndIf
  
  If HistoryActive
    ; update the timer interval
    RemoveWindowTimer(#WINDOW_Main, #TIMER_History)
    AddWindowTimer(#WINDOW_Main, #TIMER_History, HistoryTimer * 60000) ; value is in minutes
  EndIf
  
  HistoryMaxFileSize = Val(GetGadgetText(#GADGET_Preferences_HistoryMaxFileSize))*1024
  If HistoryMaxFileSize < 1024
    HistoryMaxFileSize = 1024
  ElseIf HistoryMaxFileSize > 100*1024*1024 ; 100 mb
    HistoryMaxFileSize = 100*1024*1024
  EndIf
  
  MaxSessionDays = Val(GetGadgetText(#GADGET_Preferences_HistoryDays))
  If MaxSessionDays < 1
    MaxSessionDays = 1
  EndIf
  
  MaxSessionCount = Val(GetGadgetText(#GADGET_Preferences_HistoryCount))
  If MaxSessionCount < 1
    MaxSessionCount = 1
  EndIf
  
  If GetGadgetState(#GADGET_Preferences_HistoryPurgeNever)
    HistoryPurgeMode = 0
  ElseIf GetGadgetState(#GADGET_Preferences_HistoryPurgeByCount)
    HistoryPurgeMode = 1
  Else
    HistoryPurgeMode = 2
  EndIf
  
  DebuggerTimeout = Val(GetGadgetText(#GADGET_Preferences_DebuggerTimeout))
  If DebuggerTimeout < 100
    DebuggerTimeout = 100
  ElseIf DebuggerTimeout > 3600000
    DebuggerTimeout = 3600000
  EndIf
  
  ; to know if we need to restart the compiler (for language change)
  OldLanguage$     = CurrentLanguage$
  CurrentLanguage$ = GetGadgetText(#GADGET_Preferences_Languages)
  
  For i = 0 To #ITEM_LastOption
    If GetGadgetItemState(#GADGET_Preferences_CodeOptions, i) & #PB_ListIcon_Checked
      AutocompleteOptions(i) = 1
    Else
      AutocompleteOptions(i) = 0
    EndIf
  Next i
  
  For i = 0 To #PBITEM_Last
    If GetGadgetItemState(#GADGET_Preferences_PBOptions, i) & #PB_ListIcon_Checked
      AutocompletePBOptions(i) = 1
    Else
      AutocompletePBOptions(i) = 0
    EndIf
  Next i
  
  If GetGadgetState(#GADGET_Preferences_SourceOnly)
    AutoCompleteProject  = 0
    AutoCompleteAllFiles = 0
  ElseIf GetGadgetState(#GADGET_Preferences_ProjectOnly)
    AutoCompleteProject  = 1
    AutoCompleteAllFiles = 0
  ElseIf GetGadgetState(#GADGET_Preferences_ProjectAllFiles)
    AutoCompleteProject  = 1
    AutoCompleteAllFiles = 1
  Else
    AutoCompleteProject  = 0
    AutoCompleteAllFiles = 1
  EndIf
  
  ; read coloring options and build the VTs (VT will be empty if option disabled)
  ;
  CustomKeywordFile$ = GetGadgetText(#GADGET_Preferences_KeywordFile)
  
  ClearList(CustomKeywordList())
  For i = 0 To CountGadgetItems(#GADGET_Preferences_KeywordList)-1
    AddElement(CustomKeywordList())
    CustomKeywordList() = GetGadgetItemText(#GADGET_Preferences_KeywordList, i, 0)
  Next i
  SortList(CustomKeywordList(), 2)
  BuildCustomKeywordTable()
  
  ; read folding options and update the VTs
  ;
  NbFoldStartWords = CountGadgetItems(#GADGET_Preferences_FoldStartList)
  For i = 1 To NbFoldStartWords
    FoldStart$(i) = GetGadgetItemText(#GADGET_Preferences_FoldStartList, i-1, 0)
  Next i
  
  NbFoldEndWords = CountGadgetItems(#GADGET_Preferences_FoldEndList)
  For i = 1 To NbFoldEndWords
    FoldEnd$(i) = GetGadgetItemText(#GADGET_Preferences_FoldEndList, i-1, 0)
  Next i
  BuildFoldingVT()
  
  ; BuildFoldingVT() sorts the Arrays, so update the Gadget content so IsPreferenceChanged()
  ; will check this correctly for the 'apply' button state
  ;
  ClearGadgetItems(#GADGET_Preferences_FoldStartList)
  For i = 1 To NbFoldStartWords
    AddGadgetItem(#GADGET_Preferences_FoldStartList, -1, FoldStart$(i))
  Next i
  
  ClearGadgetItems(#GADGET_Preferences_FoldEndList)
  For i = 1 To NbFoldEndWords
    AddGadgetItem(#GADGET_Preferences_FoldEndList, -1, FoldEnd$(i))
  Next i
  
  ; Indentation
  ;
  BackspaceUnindent = GetGadgetState(#GADGET_Preferences_BackspaceUnindent)
  
  If GetGadgetState(#GADGET_Preferences_IndentNo)
    IndentMode = #INDENT_None
  ElseIf GetGadgetState(#GADGET_Preferences_IndentBlock)
    IndentMode = #INDENT_Block
  Else
    IndentMode = #INDENT_Sensitive
  EndIf
  
  NbIndentKeywords = CountGadgetItems(#GADGET_Preferences_IndentList)
  Dim IndentKeywords.IndentEntry(NbIndentKeywords)
  
  For i = 0 To NbIndentKeywords-1
    IndentKeywords(i)\Keyword$ = Trim(GetGadgetItemText(#GADGET_Preferences_IndentList, i, 0))
    IndentKeywords(i)\Before   = Val(Trim(GetGadgetItemText(#GADGET_Preferences_IndentList, i, 1)))
    IndentKeywords(i)\After    = Val(Trim(GetGadgetItemText(#GADGET_Preferences_IndentList, i, 2)))
  Next i
  
  ; Rebuild the VT. This changes the order of elements (sort), so update the gadget content
  ; So the next IsPreferenceChanged() will return false
  ;
  BuildIndentVT()
  
  For i = 0 To NbIndentKeywords-1
    SetGadgetItemText(#GADGET_Preferences_IndentList, i, IndentKeywords(i)\Keyword$, 0)
    SetGadgetItemText(#GADGET_Preferences_IndentList, i, Str(IndentKeywords(i)\Before), 1)
    SetGadgetItemText(#GADGET_Preferences_IndentList, i, Str(IndentKeywords(i)\After), 2)
  Next i
  SetGadgetText(#GADGET_Preferences_IndentKeyword, "")
  SetGadgetText(#GADGET_Preferences_IndentBefore, "")
  SetGadgetText(#GADGET_Preferences_IndentAfter, "")
  SetGadgetState(#GADGET_Preferences_IndentList, -1)
  
  ; Toolspanel colors
  ;
  ToolsPanelUseFont    = GetGadgetState(#GADGET_Preferences_UseToolsPanelFont)
  ToolsPanelFontName$  = PreferenceToolsPanelFont$
  ToolsPanelFontSize   = PreferenceToolsPanelFontSize
  ToolsPanelFontStyle  = PreferenceToolsPanelFontStyle
  
  ToolsPanelUseColors  = GetGadgetState(#GADGET_Preferences_UseToolsPanelColors)
  NoIndependentToolsColors  = GetGadgetState(#GADGET_Preferences_NoIndependentToolsColors)
  ToolsPanelFrontColor = PreferenceToolsPanelFrontColor
  ToolsPanelBackColor  = PreferenceToolsPanelBackColor
  
  If PreferenceToolsPanelFont$ = "" Or ToolsPanelUseFont = 0
    ToolsPanelFontID = #PB_Default
  Else
    ToolsPanelFontID = LoadFont(#FONT_ToolsPanel, PreferenceToolsPanelFont$, PreferenceToolsPanelFontSize, PreferenceToolsPanelFontStyle)
  EndIf
  
  DebugOutUseFont    = GetGadgetState(#GADGET_Preferences_DebugOutUseFont)
  DebugOutFont$      = PreferenceDebugOutFont$
  DebugOutFontSize   = PreferenceDebugOutFontSize
  DebugOutFontStyle  = PreferenceDebugOutFontStyle
  
  If PreferenceDebugOutFont$ = "" Or DebugOutUseFont = 0
    DebugOutFontID = #PB_Default
  Else
    DebugOutFontID = LoadFont(#FONT_DebugOut, DebugOutFont$, DebugOutFontSize, DebugOutFontStyle)
  EndIf
  
  ; destroy/recreate the current ToolsPanel settings (if any) to make it update it's values
  ;
  If CurrentPreferenceTool
    CurrentPreferenceTool\PreferenceDestroy()
    FreeGadget(#GADGET_Preferences_ToolSettingsScrollArea)
    
    OpenGadgetList(#GADGET_Preferences_ToolSettingsContainer)
    ScrollAreaGadget(#GADGET_Preferences_ToolSettingsScrollArea, 0, 0, GadgetWidth(#GADGET_Preferences_ToolSettingsContainer), GadgetHeight(#GADGET_Preferences_ToolSettingsContainer), *CurrentPreferenceToolData\PreferencesWidth, *CurrentPreferenceToolData\PreferencesHeight, 10, #PB_ScrollArea_Single)
    CurrentPreferenceTool\PreferenceCreate()
    CloseGadgetList()
    CloseGadgetList()
  EndIf
  
  ; now tell all Tools to apply their settings
  ;
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\NeedConfiguration
      PanelTool.ToolsPanelInterface = @AvailablePanelTools()
      PanelTool\PreferenceApply()
    EndIf
  Next AvailablePanelTools()
  
  ; filter out wrong values
  ;
  If Right(SourcePath$, 1) <> #Separator And SourcePath$ <> ""
    SourcePath$ + #Separator
  EndIf
  
  If TabLength <= 0
    TabLength = 1
  EndIf
  
  If FindHistorySize <= 0
    FindHistorySize = 1
  ElseIf FindHistorySize > #MAX_FindHistory
    FindHistorySize = #MAX_FindHistory
  EndIf
  
  If FilesHistorySize < 0
    FilesHistorySize = 0
  ElseIf FilesHistorySize > #MAX_RecentFiles
    FilesHistorySize = #MAX_RecentFiles
  EndIf
  
  If AutoCompletePopupLength < 1
    AutoCompletePopupLength = 1
  EndIf
  
  If ToolsPanelHideDelay < 0
    ToolsPanelHideDelay = 0
  EndIf
  
  ; apply file monitor changes
  SetupFileMonitor()
  
  ApplyPrefsTheme()
  
  ; Disable some color gadgets for special color schemes
  DisableSelectionColorGadgets(FindCurrentColorScheme())
  
  ; Update Scintilla word chars
  ApplyWordChars()
  
  ; remove the old shortcuts from all debugger windows
  Debugger_RemoveExtraShortcuts()
  
  ; apply the shortcut settings
  ;
  For item = 0 To #MENU_LastShortcutItem
    KeyboardShortcuts(item) = Prefs_KeyboardShortcuts(item)
  Next item
  
  ; Load the new stuff
  ;
  LoadLanguage()
  LoadEditorFonts()
  
  ; updating of the main window must be before the hilighning
  ;
  UpdateMainWindow()
  
  ; update the menus
  ;
  RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_All)
  
  CompilerIf #CompileWindows | #CompileMac | #CompileLinuxQt ; re-add the shortcuts for tab/enter
    AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return, #MENU_Scintilla_Enter)
    AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab, #MENU_Scintilla_Tab)
    AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab, #MENU_Scintilla_ShiftTab)
  CompilerEndIf
  
  CreateIDEMenu()
  CreateIDEPopupMenu()
  CreateKeyboardShortcuts(#WINDOW_Main)
  
  ; update shortcuts on the autocomplete window
  ;
  If AutoCompleteWindowReady
    RemoveKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_All)
    
    ; Now added automatically below as they can be customized too
    ;     AddKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_Escape, #MENU_AutoComplete_Abort)
    ;     AddKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_Return, #MENU_AutoComplete_Ok)
    ;     AddKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_Tab, #MENU_AutoComplete_Ok)
    
    ; put all main window shortcuts here too.
    CreateKeyboardShortcuts(#WINDOW_AutoComplete)
  EndIf
  
  
  ; Windows only:
  ; Adds the debugger commands to the Systemmenu, making them accessible by rightclicking
  ; on the TaskbarButton too
  ;
  CompilerIf #CompileWindows
    CreateSYSTEMMenu()
  CompilerEndIf
  
  
  ; update the toolbar
  ;
  FreeIDEToolbar()
  ToolbarItemCount = PreferenceToolbarCount
  For i = 1 To ToolbarItemCount
    Toolbar(i)\Name$ = PreferenceToolbar(i)\Name$
    Toolbar(i)\Action$ = PreferenceToolbar(i)\Action$
  Next i
  CreateIDEToolBar()
  
  ; Update additional compiler list
  ;
  ClearList(Compilers())
  ForEach PreferenceCompilers()
    AddElement(Compilers())
    Compilers() = PreferenceCompilers() ; structure copy
  Next PreferenceCompilers()
  SortCompilers()
  
  ; calc which colors are actually used for display
  CalculateHighlightingColors()
  
  ; update all syntax highlighthing
  ;
  *Source = *ActiveSource
  ForEach FileList()
    If @FileList() <> *ProjectInfo
      *ActiveSource = @FileList()
      
      FullSourceScan(@FileList())                     ; re-scan autocomplete + procedurebrowser
      SortParserData(@FileList()\Parser, @FileList()) ; update sorted data in case its not the active source
      UpdateFolding(@FileList(), 0, -1)               ; redo all folding
      
      If EnableColoring
        SetUpHighlightingColors() ; needed for every gadget individually now (scintilla)
        SetBackgroundColor()
        SetLineNumberColor()
        UpdateHighlighting()   ; highlight everything after a prefs update
      Else
        RemoveAllColoring()
      EndIf
      
      ; refresh icon of project info (if present)
      If @FileList() = *ProjectInfo
        SetTabBarGadgetItemImage(#GADGET_FilesPanel, ListIndex(FileList()), OptionalImageID(#IMAGE_FilePanel_Project))
      EndIf
      
      ; check for a change in IsCode status (due to changed file extensions for code files
      If FileList()\FileName$ <> "" And FileList()\IsCode <> IsCodeFile(FileList()\FileName$)
        FileList()\IsCode = IsCodeFile(FileList()\FileName$)
        UpdateIsCodeStatus()
      EndIf
    EndIf
  Next FileList()
  
  ChangeCurrentElement(FileList(), *Source)
  *ActiveSource = *Source
  
  ; Re-scan all non-loaded project files for changed options
  ;
  If IsProject
    ForEach ProjectFiles()
      If ProjectFiles()\Source = 0 And ProjectFiles()\AutoScan ; not currently loaded, but scanning
        ScanFile(ProjectFiles()\FileName$, @ProjectFiles()\Parser)
      EndIf
    Next ProjectFiles()
  EndIf
  
  UpdateProcedureList() ; update list for current source
  UpdateVariableViewer()
  UpdateProjectPanel()
  
  UpdateSelectionRepeat()
  
  UpdateToolbarView()
  RunOnce_UpdateSetting()
  
  UpdateProjectInfoPreferences()
  
  UpdateMenuStates()
  SetDebuggerMenuStates()
  
  ; now update all open windows
  ;
  If IsWindow(#WINDOW_About)
    AboutWindowDialog\LanguageUpdate()
    AboutWindowDialog\GuiUpdate()
  EndIf
  
  If IsWindow(#WINDOW_AddTools)
    AddToolsWindowDialog\LanguageUpdate()
    AddToolsWindowDialog\GuiUpdate()
  EndIf
  
  If IsWindow(#WINDOW_EditTools)
    UpdateEditToolsWindow()
  EndIf
  
  If IsWindow(#WINDOW_Option)
    UpdateOptionWindow()
  EndIf
  
  If IsWindow(#WINDOW_Build)
    UpdateBuildWindow()
  EndIf
  
  If IsWindow(#WINDOW_ProjectOptions)
    UpdateProjectOptionsWindow()
  EndIf
  
  If IsWindow(#WINDOW_Grep)
    UpdateGrepWindow()
  EndIf
  
  If IsWindow(#WINDOW_GrepOutput)
    GrepOutputDialog\LanguageUpdate()
    GrepOutputDialog\GuiUpdate()
  EndIf
  
  If IsWindow(#WINDOW_Find)
    UpdateFindWindow()
  EndIf
  
  If IsWindow(#WINDOW_FileViewer)
    UpdateFileViewerWindow()
  EndIf
  
  If IsWindow(#WINDOW_Goto)
    GotoWindowDialog\LanguageUpdate()
    GotoWindowDialog\GuiUpdate()
  EndIf
  
  If IsWindow(#WINDOW_StructureViewer)
    StructureViewerDialog\LanguageUpdate()
    StructureViewerDialog\GuiUpdate()
  EndIf
  
  ;   If IsWindow(#WINDOW_CPUMonitor)
  ;     UpdateCPUMonitorWindow()
  ;   EndIf
  
  If IsWindow(#WINDOW_Template)
    UpdateTemplateWindow()
  EndIf
  
  If IsWindow(#WINDOW_MacroError)
    UpdateMacroErrorWindow()
  EndIf
  
  If IsWindow(#WINDOW_Warnings)
    UpdateWarningWindow()
  EndIf
  
  If IsWindow(#WINDOW_Diff)
    UpdateDiffWindow()
  EndIf
  
  If IsWindow(#WINDOW_DiffDialog)
    UpdateDiffDialogWindow()
  EndIf
  
  If IsWindow(#WINDOW_FileMonitor)
    FileMonitorWindowEvents(#PB_Event_CloseWindow) ; just close this, no updating
  EndIf
  
  If IsWindow(#WINDOW_EditHistory)
    UpdateEditHistoryWindow()
  EndIf
  
  If IsWindow(#WINDOW_Updates)
    UpdateWindowEvents(#PB_Event_CloseWindow) ; just close this, no updating
  EndIf
  
  CompilerIf #CompileLinux | #CompileMac
    If IsWindow(#WINDOW_Help)
      UpdateHelpWindow()
    EndIf
  CompilerEndIf
  
  ; update all debugger windows
  ;
  Debugger_UpdateWindowPreferences()
  
  ; add the extra ide shortcuts to the ide windows again
  Debugger_AddExtraShortcuts()
  
  
  ; UpdatePreferenceWindow() is only called when 'Apply' is clicked, otherwise the window is closed anyway
  
  ; finally, save the preferences to file
  ;
  SavePreferences()
  
  StopFlickerFix(#WINDOW_Main, 1)
  
  ; We changed the Compilers() linked list, so go back to the default
  ; compiler as this one is always present.
  ; SpiderBasic needs also compiler restart when changing the JDK path
  RestartCompiler(@DefaultCompiler)
  
  IsApplyPreferences = #False
  
EndProcedure


Procedure OpenPreferencesWindow()
  
  If IsWindow(#WINDOW_Preferences) <> 0
    SetWindowForeground(#WINDOW_Preferences)
    ProcedureReturn
  EndIf
  
  PreferenceWindowDialog = OpenDialog(?Dialog_Preferences, WindowID(#WINDOW_Main), @PreferenceWindowPosition)
  If PreferenceWindowDialog = 0
    ProcedureReturn
  EndIf
  
  EnsureWindowOnDesktop(#WINDOW_Preferences)
  
  ;- General
  ;
  SetGadgetState(#GADGET_Preferences_RunOnce, Editor_RunOnce)
  SetGadgetState(#GADGET_Preferences_MemorizeWindow, MemorizeWindow)
  SetGadgetState(#GADGET_Preferences_AutoReload, AutoReload)
  SetGadgetState(#GADGET_Preferences_DisplayFullPath, DisplayFullPath)
  SetGadgetState(#GADGET_Preferences_EnableAccessibility, EnableAccessibility)
  
  CompilerIf #CompileMac
    SetGadgetState(#GADGET_Preferences_DisplayDarkMode, DisplayDarkMode)
  CompilerEndIf
  SetGadgetState(#GADGET_Preferences_NoSplashScreen, NoSplashScreen)
  
  SetGadgetText(#GADGET_Preferences_FileHistorySize, Str(FilesHistorySize))
  SetGadgetText(#GADGET_Preferences_FindHistorySize, Str(FindHistorySize))
  
  SetGadgetState(#GADGET_Preferences_UpdateCheckInterval, UpdateCheckInterval)
  SetGadgetState(#GADGET_Preferences_UpdateCheckVersions, UpdateCheckVersions)
  
  CompilerIf #CompileMac
    SetGadgetState(#GADGET_Preferences_RunOnce, 0)
    DisableGadget(#GADGET_Preferences_RunOnce, 1)
  CompilerEndIf
  
  ;- --> Language
  ;
  CollectLanguageInfo()
  ClearGadgetItems(#GADGET_Preferences_Languages)
  
  SelectedLanguage = 0
  ForEach AvailableLanguages()
    AddGadgetItem(#GADGET_Preferences_Languages, -1, AvailableLanguages()\Name$)
    
    If UCase(AvailableLanguages()\Name$) = UCase(CurrentLanguage$)
      SelectedLanguage = ListIndex(AvailableLanguages())
    EndIf
  Next AvailableLanguages()
  
  SetGadgetState(#GADGET_Preferences_Languages, SelectedLanguage)
  SelectElement(AvailableLanguages(), SelectedLanguage)
  
  Info$ = Language("Preferences", "LanguageInfo") + ":"  + #NewLine + #NewLine
  Info$ + Language("Preferences", "LastUpdated")  + ":    " + AvailableLanguages()\Date$ + #NewLine
  Info$ + Language("Preferences", "Creator")      + ":    " + AvailableLanguages()\Creator$ + #NewLine
  Info$ + Language("Preferences", "Email")        + ":    " + AvailableLanguages()\CreatorEmail$ + #NewLine + #NewLine
  Info$ + Language("Preferences", "FileName")     + ":    " + CreateRelativePath(PureBasicPath$, AvailableLanguages()\FileName$)
  SetGadgetText(#GADGET_Preferences_LanguageInfo, Info$)
  
  
  ;- --> Shortcuts
  ;
  SetGadgetItemAttribute(#GADGET_Preferences_ShortcutList, 0, #PB_ListIcon_ColumnWidth, GadgetWidth(#GADGET_Preferences_ShortcutList)-120, 0)
  
  ; copy the values to modify them in the preferences
  For item = 0 To #MENU_LastShortcutItem
    Prefs_KeyboardShortcuts(item) = KeyboardShortcuts(item)
  Next item
  FillShortcutList()
  
  SetGadgetState(#GADGET_Preferences_SelectShortcut, 0)
  
  ;- --> Themes
  ;
  CreatePrefsThemeList()
  
  SetGadgetState(#GADGET_Preferences_EnableMenuIcons, EnableMenuIcons)
  SetGadgetState(#GADGET_Preferences_ShowMainToolbar, ShowMainToolbar)
  
  If EnableAccessibility
    DisableGadget(#GADGET_Preferences_EnableMenuIcons, #True) ; forced off in accessibility mode
  EndIf
  
  ;- --> Toolbar
  ;
  PreferenceToolbarCount = ToolbarItemCount
  For i = 1 To ToolbarItemCount
    PreferenceToolbar(i)\Name$ = Toolbar(i)\Name$
    PreferenceToolbar(i)\Action$ = Toolbar(i)\Action$
    AddGadgetItem(#GADGET_Preferences_ToolbarList, -1, "")
  Next i
  UpdatePrefsToolbarList()
  
  ToolbarPreferenceMode = -1
  ToolbarPreferenceAction = -1
  UpdatePrefsToolbarItem(#True)
  
  EnableGadgetDrop(#GADGET_Preferences_ToolbarList, #PB_Drop_Private, #PB_Drag_Move, #DRAG_Preferences_Toolbar)
  
  
  ;- Editor
  ;
  SetGadgetState(#GADGET_Preferences_MonitorFileChanges, MonitorFileChanges)
  SetGadgetState(#GADGET_Preferences_SaveProjectSettings, SaveProjectSettings)
  SetGadgetState(#GADGET_Preferences_AutoSave, AutoSave)
  SetGadgetState(#GADGET_Preferences_AutoSaveAll, AutoSaveAll)
  SetGadgetState(#GADGET_Preferences_MemorizeCursor, MemorizeCursor)
  SetGadgetState(#GADGET_Preferences_MemorizeMarkers, MemorizeMarkers)
  SetGadgetState(#GADGET_Preferences_AlwaysHideLog, AlwaysHideLog)
  SetGadgetState(#GADGET_Preferences_RealTab, RealTab)
  
  SetGadgetText(#GADGET_Preferences_TabLength, Str(TabLength))
  SetGadgetText(#GADGET_Preferences_SourcePath, SourcePath$)
  
  EnableGadgetDrop(#GADGET_Preferences_SourcePath, #PB_Drop_Files, #PB_Drag_Copy)
  
  SetGadgetState(#GADGET_Preferences_FilesPanelMultiline, FilesPanelMultiline)
  SetGadgetState(#GADGET_Preferences_FilesPanelCloseButtons, FilesPanelCloseButtons)
  SetGadgetState(#GADGET_Preferences_FilesPanelNewButton, FilesPanelNewButton)
  
  SetGadgetText(#GADGET_Preferences_CodeFileExtensions, CodeFileExtensions$)
  
  ;   If EnableMarkers = 0
  ;     DisableGadget(#GADGET_Preferences_MemorizeMarkers, 1)
  ;   EndIf
  
  
  ;- --> Editing
  ;
  PreferenceFontName$ = EditorFontName$
  PreferenceFontSize  = EditorFontSize
  PreferenceFontStyle = EditorFontStyle
  If LoadFont(#FONT_Preferences_CurrentFont, PreferenceFontName$, PreferenceFontSize, PreferenceFontStyle)
    SetGadgetFont(#GADGET_Preferences_CurrentFont, FontID(#FONT_Preferences_CurrentFont))
  EndIf
  
  ; the mac does not allow font changes yet
  ;   CompilerIf #CompileMac
  ;     DisableGadget(#GADGET_Preferences_SelectFont, 1)
  ;   CompilerEndIf
  
  ;  SetGadgetState(#GADGET_Preferences_EnableColoring, EnableColoring)
  SetGadgetState(#GADGET_Preferences_EnableBolding, EnableKeywordBolding)
  SetGadgetState(#GADGET_Preferences_EnableCaseCorrection, EnableCaseCorrection)
  SetGadgetState(#GADGET_Preferences_EnableLineNumbers, EnableLineNumbers)
  ;  SetGadgetState(#GADGET_Preferences_EnableMarkers, EnableMarkers)
  SetGadgetState(#GADGET_Preferences_EnableBraceMatch, EnableBraceMatch)
  SetGadgetState(#GADGET_Preferences_EnableKeywordMatch, EnableKeywordMatch)
  SetGadgetState(#GADGET_Preferences_EnableFolding, EnableFolding)
  SetGadgetText(#GADGET_Preferences_ExtraWordChars, ExtraWordChars$)
  
  
  ;   If EnableColoring = 0
  ;     DisableGadget(#GADGET_Preferences_EnableBolding, 1)
  ;   EndIf
  
  ;- --> Colors
  ;
  For i = 0 To #COLOR_Last
    Colors(i)\PrefsValue = Colors(i)\UserValue
    SetGadgetState(#GADGET_Preferences_FirstColorCheck+i, Colors(i)\Enabled)
    
    If CreateImage(#IMAGE_Preferences_FirstColor+i, DesktopScaledX(45), DesktopScaledY(22))
      If Colors(i)\PrefsValue <> -1
        Color = Colors(i)\PrefsValue
      Else
        Color = $C0C0C0 ; Default color
      EndIf
      
      UpdatePreferenceSyntaxColor(i, Color)
    EndIf
  Next i
  
  CurrentScheme = -1
  ForEach ColorScheme()
    AddGadgetItem(#GADGET_Preferences_ColorSchemes, ListIndex(ColorScheme()), ColorScheme()\Name$)
    SetGadgetItemData(#GADGET_Preferences_ColorSchemes, ListIndex(ColorScheme()), @ColorScheme())
    If ColorSchemeMatchesCurrentSettings(@ColorScheme())
      CurrentScheme = ListIndex(ColorScheme())
    EndIf
  Next
  
  SetGadgetItemText(#GADGET_Preferences_ColorSchemes, CountGadgetItems(#GADGET_Preferences_ColorSchemes)-1, Language("Preferences", "Accessibility"), 0)
  ;AddGadgetItem(#GADGET_Preferences_ColorSchemes, -1, "")
  If CurrentScheme >= 0
    SetGadgetState(#GADGET_Preferences_ColorSchemes, CurrentScheme)
    DisableSelectionColorGadgets(GetGadgetItemData(#GADGET_Preferences_ColorSchemes, CurrentScheme))
  Else
    ;SetGadgetState(#GADGET_Preferences_ColorSchemes, CountGadgetItems(#GADGET_Preferences_ColorSchemes)-1)
    SetGadgetState(#GADGET_Preferences_ColorSchemes, -1)
    DisableSelectionColorGadgets(#Null)
  EndIf
  
  ;- ------> Custom Keywords
  ;
  SetGadgetText(#GADGET_Preferences_KeywordFile, CustomKeywordFile$)
  
  ForEach CustomKeywordList()
    AddGadgetItem(#GADGET_Preferences_KeywordList, -1, CustomKeywordList())
  Next CustomKeywordList()
  
  EnableGadgetDrop(#GADGET_Preferences_KeywordFile, #PB_Drop_Files, #PB_Drag_Copy)
  
  ; we accept files and text here (both are added as keywords)
  EnableGadgetDrop(#GADGET_Preferences_KeywordList, #PB_Drop_Text, #PB_Drag_Copy)
  EnableGadgetDrop(#GADGET_Preferences_KeywordList, #PB_Drop_Files, #PB_Drag_Copy)
  
  ;- --> Folding
  ;
  For i = 1 To NbFoldStartWords
    AddGadgetItem(#GADGET_Preferences_FoldStartList, -1, FoldStart$(i))
  Next i
  
  For i = 1 To NbFoldEndWords
    AddGadgetItem(#GADGET_Preferences_FoldEndList, -1, FoldEnd$(i))
  Next i
  
  If EnableFolding = 0
    For i = #GADGET_Preferences_FoldStartList To #GADGET_Preferences_FoldEndRemove
      DisableGadget(i, 1)
    Next i
  EndIf
  
  EnableGadgetDrop(#GADGET_Preferences_FoldStartList, #PB_Drop_Text, #PB_Drag_Copy)
  EnableGadgetDrop(#GADGET_Preferences_FoldEndList, #PB_Drop_Text, #PB_Drag_Copy)
  
  ;- --> Indentation
  ;
  SetGadgetState(#GADGET_Preferences_ShowWhiteSpace, ShowWhiteSpace)
  SetGadgetState(#GADGET_Preferences_ShowIndentGuides, ShowIndentGuides)
  SetGadgetState(#GADGET_Preferences_UseTabIndentForSplittedLines, UseTabIndentForSplittedLines)
  
  If IndentMode = #INDENT_None
    SetGadgetState(#GADGET_Preferences_IndentNo, 1)
  ElseIf IndentMode = #INDENT_Block
    SetGadgetState(#GADGET_Preferences_IndentBlock, 1)
  Else
    SetGadgetState(#GADGET_Preferences_IndentSensitive, 1)
  EndIf
  
  SetGadgetState(#GADGET_Preferences_BackspaceUnindent, BackspaceUnindent)
  
  For i = 0 To NbIndentKeywords-1
    AddGadgetItem(#GADGET_Preferences_IndentList, -1, IndentKeywords(i)\Keyword$+Chr(10)+Str(IndentKeywords(i)\Before)+Chr(10)+Str(IndentKeywords(i)\After))
  Next i
  
  If IndentMode < 2
    For i = #GADGET_Preferences_IndentList To #GADGET_Preferences_IndentRemove
      DisableGadget(i, 1)
    Next i
  EndIf
  
  ;- --> AutoComplete
  ;
  SetGadgetText(#GADGET_Preferences_BoxWidth, Str(AutoCompleteWindowWidth))
  SetGadgetText(#GADGET_Preferences_BoxHeight, Str(AutoCompleteWindowHeight))
  SetGadgetText(#GADGET_Preferences_AutoPopupLength, Str(AutoCompletePopupLength))
  
  SetGadgetState(#GADGET_Preferences_AddBrackets, AutoCompleteAddBrackets)
  SetGadgetState(#GADGET_Preferences_AddSpaces, AutoCompleteAddSpaces)
  SetGadgetState(#GADGET_Preferences_AddEndKeywords, AutoCompleteAddEndKeywords)
  SetGadgetState(#GADGET_Preferences_AutoPopup, AutoPopupNormal)
  ;  SetGadgetState(#GADGET_Preferences_NoComments, AutoCompleteNoComments)
  ;  SetGadgetState(#GADGET_Preferences_NoStrings, AutoCompleteNoStrings)
  SetGadgetState(#GADGET_Preferences_StructureItems, AutoPopupStructures)
  SetGadgetState(#GADGET_Preferences_ModulePrefix, AutoPopupModules)
  
  If AutoPopupNormal = 0
    ;    DisableGadget(#GADGET_Preferences_NoComments, 1)
    ;    DisableGadget(#GADGET_Preferences_NoStrings, 1)
    DisableGadget(#GADGET_Preferences_AutoPopupLength, 1)
  EndIf
  
  ;- ------> AutoComplete List
  ;
  Restore SourceItem_Names
  For i = 0 To #ITEM_LastOption
    Read.s ItemName$
    AddGadgetItem(#GADGET_Preferences_CodeOptions, i, Language("Preferences","Option_"+ItemName$))
    If AutocompleteOptions(i)
      SetGadgetItemState(#GADGET_Preferences_CodeOptions, i, #PB_ListIcon_Checked)
    EndIf
  Next i
  
  Restore PBItem_Names
  For i = 0 To #PBITEM_Last
    Read.s ItemName$
    AddGadgetItem(#GADGET_Preferences_PBOptions, i, Language("Preferences","Option_"+ItemName$))
    If AutocompletePBOptions(i)
      SetGadgetItemState(#GADGET_Preferences_PBOptions, i, #PB_ListIcon_Checked)
    EndIf
  Next i
  
  If AutoCompleteProject = 0 And AutoCompleteAllFiles = 0
    SetGadgetState(#GADGET_Preferences_SourceOnly, 1)
  ElseIf AutoCompleteProject And AutoCompleteAllFiles = 0
    SetGadgetState(#GADGET_Preferences_ProjectOnly, 1)
  ElseIf AutoCompleteProject And AutoCompleteAllFiles
    SetGadgetState(#GADGET_Preferences_ProjectAllFiles, 1)
  Else
    SetGadgetState(#GADGET_Preferences_AllFiles, 1)
  EndIf
  
  ;- --> Issues
  ;
  If CreateImage(#IMAGE_Preferences_IssueColor, DesktopScaledX(45), DesktopScaledY(20))
    UpdateImageColorGadget(#GADGET_Preferences_IssueColor, #IMAGE_Preferences_IssueColor, $C0C0C0)
  EndIf
  
  ; Small hack:
  ; the option gadgets have other gadgets created in between them due to the layout, so
  ; they do not belong to the same option group.
  ; so re-create them here manually to have one group
  OpenGadgetList(#GADGET_Preferences_FirstContainer+13)
  OptionGadget(#GADGET_Preferences_IssueCodeNoColor, 0, 0, 0, 0, Language("Preferences","IssueCodeNoColor"))
  OptionGadget(#GADGET_Preferences_IssueCodeBack, 0, 0, 0, 0, Language("Preferences","IssueCodeBack"))
  OptionGadget(#GADGET_Preferences_IssueCodeLine, 0, 0, 0, 0, Language("Preferences","IssueCodeLine"))
  CloseGadgetList()
  
  ; set images for the priorities from the theme
  For i = 0 To 4
    SetGadgetItemImage(#GADGET_Preferences_IssuePriority, i, OptionalImageID(#IMAGE_Priority0 + i))
  Next i
  
  ; nothing selected yet
  For i = #GADGET_Preferences_UpdateIssue To #GADGET_Preferences_IssueInBrowser
    DisableGadget(i, 1)
  Next i
  
  ; make a copy of the currently existing issue defs
  CopyList(Issues(), PreferenceIssues())
  
  ; add to the list
  ForEach Issues()
    Item$ = Issues()\Name$+Chr(10)+Issues()\Expression$+Chr(10)+Language("ToolsPanel","Prio" + Issues()\Priority)
    AddGadgetItem(#GADGET_Preferences_IssueList, -1, Item$, OptionalImageID(#IMAGE_Priority0 + Issues()\Priority))
  Next Issues()
  
  
  ;- --> EditHistory
  ;
  SetGadgetState(#GADGET_Preferences_EnableHistory, EnableHistory)
  SetGadgetText(#GADGET_Preferences_HistoryTimer, Str(HistoryTimer))
  SetGadgetText(#GADGET_Preferences_HistoryMaxFileSize, Str(HistoryMaxFileSize/1024)) ; display is in kb
  SetGadgetText(#GADGET_Preferences_HistoryDays, Str(MaxSessionDays))
  SetGadgetText(#GADGET_Preferences_HistoryCount, Str(MaxSessionCount))
  
  DBSize = FileSize(HistoryDatabaseFile$)
  If DBSize < 0
    DBSize = 0
  EndIf
  FileInfo$ = Language("Preferences","HistoryFile") + ": " + HistoryDatabaseFile$ + #NewLine
  FileInfo$ + Language("Preferences","HistoryFileSize") + ": " + StrByteSize(DBSize)
  SetGadgetText(#GADGET_Preferences_HistoryFile, FileInfo$)
  
  ; Small hack:
  ; the option gadgets have text gadgets created in between them due to the layout, so
  ; they do not belong to the same option group.
  ; so re-create them here manually to have one group
  OpenGadgetList(#GADGET_Preferences_FirstContainer+14)
  OptionGadget(#GADGET_Preferences_HistoryPurgeNever, 0, 0, 0, 0, Language("Preferences","PurgeNever"))
  OptionGadget(#GADGET_Preferences_HistoryPurgeByCount, 0, 0, 0, 0, Language("Preferences","PurgeByCount1"))
  OptionGadget(#GADGET_Preferences_HistoryPurgeByDays, 0, 0, 0, 0, Language("Preferences","PurgeByDays1"))
  CloseGadgetList()
  
  Select HistoryPurgeMode
    Case 0: SetGadgetState(#GADGET_Preferences_HistoryPurgeNever, 1)
    Case 1: SetGadgetState(#GADGET_Preferences_HistoryPurgeByCount, 1)
    Default: SetGadgetState(#GADGET_Preferences_HistoryPurgeByDays, 1)
  EndSelect
  
  If EnableHistory = 0
    For i = #GADGET_Preferences_HistoryTimer To #GADGET_Preferences_HistoryCount
      DisableGadget(i, 1)
    Next i
  EndIf
  
  
  ;- Compilers
  ;
  SetGadgetText(#GADGET_Preferences_DefaultCompiler, DefaultCompiler\VersionString$+#NewLine+DefaultCompiler\Executable$)
  
  ClearList(PreferenceCompilers())
  ForEach Compilers()
    AddElement(PreferenceCompilers())
    PreferenceCompilers() = Compilers()
    
    If PreferenceCompilers()\Validated
      AddGadgetItem(#GADGET_Preferences_CompilerList, -1, PreferenceCompilers()\VersionString$+Chr(10)+PreferenceCompilers()\Executable$)
    Else
      AddGadgetItem(#GADGET_Preferences_CompilerList, -1, Language("Compiler","UnknownVersion")+Chr(10)+PreferenceCompilers()\Executable$)
    EndIf
  Next Compilers()
  
  EnableGadgetDrop(#GADGET_Preferences_CompilerList, #PB_Drop_Files, #PB_Drag_Copy)
  EnableGadgetDrop(#GADGET_Preferences_CompilerExe,  #PB_Drop_Files, #PB_Drag_Copy)
  
  ;- --> Defaults
  ;
  SetGadgetState(#GADGET_Preferences_Debugger, OptionDebugger)
  SetGadgetState(#GADGET_Preferences_ErrorLog, OptionErrorLog)
  SetGadgetState(#GADGET_Preferences_Encoding, OptionEncoding)
  SetGadgetState(#GADGET_Preferences_NewLineType, OptionNewLineType)
  SetGadgetState(#GADGET_Preferences_UseCompileCount, OptionUseCompileCount)
  SetGadgetState(#GADGET_Preferences_UseBuildCount, OptionUseBuildCount)
  
  SetGadgetText(#GADGET_Preferences_SubSystem, OptionSubSystem$)
  
  SetGadgetState(#GADGET_Preferences_CustomCompiler, OptionCustomCompiler)
  
  AddGadgetItem(#GADGET_Preferences_SelectCustomCompiler, -1, DefaultCompiler\VersionString$)
  ForEach PreferenceCompilers()
    If PreferenceCompilers()\Validated
      AddGadgetItem(#GADGET_Preferences_SelectCustomCompiler, -1, PreferenceCompilers()\VersionString$)
    EndIf
  Next PreferenceCompilers()
  SetGadgetText(#GADGET_Preferences_SelectCustomCompiler, OptionCompilerVersion$)
  If OptionCustomCompiler = #False
    DisableGadget(#GADGET_Preferences_SelectCustomCompiler, #True)
  EndIf
  
  CompilerIf #SpiderBasic
    SetGadgetText(#GADGET_Preferences_WebBrowser, OptionWebBrowser$)
    SetGadgetText(#GADGET_Preferences_WebServerPort, Str(OptionWebServerPort))
    SetGadgetText(#GADGET_Preferences_JDK, OptionJDK$)
    SetGadgetText(#GADGET_Preferences_AppleTeamID, OptionAppleTeamID$)
  CompilerElse
    SetGadgetState(#GADGET_Preferences_Purifier, OptionPurifier)
    SetGadgetState(#GADGET_Preferences_InlineASM, OptionInlineASM)
    SetGadgetState(#GADGET_Preferences_XPSkin, OptionXPSkin)
    SetGadgetState(#GADGET_Preferences_Wayland, OptionWayland)
    SetGadgetState(#GADGET_Preferences_VistaAdmin, OptionVistaAdmin)
    SetGadgetState(#GADGET_Preferences_VistaUser, OptionVistaUser)
    SetGadgetState(#GADGET_Preferences_DPIAware, OptionDPIAware)
    SetGadgetState(#GADGET_Preferences_DllProtection, OptionDllProtection)
    SetGadgetState(#GADGET_Preferences_SharedUCRT, OptionSharedUCRT)
    SetGadgetState(#GADGET_Preferences_Thread, OptionThread)
    SetGadgetState(#GADGET_Preferences_Optimizer, OptionOptimizer)
    SetGadgetState(#GADGET_Preferences_OnError, OptionOnError)
    SetGadgetState(#GADGET_Preferences_ExecutableFormat, OptionExeFormat)
    SetGadgetState(#GADGET_Preferences_CPU, OptionCPU)
    SetGadgetState(#GADGET_Preferences_TemporaryExe, OptionTemporaryExe)
    SetGadgetState(#GADGET_Preferences_UseCreateExecutable, OptionUseCreateExe)
  CompilerEndIf
  
  CompilerIf #CompileLinux And Not #SpiderBasic
    DisableGadget(#GADGET_Preferences_DPIAware, 1)
  CompilerEndIf
  
  CompilerIf Not #CompileWindows
    DisableGadget(#GADGET_Preferences_XPSkin, 1)
    DisableGadget(#GADGET_Preferences_VistaAdmin, 1)
    DisableGadget(#GADGET_Preferences_VistaUser, 1)
    DisableGadget(#GADGET_Preferences_DllProtection, 1)
    DisableGadget(#GADGET_Preferences_SharedUCRT, 1)
  CompilerEndIf
  
   CompilerIf Not #CompileLinux And Not #SpiderBasic
    DisableGadget(#GADGET_Preferences_Wayland, 1)
  CompilerEndIf
  
  ;- Debugger
  ;
  ;   CompilerIf #CompileMac ; OSX-debug
  ;     SetGadgetState(#GADGET_Preferences_DebuggerMode, DebuggerMode-2)
  ;   CompilerElse
  SetGadgetState(#GADGET_Preferences_DebuggerMode, DebuggerMode-1)
  ;   CompilerEndIf
  
  SetGadgetState(#GADGET_Preferences_WarningMode, WarningMode)
  
  SetGadgetState(#GADGET_Preferences_DebuggerMemorizeWindows, DebuggerMemorizeWindows)
  SetGadgetState(#GADGET_Preferences_DebuggerAlwaysOnTop, DebuggerOnTop)
  SetGadgetState(#GADGET_Preferences_DebuggerBringToTop, DebuggerBringToTop)
  SetGadgetState(#GADGET_Preferences_DebuggerStopAtStart, CallDebuggerOnStart)
  SetGadgetState(#GADGET_Preferences_DebuggerStopAtEnd, CallDebuggerOnEnd)
  SetGadgetState(#GADGET_Preferences_DebuggerLogTimeStamp, LogTimeStamp)
  SetGadgetState(#GADGET_Preferences_KillOnError, DebuggerKillOnError)
  SetGadgetState(#GADGET_Preferences_KeepErrorMarks, DebuggerKeepErrorMarks)
  SetGadgetState(#GADGET_Preferences_AutoClearLog, AutoClearLog)
  SetGadgetState(#GADGET_Preferences_DisplayErrorWindow, DisplayErrorWindow)
  
  SetGadgetText(#GADGET_Preferences_DebuggerTimeout, Str(DebuggerTimeout))
  
  CompilerIf #DEFAULT_CanWindowStayOnTop = 0
    SetGadgetState(#GADGET_Preferences_DebuggerAlwaysOnTop, 0)
    DisableGadget(#GADGET_Preferences_DebuggerAlwaysOnTop, 1)
  CompilerEndIf
  
  
  ;- --> Individual settings
  ;
  SetGadgetState(#GADGET_Preferences_DebugIsHex, DebugIsHex)
  SetGadgetState(#GADGET_Preferences_DebugOutTimeStamp, DebugTimeStamp)
  SetGadgetState(#GADGET_Preferences_DebugToLog, DebugOutputToErrorLog)
  SetGadgetState(#GADGET_Preferences_DebugOutUseFont, DebugOutUseFont)
  
  PreferenceDebugOutFont$     = DebugOutFont$
  PreferenceDebugOutFontSize  = DebugOutFontSize
  PreferenceDebugOutFontStyle = DebugOutFontStyle
  
  If DebugOutUseFont = 0
    DisableGadget(#GADGET_Preferences_DebugOutFont, 1)
  EndIf
  
  SetGadgetState(#GADGET_Preferences_RegisterIsHex, RegisterIsHex)
  SetGadgetState(#GADGET_Preferences_StackIsHex, StackIsHex)
  SetGadgetState(#GADGET_Preferences_AutoStackUpdate, AutoStackUpdate)
  
  CompilerIf #CompileMac
    SetGadgetState(#GADGET_Preferences_RegisterIsHex, 0)
    SetGadgetState(#GADGET_Preferences_StackIsHex, 0)
    SetGadgetState(#GADGET_Preferences_AutoStackUpdate, 0)
    DisableGadget(#GADGET_Preferences_RegisterIsHex, 1)
    DisableGadget(#GADGET_Preferences_StackIsHex, 1)
    DisableGadget(#GADGET_Preferences_AutoStackUpdate, 1)
    HideGadget(#GADGET_Preferences_ToolbarClassic, 1)
  CompilerEndIf
  
  SetGadgetState(#GADGET_Preferences_MemoryIsHex, MemoryIsHex)
  SetGadgetState(#GADGET_Preferences_MemoryOneColumn, MemoryOneColumnOnly)
  
  SetGadgetState(#GADGET_Preferences_VariableIsHex, VariableIsHex)
  
  SetGadgetState(#GADGET_Preferences_ProfilerStartup, ProfilerRunAtStart)
  
  ;- --> Default Windows
  ;
  SetGadgetState(#GADGET_Preferences_DebugWindowOpen, AutoOpenDebugOutput)
  SetGadgetState(#GADGET_Preferences_AsmWindowOpen, AutoOpenAsmWindow)
  SetGadgetState(#GADGET_Preferences_MemoryWindowOpen, AutoOpenMemoryViewer)
  SetGadgetState(#GADGET_Preferences_VariableWindowOpen, AutoOpenVariableViewer)
  SetGadgetState(#GADGET_Preferences_ProfilerWindowOpen, AutoOpenProfiler)
  SetGadgetState(#GADGET_Preferences_HistoryWindowOpen, AutoOpenHistory)
  SetGadgetState(#GADGET_Preferences_WatchlistWindowOpen, AutoOpenWatchlist)
  SetGadgetState(#GADGET_Preferences_LibraryViewerWindowOpen, AutoOpenLibraryViewer)
  SetGadgetState(#GADGET_Preferences_DataBreakpointsOpen, AutoOpenDataBreakpoints)
  SetGadgetState(#GADGET_Preferences_PurifierOpen, AutoOpenPurifier)
  
  CompilerIf #CompileMac
    SetGadgetState(#GADGET_Preferences_AsmWindowOpen, 0)
    DisableGadget(#GADGET_Preferences_AsmWindowOpen, 1)
  CompilerEndIf
  
  If DebuggerMode = 3 ; disable for console debugger only
    For i = #GADGET_Preferences_DebuggerMemorizeWindows To #GADGET_Preferences_WatchlistWindowOpen
      DisableGadget(i, 1)
    Next i
  EndIf
  
  
  ;- ToolsPanel
  ;
  DisableGadget(#GADGET_Preferences_AddTool, 1)      ; initial state is always disabled
  DisableGadget(#GADGET_Preferences_RemoveTool, 1)
  DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
  DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
  
  ; we can copy from available to used
  ; we can move from used to available (it disappears in the used list then)
  ; and we can move inside the used list
  EnableGadgetDrop(#GADGET_Preferences_UsedTools, #PB_Drop_Private, #PB_Drag_Copy, #DRAG_Preferences_ToolsFromAvailable)
  EnableGadgetDrop(#GADGET_Preferences_UsedTools, #PB_Drop_Private, #PB_Drag_Move, #DRAG_Preferences_ToolsFromUsed)
  EnableGadgetDrop(#GADGET_Preferences_AvailableTools, #PB_Drop_Private, #PB_Drag_Move, #DRAG_Preferences_ToolsFromUsed)
  
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\ExternalPlugin
      AddGadgetItem(#GADGET_Preferences_AvailableTools, -1, AvailablePanelTools()\ToolName$+"*")
    Else
      AddGadgetItem(#GADGET_Preferences_AvailableTools, -1, Language("ToolsPanel", AvailablePanelTools()\ToolName$))
    EndIf
  Next AvailablePanelTools()
  
  ClearList(NewUsedPanelTools())
  ForEach UsedPanelTools()
    *ToolData.ToolsPanelEntry = UsedPanelTools()
    If *ToolData\ExternalPlugin
      AddGadgetItem(#GADGET_Preferences_UsedTools, -1, *ToolData\ToolName$+"*")
    Else
      AddGadgetItem(#GADGET_Preferences_UsedTools, -1, Language("ToolsPanel", *ToolData\ToolName$))
    EndIf
    
    AddElement(NewUsedPanelTools())          ;make a copy of the list..
    NewUsedPanelTools() = UsedPanelTools()
  Next UsedPanelTools()
  
  CurrentPreferenceTool      = 0
  *CurrentPreferenceToolData = 0
  
  ; now tell all Tools that the preferences are opened and that they should
  ; copy the current Preferences to use them in the while the preferences are edited, so
  ; that the original values stay unchanged
  ;
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\NeedConfiguration
      PanelTool.ToolsPanelInterface = @AvailablePanelTools()
      PanelTool\PreferenceStart()
    EndIf
  Next AvailablePanelTools()
  
  
  ;- --> Options
  ;
  If CreateImage(#IMAGE_Preferences_ToolsPanelFrontColor, DesktopScaledX(45), DesktopScaledY(21))
    UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelFrontColor, #IMAGE_Preferences_ToolsPanelFrontColor, ToolsPanelFrontColor)
  EndIf
  
  If CreateImage(#IMAGE_Preferences_ToolsPanelBackColor, DesktopScaledX(45), DesktopScaledX(21))
    UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelBackColor, #IMAGE_Preferences_ToolsPanelBackColor, ToolsPanelBackColor)
  EndIf
  
  SetGadgetState(#GADGET_Preferences_ToolsPanelSide, ToolsPanelSide)
  SetGadgetText(#GADGET_Preferences_ToolsPanelDelay, Str(ToolsPanelHideDelay))
  
  CompilerIf #CompileWindows = 0
    ; hide this on linux/mac, (not just disable, as it gets enabled/disabled later on)
    HideGadget(#GADGET_Preferences_ToolsPanelDelay, 1)
    HideGadget(#GADGET_Preferences_ToolsPanelDelayText, 1)
  CompilerEndIf
  
  CompilerIf #CompileMac
    ; On Mac, hide all the color & font options as they are not supported for now
    HideGadget(#GADGET_Preferences_UseToolsPanelFont, 1)
    HideGadget(#GADGET_Preferences_SelectToolsPanelFont, 1)
  CompilerEndIf
  
  PreferenceToolsPanelFrontColor = ToolsPanelFrontColor
  PreferenceToolsPanelBackColor  = ToolsPanelBackColor
  PreferenceToolsPanelFont$      = ToolsPanelFontName$
  PreferenceToolsPanelFontSize   = ToolsPanelFontSize
  PreferenceToolsPanelFontStyle  = ToolsPanelFontStyle
  
  SetGadgetState(#GADGET_Preferences_NoIndependentToolsColors, NoIndependentToolsColors)
  SetGadgetState(#GADGET_Preferences_AutoHidePanel, ToolsPanelAutoHide)
  If ToolsPanelAutoHide = 0
    DisableGadget(#GADGET_Preferences_ToolsPanelDelay, 1)
    DisableGadget(#GADGET_Preferences_ToolsPanelDelayText, 1)
  EndIf
  
  SetGadgetState(#GADGET_Preferences_UseToolsPanelFont,   ToolsPanelUseFont)
  SetGadgetState(#GADGET_Preferences_UseToolsPanelColors, ToolsPanelUseColors)
  
  If ToolsPanelUseFont = 0
    DisableGadget(#GADGET_Preferences_SelectToolsPanelFont, 1)
  EndIf
  
  If ToolsPanelUseColors = 0
    DisableGadget(#GADGET_Preferences_ToolsPanelFrontColorSelect, 1)
    DisableGadget(#GADGET_Preferences_ToolsPanelBackColorSelect, 1)
    DisableGadget(#GADGET_Preferences_NoIndependentToolsColors, 1)
  EndIf
  
  
  ;- Import/Export
  ;
  SetGadgetState(#GADGET_Preferences_ExpShortcut, 1) ; always turn these on by default
  SetGadgetState(#GADGET_Preferences_ExpToolbar, 1)  ; always turn these on by default
  SetGadgetState(#GADGET_Preferences_ExpColor, 1)    ; always turn these on by default
  SetGadgetState(#GADGET_Preferences_ExpFolding, 1)  ; always turn these on by default
  
  SetGadgetText(#GADGET_Preferences_ExportFile, Preferences_ExportFile$)
  SetGadgetText(#GADGET_Preferences_ImportFile, Preferences_ImportFile$)
  
  DisableGadget(#GADGET_Preferences_ImpShortcut, 1)
  DisableGadget(#GADGET_Preferences_ImpToolbar, 1)
  DisableGadget(#GADGET_Preferences_ImpColor, 1)
  DisableGadget(#GADGET_Preferences_ImpFolding, 1)
  DisableGadget(#GADGET_Preferences_Import, 1)
  
  EnableGadgetDrop(#GADGET_Preferences_ExportFile, #PB_Drop_Files, #PB_Drag_Copy)
  EnableGadgetDrop(#GADGET_Preferences_ImportFile, #PB_Drop_Files, #PB_Drag_Copy)
  
  ;- Form
  ;
  SetGadgetState(#GADGET_Preferences_FormVariable, FormVariable)
  SetGadgetState(#GADGET_Preferences_FormVariableCaption, FormVariableCaption)
  SetGadgetState(#GADGET_Preferences_FormGrid, FormGrid)
  SetGadgetText(#GADGET_Preferences_FormGridSize, Str(FormGridSize))
  SetGadgetState(#GADGET_Preferences_FormEventProcedure, FormEventProcedure)
  
  Select FormSkin
    Case #PB_OS_MacOS
      SetGadgetState(#GADGET_Preferences_FormSkin,0)
    Case #PB_OS_Linux
      SetGadgetState(#GADGET_Preferences_FormSkin,3)
    Case #PB_OS_Windows
      Select FormSkinVersion
        Case 7
          SetGadgetState(#GADGET_Preferences_FormSkin,1)
        Case 8
          SetGadgetState(#GADGET_Preferences_FormSkin,2)
      EndSelect
  EndSelect
  
  If (FormVersionWarnings & #FDI_Warn_NotRecognized) = #FDI_Warn_NotRecognized
    SetGadgetState(#GADGET_Preferences_FormNotRecognized, 1)
  Else
    SetGadgetState(#GADGET_Preferences_FormNotRecognized, 0)
  EndIf
  
  If (FormVersionWarnings & #FDI_Warn_DowngradeAlways) = #FDI_Warn_DowngradeAlways
    SetGadgetState(#GADGET_Preferences_FormDowngrade, 1)
  Else
    SetGadgetState(#GADGET_Preferences_FormDowngrade, 0)
  EndIf
  
  If (FormVersionWarnings & (#FDI_Warn_UpgradeBreaking | #FDI_Warn_UpgradeAlways)) = 0
    SetGadgetState(#GADGET_Preferences_FormUpgrade, 0)
  ElseIf (FormVersionWarnings & #FDI_Warn_UpgradeBreaking) = #FDI_Warn_UpgradeBreaking
    SetGadgetState(#GADGET_Preferences_FormUpgrade, 1)
  ElseIf (FormVersionWarnings & #FDI_Warn_UpgradeAlways) = #FDI_Warn_UpgradeAlways
    SetGadgetState(#GADGET_Preferences_FormUpgrade, 2)
  EndIf
  
  PreferenceCurrentPage = 0
  For i = 0 To CountGadgetItems(#GADGET_Preferences_Tree) - 1
    SetGadgetItemState(#GADGET_Preferences_Tree, i, #PB_Tree_Expanded)
  Next i
  
  DisableGadget(#GADGET_Preferences_Apply, 1)
  
  PreferenceWindowDialog\GuiUpdate() ; important, to take care of image changes etc
  HideWindow(#WINDOW_Preferences, 0)
  
  ; fix required for the centereing of non-resizable windows in the dialog manager
  ; (works only if window is visible)
  CompilerIf #CompileLinuxGtk
    If PreferenceWindowPosition\x = -1 And PreferenceWindowPosition\y = -1
      While WindowEvent(): Wend
      gtk_window_set_position_(WindowID(#WINDOW_Preferences), #GTK_WIN_POS_CENTER)
    EndIf
  CompilerEndIf
  
  SetActiveWindow(#WINDOW_Preferences) ;TODO: check why preferences loose focus when they are opened.
  SetActiveGadget(#GADGET_Preferences_Tree)
  
EndProcedure


Procedure UpdatePreferenceWindow()
  
  PreferenceWindowDialog\LanguageUpdate()
  
  SelectElement(AvailableLanguages(), SelectedLanguage)
  Info$ = Language("Preferences", "LanguageInfo") + ":"  + #NewLine + #NewLine
  Info$ + Language("Preferences", "LastUpdated")  + ":    " + AvailableLanguages()\Date$ + #NewLine
  Info$ + Language("Preferences", "Creator")      + ":    " + AvailableLanguages()\Creator$ + #NewLine
  Info$ + Language("Preferences", "Email")        + ":    " + AvailableLanguages()\CreatorEmail$ + #NewLine + #NewLine
  Info$ + Language("Preferences", "FileName")     + ":    " + CreateRelativePath(PureBasicPath$, AvailableLanguages()\FileName$)
  SetGadgetText(#GADGET_Preferences_LanguageInfo, Info$)
  
  ToolbarPreferenceMode = -1
  ToolbarPreferenceAction = -1
  UpdatePrefsToolbarList()
  UpdatePrefsToolbarItem()
  
  FillShortcutList()
  
  ;   For i = 0 To #NbShortcutKeys-1
  ;     SetGadgetItemText(#GADGET_Preferences_ShortcutKey, i, ShortcutNames(i), 0)
  ;   Next i
  
  HistoryFileSize = FileSize(HistoryDatabaseFile$)
  If HistoryFileSize < 0
    HistoryFileSize = 0
  EndIf
  FileInfo$ = Language("Preferences","HistoryFile") + ": " + HistoryDatabaseFile$ + #NewLine
  FileInfo$ + Language("Preferences","HistoryFileSize") + ": " + StrByteSize(HistoryFileSize)
  SetGadgetText(#GADGET_Preferences_HistoryFile, FileInfo$)
  
  
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\ExternalPlugin
      SetGadgetItemText(#GADGET_Preferences_AvailableTools, ListIndex(AvailablePanelTools()), AvailablePanelTools()\ToolName$, 0)
    Else
      SetGadgetItemText(#GADGET_Preferences_AvailableTools, ListIndex(AvailablePanelTools()), Language("ToolsPanel", AvailablePanelTools()\ToolName$), 0)
    EndIf
  Next AvailablePanelTools()
  
  ForEach NewUsedPanelTools()
    *ToolData.ToolsPanelEntry = NewUsedPanelTools()
    If *ToolData\ExternalPlugin
      SetGadgetItemText(#GADGET_Preferences_UsedTools, ListIndex(NewUsedPanelTools()), *ToolData\ToolName$, 0)
    Else
      SetGadgetItemText(#GADGET_Preferences_UsedTools, ListIndex(NewUsedPanelTools()), Language("ToolsPanel", *ToolData\ToolName$), 0)
    EndIf
  Next NewUsedPanelTools()
  
  If CurrentPreferenceTool
    If *CurrentPreferenceToolData\ExternalPlugin
      SetGadgetText(#GADGET_Preferences_ToolSettingsTitle, Language("Preferences","Configuration") + " - " + *CurrentPreferenceToolData\ToolName$)
    Else
      SetGadgetText(#GADGET_Preferences_ToolSettingsTitle, Language("Preferences","Configuration") + " - " + Language("ToolsPanel", *CurrentPreferenceToolData\ToolName$))
    EndIf
    
    CurrentPreferenceTool\PreferenceDestroy()
    FreeGadget(#GADGET_Preferences_ToolSettingsScrollArea)
    
    OpenGadgetList(#GADGET_Preferences_ToolSettingsContainer)
    ScrollAreaGadget(#GADGET_Preferences_ToolSettingsScrollArea, 0, 0, GadgetWidth(#GADGET_Preferences_ToolSettingsContainer)-4, GadgetHeight(#GADGET_Preferences_ToolSettingsContainer)-4, *CurrentPreferenceToolData\PreferencesWidth, *CurrentPreferenceToolData\PreferencesHeight, 10, #PB_ScrollArea_Single)
    CurrentPreferenceTool\PreferenceCreate()
    CloseGadgetList()
    CloseGadgetList()
    
    ; gives the prefs function to update these values during creation (good for the dynamic gui stuff)
    SetGadgetAttribute(#GADGET_Preferences_ToolSettingsScrollArea, #PB_ScrollArea_InnerWidth, *CurrentPreferenceToolData\PreferencesWidth)
    SetGadgetAttribute(#GADGET_Preferences_ToolSettingsScrollArea, #PB_ScrollArea_InnerHeight, *CurrentPreferenceToolData\PreferencesHeight)
  Else
    SetGadgetText(#GADGET_Preferences_ToolSettingsTitle, Language("Preferences","Configuration"))
  EndIf
  
  ; set images for the priorities from the theme
  For i = 0 To 4
    SetGadgetItemImage(#GADGET_Preferences_IssuePriority, i, OptionalImageID(#IMAGE_Priority0 + i))
  Next i
  
  ; update priority columns
  ForEach PreferenceIssues()
    SetGadgetItemImage(#GADGET_Preferences_IssueList, ListIndex(PreferenceIssues()), OptionalImageID(#IMAGE_Priority0 + PreferenceIssues()\Priority))
    SetGadgetItemText(#GADGET_Preferences_IssueList, ListIndex(PreferenceIssues()), Language("ToolsPanel","Prio" + PreferenceIssues()\Priority), 2)
  Next PreferenceIssues()
  
  PreferenceWindowDialog\GuiUpdate()
  
EndProcedure


Procedure ExportPreferences()
  FileName$ = ResolveRelativePath(CurrentDirectory$, GetGadgetText(#GADGET_Preferences_ExportFile))
  
  If FileSize(FileName$) >= 0
    If MessageRequester(#ProductName$,Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #FLAG_Warning|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
      ProcedureReturn
    EndIf
  EndIf
  
  If CreatePreferences(FileName$)
    
    PreferenceComment(#ProductName$ + " IDE Exported Preferences")
    PreferenceComment("")
    
    ; write header
    PreferenceGroup("Sections")
    If GetGadgetState(#GADGET_Preferences_ExpShortcut)
      WritePreferenceLong("IncludeShortcuts", 1)
    EndIf
    If GetGadgetState(#GADGET_Preferences_ExpToolbar)
      WritePreferenceLong("IncludeToolbar", 1)
    EndIf
    If GetGadgetState(#GADGET_Preferences_ExpColor)
      WritePreferenceLong("IncludeColors", 1)
    EndIf
    If GetGadgetState(#GADGET_Preferences_ExpFolding)
      WritePreferenceLong("IncludeFolding", 1)
    EndIf
    
    ; write shortcuts
    ;
    If GetGadgetState(#GADGET_Preferences_ExpShortcut)
      PreferenceComment("")
      PreferenceComment("Shortcut settings")
      PreferenceComment("")
      PreferenceGroup("Shortcuts")
      
      Restore ShortcutItems
      For i = 0 To #MENU_LastShortcutItem
        Read.s MenuTitle$
        Read.s MenuItem$
        Read.l DefaultShortcut
        WritePreferenceString(MenuItem$, ShortcutToIndependentName(Prefs_KeyboardShortcuts(i)))
      Next i
    EndIf
    
    
    ; write toolbar
    ;
    If GetGadgetState(#GADGET_Preferences_ExpToolbar)
      PreferenceComment("")
      PreferenceComment("Toolbar layout")
      PreferenceComment("")
      PreferenceGroup("Toolbar")
      
      WritePreferenceLong("ItemCount", PreferenceToolbarCount)
      For i = 1 To PreferenceToolbarCount
        WritePreferenceString("Icon_"+Str(i), PreferenceToolbar(i)\Name$)
        WritePreferenceString("Action_"+Str(i), PreferenceToolbar(i)\Action$)
      Next i
    EndIf
    
    ; write colors
    ;
    If GetGadgetState(#GADGET_Preferences_ExpColor)
      PreferenceComment("")
      PreferenceComment("Color settings")
      PreferenceComment("")
      
      PreferenceGroup("Colors")
      
      Restore ColorKeys
      For i = 0 To #COLOR_Last
        Read.s ColorKey$
        WritePreferenceString(ColorKey$, RGBString(Colors(i)\PrefsValue))
        WritePreferenceLong  (ColorKey$+"_Used", GetGadgetState(#GADGET_Preferences_FirstColorCheck+i))
      Next i
      
      WritePreferenceString  ("ToolsPanel_FrontColor",       RGBString(PreferenceToolsPanelFrontColor))
      WritePreferenceString  ("ToolsPanel_BackColor",        RGBString(PreferenceToolsPanelBackColor))
      
    EndIf
    
    ; write folding
    ;
    If GetGadgetState(#GADGET_Preferences_ExpFolding)
      PreferenceComment("")
      PreferenceComment("Folding Keywords")
      PreferenceComment("")
      PreferenceGroup("Folding")
      
      StartCount = CountGadgetItems(#GADGET_Preferences_FoldStartList)
      EndCount = CountGadgetItems(#GADGET_Preferences_FoldEndList)
      WritePreferenceLong("StartWords", StartCount)
      WritePreferenceLong("EndWords", EndCount)
      
      For i = 1 To StartCount
        WritePreferenceString("Start_"+Str(i), GetGadgetItemText(#GADGET_Preferences_FoldStartList, i-1, 0))
      Next i
      For i = 1 To EndCount
        WritePreferenceString("End_"+Str(i), GetGadgetItemText(#GADGET_Preferences_FoldEndList, i-1, 0))
      Next i
    EndIf
    
    ClosePreferences()
    MessageRequester(#ProductName$, Language("Preferences", "ExportComplete"), #FLAG_Info)
  Else
    MessageRequester(#ProductName$, LanguagePattern("Misc", "PreferenceError", "%filename%", FileName$), #FLAG_ERROR)
  EndIf
  
EndProcedure

Procedure ImportPreferences()
  FileName$ = ResolveRelativePath(CurrentDirectory$, GetGadgetText(#GADGET_Preferences_ImportFile))
  
  If OpenPreferences(FileName$)
    
    If PreferenceGroup("Sections") = 0
      ; check for the jaPBe files...
      
      ClosePreferences() ; must reopen the file to get the non-group strings in a jaPBe file
      OpenPreferences(FileName$)
      
      If ReadPreferenceString("DefaultFont", "--non-existent--") <> "--non-existent--"
        
        ; we can only take the colors from the file, toolspanel/debugger colors not supported
        
        Colors( 0)\PrefsValue = ValHex(ReadPreferenceString("ASMKeywordFore",  Hex(Colors( 0)\PrefsValue)))
        Colors( 1)\PrefsValue = ValHex(ReadPreferenceString("DefaultBack",     Hex(Colors( 1)\PrefsValue)))
        Colors( 2)\PrefsValue = ValHex(ReadPreferenceString("KeyCommandFore",  Hex(Colors( 2)\PrefsValue)))
        Colors( 3)\PrefsValue = ValHex(ReadPreferenceString("CommentFore",     Hex(Colors( 3)\PrefsValue)))
        Colors( 4)\PrefsValue = ValHex(ReadPreferenceString("ConstantFore",    Hex(Colors( 4)\PrefsValue)))
        Colors( 5)\PrefsValue = ValHex(ReadPreferenceString("DefaultFore",     Hex(Colors( 5)\PrefsValue)))
        Colors( 6)\PrefsValue = ValHex(ReadPreferenceString("DefaultFore",     Hex(Colors( 6)\PrefsValue)))
        Colors( 7)\PrefsValue = ValHex(ReadPreferenceString("DigitFore",       Hex(Colors( 7)\PrefsValue)))
        Colors( 8)\PrefsValue = ValHex(ReadPreferenceString("OperatorsFore",   Hex(Colors( 8)\PrefsValue)))
        Colors( 9)\PrefsValue = ValHex(ReadPreferenceString("VariableFore",    Hex(Colors( 9)\PrefsValue)))
        Colors(10)\PrefsValue = ValHex(ReadPreferenceString("PBProcedureFore", Hex(Colors(10)\PrefsValue)))
        Colors(11)\PrefsValue = ValHex(ReadPreferenceString("SeparatorsFore",  Hex(Colors(11)\PrefsValue)))
        Colors(12)\PrefsValue = ValHex(ReadPreferenceString("StringFore",      Hex(Colors(12)\PrefsValue)))
        Colors(13)\PrefsValue = ValHex(ReadPreferenceString("StructureFore",   Hex(Colors(13)\PrefsValue)))
        Colors(14)\PrefsValue = ValHex(ReadPreferenceString("LineNumberFore",  Hex(Colors(14)\PrefsValue)))
        Colors(15)\PrefsValue = ValHex(ReadPreferenceString("LineNumberBack",  Hex(Colors(15)\PrefsValue)))
        Colors(16)\PrefsValue = ValHex(ReadPreferenceString("BookmarkFore",    Hex(Colors(16)\PrefsValue)))
        Colors(17)\PrefsValue = ValHex(ReadPreferenceString("CurrentLine",     Hex(Colors(17)\PrefsValue)))
        Colors(18)\PrefsValue = ValHex(ReadPreferenceString("DefaultFore",     Hex(Colors(18)\PrefsValue)))
        Colors(19)\PrefsValue = ValHex(ReadPreferenceString("Selection",       Hex(Colors(19)\PrefsValue)))
        Colors(20)\PrefsValue = ValHex(ReadPreferenceString("DefaultFore",     Hex(Colors(20)\PrefsValue)))
        
        ; apply the colors to the gadgets
        For i = 0 To #COLOR_Last
          UpdatePreferenceSyntaxColor(i, Colors(i)\PrefsValue)
        Next i
        
        MessageRequester(#ProductName$, Language("Preferences", "ImportComplete"), #FLAG_Info)
      Else
        MessageRequester(#ProductName$, Language("Preferences", "UnknownPrefFormat"), #FLAG_Error)
      EndIf
      
    Else ; ok, it is our own format
      
      IsShortcuts = ReadPreferenceLong("IncludeShortcuts", 0)
      IsToolbar   = ReadPreferenceLong("IncludeToolbar", 0)
      IsColors    = ReadPreferenceLong("IncludeColors", 0)
      IsFolding   = ReadPreferenceLong("IncludeFolding", 0)
      
      If GetGadgetState(#GADGET_Preferences_ImpShortcut) And IsShortcuts And PreferenceGroup("Shortcuts")
        Restore ShortcutItems
        For i = 0 To #MENU_LastShortcutItem
          Read.s MenuTitle$
          Read.s MenuItem$
          Read.l DefaultShortcut
          ShortcutName$ = ReadPreferenceString(MenuItem$, ShortcutToIndependentName(Prefs_KeyboardShortcuts(i)))
          Prefs_KeyboardShortcuts(i) = IndependentNameToShortcut(ShortcutName$)
        Next i
        FillShortcutList()
      EndIf
      
      If GetGadgetState(#GADGET_Preferences_ImpToolbar) And IsToolbar And PreferenceGroup("Toolbar")
        PreferenceToolbarCount = ReadPreferenceLong("ItemCount", PreferenceToolbarCount)
        ClearGadgetItems(#GADGET_Preferences_ToolbarList)
        
        For i = 1 To PreferenceToolbarCount
          PreferenceToolbar(i)\Name$ = ConvertToolbarIconName(ReadPreferenceString("Icon_"+Str(i), PreferenceToolbar(i)\Name$))
          PreferenceToolbar(i)\Action$ = ReadPreferenceString("Action_"+Str(i), PreferenceToolbar(i)\Action$)
          AddGadgetItem(#GADGET_Preferences_ToolbarList, -1, "")
        Next i
        
        UpdatePrefsToolbarList()
        ToolbarPreferenceMode = -1
        ToolbarPreferenceAction = -1
        UpdatePrefsToolbarItem()
        
      EndIf
      
      If GetGadgetState(#GADGET_Preferences_ImpColor) And IsColors And PreferenceGroup("Colors")
        
        Restore ColorKeys
        For i = 0 To #COLOR_Last
          Read.s ColorKey$
          Colors(i)\PrefsValue = ColorFromRGBString(ReadPreferenceString(ColorKey$, RGBString(Colors(i)\PrefsValue)))
          SetGadgetState(#GADGET_Preferences_FirstColorCheck+i, ReadPreferenceLong(ColorKey$+"_Used", GetGadgetState(#GADGET_Preferences_FirstColorCheck+i)))
          
          If Colors(i)\PrefsValue <> -1
            Color = Colors(i)\PrefsValue
            DisableGadget(#GADGET_Preferences_FirstColorText+i, 0)
            DisableGadget(#GADGET_Preferences_FirstSelectColor+i, 0)
          Else
            Color = $C0C0C0
            DisableGadget(#GADGET_Preferences_FirstColorText+i, 1)
            DisableGadget(#GADGET_Preferences_FirstSelectColor+i,1)
          EndIf
          UpdatePreferenceSyntaxColor(i, Color)
        Next i
        
        PreferenceToolsPanelFrontColor = ColorFromRGBString(ReadPreferenceString("ToolsPanel_FrontColor", RGBString(PreferenceToolsPanelFrontColor)))
        PreferenceToolsPanelBackColor = ColorFromRGBString(ReadPreferenceString("ToolsPanel_BackColor", RGBString(PreferenceToolsPanelBackColor)))
        
        If IsImage(#IMAGE_Preferences_ToolsPanelFrontColor)
          UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelFrontColor, #IMAGE_Preferences_ToolsPanelFrontColor, PreferenceToolsPanelFrontColor)
        EndIf
        
        If IsImage(#IMAGE_Preferences_ToolsPanelBackColor)
          UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelBackColor, #IMAGE_Preferences_ToolsPanelBackColor, PreferenceToolsPanelBackColor)
        EndIf
        
      EndIf
      
      If GetGadgetState(#GADGET_Preferences_ImpFolding) And IsFolding And PreferenceGroup("Folding")
        
        StartCount = ReadPreferenceLong("StartWords", 0)
        ClearGadgetItems(#GADGET_Preferences_FoldStartList)
        For i = 1 To StartCount
          String$ = ReadPreferenceString("Start_"+Str(i), "")
          If String$ <> ""
            AddGadgetItem(#GADGET_Preferences_FoldStartList, -1, String$)
          EndIf
        Next i
        
        EndCount = ReadPreferenceLong("EndWords", 0)
        ClearGadgetItems(#GADGET_Preferences_FoldEndList)
        For i = 1 To EndCount
          String$ = ReadPreferenceString("End_"+Str(i), "")
          If String$ <> ""
            AddGadgetItem(#GADGET_Preferences_FoldEndList, -1, String$)
          EndIf
        Next i
        
      EndIf
      MessageRequester(#ProductName$, Language("Preferences", "ImportComplete"), #FLAG_Info)
      
      
    EndIf
    
    ClosePreferences()
    
  Else
    MessageRequester(#ProductName$, Language("Misc", "ReadError")+".", #FLAG_ERROR)
  EndIf
  
EndProcedure

Procedure CheckImportPreferencesFile() ; open the file, do not import anything
  FileName$ = ResolveRelativePath(CurrentDirectory$, GetGadgetText(#GADGET_Preferences_ImportFile))
  
  If OpenPreferences(FileName$)
    DisableGadget(#GADGET_Preferences_Import, 0)
    
    If PreferenceGroup("Sections") = 0
      ; this might be a jaPBe color scheme file. i was asked to support this.
      DisableGadget(#GADGET_Preferences_ImpShortcut, 1)
      DisableGadget(#GADGET_Preferences_ImpToolbar, 1)
      DisableGadget(#GADGET_Preferences_ImpFolding, 1)
      
      ClosePreferences() ; must reopen the file to get the non-group strings in a jaPBe file
      OpenPreferences(FileName$)
      
      If ReadPreferenceString("DefaultFont", "--non-existent--") <> "--non-existent--"
        DisableGadget(#GADGET_Preferences_ImpColor, 0) ; yes, seems to be a jaPBe color file
      Else
        DisableGadget(#GADGET_Preferences_Import, 1) ; this file is unknown
        DisableGadget(#GADGET_Preferences_ImpColor, 1)
        MessageRequester(#ProductName$, Language("Preferences", "UnknownPrefFormat"), #FLAG_Error)
      EndIf
      
    Else ; our own export format it is.
      
      If ReadPreferenceLong("IncludeShortcuts", 0)
        DisableGadget(#GADGET_Preferences_ImpShortcut, 0)
      Else
        DisableGadget(#GADGET_Preferences_ImpShortcut, 1)
      EndIf
      
      If ReadPreferenceLong("IncludeToolbar", 0)
        DisableGadget(#GADGET_Preferences_ImpToolbar, 0)
      Else
        DisableGadget(#GADGET_Preferences_ImpToolbar, 1)
      EndIf
      
      If ReadPreferenceLong("IncludeColors", 0)
        DisableGadget(#GADGET_Preferences_ImpColor, 0)
      Else
        DisableGadget(#GADGET_Preferences_ImpColor, 1)
      EndIf
      
      If ReadPreferenceLong("IncludeFolding", 0)
        DisableGadget(#GADGET_Preferences_ImpFolding, 0)
      Else
        DisableGadget(#GADGET_Preferences_ImpFolding, 1)
      EndIf
      
    EndIf
    
    ClosePreferences()
    
  Else
    
    MessageRequester(#ProductName$, Language("Misc", "ReadError")+".")
    DisableGadget(#GADGET_Preferences_Import, 1)
    DisableGadget(#GADGET_Preferences_ImpShortcut, 1)
    DisableGadget(#GADGET_Preferences_ImpToolbar, 1)
    DisableGadget(#GADGET_Preferences_ImpColor, 1)
    DisableGadget(#GADGET_Preferences_ImpFolding, 1)
  EndIf
  
EndProcedure

; A quite often used piece of code so its separate
;
Procedure UpdateToolsPanel_ToolsSettings(Gadget)
  
  state = GetGadgetState(Gadget)
  If state <> -1
    If CurrentPreferenceTool
      CurrentPreferenceTool\PreferenceDestroy() ; close the settings for previous tool
      FreeGadget(#GADGET_Preferences_ToolSettingsScrollArea)
      SetGadgetText(#GADGET_Preferences_ToolSettingsTitle, Language("Preferences","Configuration"))
    EndIf
    CurrentPreferenceTool = 0
    
    If Gadget = #GADGET_Preferences_UsedTools
      SetGadgetState(#GADGET_Preferences_AvailableTools, -1) ; deselect the other gadget, so you can tell to which Tool the settings belong
      
      SelectElement(NewUsedPanelTools(), state)
      *CurrentPreferenceToolData = NewUsedPanelTools()
    Else
      SetGadgetState(#GADGET_Preferences_UsedTools, -1)
      
      SelectElement(AvailablePanelTools(), state)
      *CurrentPreferenceToolData = @AvailablePanelTools()
    EndIf
    
    If *CurrentPreferenceToolData\NeedConfiguration
      CurrentPreferenceTool = *CurrentPreferenceToolData
      OpenGadgetList(#GADGET_Preferences_ToolSettingsContainer)
      ScrollAreaGadget(#GADGET_Preferences_ToolSettingsScrollArea, 0, 0, GadgetWidth(#GADGET_Preferences_ToolSettingsContainer), GadgetHeight(#GADGET_Preferences_ToolSettingsContainer), *CurrentPreferenceToolData\PreferencesWidth, *CurrentPreferenceToolData\PreferencesHeight, 10, #PB_ScrollArea_Single)
      CurrentPreferenceTool\PreferenceCreate()
      CloseGadgetList()
      CloseGadgetList()
      
      If *CurrentPreferenceToolData\ExternalPlugin
        SetGadgetText(#GADGET_Preferences_ToolSettingsTitle, Language("Preferences","Configuration") + " - " + *CurrentPreferenceToolData\ToolName$)
      Else
        SetGadgetText(#GADGET_Preferences_ToolSettingsTitle, Language("Preferences","Configuration") + " - " + Language("ToolsPanel", *CurrentPreferenceToolData\ToolName$))
      EndIf
    EndIf
    
    If Gadget = #GADGET_Preferences_UsedTools
      DisableGadget(#GADGET_Preferences_AddTool, 1)
      DisableGadget(#GADGET_Preferences_RemoveTool, 0)
      If state > 0
        DisableGadget(#GADGET_Preferences_MoveToolUp, 0)
      Else
        DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
      EndIf
      
      If state < ListSize(NewUsedPanelTools())-1
        DisableGadget(#GADGET_Preferences_MoveToolDown, 0)
      Else
        DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
      EndIf
      
    Else
      ; check if this tool exists in the used list
      SelectElement(AvailablePanelTools(), state)
      found = 0
      
      ForEach NewUsedPanelTools()
        If NewUsedPanelTools() = @AvailablePanelTools()
          found = 1
          Break
        EndIf
      Next NewUsedPanelTools()
      
      If found = 0
        DisableGadget(#GADGET_Preferences_AddTool, 0)
      Else
        DisableGadget(#GADGET_Preferences_AddTool, 1)
      EndIf
      DisableGadget(#GADGET_Preferences_RemoveTool, 1)
      DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
      DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
      
    EndIf
    
  Else
    
    DisableGadget(#GADGET_Preferences_AddTool, 1)
    DisableGadget(#GADGET_Preferences_RemoveTool, 1)
    DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
    DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
    
  EndIf
  
EndProcedure

Procedure Preferences_AddNewCompiler(Executable$)
  ;
  ; The user can open/drag:
  ; - the PureBasic folder
  ; - the Compilers folder
  ; - the Compiler executable
  ;
  If Right(Executable$, 1) = #Separator
    Executable$ = Left(Executable$, Len(Executable$)-1)
  EndIf
  
  Compiler$ = ""
  
  If FileSize(Executable$) > 0
    Compiler$ = UniqueFileName(Executable$)
    
    CompilerIf #CompileWindows
    ElseIf FileSize(Executable$ + "\PBCompiler.exe") > 0
      Compiler$ = UniqueFileName(Executable$ + "\PBCompiler.exe")
      
    ElseIf FileSize(Executable$ + "\Compilers\PBCompiler.exe") > 0
      Compiler$= UniqueFileName(Executable$ + "\Compilers\PBCompiler.exe")
    CompilerElse
    ElseIf FileSize(Executable$ + "/pbcompiler") > 0
      Compiler$ = UniqueFileName(Executable$ + "/pbcompiler")
      
    ElseIf FileSize(Executable$ + "/compilers/pbcompiler") > 0
      Compiler$ = UniqueFileName(Executable$ + "/compilers/pbcompiler")
    CompilerEndIf
    
  EndIf
  
  If Compiler$ = "" ; no matching file found
    AddElement(PreferenceCompilers())
    PreferenceCompilers()\Executable$ = Executable$
    PreferenceCompilers()\Validated   = #False
    
  Else
    
    ; Check if the compiler is already present
    ;
    If IsEqualFile(Compiler$, DefaultCompiler\Executable$)
      SetGadgetState(#GADGET_Preferences_CompilerList, -1)
      ProcedureReturn
    EndIf
    
    ForEach PreferenceCompilers()
      If IsEqualFile(Compiler$, PreferenceCompilers()\Executable$)
        SetGadgetState(#GADGET_Preferences_CompilerList, ListIndex(PreferenceCompilers()))
        SetActiveGadget(#GADGET_Preferences_CompilerList)
        ProcedureReturn
      EndIf
    Next PreferenceCompilers()
    
    ; Validate and add
    ;
    AddElement(PreferenceCompilers())
    GetCompilerVersion(Compiler$, @PreferenceCompilers())
    
    If PreferenceCompilers()\Validated
      AddGadgetItem(#GADGET_Preferences_CompilerList, -1, PreferenceCompilers()\VersionString$+Chr(10)+PreferenceCompilers()\Executable$)
      AddGadgetItem(#GADGET_Preferences_SelectCustomCompiler, -1, PreferenceCompilers()\VersionString$)
    Else
      AddGadgetItem(#GADGET_Preferences_CompilerList, -1, Language("Compiler","UnknownVersion")+Chr(10)+PreferenceCompilers()\Executable$)
    EndIf
    SetActiveGadget(#GADGET_Preferences_CompilerList)
    
  EndIf
  
EndProcedure

Procedure PreferencesWindowEvents(EventID)
  Static DragItem
  
  ; Note: on linux there seems to be an event sometimes after the window closed.. to be investigated
  If IsWindow(#WINDOW_Preferences) = 0
    ProcedureReturn
  EndIf
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    EventGadgetID = EventMenu()
  Else
    EventGadgetID = EventGadget()
  EndIf
  
  
  If EventID = #PB_Event_GadgetDrop
    Select EventGadgetID
        
      Case #GADGET_Preferences_ToolbarList
        Target = GetGadgetState(#GADGET_Preferences_ToolbarList)
        If Target = -1
          Target = CountGadgetItems(#GADGET_Preferences_ToolbarList)-1
        EndIf
        
        Target + 1   ; array indexes are 1-based!
        DragItem + 1
        
        If Target <> DragItem
          Name$ = PreferenceToolbar(DragItem)\Name$
          Action$ = PreferenceToolbar(DragItem)\Action$
          If Target > DragItem
            For i = DragItem To Target-1
              PreferenceToolbar(i)\Name$ = PreferenceToolbar(i+1)\Name$
              PreferenceToolbar(i)\Action$ = PreferenceToolbar(i+1)\Action$
            Next i
            
          Else
            For i = DragItem To Target+1 Step -1
              PreferenceToolbar(i)\Name$ = PreferenceToolbar(i-1)\Name$
              PreferenceToolbar(i)\Action$ = PreferenceToolbar(i-1)\Action$
            Next i
            
          EndIf
          PreferenceToolbar(Target)\Name$ = Name$
          PreferenceToolbar(Target)\Action$ = Action$
          UpdatePrefsToolbarList()
        EndIf
        UpdatePrefsToolbarItem()
        
        
      Case #GADGET_Preferences_SourcePath
        Path$ = StringField(EventDropFiles(), 1, Chr(10))
        If FileSize(Path$) <> -2 ; probably a file then
          Path$ = GetPathPart(Path$)
        EndIf
        SetGadgetText(#GADGET_Preferences_SourcePath, Path$)
        
      Case #GADGET_Preferences_KeywordList
        If EventDropType() = #PB_Drop_Text
          Text$ = EventDropText()
          
          ; we accept any word as a keyword in the text...
          *Pointer.Character = @Text$
          While *Pointer\c
            While *Pointer\c And ValidCharacters(*Pointer\c) = 0 ; skip everything else
              *Pointer + SizeOf(Character)
            Wend
            
            If ValidCharacters(*Pointer\c)
              *Start = *Pointer
              While *Pointer\c And ValidCharacters(*Pointer\c)
                *Pointer + SizeOf(Character)
              Wend
              Word$ = PeekS(*Start, (*Pointer-*Start)/SizeOf(Character))
              AddGadgetItem(#GADGET_Preferences_KeywordList, -1, Word$)
            EndIf
          Wend
          SetGadgetState(#GADGET_Preferences_KeywordList, CountGadgetItems(#GADGET_Preferences_KeywordList)-1)
          SetGadgetState(#GADGET_Preferences_KeywordList, -1)
          
        Else
          File$ = StringField(EventDropFiles(), 1, Chr(10))
          
          If ReadFile(#FILE_LoadFunctions, File$)
            While Not Eof(#FILE_LoadFunctions)
              Word$ = Trim(RemoveString(ReadString(#FILE_LoadFunctions), Chr(9)))
              
              *Cursor.Character = @Word$
              While *Cursor\c
                If ValidCharacters(*Cursor\c) = 0
                  Word$ = ""
                  Break
                EndIf
                *Cursor + SizeOf(Character)
              Wend
              
              If Word$ <> ""
                AddGadgetItem(#GADGET_Preferences_KeywordList, -1, Word$)
              EndIf
            Wend
            CloseFile(#FILE_LoadFunctions)
          EndIf
          SetGadgetState(#GADGET_Preferences_KeywordList, CountGadgetItems(#GADGET_Preferences_KeywordList)-1)
          SetGadgetState(#GADGET_Preferences_KeywordList, -1)
          
        EndIf
        
      Case #GADGET_Preferences_KeywordFile
        File$ = StringField(EventDropFiles(), 1, Chr(10))
        SetGadgetText(#GADGET_Preferences_KeywordFile, File$)
        
        
        ; we can handle both cases the same here...
      Case #GADGET_Preferences_FoldStartList, #GADGET_Preferences_FoldEndList
        Text$ = EventDropText()
        
        ; we accept any word as a keyword in the text...
        *Pointer.Character = @Text$
        While *Pointer\c
          While *Pointer\c And ValidCharacters(*Pointer\c) = 0 ; skip everything else
            *Pointer + SizeOf(Character)
          Wend
          
          If ValidCharacters(*Pointer\c)
            *Start = *Pointer
            While *Pointer\c And ValidCharacters(*Pointer\c)
              *Pointer + SizeOf(Character)
            Wend
            Word$ = PeekS(*Start, (*Pointer-*Start)/SizeOf(Character))
            
            If Word$ <> "" And CountGadgetItems(EventGadgetID) < #MAX_FoldWords
              AddGadgetItem(EventGadgetID, -1, Word$)
            EndIf
          EndIf
        Wend
        SetGadgetState(EventGadgetID, CountGadgetItems(EventGadgetID)-1)
        SetGadgetState(EventGadgetID, -1)
        
        
      Case #GADGET_Preferences_ExportFile
        File$ = StringField(EventDropFiles(), 1, Chr(10))
        SetGadgetText(#GADGET_Preferences_ExportFile, File$)
        
      Case #GADGET_Preferences_ImportFile
        File$ = StringField(EventDropFiles(), 1, Chr(10))
        SetGadgetText(#GADGET_Preferences_ImportFile, File$)
        
        
      Case #GADGET_Preferences_UsedTools
        If EventDropPrivate() = #DRAG_Preferences_ToolsFromAvailable
          ; add from available list (if not already present)
          SelectElement(AvailablePanelTools(), DragItem)
          found = 0
          
          ForEach NewUsedPanelTools()
            If NewUsedPanelTools() = @AvailablePanelTools()
              found = 1
              SetGadgetState(#GADGET_Preferences_UsedTools, ListIndex(NewUsedPanelTools()))
              Break
            EndIf
          Next NewUsedPanelTools()
          
          If found = 0
            Target = GetGadgetState(#GADGET_Preferences_UsedTools)
            If Target = -1
              Target = CountGadgetItems(#GADGET_Preferences_UsedTools)
              LastElement(NewUsedPanelTools())
              AddElement(NewUsedPanelTools())
            Else
              SelectElement(NewUsedPanelTools(), Target)
              InsertElement(NewUsedPanelTools())
            EndIf
            
            NewUsedPanelTools() = @AvailablePanelTools()
            
            If AvailablePanelTools()\ExternalPlugin
              AddGadgetItem(#GADGET_Preferences_UsedTools, Target, AvailablePanelTools()\ToolName$+"*")
            Else
              AddGadgetItem(#GADGET_Preferences_UsedTools, Target, Language("ToolsPanel", AvailablePanelTools()\ToolName$))
            EndIf
            
            SetGadgetState(#GADGET_Preferences_UsedTools, Target)
          EndIf
          
        Else
          ; reorder list
          Target = GetGadgetState(#GADGET_Preferences_UsedTools)
          If Target = -1
            Target = CountGadgetItems(#GADGET_Preferences_UsedTools)-1
          EndIf
          
          If Target <> DragItem
            SelectElement(NewUsedPanelTools(), DragItem)
            Value = NewUsedPanelTools()
            Text$ = GetGadgetItemText(#GADGET_Preferences_UsedTools, DragItem)
            
            DeleteElement(NewUsedPanelTools())
            
            If Target > DragItem
              For i = DragItem To Target-1
                SetGadgetItemText(#GADGET_Preferences_UsedTools, i, GetGadgetItemText(#GADGET_Preferences_UsedTools, i+1))
              Next i
              
              SelectElement(NewUsedPanelTools(), Target-1)
              AddElement(NewUsedPanelTools())
              
            Else
              For i = DragItem To Target+1 Step -1
                SetGadgetItemText(#GADGET_Preferences_UsedTools, i, GetGadgetItemText(#GADGET_Preferences_UsedTools, i-1))
              Next i
              
              SelectElement(NewUsedPanelTools(), Target)
              InsertElement(NewUsedPanelTools())
              
            EndIf
            
            NewUsedPanelTools() = Value
            SetGadgetItemText(#GADGET_Preferences_UsedTools, Target, Text$)
            
          EndIf
          
          SetGadgetState(#GADGET_Preferences_UsedTools, Target)
        EndIf
        
        UpdateToolsPanel_ToolsSettings(#GADGET_Preferences_UsedTools)
        
        
      Case #GADGET_Preferences_AvailableTools
        ; a drop means we are deleting from the used list
        SelectElement(NewUsedPanelTools(), DragItem)
        DeleteElement(NewUsedPanelTools())
        RemoveGadgetItem(#GADGET_Preferences_UsedTools, DragItem)
        
        If CurrentPreferenceTool
          CurrentPreferenceTool\PreferenceDestroy() ; close the settings for previous tool
          FreeGadget(#GADGET_Preferences_ToolSettingsScrollArea)
        EndIf
        CurrentPreferenceTool = 0
        SetGadgetState(#GADGET_Preferences_AvailableTools, -1)
        SetGadgetState(#GADGET_Preferences_UsedTools, -1)
        DisableGadget(#GADGET_Preferences_AddTool, 1)
        DisableGadget(#GADGET_Preferences_RemoveTool, 1)
        DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
        DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
        
      Case #GADGET_Preferences_CompilerList
        Files$ = EventDropFiles()
        Count  = CountString(EventDropFiles(), Chr(10)) + 1
        For i = 1 To Count
          Preferences_AddNewCompiler(StringField(Files$, i, Chr(10)))
        Next i
        
      Case #GADGET_Preferences_CompilerExe
        SetGadgetText(#GADGET_Preferences_CompilerExe, StringField(EventDropFiles(), 1, Chr(10)))
        
    EndSelect
    
    If IsPreferenceChanged()
      DisableGadget(#GADGET_Preferences_Apply, 0)
    Else
      DisableGadget(#GADGET_Preferences_Apply, 1)
    EndIf
    
  ElseIf EventID = #PB_Event_Gadget
    
    Select EventGadgetID
        
        CompilerIf #SpiderBasic
        Case #GADGET_Preferences_SelectWebBrowser
          CompilerIf #CompileWindows
            Pattern$ = Language("Compiler","ExePattern")
          CompilerElse
            Pattern$ = ""
          CompilerEndIf
          Filename$ = OpenFileRequester("Select Web Browser", OptionWebBrowser$, Pattern$, 0)
          If Filename$
            SetGadgetText(#GADGET_Preferences_WebBrowser, Filename$)
          EndIf
          
        Case #GADGET_Preferences_SelectJDK
          Path$ = PathRequester("Select JDK", OptionJDK$)
          If Path$
            SetGadgetText(#GADGET_Preferences_JDK, Path$)
          EndIf
          
        CompilerEndIf
        
      Case #GADGET_Preferences_Tree
        index = GetGadgetState(#GADGET_Preferences_Tree)
        CompilerIf #SpiderBasic
          If index > 16 : index + 4 : EndIf ; As we have remove some tree item, we need to shift them
        CompilerEndIf
        If index <> -1 And index <> PreferenceCurrentPage
          HideGadget(#GADGET_Preferences_FirstContainer+index, 0)
          HideGadget(#GADGET_Preferences_FirstContainer+PreferenceCurrentPage, 1)
          PreferenceCurrentPage = index
        EndIf
        
      Case #GADGET_Preferences_Ok
        ApplyPreferences()
        Quit = 1
        
      Case #GADGET_Preferences_Cancel
        Quit = 1
        
      Case #GADGET_Preferences_Apply
        DisableGadget(#GADGET_Preferences_Ok, 1) ; disable OK/Cancel to avoid a crash if OK is called during the apply (as we process the event loop somewhere in ApplyPreferences() -> recursive call)
        DisableGadget(#GADGET_Preferences_Cancel, 1)
        ApplyPreferences()
        UpdatePreferenceWindow()
        SetWindowForeground(#WINDOW_Preferences)
        DisableGadget(#GADGET_Preferences_Apply, 1)
        DisableGadget(#GADGET_Preferences_Ok, 0)
        DisableGadget(#GADGET_Preferences_Cancel, 0)
        
      Case #GADGET_Preferences_PageUp
        index = GetGadgetState(#GADGET_Preferences_Tree)
        If index > 0
          SetGadgetState(#GADGET_Preferences_Tree, index - 1)
        ElseIf index = -1
          SetGadgetState(#GADGET_Preferences_Tree, 0)
        EndIf
        SetActiveGadget(#GADGET_Preferences_Tree)
        PostEvent(#PB_Event_Gadget, #WINDOW_Preferences, #GADGET_Preferences_Tree, #PB_EventType_Change)
        
      Case #GADGET_Preferences_PageDown
        index = GetGadgetState(#GADGET_Preferences_Tree)
        If index < CountGadgetItems(#GADGET_Preferences_Tree) - 1
          SetGadgetState(#GADGET_Preferences_Tree, index + 1)
        ElseIf index = -1
          SetGadgetState(#GADGET_Preferences_Tree, 0)
        EndIf
        SetActiveGadget(#GADGET_Preferences_Tree)
        PostEvent(#PB_Event_Gadget, #WINDOW_Preferences, #GADGET_Preferences_Tree, #PB_EventType_Change)
        
      Case #GADGET_Preferences_EnableAccessibility
        ; disable the menu icons setting (force it to off) if this is enabled
        If GetGadgetState(#GADGET_Preferences_EnableAccessibility)
          SetGadgetState(#GADGET_Preferences_EnableMenuIcons, 0)
          DisableGadget(#GADGET_Preferences_EnableMenuIcons, #True)
        Else
          DisableGadget(#GADGET_Preferences_EnableMenuIcons, #False)
        EndIf
        
      Case #GADGET_Preferences_EnableHistory
        Enabled = GetGadgetState(#GADGET_Preferences_EnableHistory)
        For i = #GADGET_Preferences_HistoryTimer To #GADGET_Preferences_HistoryCount
          DisableGadget(i, 1-Enabled)
        Next i
        
      Case #GADGET_Preferences_GetSourcePath
        Path$ = PathRequester("", GetGadgetText(#GADGET_Preferences_SourcePath))
        If Path$ <> ""
          SetGadgetText(#GADGET_Preferences_SourcePath, Path$)
        EndIf
        
        
        ;       Case #GADGET_Preferences_EnableColoring
        ;         state = GetGadgetState(#GADGET_Preferences_EnableColoring)
        ;         DisableGadget(#GADGET_Preferences_EnableBolding, 1-state)
        ;         For i = #GADGET_Preferences_FirstSelectColor To #GADGET_Preferences_LastSelectColor
        ;           DisableGadget(i, 1-state)
        ;         Next i
        
      Case #GADGET_Preferences_EnableLineNumbers
        state = GetGadgetState(#GADGET_Preferences_EnableLineNumbers)
        
        For i = #GADGET_Preferences_FoldStartList To #GADGET_Preferences_FoldEndRemove
          DisableGadget(i, 1-state)
        Next i
        
        If state = 1 And GetGadgetState(#GADGET_Preferences_EnableFolding) = 0
          For i = #GADGET_Preferences_FoldStartList To #GADGET_Preferences_FoldEndRemove
            DisableGadget(i, 1)
          Next i
        EndIf
        
        ;       Case #GADGET_Preferences_EnableMarkers
        ;         DisableGadget(#GADGET_Preferences_MemorizeMarkers, 1-GetGadgetState(#GADGET_Preferences_EnableMarkers))
        
      Case #GADGET_Preferences_EnableFolding
        state = GetGadgetState(#GADGET_Preferences_EnableFolding)
        For i = #GADGET_Preferences_FoldStartList To #GADGET_Preferences_FoldEndRemove
          DisableGadget(i, 1-state)
        Next i
        
      Case #GADGET_Preferences_SelectFont
        If FontRequester(PreferenceFontName$, PreferenceFontSize, PreferenceFontStyle) And SelectedFontName() <> ""
          
          If LoadFont(#FONT_Preferences_CurrentFont, SelectedFontName(), SelectedFontSize(), SelectedFontStyle())
            SetGadgetFont(#GADGET_Preferences_CurrentFont, FontID(#FONT_Preferences_CurrentFont))
            
            PreferenceFontName$ = SelectedFontName()
            PreferenceFontSize  = SelectedFontSize()
            PreferenceFontStyle = SelectedFontStyle()
          Else
            LoadFont(#FONT_Preferences_CurrentFont, PreferenceFontName$, PreferenceFontSize, PreferenceFontStyle)
            SetGadgetFont(#GADGET_Preferences_CurrentFont, FontID(#FONT_Preferences_CurrentFont))
          EndIf
        EndIf
        
      Case #GADGET_Preferences_Languages
        If SelectedLanguage <> GetGadgetState(#GADGET_Preferences_Languages)
          SelectedLanguage = GetGadgetState(#GADGET_Preferences_Languages)
          SelectElement(AvailableLanguages(), SelectedLanguage)
          
          Info$ = Language("Preferences", "LanguageInfo") + ":"  + #NewLine + #NewLine
          Info$ + Language("Preferences", "LastUpdated")  + ":    " + AvailableLanguages()\Date$ + #NewLine
          Info$ + Language("Preferences", "Creator")      + ":    " + AvailableLanguages()\Creator$ + #NewLine
          Info$ + Language("Preferences", "Email")        + ":    " + AvailableLanguages()\CreatorEmail$ + #NewLine + #NewLine
          Info$ + Language("Preferences", "FileName")     + ":    " + CreateRelativePath(PureBasicPath$, AvailableLanguages()\FileName$)
          SetGadgetText(#GADGET_Preferences_LanguageInfo, Info$)
        EndIf
        
      Case #GADGET_Preferences_GetKeywordFile
        File$ = OpenFileRequester(Language("Preferences", "OpenKeywordFile"), GetGadgetText(#GADGET_Preferences_KeywordFile), Language("Compiler", "AllFilesPattern"), 0)
        If File$ <> ""
          SetGadgetText(#GADGET_Preferences_KeywordFile, File$)
        EndIf
        
        
      Case #GADGET_Preferences_KeywordAdd
        Text$ = GetGadgetText(#GADGET_Preferences_KeywordText)
        If Text$ <> ""
          AddGadgetItem(#GADGET_Preferences_KeywordList, -1, Text$)
          SetGadgetState(#GADGET_Preferences_KeywordList, CountGadgetItems(#GADGET_Preferences_KeywordList)-1)
          SetGadgetState(#GADGET_Preferences_KeywordList, -1)
          SetGadgetText(#GADGET_Preferences_KeywordText, "")
        EndIf
        
      Case #GADGET_Preferences_KeywordRemove
        ; go backwards, so the removed items do not change any index...
        For i = CountGadgetItems(#GADGET_Preferences_KeywordList)-1 To 0 Step -1
          If GetGadgetItemState(#GADGET_Preferences_KeywordList, i) ; selected
            RemoveGadgetItem(#GADGET_Preferences_KeywordList, i)
          EndIf
        Next i
        
      Case #GADGET_Preferences_FoldStartAdd
        Text$ = GetGadgetText(#GADGET_Preferences_FoldStartText)
        If Text$ <> "" And CountGadgetItems(#GADGET_Preferences_FoldStartList) < #MAX_FoldWords
          AddGadgetItem(#GADGET_Preferences_FoldStartList, -1, Text$)
          SetGadgetState(#GADGET_Preferences_FoldStartList, CountGadgetItems(#GADGET_Preferences_FoldStartList)-1)
          SetGadgetState(#GADGET_Preferences_FoldStartList, -1)
          SetGadgetText(#GADGET_Preferences_FoldStartText, "")
        EndIf
        
      Case #GADGET_Preferences_FoldEndAdd
        Text$ = GetGadgetText(#GADGET_Preferences_FoldEndText)
        If Text$ <> "" And CountGadgetItems(#GADGET_Preferences_FoldEndList) < #MAX_FoldWords
          AddGadgetItem(#GADGET_Preferences_FoldEndList, -1, Text$)
          SetGadgetState(#GADGET_Preferences_FoldEndList, CountGadgetItems(#GADGET_Preferences_FoldEndList)-1)
          SetGadgetState(#GADGET_Preferences_FoldEndList, -1)
          SetGadgetText(#GADGET_Preferences_FoldEndText, "")
        EndIf
        
      Case #GADGET_Preferences_FoldStartRemove
        ; go backwards, so the removed items do not change any index...
        For i = CountGadgetItems(#GADGET_Preferences_FoldStartList)-1 To 0 Step -1
          If GetGadgetItemState(#GADGET_Preferences_FoldStartList, i) ; selected
            RemoveGadgetItem(#GADGET_Preferences_FoldStartList, i)
          EndIf
        Next i
        
      Case #GADGET_Preferences_FoldEndRemove
        ; go backwards, so the removed items do not change any index...
        For i = CountGadgetItems(#GADGET_Preferences_FoldEndList)-1 To 0 Step -1
          If GetGadgetItemState(#GADGET_Preferences_FoldEndList, i) ; selected
            RemoveGadgetItem(#GADGET_Preferences_FoldEndList, i)
          EndIf
        Next i
        
        
      Case #GADGET_Preferences_ToolbarList
        UpdatePrefsToolbarItem()
        
        If EventType() = #PB_EventType_DragStart
          DragItem = GetGadgetState(#GADGET_Preferences_ToolbarList)
          If DragItem <> -1
            DragPrivate(#DRAG_Preferences_Toolbar, #PB_Drag_Move)
          EndIf
        EndIf
        
      Case #GADGET_Preferences_ToolbarIconType
        UpdatePrefsToolbarItem()
        
      Case #GADGET_Preferences_ToolbarIconList
        UpdatePrefsToolbarItem()
        
      Case #GADGET_Preferences_ToolbarOpenIcon
        CompilerIf #CompileWindows
          Pattern$ = Language("Preferences","IconPattern")
        CompilerElse
          Pattern$ = RemoveString(RemoveString(Language("Preferences","IconPattern"), "*.ico;"), "*.ico,") ; remove icons
        CompilerEndIf
        File$ = OpenFileRequester(Language("Preferences","OpenIcon"), GetGadgetText(#GADGET_Preferences_ToolbarIconName), Pattern$, 0)
        If File$ <> ""
          SetGadgetText(#GADGET_Preferences_ToolbarIconName, File$)
        EndIf
        
      Case #GADGET_Preferences_ToolbarActionType
        UpdatePrefsToolbarItem()
        
      Case #GADGET_Preferences_ToolbarActionList
        UpdatePrefsToolbarItem()
        
      Case #GADGET_Preferences_ToolbarMoveUp
        index = GetGadgetState(#GADGET_Preferences_ToolbarList) + 1
        If index > 1
          Name$ = PreferenceToolbar(index)\Name$
          Action$ = PreferenceToolbar(index)\Action$
          PreferenceToolbar(index)\Name$ = PreferenceToolbar(index-1)\Name$
          PreferenceToolbar(index)\Action$ = PreferenceToolbar(index-1)\Action$
          PreferenceToolbar(index-1)\Name$ = Name$
          PreferenceToolbar(index-1)\Action$ = Action$
          SetGadgetState(#GADGET_Preferences_ToolbarList, index-2)
          UpdatePrefsToolbarList()
        EndIf
        
      Case #GADGET_Preferences_ToolbarMoveDown
        index = GetGadgetState(#GADGET_Preferences_ToolbarList) + 1
        If index < PreferenceToolbarCount And index <> 0
          Name$ = PreferenceToolbar(index)\Name$
          Action$ = PreferenceToolbar(index)\Action$
          PreferenceToolbar(index)\Name$ = PreferenceToolbar(index+1)\Name$
          PreferenceToolbar(index)\Action$ = PreferenceToolbar(index+1)\Action$
          PreferenceToolbar(index+1)\Name$ = Name$
          PreferenceToolbar(index+1)\Action$ = Action$
          SetGadgetState(#GADGET_Preferences_ToolbarList, index)
          UpdatePrefsToolbarList()
        EndIf
        
      Case #GADGET_Preferences_ToolbarDelete
        index = GetGadgetState(#GADGET_Preferences_ToolbarList) + 1
        If index <> 0
          For i = index+1 To PreferenceToolbarCount
            PreferenceToolbar(i-1)\Name$ = PreferenceToolbar(i)\Name$
            PreferenceToolbar(i-1)\Action$ = PreferenceToolbar(i)\Action$
          Next i
          PreferenceToolbarCount - 1
          RemoveGadgetItem(#GADGET_Preferences_ToolbarList, index-1)
          
          If index > 1
            SetGadgetState(#GADGET_Preferences_ToolbarList, index-2)
          Else
            SetGadgetState(#GADGET_Preferences_ToolbarList, index-1)
          EndIf
          SetActiveGadget(#GADGET_Preferences_ToolbarList) ; make the new mark visible
        EndIf
        
      Case #GADGET_Preferences_ToolbarAdd
        
        If PreferenceToolbarCount < #MAX_ToolbarButtons
          AddGadgetItem(#GADGET_Preferences_ToolbarList, -1, "")
          PreferenceToolbarCount + 1
          index = PreferenceToolbarCount
          If GetGadgetState(#GADGET_Preferences_ToolbarIconType) = #TOOLBARICONTYPE_Separator
            PreferenceToolbar(index)\Name$ = "Separator"
            PreferenceToolbar(index)\Action$ = ""
          ElseIf GetGadgetState(#GADGET_Preferences_ToolbarIconType) = #TOOLBARICONTYPE_Space
            PreferenceToolbar(index)\Name$ = "Space"
            PreferenceToolbar(index)\Action$ = ""
          Else
            Select GetGadgetState(#GADGET_Preferences_ToolbarIconType)
              Case #TOOLBARICONTYPE_Internal
                PreferenceToolbar(index)\Name$ = ToolbarMenuName$(GetGadgetState(#GADGET_Preferences_ToolbarIconList)+1)
              Case #TOOLBARICONTYPE_External
                PreferenceToolbar(index)\Name$ = "External:"+GetGadgetText(#GADGET_Preferences_ToolbarIconName)
            EndSelect
            
            If GetGadgetState(#GADGET_Preferences_ToolbarActionType) = 0
              PreferenceToolbar(index)\Action$ = ToolbarMenuName$(GetGadgetState(#GADGET_Preferences_ToolbarActionList)+1)
            Else
              PreferenceToolbar(index)\Action$ = "Tool:"+GetGadgetText(#GADGET_Preferences_ToolbarActionList)
            EndIf
          EndIf
          UpdatePrefsToolbarList()
        Else
          MessageRequester("PureBasic", Language("Preferences","MaxItems"), #FLAG_Error)
        EndIf
        
      Case #GADGET_Preferences_ToolbarSet
        index = GetGadgetState(#GADGET_Preferences_ToolbarList) + 1
        If index <> 0
          
          If GetGadgetState(#GADGET_Preferences_ToolbarIconType) = #TOOLBARICONTYPE_Separator
            PreferenceToolbar(index)\Name$ = "Separator"
            PreferenceToolbar(index)\Action$ = ""
          ElseIf GetGadgetState(#GADGET_Preferences_ToolbarIconType) = #TOOLBARICONTYPE_Space
            PreferenceToolbar(index)\Name$ = "Space"
            PreferenceToolbar(index)\Action$ = ""
          Else
            Select GetGadgetState(#GADGET_Preferences_ToolbarIconType)
              Case #TOOLBARICONTYPE_Internal
                PreferenceToolbar(index)\Name$ = ToolbarMenuName$(GetGadgetState(#GADGET_Preferences_ToolbarIconList)+1)
              Case #TOOLBARICONTYPE_External
                PreferenceToolbar(index)\Name$ = "External:"+GetGadgetText(#GADGET_Preferences_ToolbarIconName)
            EndSelect
            
            If GetGadgetState(#GADGET_Preferences_ToolbarActionType) = 0
              PreferenceToolbar(index)\Action$ = ToolbarMenuName$(GetGadgetState(#GADGET_Preferences_ToolbarActionList)+1)
            Else
              PreferenceToolbar(index)\Action$ = "Tool:"+GetGadgetText(#GADGET_Preferences_ToolbarActionList)
            EndIf
          EndIf
          UpdatePrefsToolbarList()
        EndIf
        
      Case #GADGET_Preferences_ToolbarClassic
        ClearGadgetItems(#GADGET_Preferences_ToolbarList)
        Restore ToolbarClassic
        
        Read.l PreferenceToolbarCount
        For i = 1 To PreferenceToolbarCount
          Read.s PreferenceToolbar(i)\Name$
          Read.s PreferenceToolbar(i)\Action$
          AddGadgetItem(#GADGET_Preferences_ToolbarList, -1, "")
        Next i
        UpdatePrefsToolbarList()
        UpdatePrefsToolbarItem()
        
      Case #GADGET_Preferences_ToolbarDefault
        ClearGadgetItems(#GADGET_Preferences_ToolbarList)
        Restore ToolbarPureBAsic
        
        Read.l PreferenceToolbarCount
        For i = 1 To PreferenceToolbarCount
          Read.s PreferenceToolbar(i)\Name$
          Read.s PreferenceToolbar(i)\Action$
          AddGadgetItem(#GADGET_Preferences_ToolbarList, -1, "")
        Next i
        UpdatePrefsToolbarList()
        UpdatePrefsToolbarItem()
        
      Case #GADGET_Preferences_VistaAdmin
        If GetGadgetState(#GADGET_Preferences_VistaAdmin)
          SetGadgetState(#GADGET_Preferences_VistaUser, 0) ; both cannot be at once
        EndIf
        
      Case #GADGET_Preferences_VistaUser
        If GetGadgetState(#GADGET_Preferences_VistaUser)
          SetGadgetState(#GADGET_Preferences_VistaAdmin, 0) ; both cannot be at once
        EndIf
        
        
      Case #GADGET_Preferences_AutoPopup
        state = GetGadgetState(#GADGET_Preferences_AutoPopup)
        ;        DisableGadget(#GADGET_Preferences_NoComments, 1-state)
        ;        DisableGadget(#GADGET_Preferences_NoStrings, 1-state)
        DisableGadget(#GADGET_Preferences_AutoPopupLength, 1-state)
        DisableGadget(#GADGET_Preferences_AutoPopupText, 1-state)
        
        
      Case #GADGET_Preferences_ToolsPanelFrontColorSelect
        Color = ColorRequester(PreferenceToolsPanelFrontColor)
        If Color <> -1
          PreferenceToolsPanelFrontColor = Color
          If IsImage(#IMAGE_Preferences_ToolsPanelFrontColor)
            UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelFrontColor, #IMAGE_Preferences_ToolsPanelFrontColor, Color)
          EndIf
        EndIf
        
      Case #GADGET_Preferences_ToolsPanelBackColorSelect
        Color = ColorRequester(PreferenceToolsPanelBackColor)
        If Color <> -1
          PreferenceToolsPanelBackColor = Color
          If IsImage(#IMAGE_Preferences_ToolsPanelBackColor)
            UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelBackColor, #IMAGE_Preferences_ToolsPanelBackColor, Color)
          EndIf
        EndIf
        
      Case #GADGET_Preferences_SelectToolsPanelFont
        If FontRequester(PreferenceToolsPanelFont$, PreferenceToolsPanelFontSize, PreferenceToolsPanelFontStyle) <> 0 And SelectedFontName() <> ""
          PreferenceToolsPanelFont$ = SelectedFontName()
          PreferenceToolsPanelFontSize = SelectedFontSize()
          PreferenceToolsPanelFontStyle = SelectedFontStyle()
        EndIf
        
      Case #GADGET_Preferences_UseToolsPanelFont
        state = GetGadgetState(#GADGET_Preferences_UseToolsPanelFont)
        DisableGadget(#GADGET_Preferences_SelectToolsPanelFont, 1-state)
        
      Case #GADGET_Preferences_UseToolsPanelColors
        state = GetGadgetState(#GADGET_Preferences_UseToolsPanelColors)
        DisableGadget(#GADGET_Preferences_ToolsPanelFrontColorSelect, 1-state)
        DisableGadget(#GADGET_Preferences_ToolsPanelBackColorSelect, 1-state)
        
      Case #GADGET_Preferences_AvailableTools
        UpdateToolsPanel_ToolsSettings(#GADGET_Preferences_AvailableTools)
        
        If EventType() = #PB_EventType_DragStart
          DragItem = GetGadgetState(#GADGET_Preferences_AvailableTools)
          If DragItem <> -1
            DragPrivate(#DRAG_Preferences_ToolsFromAvailable, #PB_Drag_Copy)
          EndIf
        EndIf
        
        
      Case #GADGET_Preferences_UsedTools
        UpdateToolsPanel_ToolsSettings(#GADGET_Preferences_UsedTools)
        
        If EventType() = #PB_EventType_DragStart
          DragItem = GetGadgetState(#GADGET_Preferences_UsedTools)
          If DragItem <> -1
            DragPrivate(#DRAG_Preferences_ToolsFromUsed, #PB_Drag_Move)
          EndIf
        EndIf
        
        
      Case #GADGET_Preferences_AddTool
        SelectElement(AvailablePanelTools(), GetGadgetState(#GADGET_Preferences_AvailableTools))
        found = 0
        
        ForEach NewUsedPanelTools()
          If NewUsedPanelTools() = @AvailablePanelTools()
            found = 1
            SetGadgetState(#GADGET_Preferences_UsedTools, ListIndex(NewUsedPanelTools()))
            Break
          EndIf
        Next NewUsedPanelTools()
        
        If found = 0
          LastElement(NewUsedPanelTools())
          AddElement(NewUsedPanelTools())
          NewUsedPanelTools() = @AvailablePanelTools()
          
          If AvailablePanelTools()\ExternalPlugin
            AddGadgetItem(#GADGET_Preferences_UsedTools, -1, AvailablePanelTools()\ToolName$+"*")
          Else
            AddGadgetItem(#GADGET_Preferences_UsedTools, -1, Language("ToolsPanel", AvailablePanelTools()\ToolName$))
          EndIf
          DisableGadget(#GADGET_Preferences_AddTool, 1)
        EndIf
        
        
      Case #GADGET_Preferences_RemoveTool
        SelectElement(NewUsedPanelTools(), GetGadgetState(#GADGET_Preferences_UsedTools))
        DeleteElement(NewUsedPanelTools())
        RemoveGadgetItem(#GADGET_Preferences_UsedTools, GetGadgetState(#GADGET_Preferences_UsedTools))
        
        If CurrentPreferenceTool
          CurrentPreferenceTool\PreferenceDestroy() ; close the settings for previous tool
          FreeGadget(#GADGET_Preferences_ToolSettingsScrollArea)
        EndIf
        CurrentPreferenceTool = 0
        DisableGadget(#GADGET_Preferences_AddTool, 1)
        DisableGadget(#GADGET_Preferences_RemoveTool, 1)
        DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
        DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
        
        
      Case #GADGET_Preferences_MoveToolUp
        index = GetGadgetState(#GADGET_Preferences_UsedTools)
        SelectElement(NewUsedPanelTools(), index)
        
        Current = NewUsedPanelTools()
        PreviousElement(NewUsedPanelTools())
        Previous = NewUsedPanelTools()
        NewUsedPanelTools() = Current
        NextElement(NewUsedPanelTools())
        NewUsedPanelTools() = Previous
        
        Text$ = GetGadgetItemText(#GADGET_Preferences_UsedTools, index, 0)
        SetGadgetItemText(#GADGET_Preferences_UsedTools, index, GetGadgetItemText(#GADGET_Preferences_UsedTools, index-1, 0), 0)
        SetGadgetItemText(#GADGET_Preferences_UsedTools, index-1, Text$, 0)
        SetGadgetState(#GADGET_Preferences_UsedTools, index-1)
        
        If index <= 1
          DisableGadget(#GADGET_Preferences_MoveToolUp, 1)
        EndIf
        DisableGadget(#GADGET_Preferences_MoveToolDown, 0)
        
        
      Case #GADGET_Preferences_MoveToolDown
        index = GetGadgetState(#GADGET_Preferences_UsedTools)
        SelectElement(NewUsedPanelTools(), index)
        
        Current = NewUsedPanelTools()
        NextElement(NewUsedPanelTools())
        NextElement = NewUsedPanelTools()
        NewUsedPanelTools() = Current
        PreviousElement(NewUsedPanelTools())
        NewUsedPanelTools() = NextElement
        
        Text$ = GetGadgetItemText(#GADGET_Preferences_UsedTools, index, 0)
        SetGadgetItemText(#GADGET_Preferences_UsedTools, index, GetGadgetItemText(#GADGET_Preferences_UsedTools, index+1, 0), 0)
        SetGadgetItemText(#GADGET_Preferences_UsedTools, index+1, Text$, 0)
        SetGadgetState(#GADGET_Preferences_UsedTools, index+1)
        
        DisableGadget(#GADGET_Preferences_MoveToolUp, 0)
        If index >= ListSize(NewUsedPanelTools())-2
          DisableGadget(#GADGET_Preferences_MoveToolDown, 1)
        EndIf
        
      Case #GADGET_Preferences_AutoHidePanel
        state = GetGadgetState(#GADGET_Preferences_AutoHidePanel)
        DisableGadget(#GADGET_Preferences_ToolsPanelDelay, 1-state)
        DisableGadget(#GADGET_Preferences_ToolsPanelDelayText, 1-state)
        
        
      Case #GADGET_Preferences_ShortcutList
        index = GetGadgetState(#GADGET_Preferences_ShortcutList)
        If index = -1
          Shortcut = 0
        Else
          Shortcut = Prefs_KeyboardShortcuts(index)
        EndIf
        SetGadgetState(#GADGET_Preferences_SelectShortcut, Shortcut)
        
        ;         If Shortcut & #PB_Shortcut_Control ; on win98, using "Shortcut & #PB_Shortcut_Control" directly in setgadgetstate does not work!
        ;           SetGadgetState(#GADGET_Preferences_ShortcutControl, 1)
        ;         Else
        ;           SetGadgetState(#GADGET_Preferences_ShortcutControl, 0)
        ;         EndIf
        ;         If Shortcut & #PB_Shortcut_Alt
        ;           SetGadgetState(#GADGET_Preferences_ShortcutAlt,     1)
        ;         Else
        ;           SetGadgetState(#GADGET_Preferences_ShortcutAlt,     0)
        ;         EndIf
        ;         If Shortcut & #PB_Shortcut_Shift
        ;           SetGadgetState(#GADGET_Preferences_ShortcutShift,   1)
        ;         Else
        ;           SetGadgetState(#GADGET_Preferences_ShortcutShift,   0)
        ;         EndIf
        ;
        ;         CompilerIf #CompileMac
        ;           SetGadgetState(#GADGET_Preferences_ShortcutCommand, Shortcut & #PB_Shortcut_Command)
        ;         CompilerEndIf
        ;
        ;         SetGadgetState(#GADGET_Preferences_ShortcutKey, GetBaseKeyIndex(Shortcut))
        
      Case #GADGET_Preferences_ShortcutSet
        Shortcut = GetGadgetState(#GADGET_Preferences_SelectShortcut)
        ;         Shortcut = ShortcutValues(GetGadgetState(#GADGET_Preferences_ShortcutKey))
        ;         If GetGadgetState(#GADGET_Preferences_ShortcutControl)
        ;           Shortcut | #PB_Shortcut_Control
        ;         EndIf
        ;         If GetGadgetState(#GADGET_Preferences_ShortcutAlt)
        ;           Shortcut | #PB_Shortcut_Alt
        ;         EndIf
        ;         If GetGadgetState(#GADGET_Preferences_ShortcutShift)
        ;           Shortcut | #PB_Shortcut_Shift
        ;         EndIf
        ;         If GetGadgetState(#GADGET_Preferences_ShortcutCommand)
        ;           Shortcut | #PB_Shortcut_Command
        ;         EndIf
        
        index = GetGadgetState(#GADGET_Preferences_ShortcutList)
        If index >= 0
          If IsShortcutUsed(Shortcut, index, 0)
            ; Shortcut is already used... ask if user would like to reassign it now
            Text$ = Language("Shortcuts","AllreadyUsed")+#NewLine+Chr(34)+GetShortcutOwner(Shortcut)+Chr(34)+#NewLine+#NewLine+Language("Shortcuts","ReassignPrompt")
            If MessageRequester(#ProductName$, Text$, #FLAG_Question | #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes ; DO NOT FIX TYPO: AllreadyUsed
              For i = 0 To #MENU_LastShortcutItem
                If Prefs_KeyboardShortcuts(i) = Shortcut
                  Prefs_KeyboardShortcuts(i) = 0
                  SetGadgetItemText(#GADGET_Preferences_ShortcutList, i, "", 1)
                EndIf
              Next i
              Prefs_KeyboardShortcuts(index) = Shortcut ; must be before the SetText for OSX (see ShortcutManagement.pb)
              SetGadgetItemText(#GADGET_Preferences_ShortcutList, index, GetShortcutText(Shortcut), 1)
            EndIf
          Else
            Prefs_KeyboardShortcuts(index) = Shortcut ; must be before the SetText for OSX (see ShortcutManagement.pb)
            SetGadgetItemText(#GADGET_Preferences_ShortcutList, index, GetShortcutText(Shortcut), 1)
          EndIf
        EndIf
        
      Case #GADGET_Preferences_DebuggerMode
        If GetGadgetState(#GADGET_Preferences_DebuggerMode) <> 2 ; disable for console debugger only
          For i = #GADGET_Preferences_DebuggerMemorizeWindows To #GADGET_Preferences_WatchlistWindowOpen
            DisableGadget(i, 0)
          Next i
        Else
          For i = #GADGET_Preferences_DebuggerMemorizeWindows To #GADGET_Preferences_WatchlistWindowOpen
            DisableGadget(i, 1)
          Next i
        EndIf
        
      Case #GADGET_Preferences_DebugOutUseFont
        state = GetGadgetState(#GADGET_Preferences_DebugOutUseFont)
        DisableGadget(#GADGET_Preferences_DebugOutFont, 1-state)
        
      Case #GADGET_Preferences_DebugOutFont
        If FontRequester(PreferenceDebugOutFont$, PreferenceDebugOutFontSize, PreferenceDebugOutFontStyle) <> 0 And SelectedFontName() <> ""
          PreferenceDebugOutFont$ = SelectedFontName()
          PreferenceDebugOutFontSize = SelectedFontSize()
          PreferenceDebugOutFontStyle = SelectedFontStyle()
        EndIf
        
      Case #GADGET_Preferences_ColorSchemes
        index = GetGadgetState(#GADGET_Preferences_ColorSchemes)
        If index >= 0
          LoadColorSchemeToPreferencesWindow(GetGadgetItemData(#GADGET_Preferences_ColorSchemes, index))
        EndIf
        
      Case #GADGET_Preferences_GetExportFile
        File$ = SaveFileRequester(Language("Misc","SaveFile"), GetGadgetText(#GADGET_Preferences_ExportFile), Language("Preferences","PrefExportPattern"), 0)
        If File$ <> ""
          If GetExtensionPart(File$) = ""
            File$ + ".prefs"
          EndIf
          SetGadgetText(#GADGET_Preferences_ExportFile, File$)
        EndIf
        
      Case #GADGET_Preferences_GetImportFile
        File$ = OpenFileRequester(Language("Misc","OpenFile"), GetGadgetText(#GADGET_Preferences_ImportFile), Language("Preferences","PrefExportPattern"), 0)
        If File$ <> ""
          SetGadgetText(#GADGET_Preferences_ImportFile, File$)
          DisableGadget(#GADGET_Preferences_ImpShortcut, 1) ; disable again, as it is a new file
          DisableGadget(#GADGET_Preferences_ImpToolbar, 1)
          DisableGadget(#GADGET_Preferences_ImpColor, 1)
          DisableGadget(#GADGET_Preferences_ImpFolding, 1)
          DisableGadget(#GADGET_Preferences_Import, 1)
        EndIf
        
      Case #GADGET_Preferences_ImportFile
        If EventType() = #PB_EventType_Change
          DisableGadget(#GADGET_Preferences_ImpShortcut, 1) ; disable again, as it is a new file
          DisableGadget(#GADGET_Preferences_ImpToolbar, 1)
          DisableGadget(#GADGET_Preferences_ImpColor, 1)
          DisableGadget(#GADGET_Preferences_ImpFolding, 1)
          DisableGadget(#GADGET_Preferences_Import, 1)
        EndIf
        
      Case #GADGET_Preferences_Export
        ExportPreferences()
        
      Case #GADGET_Preferences_OpenImport
        CheckImportPreferencesFile()
        
      Case #GADGET_Preferences_Import
        ImportPreferences()
        
      Case #GADGET_Preferences_AddCompiler
        If GetGadgetText(#GADGET_Preferences_CompilerExe) <> ""
          Preferences_AddNewCompiler(GetGadgetText(#GADGET_Preferences_CompilerExe))
          SetGadgetText(#GADGET_Preferences_CompilerExe, "")
        EndIf
        
      Case #GADGET_Preferences_RemoveCompiler
        index = GetGadgetState(#GADGET_Preferences_CompilerList)
        If index <> -1
          RemovedVersion$ = GetGadgetItemText(#GADGET_Preferences_CompilerList, index, 0)
          RemoveGadgetItem(#GADGET_Preferences_CompilerList, index)
          SelectElement(PreferenceCompilers(), index)
          DeleteElement(PreferenceCompilers())
          
          ; remove also from compiler defaults gadget. Never remove the default compiler (index 0)
          For i = 1 To CountGadgetItems(#GADGET_Preferences_SelectCustomCompiler)-1
            If GetGadgetItemText(#GADGET_Preferences_SelectCustomCompiler, i, 0) = RemovedVersion$
              RemoveGadgetItem(#GADGET_Preferences_SelectCustomCompiler, i)
              Break
            EndIf
          Next i
          ; switch back to default if the selected compiler was removed
          If GetGadgetState(#GADGET_Preferences_SelectCustomCompiler) = -1
            SetGadgetState(#GADGET_Preferences_SelectCustomCompiler, 0)
          EndIf
        EndIf
        
      Case #GADGET_Preferences_ClearCompilers
        ClearGadgetItems(#GADGET_Preferences_CompilerList)
        ClearGadgetItems(#GADGET_Preferences_SelectCustomCompiler)
        AddGadgetItem(#GADGET_Preferences_SelectCustomCompiler, -1, DefaultCompiler\VersionString$) ; re-add default compiler
        ClearList(PreferenceCompilers())
        
      Case #GADGET_Preferences_SelectCompiler
        File$ = GetGadgetText(#GADGET_Preferences_CompilerExe)
        
        CompilerIf #CompileWindows
          Pattern$ = Language("Compiler","ExePattern")
          If File$ = "" : File$ = "PBCompiler.exe" : EndIf
        CompilerElse
          Pattern$ = Language("Compiler","AllFilesPattern")
          If File$ = "" : File$ = "pbcompiler" : EndIf
        CompilerEndIf
        
        File$ = OpenFileRequester(Language("Preferences","SelectCompiler"), File$, Pattern$, 0)
        If File$ <> ""
          SetGadgetText(#GADGET_Preferences_CompilerExe, File$)
        EndIf
        
      Case #GADGET_Preferences_CustomCompiler
        If GetGadgetState(#GADGET_Preferences_CustomCompiler)
          DisableGadget(#GADGET_Preferences_SelectCustomCompiler, #False)
        Else
          DisableGadget(#GADGET_Preferences_SelectCustomCompiler, #True)
        EndIf
        
        
      Case #GADGET_Preferences_IndentNo, #GADGET_Preferences_IndentBlock, #GADGET_Preferences_IndentSensitive
        If GetGadgetState(#GADGET_Preferences_IndentNo) Or GetGadgetState(#GADGET_Preferences_IndentBlock)
          Disable = #True
        Else
          Disable = #False
        EndIf
        For i = #GADGET_Preferences_IndentList To #GADGET_Preferences_IndentRemove
          DisableGadget(i, Disable)
        Next i
        
      Case #GADGET_Preferences_IndentList
        Index = GetGadgetState(#GADGET_Preferences_IndentList)
        If Index = -1
          SetGadgetText(#GADGET_Preferences_IndentKeyword, "")
          SetGadgetText(#GADGET_Preferences_IndentBefore, "")
          SetGadgetText(#GADGET_Preferences_IndentAfter, "")
        Else
          SetGadgetText(#GADGET_Preferences_IndentKeyword, GetGadgetItemText(#GADGET_Preferences_IndentList, Index, 0))
          SetGadgetText(#GADGET_Preferences_IndentBefore, GetGadgetItemText(#GADGET_Preferences_IndentList, Index, 1))
          SetGadgetText(#GADGET_Preferences_IndentAfter, GetGadgetItemText(#GADGET_Preferences_IndentList, Index, 2))
        EndIf
        
      Case #GADGET_Preferences_IndentAdd
        Keyword$ = Trim(GetGadgetText(#GADGET_Preferences_IndentKeyword))
        Before   = Val(GetGadgetText(#GADGET_Preferences_IndentBefore)) ; convert to numeric as a sanity check (removes bad input)
        After    = Val(GetGadgetText(#GADGET_Preferences_IndentAfter))
        
        If Keyword$ <> ""
          Index = GetGadgetState(#GADGET_Preferences_IndentList)
          If Index = -1 Or Keyword$ <> GetGadgetItemText(#GADGET_Preferences_IndentList, Index, 0)
            AddGadgetItem(#GADGET_Preferences_IndentList, -1, Keyword$+Chr(10)+Str(Before)+Chr(10)+Str(After))
            SetGadgetState(#GADGET_Preferences_IndentList, CountGadgetItems(#GADGET_Preferences_IndentList)-1)
            
            ; Clear for further input
            FlushEvents() ; Need to flush as else a #PB_EventType_Change causes an immediate update because of the SetGadgetState above
            SetGadgetText(#GADGET_Preferences_IndentKeyword, "")
            SetGadgetText(#GADGET_Preferences_IndentBefore, "")
            SetGadgetText(#GADGET_Preferences_IndentAfter, "")
          Else
            SetGadgetItemText(#GADGET_Preferences_IndentList, Index, Keyword$, 0)
            SetGadgetItemText(#GADGET_Preferences_IndentList, Index, Str(Before), 1)
            SetGadgetItemText(#GADGET_Preferences_IndentList, Index, Str(After), 2)
            
            ; Update to match our sanity checked input
            SetGadgetText(#GADGET_Preferences_IndentKeyword, Keyword$)
            SetGadgetText(#GADGET_Preferences_IndentBefore, Str(Before))
            SetGadgetText(#GADGET_Preferences_IndentAfter, Str(After))
          EndIf
        EndIf
        
      Case #GADGET_Preferences_IndentRemove
        Index = GetGadgetState(#GADGET_Preferences_IndentList)
        If Index <> -1
          RemoveGadgetItem(#GADGET_Preferences_IndentList, Index)
          SetGadgetText(#GADGET_Preferences_IndentKeyword, "")
          SetGadgetText(#GADGET_Preferences_IndentBefore, "")
          SetGadgetText(#GADGET_Preferences_IndentAfter, "")
        EndIf
        
      Case #GADGET_Preferences_IssueList
        index = GetGadgetState(#GADGET_Preferences_IssueList)
        If index < 0
          For i = #GADGET_Preferences_UpdateIssue To #GADGET_Preferences_IssueInBrowser
            DisableGadget(i, 1)
          Next i
        Else
          ; enable all gadgets
          For i = #GADGET_Preferences_UpdateIssue To #GADGET_Preferences_IssueInBrowser
            DisableGadget(i, 0)
          Next i
          
          ; set the proper data
          SelectElement(PreferenceIssues(), index)
          SetGadgetText(#GADGET_Preferences_IssueName, PreferenceIssues()\Name$)
          SetGadgetText(#GADGET_Preferences_IssueExpr, PreferenceIssues()\Expression$)
          SetGadgetState(#GADGET_Preferences_IssuePriority, PreferenceIssues()\Priority)
          SetGadgetState(#GADGET_Preferences_IssueInTool, PreferenceIssues()\InTool)
          SetGadgetState(#GADGET_Preferences_IssueInBrowser, PreferenceIssues()\InBrowser)
          
          UpdateImageColorGadget(#GADGET_Preferences_IssueColor, #IMAGE_Preferences_IssueColor, PreferenceIssues()\Color)
          PreferenceIssueColor = PreferenceIssues()\Color
          
          Select PreferenceIssues()\CodeMode
            Case 0
              SetGadgetState(#GADGET_Preferences_IssueCodeNoColor, 1)
              SetGadgetState(#GADGET_Preferences_IssueCodeBack, 0)
              SetGadgetState(#GADGET_Preferences_IssueCodeLine, 0)
            Case 1
              SetGadgetState(#GADGET_Preferences_IssueCodeNoColor, 0)
              SetGadgetState(#GADGET_Preferences_IssueCodeBack, 1)
              SetGadgetState(#GADGET_Preferences_IssueCodeLine, 0)
            Case 2
              SetGadgetState(#GADGET_Preferences_IssueCodeNoColor, 0)
              SetGadgetState(#GADGET_Preferences_IssueCodeBack, 0)
              SetGadgetState(#GADGET_Preferences_IssueCodeLine, 1)
          EndSelect
        EndIf
        
      Case #GADGET_Preferences_NewIssue, #GADGET_Preferences_UpdateIssue
        ; almost the same code here for both events
        ; first check regex
        regex = CreateRegularExpression(#PB_Any, GetGadgetText(#GADGET_Preferences_IssueExpr))
        If regex
          FreeRegularExpression(regex)
          
          ; there is a quite low limit (6) on possible markers for the issues, so check this here
          markers = 0
          ForEach PreferenceIssues()
            If PreferenceIssues()\CodeMode = 2
              markers + 1
            EndIf
          Next
          
          ; check the limit
          If GetGadgetState(#GADGET_Preferences_IssueCodeLine) = 0 Or markers < #MAX_IssueMarkers
            
            If EventGadgetID = #GADGET_Preferences_NewIssue
              LastElement(PreferenceIssues())
              AddElement(PreferenceIssues())
              PreferenceIssues()\Priority = 2 ; normal prio
              index = ListIndex(PreferenceIssues())
              AddGadgetItem(#GADGET_Preferences_IssueList, -1, "")
              PreferenceIssueColor = $c0c0c0
            Else
              index = GetGadgetState(#GADGET_Preferences_IssueList)
            EndIf
            
            If index <> -1
              ; update list
              SelectElement(PreferenceIssues(), index)
              PreferenceIssues()\Name$       = GetGadgetText(#GADGET_Preferences_IssueName)
              PreferenceIssues()\Expression$ = GetGadgetText(#GADGET_Preferences_IssueExpr)
              PreferenceIssues()\Priority    = GetGadgetState(#GADGET_Preferences_IssuePriority)
              PreferenceIssues()\Color       = PreferenceIssueColor
              PreferenceIssues()\InTool      = GetGadgetState(#GADGET_Preferences_IssueInTool)
              PreferenceIssues()\InBrowser   = GetGadgetState(#GADGET_Preferences_IssueInBrowser)
              
              If GetGadgetState(#GADGET_Preferences_IssueCodeNoColor)
                PreferenceIssues()\CodeMode = 0
              ElseIf GetGadgetState(#GADGET_Preferences_IssueCodeBack)
                PreferenceIssues()\CodeMode = 1
              Else
                PreferenceIssues()\CodeMode = 2
              EndIf
              
              ; update gadget
              SetGadgetItemText(#GADGET_Preferences_IssueList, index, PreferenceIssues()\Name$, 0)
              SetGadgetItemText(#GADGET_Preferences_IssueList, index, PreferenceIssues()\Expression$, 1)
              SetGadgetItemText(#GADGET_Preferences_IssueList, index, Language("ToolsPanel","Prio" + PreferenceIssues()\Priority), 2)
              SetGadgetItemImage(#GADGET_Preferences_IssueList, index, OptionalImageID(#IMAGE_Priority0 + PreferenceIssues()\Priority))
            EndIf
            
          Else
            ; too many marker issues
            MessageRequester(#ProductName$, ReplaceString(Language("Preferences","IssueCodeLineLimit"), "%limit%", Str(#MAX_IssueMarkers)), #FLAG_Error)
          EndIf
          
        Else
          ; regex is invalid
          MessageRequester(#ProductName$, Language("Preferences","InvalidExpr") + #NewLine + RegularExpressionError(), #FLAG_Error)
        EndIf
        
      Case #GADGET_Preferences_DeleteIssue
        index = GetGadgetState(#GADGET_Preferences_IssueList)
        If index <> -1
          SelectElement(PreferenceIssues(), index)
          DeleteElement(PreferenceIssues())
          RemoveGadgetItem(#GADGET_Preferences_IssueList, index)
          
          For i = #GADGET_Preferences_UpdateIssue To #GADGET_Preferences_IssueInBrowser
            DisableGadget(i, 1)
          Next i
        EndIf
        
      Case #GADGET_Preferences_SelectIssueColor
        NewColor = ColorRequester(PreferenceIssueColor)
        If NewColor <> -1
          UpdateImageColorGadget(#GADGET_Preferences_IssueColor, #IMAGE_Preferences_IssueColor, NewColor)
          PreferenceIssueColor = NewColor
        EndIf
        
      Default
        If EventGadgetID >= #GADGET_Preferences_FirstSelectColor And EventGadgetID <= #GADGET_Preferences_LastSelectColor
          index = EventGadgetID - #GADGET_Preferences_FirstSelectColor
          Color = ColorRequester(Colors(index)\PrefsValue)
          If Color <> -1
            Colors(index)\PrefsValue = Color
            UpdatePreferenceSyntaxColor(index, Color)
          EndIf
          
        ElseIf CurrentPreferenceTool  ; unknown gadget event.. sent too ToolsPanel tool
          CurrentPreferenceTool\PreferenceEvents(EventGadgetID)
        EndIf
        
    EndSelect
    
    ; NOTE: On linux (gtk2), there seems to be another event fired for this window, while it is closed. So the IsPreferenceChanged()
    ; will try to check gadgets which no longer exist. The If check prevents this, but this may still be a purebasic bug.
    ; Comment the outer 'If', open the preferences. Add a tool (like explorer), and click 'Ok'. The debugger will throw errors.
    ; Do the same and click 'Apply', and there is no error. So it is something together with ApplyPreferences() and closing the window.
    ; TODO: To be investigated more closely.
    ;
    If Quit = 0 And IsWindow(#WINDOW_Preferences)
      
      If IsPreferenceChanged()
        DisableGadget(#GADGET_Preferences_Apply, 0)
      Else
        DisableGadget(#GADGET_Preferences_Apply, 1)
      EndIf
      
    EndIf
    
  ElseIf EventID = #PB_Event_CloseWindow
    Quit = 1
    
  EndIf
  
  
  If Quit And IsApplyPreferences = #False ; Don't close the window if the prefs are currently applying, as it act on the preference window as well
    FreePrefsThemeList()
    
    FreeImage(#IMAGE_Preferences_ToolsPanelFrontColor)
    FreeImage(#IMAGE_Preferences_ToolsPanelBackColor)
    
    If IsFont(#FONT_Preferences_CurrentFont)
      FreeFont(#FONT_Preferences_CurrentFont)
    EndIf
    
    ClearList(NewUsedPanelTools())
    ClearList(PreferenceCompilers())
    
    Preferences_ImportFile$ = GetGadgetText(#GADGET_Preferences_ImportFile) ; only saved for this session
    Preferences_ExportFile$ = GetGadgetText(#GADGET_Preferences_ExportFile)
    
    For i = #IMAGE_Preferences_FirstColor To #IMAGE_Preferences_LastColor
      FreeImage(i)
    Next i
    
    If MemorizeWindow
      PreferenceWindowDialog\Close(@PreferenceWindowPosition)
    Else
      PreferenceWindowDialog\Close()
    EndIf
  EndIf
EndProcedure



DataSection
  
  ;- Color Preference keys
  ; List of names in order of the #COLOR values that contains the keys
  ; for loading/saving the preferences
  ;
  ColorKeys:
  Data$ "ASMKeywordColor"
  Data$ "BackgroundColor"
  Data$ "BasicKeywordColor"
  Data$ "CommentColor"
  Data$ "ConstantColor"
  Data$ "LabelColor"
  Data$ "NormalTextColor"
  Data$ "NumberColor"
  Data$ "OperatorColor"
  Data$ "PointerColor"
  Data$ "PureKeywordColor"
  Data$ "SeparatorColor"
  Data$ "StringColor"
  Data$ "StructureColor"
  Data$ "LineNumberColor"
  Data$ "LineNumberBackColor"
  Data$ "MarkerColor"
  Data$ "CurrentLineColor"
  Data$ "SelectionColor"
  Data$ "SelectionFrontColor"
  Data$ "CursorColor"
  Data$ "Debugger_LineColor"
  Data$ "Debugger_LineSymbolColor"
  Data$ "Debugger_ErrorColor"
  Data$ "Debugger_ErrorSymbolColor"
  Data$ "Debugger_BreakPointColor"
  Data$ "Debugger_BreakpoinSymbolColor"
  Data$ "DisabledBackColor"
  Data$ "GoodBraceColor"
  Data$ "BadBraceColor"
  Data$ "ProcedureBackColor"
  Data$ "CustomKeywordColor"
  Data$ "Debugger_WarningColor"
  Data$ "Debugger_WarningSymbolColor"
  Data$ "IndentColor"
  Data$ "ModuleColor"
  Data$ "SelectionRepeatColor"
  Data$ "PlainBackground"
  
  ;- DefaultColorSchemes
  ;
  ; default color schemes for the IDE preferences
  DefaultColorSchemes:
  
  CompilerIf #SpiderBasic
    
    ; now each color scheme. first the name string, then the front & backcolor
    ; for the toolspanel, then all the colors
    ; in order if the enumeration.
    
    Data$ "SpiderBasic"
    Data.l $000000 ;  ToolsPanelFrontColor
    Data.l $FFFFFF ;  ToolsPanelBackColor
    Data.l $800080 ; #COLOR_ASMKeyword
    Data.l $FFFFFF ; #COLOR_GlobalBackground
    Data.l $C37B23 ; #COLOR_BasicKeyword
    Data.l $009001 ; #COLOR_Comment
    Data.l $724B92 ; #COLOR_Constant
    Data.l $000000 ; #COLOR_Label
    Data.l $000000 ; #COLOR_NormalText
    Data.l $000000 ; #COLOR_Number
    Data.l $000000 ; #COLOR_Operator
    Data.l $000000 ; #COLOR_Pointer
    Data.l $F39B43 ; #COLOR_PureKeyword
    Data.l $000000 ; #COLOR_Separator
    Data.l $F39B43 ; #COLOR_String
    Data.l $000000 ; #COLOR_Structure
    Data.l $808080 ; #COLOR_LineNumber
    Data.l $F0F0F0 ; #COLOR_LineNumberBack
    Data.l $000000 ; #COLOR_Marker
    Data.l $F8F8F8 ; #COLOR_CurrentLine
    Data.l $6A240A ; #COLOR_Selection
    Data.l $FFFFFF ; #COLOR_SelectionFront
    Data.l $000000 ; #COLOR_Cursor
    Data.l $00FFFF ; #COLOR_DebuggerLine
    Data.l $00FFFF ; #COLOR_DebuggerLineSymbol
    Data.l $0000FF ; #COLOR_DebuggerError
    Data.l $0000FF ; #COLOR_DebuggerErrorSymbol
    Data.l $FFFF00 ; #COLOR_DebuggerBreakPoint
    Data.l $FFFF00 ; #COLOR_DebuggerBreakpointSymbol
    Data.l $F5F5F5 ; #COLOR_DisabledBack
    Data.l $CC0000 ; #COLOR_GoodBrace
    Data.l $0000CC ; #COLOR_BadBrace
    Data.l $FFFFFF ; #COLOR_ProcedureBack
    Data.l 0       ; #COLOR_CustomKeyword
    Data.l $0080FF ; #COLOR_DebuggerWarning
    Data.l $0080FF ; #COLOR_DebuggerWarningSymbol
    Data.l $008000 ; #COLOR_Whitespace
    Data.l $000000 ; #COLOR_Module
    Data.l $FAECAB ; #COLOR_SelectionRepeat
    Data.l $FFFFFF ; #COLOR_PlainBackground
    
  CompilerEndIf
  
  ; now each color scheme. first the name string, then the front & backcolor
  ; for the toolspanel, then all the colors
  ; in order if the enumeration.
  
  Data$ "PureBasic"
  Data.l 0       ;  ToolsPanelFrontColor
  Data.l $DFFFFF ;  ToolsPanelBackColor
  Data.l $724B92 ; #COLOR_ASMKeyword
  Data.l $DFFFFF ; #COLOR_GlobalBackground
  Data.l $666600 ; #COLOR_BasicKeyword
  Data.l $AAAA00 ; #COLOR_Comment
  Data.l $724B92 ; #COLOR_Constant
  Data.l 0       ; #COLOR_Label
  Data.l 0       ; #COLOR_NormalText
  Data.l 0       ; #COLOR_Number
  Data.l 0       ; #COLOR_Operator
  Data.l 0       ; #COLOR_Pointer
  Data.l $666600 ; #COLOR_PureKeyword
  Data.l 0       ; #COLOR_Separator
  Data.l $FF8000 ; #COLOR_String
  Data.l 0       ; #COLOR_Structure
  Data.l $808080 ; #COLOR_LineNumber
  Data.l $D7FFFF ; #COLOR_LineNumberBack
  Data.l $AAAA00 ; #COLOR_Marker
  Data.l $B7FFFF ; #COLOR_CurrentLine
  Data.l $C0C0C0 ; #COLOR_Selection
  Data.l 0       ; #COLOR_SelectionFront
  Data.l 0       ; #COLOR_Cursor
  Data.l $FFE8E8 ; #COLOR_DebuggerLine
  Data.l $FFE8E8 ; #COLOR_DebuggerLineSymbol
  Data.l $0000FF ; #COLOR_DebuggerError
  Data.l $0000FF ; #COLOR_DebuggerErrorSymbol
  Data.l $FFFF00 ; #COLOR_DebuggerBreakPoint
  Data.l $FFFF00 ; #COLOR_DebuggerBreakpointSymbol
  Data.l $F8F8F8 ; #COLOR_DisabledBack
  Data.l $666600 ; #COLOR_GoodBrace
  Data.l $0000FF ; #COLOR_BadBrace
  Data.l $DFFFFF ; #COLOR_ProcedureBack
  Data.l $660000 ; #COLOR_CustomKeyword
  Data.l $00D0FF ; #COLOR_DebuggerWarning
  Data.l $00D0FF ; #COLOR_DebuggerWarningSymbol
  Data.l $AAAA00 ; #COLOR_Whitespace
  Data.l 0       ; #COLOR_Module
  Data.l $A7FFB0 ; #COLOR_SelectionRepeat
  Data.l $DFFFFF ; #COLOR_PlainBackground
  
  
  Data$ "Accessibility"
AccessibilityColorScheme:
  Data.l 0        ;  ToolsPanelFrontColor
  Data.l $FFFFFF  ;  ToolsPanelBackColor
  Data.l $000000  ; #COLOR_ASMKeyword
  Data.l $FFFFFF  ; #COLOR_GlobalBackground
  Data.l $FF0000  ; #COLOR_BasicKeyword
  Data.l $0000FF  ; #COLOR_Comment
  Data.l 0        ; #COLOR_Constant
  Data.l 0        ; #COLOR_Label
  Data.l 0        ; #COLOR_NormalText
  Data.l 0        ; #COLOR_Number
  Data.l 0        ; #COLOR_Operator
  Data.l 0        ; #COLOR_Pointer
  Data.l 9        ; #COLOR_PureKeyword
  Data.l 0        ; #COLOR_Separator
  Data.l 0        ; #COLOR_String
  Data.l 0        ; #COLOR_Structure
  Data.l $FFFFFF  ; #COLOR_LineNumber
  Data.l 0        ; #COLOR_LineNumberBack
  Data.l 0        ; #COLOR_Marker
  Data.l $FFFFFF  ; #COLOR_CurrentLine
  Data.l -1       ; #COLOR_Selection  - special setting to always use the syscolors
  Data.l -1       ; #COLOR_SelectionFront
  Data.l 0        ; #COLOR_Cursor
  Data.l $00FFFF  ; #COLOR_DebuggerLine
  Data.l $00FFFF  ; #COLOR_DebuggerLineSymbol
  Data.l $0000FF  ; #COLOR_DebuggerError
  Data.l $0000FF  ; #COLOR_DebuggerErrorSymbol
  Data.l $008000  ; #COLOR_DebuggerBreakPoint
  Data.l $008000  ; #COLOR_DebuggerBreakpointSymbol
  Data.l $C0C0C0  ; #COLOR_DisabledBack
  Data.l 0        ; #COLOR_GoodBrace
  Data.l $0000FF  ; #COLOR_BadBrace
  Data.l $FFFFFF  ; #COLOR_ProcedureBack
  Data.l 0        ; #COLOR_CustomKeyword
  Data.l $0080FF  ; #COLOR_DebuggerWarning
  Data.l $0080FF  ; #COLOR_DebuggerWarningSymbol
  Data.l $0000FF  ; #COLOR_Whitespace
  Data.l 0        ; #COLOR_Module
  Data.l $FFFFFF  ; #COLOR_SelectionRepeat
  Data.l $FFFFFF  ; #COLOR_PlainBackground
  
  Data$ ""        ; Empty string to mark the end of the Default Color Schemes
  
  
  ; List of default Indent keywords (as of 4.50)
  ; Newer keywords are added in the code above for a better transition between versions
  ; Format is: Keyword, Indentunits before, IndentUnits after
  ; Order and case do not matter
  ;
  DefaultIndentList:
  Data.l 45   ; Number of default keywords
  
  Data$ "If":                Data.l  0, 1
  Data$ "Else":              Data.l -1, 1
  Data$ "ElseIf":            Data.l -1, 1
  Data$ "EndIf":             Data.l -1, 0
  
  Data$ "Select":            Data.l  0, 2
  Data$ "Case":              Data.l -1, 1
  Data$ "Default":           Data.l -1, 1
  Data$ "EndSelect":         Data.l -2, 0
  
  Data$ "CompilerSelect":    Data.l  0, 2
  Data$ "CompilerCase":      Data.l -1, 1
  Data$ "CompilerDefault":   Data.l -1, 1
  Data$ "CompilerEndSelect": Data.l -2, 0
  
  Data$ "CompilerIf":        Data.l  0, 1
  Data$ "CompilerElse":      Data.l -1, 1
  Data$ "CompilerEndIf":     Data.l -1, 0
  
  Data$ "DataSection":       Data.l  0, 1
  Data$ "EndDataSection":    Data.l -1, 0
  
  Data$ "Procedure":         Data.l  0, 1
  Data$ "ProcedureC":        Data.l  0, 1
  Data$ "ProcedureCDLL":     Data.l  0, 1
  Data$ "ProcedureDLL":      Data.l  0, 1
  Data$ "EndProcedure":      Data.l -1, 0
  
  Data$ "For":               Data.l  0, 1
  Data$ "ForEach":           Data.l  0, 1
  Data$ "Next":              Data.l -1, 0
  
  Data$ "Repeat":            Data.l  0, 1
  Data$ "ForEver":           Data.l -1, 0
  Data$ "Until":             Data.l -1, 0
  
  Data$ "While":             Data.l  0, 1
  Data$ "Wend":              Data.l -1, 0
  
  Data$ "Import":            Data.l  0, 1
  Data$ "ImportC":           Data.l  0, 1
  Data$ "EndImport":         Data.l -1, 0
  
  Data$ "Enumeration":       Data.l  0, 1
  Data$ "EndEnumeration":    Data.l -1, 0
  
  Data$ "Interface":         Data.l  0, 1
  Data$ "EndInterface":      Data.l -1, 0
  
  Data$ "Macro":             Data.l  0, 1
  Data$ "EndMacro":          Data.l -1, 0
  
  Data$ "Structure":         Data.l  0, 1
  Data$ "EndStructure":      Data.l -1, 0
  
  Data$ "StructureUnion":    Data.l  0, 1
  Data$ "EndStructureUnion": Data.l -1, 0
  
  Data$ "With":              Data.l  0, 1
  Data$ "EndWith":           Data.l -1, 0
  
  
EndDataSection
