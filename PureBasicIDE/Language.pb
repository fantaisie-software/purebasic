; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Global NbLanguageGroups, NbLanguageStrings

Structure LanguageInfo
  Name$
  FileName$
  Date$
  Creator$
  CreatorEmail$
EndStructure

Global NewList AvailableLanguages.LanguageInfo()

Structure LanguageGroup
  Name$
  GroupStart.l
  GroupEnd.l
  IndexTable.l[256]
EndStructure

Procedure GetLanguageInfo(FileName$)
  
  If OpenPreferences(FileName$)
    
    If PreferenceGroup("LanguageInfo")
      
      If ReadPreferenceString("Application", "") = #CatalogFileIDE ; to sort out similar language files for different applications
        
        Name$ = ReadPreferenceString("Language", "")
        If Name$ <> "" And UCase(Name$) <> "ENGLISH" ; use internal strings instead of the english file
          
          AddElement(AvailableLanguages())
          AvailableLanguages()\Name$         = Name$
          AvailableLanguages()\FileName$     = FileName$
          AvailableLanguages()\Date$         = ReadPreferenceString("LastUpdated", "-")
          AvailableLanguages()\Creator$      = ReadPreferenceString("Creator", "-")
          AvailableLanguages()\CreatorEmail$ = ReadPreferenceString("Email", "-")
          
        EndIf
        
      EndIf
    EndIf
    ClosePreferences()
  EndIf
  
EndProcedure

Procedure CollectLanguageInfo()
  
  ClearList(AvailableLanguages())
  
  ; add the base language
  ;
  AddElement(AvailableLanguages())
  AvailableLanguages()\Name$         = "English"
  AvailableLanguages()\FileName$     = "-------"
  AvailableLanguages()\Date$         = FormatDate("%mm/%dd/%yyyy", #PB_Compiler_Date)
  AvailableLanguages()\Creator$      = #ProductName$ + " Team"
  AvailableLanguages()\CreatorEmail$ = "support@" + LCase(#ProductName$) + ".com"
  
  ; find more language files
  ;
  If ExamineDirectory(0, PureBasicPath$ + #DEFAULT_CatalogPath, "*.catalog")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = 1
        GetLanguageInfo(PureBasicPath$ + #DEFAULT_CatalogPath+DirectoryEntryName(0))
      EndIf
    Wend
    
    FinishDirectory(0)
  EndIf
  
  ; look in subfolders of the catalogs path as well..
  ;
  If ExamineDirectory(0, PureBasicPath$ + #DEFAULT_CatalogPath, "*.*")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = 2
        If DirectoryEntryName(0) <> ".." And DirectoryEntryName(0) <> "."
          Directory$ = PureBasicPath$ + #DEFAULT_CatalogPath + DirectoryEntryName(0) + #Separator
          If ExamineDirectory(1, Directory$, "*.catalog")
            While NextDirectoryEntry(1)
              If DirectoryEntryType(1) = 1
                GetLanguageInfo(Directory$ + DirectoryEntryName(1))
              EndIf
            Wend
            
            FinishDirectory(1)
          EndIf
        EndIf
      EndIf
    Wend
    
    FinishDirectory(0)
  EndIf
  
EndProcedure

; Read the entry from the language file and apply any needed codepage
; translation to oem page.
; (note that the codepage stuff is windows+unicode only For now.)
;
Procedure.s ReadLanguageEntry(Key$, DefaultValue$)
  Result$ = ReadPreferenceString(Key$, DefaultValue$)
  
  CompilerIf #CompileWindows
    CompilerIf #PB_Compiler_Unicode ; only in unicode mode (standalone debugger)
      
      ; It was loaded using the ANSI codepage, so we transform it to ascii with that
      ;
      *AsciiBuffer = AllocateMemory(StringByteLength(Result$, #PB_Ascii) + 1)
      If *AsciiBuffer
        PokeS(*AsciiBuffer, Result$, -1, #PB_Ascii)
        
        ; now transform back to unicode with the oem codepage
        ;
        Length = MultiByteToWideChar_(#CP_OEMCP, 0, *AsciiBuffer, -1, 0, 0)
        Result$ = Space(Length)
        
        MultiByteToWideChar_(CodePage, 0, *AsciiBuffer, -1, @Result$, Length)
        FreeMemory(*AsciiBuffer)
      EndIf
      
    CompilerEndIf
  CompilerEndIf
  
  ProcedureReturn Trim(Result$)
EndProcedure

Procedure LoadLanguage()
  
  ; do a quick count in the datasection:
  ;
  NbLanguageGroups = 0
  NbLanguageStrings = 0
  
  Restore Language
  Repeat
    
    Read.s Name$
    Read.s String$
    
    Name$ = UCase(Name$)
    
    If Name$ = "_GROUP_"
      NbLanguageGroups + 1
    ElseIf Name$ = "_END_"
      Break
    Else
      NbLanguageStrings + 1
    EndIf
    
  ForEver
  
  Global Dim LanguageGroups.LanguageGroup(NbLanguageGroups)  ; all one based here
  Global Dim LanguageStrings.s(NbLanguageStrings)
  Global Dim LanguageNames.s(NbLanguageStrings)
  
  ; Now load the standard language:
  ;
  Group = 0
  StringIndex = 0
  
  Restore Language
  Repeat
    
    Read.s Name$
    Read.s String$
    
    Name$ = UCase(Name$)
    
    If Name$ = "_GROUP_"
      LanguageGroups(Group)\GroupEnd   = StringIndex
      Group + 1
      
      LanguageGroups(Group)\Name$      = UCase(String$)
      LanguageGroups(Group)\GroupStart = StringIndex + 1
      For i = 0 To 255
        LanguageGroups(Group)\IndexTable[i] = 0
      Next i
      
    ElseIf Name$ = "_END_"
      Break
      
    Else
      StringIndex + 1
      LanguageNames(StringIndex)   = Name$ + Chr(1) + String$  ; keep name and string together for easier sorting
      
    EndIf
    
  ForEver
  
  LanguageGroups(Group)\GroupEnd   = StringIndex ; set end for the last group!
  
  ; Now do the sorting and the indexing for each group
  ;
  For Group = 1 To NbLanguageGroups
    If LanguageGroups(Group)\GroupStart <= LanguageGroups(Group)\GroupEnd  ; sanity check.. check for empty groups
      
      SortArray(LanguageNames(), 0, LanguageGroups(Group)\GroupStart, LanguageGroups(Group)\GroupEnd)
      
      char = 0
      For StringIndex = LanguageGroups(Group)\GroupStart To LanguageGroups(Group)\GroupEnd
        LanguageStrings(StringIndex) = StringField(LanguageNames(StringIndex), 2, Chr(1)) ; splitt the value from the name
        LanguageNames(StringIndex)   = StringField(LanguageNames(StringIndex), 1, Chr(1))
        
        If Asc(Left(LanguageNames(StringIndex), 1)) <> char
          char = Asc(Left(LanguageNames(StringIndex), 1))
          LanguageGroups(Group)\IndexTable[char] = StringIndex
        EndIf
      Next StringIndex
      
    EndIf
  Next Group
  
  ; Now try to load an external language file
  ;
  If CurrentLanguage$ <> "English"
    
    ; get info from the saved languagefilename only
    If LanguageFile$ <> ""
      GetLanguageInfo(LanguageFile$)
    EndIf
    
    Found = 0
    
    ; do a quick search if the language is found.
    ; if the LanguageFile$ was valid, there should be only this one language in the list.
    ;
    ForEach AvailableLanguages()
      If UCase(AvailableLanguages()\Name$) = UCase(CurrentLanguage$)
        Found = 1
        Break
      EndIf
    Next AvailableLanguages()
    
    ; if the language is not found yet, the LanguageFile$ was probably invalid
    ; (maybe the purebasic dir was moved or something..)
    ; Do a complete scan for languages then
    If Found = 0
      CollectLanguageInfo()
      
      ; search again
      ForEach AvailableLanguages()
        If UCase(AvailableLanguages()\Name$) = UCase(CurrentLanguage$)
          Found = 1
          Break
        EndIf
      Next AvailableLanguages()
    EndIf
    
    If Found
      ; save for the next IDE start:
      LanguageFile$ = AvailableLanguages()\FileName$
      
      ; Try to detect if the file is utf8 (because if it is, do not translate stuff to oem codepage!
      ;
      IsUTF8 = 0
      FileID = ReadFile(#PB_Any, LanguageFile$)
      If FileID
        If ReadStringFormat(FileID) = #PB_UTF8
          IsUTF8 = 1
        EndIf
        CloseFile(FileID)
      EndIf
      
      If OpenPreferences(AvailableLanguages()\FileName$)
        For Group = 1 To NbLanguageGroups
          If LanguageGroups(Group)\GroupStart <= LanguageGroups(Group)\GroupEnd  ; sanity check.. check for empty groups
            PreferenceGroup(LanguageGroups(Group)\Name$)
            
            If IsUTF8
              For StringIndex = LanguageGroups(Group)\GroupStart To LanguageGroups(Group)\GroupEnd
                LanguageStrings(StringIndex) = ReadPreferenceString(LanguageNames(StringIndex), LanguageStrings(StringIndex))
              Next StringIndex
            Else ; apply the oem codepage change here in the unicode debugger
              For StringIndex = LanguageGroups(Group)\GroupStart To LanguageGroups(Group)\GroupEnd
                LanguageStrings(StringIndex) = ReadLanguageEntry(LanguageNames(StringIndex), LanguageStrings(StringIndex))
              Next StringIndex
            EndIf
            
          EndIf
        Next Group
        ClosePreferences()
      EndIf
    Else
      If CommandlineBuild = 0
        MessageRequester(#ProductName$, "The language '"+CurrentLanguage$+"' cannot be found!"+#NewLine+"The default language will be used.", #FLAG_Error)
      ElseIf QuietBuild = 0
        PrintN("-- The language '"+CurrentLanguage$+"' cannot be found!")
        PrintN("-- The Default language will be used.")
      EndIf
      CurrentLanguage$ = "English"
    EndIf
  EndIf
  
  BuildShortcutNamesTable() ; update the array of names for the Shortcuts
  
EndProcedure

Procedure.s Language(Group$, Name$)
  Static Group.l  ; for quicker access when using the same group more than once
  Protected String$, StringIndex, Result
  
  Group$  = UCase(Group$)
  Name$   = UCase(Name$)
  String$ = "##### String not found! #####"  ; to help find bugs
  
  If LanguageGroups(Group)\Name$ <> Group$  ; check if it is the same group as last time
    For Group = 1 To NbLanguageGroups
      If Group$ = LanguageGroups(Group)\Name$
        Break
      EndIf
    Next Group
    
    If Group > NbLanguageGroups  ; check if group was found
      Group = 0
    EndIf
  EndIf
  
  If Group <> 0
    StringIndex = LanguageGroups(Group)\IndexTable[ Asc(Left(Name$, 1)) ]
    If StringIndex <> 0
      
      Repeat
        Result = CompareMemoryString(@Name$, @LanguageNames(StringIndex))
        
        If Result = 0
          String$ = LanguageStrings(StringIndex)
          Break
          
        ElseIf Result = -1 ; string not found!
          Break
          
        EndIf
        
        StringIndex + 1
      Until StringIndex > LanguageGroups(Group)\GroupEnd
      
    EndIf
    
  EndIf
  
  CompilerIf #PB_Compiler_Debugger
    If String$ =  "##### String not found! #####"
      If Group = 0
        Debug "[LANGUAGE] Group '" + Group$ + "' wasn't found."
      EndIf
      Debug "[LANGUAGE] A string with name '" + Name$ + "' wasn't found in group '" + Group$ + "'."
    EndIf
  CompilerEndIf
  
  ProcedureReturn ReplaceString(String$, "%newline%", #NewLine, #PB_String_NoCase)
EndProcedure

; Useful for some API functions
;
Procedure.i LanguageStringAddress(Group$, Name$)
  Static String$
  
  String$ = Language(Group$, Name$)
  ProcedureReturn @String$
EndProcedure


Procedure.s LanguagePattern(Group$, Name$, Pattern$, ReplacementString$)
  ProcedureReturn ReplaceString(Language(Group$, Name$), Pattern$, ReplacementString$, #PB_String_NoCase)
EndProcedure


;- BaseLanguage
DataSection
  
  Language:
  ; Special Keywords:
  ; "_GROUP_" will indicate a new group in the datasection
  ; "_END_" will indicate the end of the language list (as there is no fixed number anymore)
  ; "LanguageInfo" group is reserved to store information about the language in a language file
  ;
  ; Note: The identifyer strings are case insensitive to make live easier :)
  
  ; ===================================================
  ;- Group - MenuTitle
  Data$ "_GROUP_",            "MenuTitle"
  ; ===================================================
  
  Data$ "File",             "&File"
  Data$ "Edit",             "&Edit"
  Data$ "Project",          "&Project"
  Data$ "Form",          "F&orm"
  Data$ "Compiler",         "&Compiler"
  Data$ "Debugger",         "&Debugger"
  Data$ "Tools",            "&Tools"
  Data$ "Help",             "&Help"
  
  ; ===================================================
  ;- Group - MenuItem
  Data$ "_GROUP_",            "MenuItem"
  ; ===================================================
  
  Data$ "New",              "&New"
  Data$ "Open",             "&Open..."
  Data$ "Save",             "&Save"
  Data$ "SaveAs",           "Save &As..."
  Data$ "SaveAll",          "Sa&ve All"
  Data$ "Reload",           "R&eload"
  Data$ "Close",            "&Close"
  Data$ "CloseAll",         "C&lose All"
  Data$ "ShowInFolder",     "Show in &Folder"
  Data$ "DiffCurrent",      "View chan&ges"
  Data$ "FileFormat",       "F&ile format"
  Data$ "EncodingPlain",    "Encoding: &Plain Text"
  Data$ "EncodingUtf8",     "Encoding: &Utf8"
  Data$ "NewlineWindows",   "Newline: &Windows (CRLF)"
  Data$ "NewlineLinux",     "Newline: &Linux (LF)"
  Data$ "NewlineMacOS",     "Newline: &MacOS (CR)"
  Data$ "SortSources",      "Sor&t Sources..."
  Data$ "Preferences",      "&Preferences..."
  Data$ "RecentFiles",      "&Recent Files"
  Data$ "EditHistory",      "Session &History"
  Data$ "Quit",             "&Quit"
  
  Data$ "Undo",             "&Undo"
  Data$ "Redo",             "&Redo"
  Data$ "Cut",              "Cu&t"
  Data$ "Copy",             "&Copy"
  Data$ "Paste",            "&Paste"
  Data$ "PasteComment",     "Paste as comment"
  Data$ "InsertComment",    "I&nsert comments"
  Data$ "RemoveComment",    "Re&move comments"
  Data$ "AutoIndent",       "Format indentation"
  Data$ "SelectAll",        "Select &All"
  Data$ "Goto",             "&Goto..."
  Data$ "JumpToKeyword",    "Goto matching &Keyword"
  Data$ "LastViewedLine",   "Goto recent &Line"
  Data$ "ToggleThisFold",   "Toggle current fol&d"
  Data$ "ToggleFolds",      "T&oggle all folds"
  Data$ "AddMarker",        "Add/Remove &Marker"
  Data$ "JumpToMarker",     "&Jump to Marker"
  Data$ "ClearMarkers",     "Cl&ear Markers"
  Data$ "Find",             "&Find/Replace..."
  Data$ "FindNext",         "Find &Next"
  Data$ "FindPrevious",     "Find &Previous"
  Data$ "FindInFiles",      "Find &in Files..."
  Data$ "Replace",          "&Replace..."
  
  Data$ "NewProject",       "&New Project..."
  Data$ "OpenProject",      "&Open Project..."
  Data$ "RecentProjects",   "Recent &Projects"
  Data$ "CloseProject",     "&Close Project"
  Data$ "ProjectOptions",   "Project &Options..."
  Data$ "AddProjectFile",   "&Add File to Project"
  Data$ "RemoveProjectFile","&Remove File from Project"
  Data$ "BackupManager",    "&Manage Backups..."
  Data$ "MakeBackup",       "Make &Backup..."
  Data$ "TodoList",         "&Tasks..."
  Data$ "OpenProjectFolder","Open Project &Folder"
  
  Data$ "NewForm",          "&New Form"
  Data$ "FormSwitch",       "&Switch Code/Design View"
  Data$ "FormDuplicate",    "&Duplicate Object"
  Data$ "FormImageManager", "&Image Manager..."
  
  Data$ "Compile",          "&Compile/Run"
  Data$ "RunExe",           "&Run"
  Data$ "SyntaxCheck",      "&Syntax check"
  Data$ "DebuggerCompile",  "Compile with Debugger"
  Data$ "NoDebuggerCompile","Compile without Debugger"
  Data$ "RestartCompiler",  "Re&start Compiler"
  Data$ "CompilerOptions",  "Compiler &Options..."
  CompilerIf #SpiderBasic
    Data$ "CreateEXE",        "&Create App..."
  CompilerElse
    Data$ "CreateEXE",        "Create &Executable..."
  CompilerEndIf
  Data$ "SetDefaultTarget", "Set &default Target"
  Data$ "BuildTarget",      "Build &Target"
  Data$ "BuildAllTargets",  "&Build all Targets"
  
  Data$ "Debugger",         "Use &Debugger"
  Data$ "Stop",             "&Stop"
  Data$ "Run",              "&Continue"
  Data$ "Kill",             "&Kill Program"
  Data$ "Step",             "S&tep"
  Data$ "StepX",            "Step <&n>"
  Data$ "StepOver",         "Ste&p Over"
  Data$ "StepOut",          "Step O&ut"
  Data$ "BreakPoint",       "&Breakpoint"
  Data$ "BreakClear",       "Clear B&reakpoints"
  Data$ "DataBreakPoints",  "Data Breakpo&ints"
  Data$ "ErrorLog",         "&Error Log"
  Data$ "ShowLog",          "&Show Error Log"
  Data$ "ClearLog",         "&Clear Log"
  Data$ "CopyLog",          "C&opy Log"
  Data$ "ClearErrorMarks",  "Clear &Error Marks"
  Data$ "DebugOutput",      "Debug &Output"
  Data$ "WatchList",        "&Watchlist"
  Data$ "VariableList",     "&Variable Viewer"
  Data$ "Profiler",         "Pro&filer"
  Data$ "History",          "Ca&llstack"
  Data$ "Memory",           "&Memory Viewer"
  Data$ "LibraryViewer",    "&Library Viewer"
  Data$ "Purifier",         "Purifier"
  Data$ "DebugAsm",         "&Assembly"
  
  Data$ "VisualDesigner",   "&Form Designer"
  Data$ "StructureViewer",  "&Structure Viewer"
  Data$ "FileViewer",       "&File Viewer"
  Data$ "VariableViewer",   "&Variable Viewer"
  Data$ "ColorPicker",      "&Color Picker"
  Data$ "AsciiTable",       "&Character Table"
  Data$ "Explorer",         "&Explorer"
  Data$ "ProcedureBrowser", "&Procedure Browser"
  Data$ "WebView",          "&WebView"
  Data$ "Issues",           "&Issue Browser"
  Data$ "Templates",        "&Templates"
  Data$ "ProjectPanel",     "P&roject Panel"
  Data$ "Diff",             "C&ompare Files/Folders"
  Data$ "AddTools",         "Configure &Tools..."
  
  Data$ "Help",             "&Help..."
  Data$ "UpdateCheck",      "&Check for updates"
  Data$ "ExternalHelp",     "&External Help"
  Data$ "About",            "&About"
  
  
  ; ===================================================
  ;- Group - ToolsPanel
  Data$ "_GROUP_",            "ToolsPanel"
  ; ===================================================
  
  Data$ "ProcedureBrowserShort", "Procedures"
  Data$ "ProcedureBrowserLong",  "Procedure Browser"
  Data$ "Explorer",         "Explorer"
  Data$ "AsciiTable",       "Character Table"
  Data$ "VariableViewerShort", "Variables"
  Data$ "VariableViewerLong",  "Variable Viewer"
  Data$ "ProjectPanelShort","Project"
  Data$ "ProjectPanelLong", "Project Panel"
  Data$ "FormShort",        "Form"
  Data$ "FormLong",         "Form Panel"
  Data$ "HelpToolShort",    "Help"
  Data$ "HelpToolLong",     "Help Tool"
  
  Data$ "WebViewShort", "WebView"
  Data$ "WebViewLong",  "WebView"
  
  Data$ "ColorPicker",      "Color Picker"
  Data$ "Mode_RGB",         "RGB"
  Data$ "Mode_HSL",         "HSL"
  Data$ "Mode_HSV",         "HSV"
  Data$ "Mode_Wheel",       "Wheel"
  Data$ "Mode_Palette",     "Palette"
  Data$ "Mode_Name",        "Name"
  Data$ "NoMatch",          "No matches found."
  Data$ "UseAlpha",         "Include alpha channel"
  Data$ "Color_Insert",     "Insert Color"
  Data$ "Color_RGB",        "Insert RGB"
  Data$ "Color_Save",       "Save Color"
  Data$ "Color_Filter",     "Filter"
  
  Data$ "Variables",        "Variables"
  Data$ "Arrays",           "Arrays"
  Data$ "LinkedLists",      "LinkedLists"
  Data$ "Structures",       "Structures"
  Data$ "Interfaces",       "Interfaces"
  Data$ "Constants",        "Constants"
  Data$ "AllSources",       "Display Elements from all open sources"
  Data$ "ScanFor",          "Scan for"
  
  Data$ "TemplatesLong",    "Code Templates"
  Data$ "TemplatesShort",   "Templates"
  
  Data$ "Favorites",       "Favorites"
  Data$ "AddFavorite",     "Add to Favorites"
  Data$ "RemoveFavorite",  "Remove from Favorites"
  
  Data$ "IssuesShort",      "Issues"
  Data$ "IssuesLong",       "Issue Browser"
  
  Data$ "Priority",         "Priority"
  Data$ "IssueName",        "Issue"
  Data$ "IssueText",        "Text"
  Data$ "Prio0",            "Blocker"
  Data$ "Prio1",            "High"
  Data$ "Prio2",            "Normal"
  Data$ "Prio3",            "Low"
  Data$ "Prio4",            "Info"
  Data$ "AllIssues",        "All issues"
  
  Data$ "SingleFile",       "Show issues of current source only"
  Data$ "MultiFile",        "Show issues of all open files/project files"
  Data$ "Export",           "Export issue list"
  
  ; For the 'Multicolored Procedure List' and the controls for coloring and scrolling.
  Data$ "HideModuleNames",	   "Hide module names"
  Data$ "HighlightProcedure", "Automatically determine and highlight the current procedure"
  Data$ "ScrollProcedure",		"Automatically scroll to current procedure"
  Data$ "EnableFolding",		"Enable automatic unfolding of the procedure after the click"
  Data$ "FrontColor",			"Changing the font color of an entry"
  Data$ "BackColor",				"Changing the background color of an entry"
  Data$ "RestoreColor",			"Restore color settings of an entry"
  Data$ "CopyClipboard",		"Copies the procedure names to the clipboard.  Options: Ctrl = All, Shift = Arguments"
  Data$ "SwitchButtons",		"Switches the functions"
  
  ; ===================================================
  ;- Group - FileStuff
  Data$ "_GROUP_",            "FileStuff"
  ; ===================================================
  
  Data$ "NewSource",        "<New>"
  Data$ "NewForm",          "<New Form>"
  Data$ "OpenFileTitle",    "Choose a file to open..."
  Data$ "SaveFileTitle",    "Save source code as..."
  CompilerIf #SpiderBasic
    Data$ "Pattern",          "SpiderBasic Files (*.sb, *.sbi, *.sbp, *.sbf)|*.sb;*.sbi;*.sbp;*.sbf|SpiderBasic Sourcecodes (*.sb)|*.sb|SpiderBasic Includefiles (*.sbi)|*.sbi|SpiderBasic Projects (*.sbp)|*.sbp|Spiderbasic Forms (*.sbf)|*.sbf|All Files (*.*)|*.*"
  CompilerElse
    Data$ "Pattern",          "PureBasic Files (*.pb, *.pbi, *.pbp, *.pbf)|*.pb;*.pbi;*.pbp;*.pbf|PureBasic Sourcecodes (*.pb)|*.pb|PureBasic Includefiles (*.pbi)|*.pbi|PureBasic Projects (*.pbp)|*.pbp|Purebasic Forms (*.pbf)|*.pbf|All Files (*.*)|*.*"
  CompilerEndIf
  
  Data$ "StatusLoading",    "Loading source code..."
  Data$ "StatusLoaded",     "Source code loaded."
  Data$ "LoadError",        "Cannot load Source code!"
  Data$ "MiscLoadError",    "Cannot load file!"
  
  Data$ "StatusSaving",     "Saving source code..."
  Data$ "StatusSaved",      "Source code saved."
  Data$ "SaveError",        "Cannot save Source code!"
  Data$ "FileExists",       "The file you specified already exists!"
  Data$ "OverWrite",        "Do you want to overwrite it?"
  Data$ "CreateError",      "The file cannot be created!"
  Data$ "FileIsOpen",       "The file you specified is currently open in the IDE!"
  Data$ "CloseOverWrite",   "Do you want to close that tab and overwrite it?"
  
  Data$ "SaveConfigError",  "Cannot save Compiler options to file"
  Data$ "Modified",         "The file '%filename%'has been modified.%newline%Do you want to save the changes?"
  Data$ "ModifiedNew",      "This new file has not been saved yet. Do you want to save it now?"
  Data$ "ReloadModified",   "This file has been modified.%newline%Should the changes be discarded by reloading it?"
  Data$ "DeletedOnDisk",    "The file '%filename%' has been deleted from the disk.%newline%Do you want to save it now?"
  Data$ "ModifiedOnDisk1",  "The file '%filename%' has been modified on disk.%newline%Do you want to reload it to reflect these changes?"
  Data$ "ModifiedOnDisk2",  "The file '%filename%' has been modified on disk.%newline%Do you want to discard your current changes and reload it from disk?"
  Data$ "ViewDiff",         "View Differences"
  Data$ "Reload",           "Reload"
  Data$ "AddNewFileTitle"   , "Adding a new project file..."
  Data$ "AddNewFileQuestion", "The file '%filename%' doesn't exists on disk.%newline%Do you want to create it ?"
  Data$ "AddNewFileError"   , "The file '%filename%' can't be created on disk."
  
  Data$ "ExportIssueTitle",  "Export issues to..."
  Data$ "ExportIssuePattern","Comma separated values (*.csv)|*.csv|All files (*.*)|*.*"
  
  ; ===================================================
  ;- Group - Project
  Data$ "_GROUP_",            "Project"
  ; ===================================================
  
  Data$ "Title",            "Project Options"
  Data$ "TitleNew",         "Create new Project"
  Data$ "TitleSave",        "Save project as..."
  Data$ "TitleOpen",        "Open project..."
  Data$ "TitleShort",       "Project"
  Data$ "CompilerOptions",  "Compiler Options"
  Data$ "ProjectOptions",   "Project Options"
  Data$ "CreateProject",    "Create"
  Data$ "DefaultName",      "New Project"
  Data$ "TabTitle",         "Project"
  
  Data$ "OptionTab",        "Project Options"
  Data$ "ProjectInfo",      "Project Info"
  Data$ "ProjectFile",      "Project File"
  Data$ "ProjectName",      "Project Name"
  Data$ "ProjectTargets",   "Project Targets"
  Data$ "Comments",         "Comments"
  
  Data$ "LoadOptions",      "Loading Options"
  Data$ "SetDefault",       "Set as default project (always open when the IDE starts)"
  Data$ "CloseAllFiles",    "Close all sources when closing the project"
  Data$ "WhenOpening",      "When opening the project..."
  Data$ "OpenLoadLast",     "load all sources that were open last time"
  Data$ "OpenLoadAll",      "load all sources of the project"
  Data$ "OpenLoadDefault",  "load only sources marked in 'Project Files'"
  Data$ "OpenLoadMain",     "load only the main file of the default target"
  Data$ "OpenLoadNone",     "load no files"
  
  Data$ "FilesChanged",     "The following files were modified while the project was closed"
  Data$ "FileMissing",      "The file '%filename%' cannot be found.%newline%Do you want to search for it?"
  Data$ "RemoveMany",       "Do you really want to remove these %count% files from the project?"
  
  Data$ "FileTab",          "Project Files"
  Data$ "View",             "View"
  Data$ "FileScan",         "Scan file for Autocomplete"
  Data$ "FileLoad",         "Load file when opening the project"
  Data$ "FilePanel",        "Show file in the Project panel"
  Data$ "FileWarn",         "Display a warning if file changed"
  
  Data$ "Filename",         "Filename"
  Data$ "FileScanShort",    "Scan"
  Data$ "FileLoadShort",    "Load"
  Data$ "FilePanelShort",   "Panel"
  Data$ "FileWarnShort",    "Warn"
  Data$ "FileSize",         "Size"
  Data$ "FileModified",     "Last Modified"
  Data$ "FileDateFormat",   "%mm/%dd/%yyyy - %hh:%ii"
  Data$ "LastOpen",         "Last open"
  Data$ "LastOpenText",     "%date% by %user% on %host%"
  Data$ "LastOpenEditor",   "Editor"
  
  Data$ "TargetShort",      "Target"
  Data$ "DebugShort",       "Debug"
  Data$ "ThreadShort",      "Thread"
  Data$ "AsmShort",         "Asm"
  Data$ "OnErrorShort",     "OnError"
  Data$ "CompileCountShort","Compile"
  Data$ "BuildCountShort",  "Build"
  Data$ "FormatShort",      "Format"
  Data$ "InputFile",        "Input File"
  
  Data$ "AddDirectory",     "Should the content of the following directory be added to the project ?"
  Data$ "AddManyFiles",     "Do you really want to add %filecount% files to the project?"
  CompilerIf #SpiderBasic
    Data$ "Pattern",          "SpiderBasic Projects (*.sbp)|*.sbp|All files (*.*)|*.*"
  CompilerElse
    Data$ "Pattern",          "PureBasic Projects (*.pbp)|*.pbp|All files (*.*)|*.*"
  CompilerEndIf
  
  Data$ "NeedName",         "A name must be specified for the project."
  Data$ "NeedFile",         "A filename must be specified for the project."
  Data$ "SaveError",        "The project file cannot be saved to disk."
  Data$ "LoadError",        "The project file cannot be loaded."
  Data$ "VersionLow",       "The version number of the project file is lower than the current version.%newline%If loaded, it will be converted to the current version."
  Data$ "VersionHigh",      "The version number of the project file is higher than the current one. %newline%If loaded, some data of the project may be lost."
  Data$ "VersionTooHigh",   "Project files with this version cannot be loaded."
  Data$ "LoadAnyway",       "Do you want to load it anyway?"
  Data$ "ProjectFile",      "Project file"
  Data$ "ProjectVersion",   "Project version"
  Data$ "CurrentVersion",   "Current version"
  Data$ "LastWrittenBy",    "Last written by"
  
  Data$ "InternalFiles",    "Project Folder"
  Data$ "ExternalFiles",    "External Files"
  Data$ "PanelOpen",        "Open"
  Data$ "PanelOpenViewer",  "Open in FileViewer"
  Data$ "PanelOpenIn",      "Open in %name%"
  Data$ "PanelAdd",         "Add file to Project..."
  Data$ "PanelRemove",      "Remove from Project"
  Data$ "PanelRescan",      "Refresh AutoComplete data"
  
  Data$ "OpenExplorerWindows", "Open in Explorer"
  Data$ "OpenExplorerLinux",   "Open in Filemanager"
  Data$ "OpenExplorerMac",     "Open in Finder"
  Data$ "ReallyClose",         "Really close the project?"
  
  ; ===================================================
  ;- Group - Preferences
  Data$ "_GROUP_",            "Preferences"
  ; ===================================================
  
  Data$ "Title",            "Preferences"
  Data$ "Apply",            "Apply"
  
  Data$ "General",          "General"
  Data$ "MemorizeWindow",   "Memorize Window positions"
  Data$ "RunOnce",          "Run only one Instance"
  Data$ "ShowMainToolbar",  "Show main Toolbar"
  Data$ "VisualDesigner",   "VisualDesigner"
  Data$ "AutoReload",       "Auto-reload last open sources"
  Data$ "FileHistorySize",  "RecentFiles list size"
  Data$ "FindHistorySize",  "Search History size"
  Data$ "Language",         "Language"
  Data$ "LanguageInfo",     "Language Information"
  Data$ "FileName",         "Filename"
  Data$ "LastUpdated",      "Last Updated"
  Data$ "Creator",          "Creator"
  Data$ "Email",            "Email"
  Data$ "EnableMenuIcons",  "Display Icons in the Menu"
  Data$ "DisplayFullPath",  "Display full Source Path in TitleBar"
  Data$ "DisplayDarkMode",  "Enable Dark Mode appearance"
  Data$ "NoSplashScreen",   "Disable Splash Screen"
  
  Data$ "Updates",          "Updates"
  Data$ "CheckInterval",    "Check for updates"
  Data$ "CheckVersions",    "Check for releases"
  Data$ "IntervalAlways",   "At every start"
  Data$ "IntervalWeekly",   "Once a week"
  Data$ "IntervalMonthly",  "Once a month"
  Data$ "IntervalNever",    "Never"
  Data$ "VersionsAll",      "All releases (including beta releases)"
  Data$ "VersionsFinal",    "Final releases"
  Data$ "VersionsLTS",      "Long term support releases"
  
  Data$ "Editor",           "Editor"
  Data$ "AutoSave",         "Auto-save before compiling"
  Data$ "AutoSaveAll",      "Save all sources with Auto-save"
  Data$ "TabLength",        "Tab Length"
  Data$ "RealTab",          "Use real Tab (ASCII 9)"
  Data$ "SourcePath",       "Source Directory"
  Data$ "MemorizeCursor",   "Memorize Cursor position"
  Data$ "MemorizeMarkers",  "Memorize Marker positions"
  Data$ "Defaults",         "Default Settings for new Files"
  Data$ "DefaultsShort",    "Defaults"
  Data$ "CPU",              "CPU Optimisation"
  Data$ "SubSystem",        "Library Subsystem"
  Data$ "SaveSettings",     "Save Settings to"
  Data$ "SaveSettings0",    "The end of the Source file"
  CompilerIf #SpiderBasic
    Data$ "SaveSettings1",    "The file <filename>.sb.cfg"
  CompilerElse
    Data$ "SaveSettings1",    "The file <filename>.pb.cfg"
  CompilerEndIf
  Data$ "SaveSettings2",    "A common file project.cfg for every directory"
  Data$ "SaveSettings3",    "Don't save anything"
  Data$ "AlwaysHideLog",    "Always hide the error log (ignore the per-source setting)"
  Data$ "MonitorFileChanges","Monitor open files for changes on disk"
  Data$ "FilesPanel",             "File selection"
  Data$ "FilesPanelMultiline",    "Display multiple rows"
  Data$ "FilesPanelCloseButtons", "Display close buttons in each tab"
  Data$ "FilesPanelNewButton",    "Add a tab to create a new source"
  Data$ "CodeFileExtensions","Code file extensions"
  
  Data$ "Editing",          "Editing"
  Data$ "Colors",           "Coloring"
  Data$ "Settings",         "Settings"
  ;Data$ "EnableColoring",   "Enable Syntax coloring"
  Data$ "EnableBolding",    "Enable bolding of Keywords"
  Data$ "EnableCase",       "Enable Case correction"
  Data$ "EnableBraceMatch", "Enable marking of matching Braces"
  Data$ "EnableKeywordMatch","Enable marking of matching Keywords"
  Data$ "EnableLineNumbers","Display Line numbers"
  Data$ "EnableAccessibility","Enable accessibility features"
  Data$ "EnableMarkers",    "Enable Line Markers"
  Data$ "ExtraWordChars",   "Extra characters included in word selection"
  Data$ "SelectFont",       "Select Font"
  Data$ "DefaultColors",    "Color Schemes"
  Data$ "ShowWhiteSpace",   "Show whitespace characters"
  Data$ "ShowIndentGuides", "Show indentation guides"
  Data$ "UseTabIndentForSplittedLines", "Use tab indent for splitted lines"
  
  CompilerIf #SpiderBasic
    Data$ "Color0",         "Inline Javascript"
  CompilerElse
    Data$ "Color0",         "ASM Keywords"
  CompilerEndIf
  Data$ "Color1",           "Background"
  Data$ "Color2",           "Basic Keywords"
  Data$ "Color3",           "Comments"
  Data$ "Color4",           "Constants"
  Data$ "Color5",           "Labels"
  Data$ "Color6",           "Normal Text"
  Data$ "Color7",           "Numbers"
  Data$ "Color8",           "Operators (* /+ -)"
  Data$ "Color9",           "Pointers"
  Data$ "Color10",          "Functions"
  Data$ "Color11",          "Separators (; , [ ])"
  Data$ "Color12",          "Strings"
  Data$ "Color13",          "Structures"
  Data$ "Color14",          "LineNumbers"
  Data$ "Color15",          "LineNumbers Background"
  Data$ "Color16",          "Line Markers"
  Data$ "Color17",          "Currentline Background"
  Data$ "Color18",          "Selection Background"
  Data$ "Color19",          "Selection Text"
  Data$ "Color20",          "Cursor"
  Data$ "Color21",          "Current Line Background (Debugger)"
  Data$ "Color22",          "Current Line Symbol (Debugger)"
  Data$ "Color23",          "Error Background (Debugger)"
  Data$ "Color24",          "Error Symbol (Debugger)"
  Data$ "Color25",          "Breakpoint Background (Debugger)"
  Data$ "Color26",          "Breakpoint Symbol (Debugger)"
  Data$ "Color27",          "Background for non-editable files (Debugger)"
  Data$ "Color28",          "Mark matching Braces and Keywords"
  Data$ "Color29",          "Mark mismatched Braces and Keywords"
  Data$ "Color30",          "Background for Procedures"
  Data$ "Color31",          "Custom Keywords"
  Data$ "Color32",          "Warning Background (Debugger)"
  Data$ "Color33",          "Warning Symbol (Debugger)"
  Data$ "Color34",          "Whitespace and indentation guides"
  Data$ "Color35",          "Module Names"
  Data$ "Color36",          "Repeated Selections Background"
  Data$ "Color37",          "Background for plain text files"
  
  Data$ "Keywords",         "Custom keywords"
  Data$ "KeywordsFile",     "Load keywords from file"
  Data$ "OpenKeywordFile",  "Choose keyword list file..."
  
  Data$ "Folding",          "Folding"
  Data$ "EnableFolding",    "Enable Source Line folding"
  Data$ "FoldStartWords",   "Folding start Keywords"
  Data$ "FoldEndWords",     "Folding end Keywords"
  
  Data$ "Themes",           "Themes"
  Data$ "Toolbar",          "Toolbar"
  Data$ "ToolbarLayout",    "Toolbar Layout"
  Data$ "Icon",             "Icon"
  Data$ "Action",           "Action"
  Data$ "ItemSettings",     "Item Settings"
  Data$ "ItemPosition",     "Position"
  Data$ "Set",              "Set"
  Data$ "ToolbarSets",      "Default Sets"
  Data$ "ToolbarDefault",   "Default Toolbar"
  Data$ "ToolbarClassic",   "Classic Toolbar"
  Data$ "Separator",        "Separator"
  Data$ "Space",            "Space"
  Data$ "StandardButton",   "Standard Icon"
  Data$ "ThemeIcon",        "Theme Icon"
  Data$ "ExternalIcon",     "Icon File"
  Data$ "ActionMenu",       "Menu Item"
  Data$ "ActionTool",       "Run Tool"
  Data$ "OpenIcon",         "Choose Icon File"
  Data$ "IconPattern",      "Icon Files (*.ico, *.png)|*.ico;*.png|All Files (*.*)|*.*"
  Data$ "MaxItems",         "Maximum number of toolbar items reached"
  
  Data$ "Tools",            "ToolsPanel"
  Data$ "Options",          "Options"
  Data$ "ToolsPanelOptions","ToolsPanel Options"
  Data$ "ToolsPanelLeft",   "Panel on the left side"
  Data$ "ToolsPanelRight",  "Panel on the right side"
  Data$ "ToolsFrontColor",  "Front Color"
  Data$ "ToolsBackColor",   "Background Color"
  Data$ "NoIndependandColors", "Do not use colors/fonts for tools in external windows."
  Data$ "AutoHidePanel",    "Automatically hide the Panel"
  Data$ "AutoHideDelay",    "Milliseconds delay before hiding the Panel"
  Data$ "ToolsPanelItems",  "Tools in the ToolsPanel"
  Data$ "AvailableTools",   "Available Tools"
  Data$ "UsedTools",        "Displayed Tools"
  Data$ "Add",              "Add"
  Data$ "Remove",           "Remove"
  Data$ "Up",               "Up"
  Data$ "Down",             "Down"
  Data$ "Configuration",    "Configuration"
  Data$ "ExplorerMode",     "Displaymode of the Explorer"
  Data$ "ExplorerTree",     "Explorer Tree"
  Data$ "ExplorerList",     "Explorer List"
  Data$ "ExplorerSavePath", "Remember last displayed Directory"
  Data$ "ProcedureSort",    "Sort Procedures by name"
  Data$ "ProcedureGroup",   "Group Markers"
  Data$ "ProcedurePrototype", "Display Procedure Arguments"
  Data$ "ProcedureMulticolor", "Multicolored Procedure List"
  
  Data$ "Indent",           "Indentation"
  Data$ "IndentTitle",      "Code Indentation"
  Data$ "IndentNo",         "No indentation"
  Data$ "IndentBlock",      "Block mode"
  Data$ "IndentSensitive",  "Keyword sensitive"
  Data$ "BackspaceUnindent","Backspace unindents"
  Data$ "AddSet",           "Add/Set"
  Data$ "Keyword",          "Keyword"
  Data$ "Before",           "Before"
  Data$ "After",            "After"
  
  Data$ "AutoComplete",     "AutoComplete"
  Data$ "AutoCompleteList", "Displayed Items"
  Data$ "DisplayFullList",  "Display the full AutoComplete list"
  Data$ "FirstCharMatch",   "Display all words that match the first character"
  Data$ "AllWordMatch",     "Display only words that begin with the typed word"
  Data$ "BoxWidth",         "Box width"
  Data$ "BoxHeight",        "Box height"
  Data$ "AddBrackets",      "Add opening Brackets to Functions/Arrays/Lists"
  Data$ "AddSpaces",        "Add a Space after PB Keywords followed by an expression"
  Data$ "AddEndKeywords",   "Add matching 'End' keyword if insert is pressed twice"
  Data$ "ListOptions",      "Items to display in the AutoComplete List"
  Data$ "NoComments",       "Disable automatic popup inside Comments"
  Data$ "NoStrings",        "Disable automatic popup inside Strings"
  Data$ "PopupLength",      "Characters needed before opening the list"
  
  Data$ "AutoPopupNormal",  "Automatically popup AutoComplete otherwise"
  Data$ "AutoPopupStructures","Automatically popup AutoComplete for Structure items"
  Data$ "AutoPopupModules", "Automatically popup AutoComplete after a Module prefix"
  Data$ "PBItems",          "Predefined Items"
  Data$ "SourceItems",      "Sourcecode Items"
  Data$ "SourceOnly",       "the current source only"
  Data$ "ProjectOnly",      "the current project (if any)"
  Data$ "ProjectAllFiles",  "the current project or all files (if none)"
  Data$ "AllFiles",         "all open files"
  Data$ "AddFrom",          "Add Items from"
  
  Data$ "Option_Variable",  "Variables"
  Data$ "Option_Array",     "Arrays"
  Data$ "Option_List",      "LinkedLists"
  Data$ "Option_Map",       "Maps"
  Data$ "Option_Procedure", "Procedures"
  Data$ "Option_Macro",     "Macros"
  Data$ "Option_Import",    "Imported Functions"
  Data$ "Option_Prototype", "Prototypes"
  Data$ "Option_Constant",  "Constants"
  Data$ "Option_Structure", "Structures"
  Data$ "Option_Interface", "Interfaces"
  Data$ "Option_Label",     "Labels"
  Data$ "Option_Module",    "Modules"
  
  Data$ "Option_PBKeywords",  "Keywords"
  CompilerIf #SpiderBasic
    Data$ "Option_ASMKeywords", "Inline Javascript"
  CompilerElse
    Data$ "Option_ASMKeywords", "ASM Keywords"
  CompilerEndIf
  Data$ "Option_PBFunctions", "Library Functions"
  Data$ "Option_APIFunctions","API Functions"
  Data$ "Option_PBConstants", "Constants"
  Data$ "Option_PBStructures","Structures"
  Data$ "Option_PBInterfaces","Interfaces"
  Data$ "Debugger",         "Debugger"
  Data$ "IndividualSettings", "Individual Settings"
  Data$ "DefaultWindows",   "Default Windows"
  
  Data$ "Compiler",         "Compiler"
  Data$ "DefaultCompiler",  "Default Compiler"
  Data$ "MoreCompilers",    "Additional Compilers"
  Data$ "CompilerVersion",  "Version"
  Data$ "CompilerPath",     "Path"
  Data$ "SelectCompiler",   "Select PureBasic compiler..."
  
  Data$ "EditHistory",     "Session History"
  Data$ "EnableHistory",   "Enable recording of history (change requires a restart)"
  Data$ "HistoryTimer1",   "Record unsaved changes every"
  Data$ "HistoryTimer2",   "minutes"
  Data$ "HistoryMaxSize1", "Record only changes to files smaller than"
  Data$ "HistoryMaxSize2", "kilobytes"
  Data$ "PurgeSessions",   "Purge old sessions from history"
  Data$ "PurgeNever",      "Keep all history"
  Data$ "PurgeByDays1",    "Keep sessions for"
  Data$ "PurgeByDays2",    "days"
  Data$ "PurgeByCount1",   "Keep maximum"
  Data$ "PurgeByCount2",   "sessions"
  Data$ "HistoryFile",     "Database location"
  Data$ "HistoryFileSize", "Database size"
  
  Data$ "AutoClearLog",     "Clear Errorlog on each run"
  Data$ "DisplayErrorWindow", "Display compilation errors in a window"
  Data$ "DebuggerMode",     "Choose Debugger Type"
  Data$ "IDEDebugger",      "Integrated IDE Debugger"
  Data$ "GUIDebugger",      "Standalone GUI Debugger"
  Data$ "ConsoleDebugger",  "Console only Debugger"
  Data$ "WarningMode",      "Choose Warning level"
  Data$ "WarningsIgnore",   "Ignore Warnings"
  Data$ "WarningsDisplay",  "Display Warnings"
  Data$ "WarningsError",    "Treat Warnings as Errors"
  Data$ "DebuggerGeneral",  "General Options"
  Data$ "StopAtStart",      "Stop execution at program start"
  Data$ "StopAtEnd",        "Stop execution before program end"
  Data$ "DebuggerMemorize", "Memorize debugger window positions"
  Data$ "DebuggerOnTop",    "Keep all debugger windows on top"
  Data$ "AutoSetOnTop",     "Bring debugger windows to front when one is focused"
  Data$ "LogTimeStamp",     "Display Timestamp in Error log"
  Data$ "Purifier",         "Purifier"
  Data$ "DataBreakpoints",  "Data Breakpoints"
  Data$ "DebugOutput",      "Debug Output"
  Data$ "AsmDebug",         "Asm Debugger"
  Data$ "MemoryViewer",     "Memory Viewer"
  Data$ "VariableViewer",   "Variable Viewer"
  Data$ "LibraryViewer",    "Library Viewer"
  Data$ "IsHex",            "Display Hex values"
  Data$ "RegisterIsHex",    "Display Registers as hex"
  Data$ "StackIsHex",       "Display Stack as hex"
  Data$ "DebugTimeStamp",   "Add Timestamp"
  Data$ "AutoStackUpdate",  "Update Stack trace automatically"
  Data$ "MemoryOneColumn",  "Array view in one column only"
  Data$ "AutoOpenWindows",  "Open Windows on debugger start"
  Data$ "Watchlist",        "Watchlist"
  Data$ "CallStack",        "Procedure Callstack"
  Data$ "KillOnError",      "Kill Program after an Error"
  Data$ "KeepErrorMarks",   "Keep Error marks after program end"
  Data$ "SystemMessages",   "Display System messages"
  Data$ "DebugToLog",       "Display debug output in the error log"
  Data$ "Profiler",         "Profiler"
  Data$ "ProfilerStartup",  "Start Profiler on program startup"
  Data$ "DebuggerTimeout",  "Timeout for Debugger startup (ms)"
  
  
  Data$ "ImportExport",     "Import/Export"
  Data$ "Import",           "Import Settings"
  Data$ "Export",           "Export Settings"
  Data$ "IncludeShortcut",  "Include Shortcut settings"
  Data$ "IncludeToolbar",   "Include Toolbar layout"
  Data$ "IncludeColors",    "Include Color settings"
  Data$ "IncludeFolding",   "Include Folding keywords"
  Data$ "SaveTo",           "Save to"
  Data$ "LoadFrom",         "Load from"
  Data$ "Open",             "Open"
  Data$ "PrefExportPattern","Preference settings (*.prefs)|*.prefs|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
  Data$ "ImportComplete",   "Importing Preferences complete."
  Data$ "ExportComplete",   "Exporting Preferences complete."
  Data$ "UnknownPrefFormat","This Preference file format is unknown."
  
  Data$ "Accessibility",    "Accessibility"
  Data$ "ShowHiddenFiles",  "Show hidden files/directories."
  
  Data$ "CustomFont",       "Use a custom font"
  Data$ "CustomColors",     "Use custom colors"
  
  Data$ "Form",                "Form"
  Data$ "FormVariable",        "New gadgets use #PB_Any by default"
  Data$ "FormVariableCaption", "New gadgets use a variable as caption"
  Data$ "FormGrid",            "Grid Visible"
  Data$ "FormEventProcedure",  "Generate event procedure"
  Data$ "FormGridSize",        "Grid Size"
  Data$ "FormSkin",            "OS Skin"
  Data$ "FormWarnings",        "Warnings"
  Data$ "WarnNotRecognized",   "For an unrecognised file"
  Data$ "WarnDowngrade",       "For a version downgrade"
  Data$ "WarnUpgrade",         "For a version upgrade"
  Data$ "Option_Always",       "Always warn"
  Data$ "Option_Backward",     "Warn if backward compatibility is affected"
  Data$ "Option_Never",        "Never warn"
  
  Data$ "Issues",             "Issues"
  Data$ "IssueNameShort",     "Name"
  Data$ "IssueExprShort",     "Expression"
  Data$ "IssueName",          "Issue name"
  Data$ "IssueExpr",          "Regular expression"
  Data$ "IssueCodeNoColor",   "No code color"
  Data$ "IssueCodeBack",      "Change issue background"
  Data$ "IssueCodeLine",      "Change line background"
  Data$ "IssueCodeLineLimit", "Only up to %limit% issues that change the line background can be defined."
  Data$ "IssueInTool",        "Show in issue tool"
  Data$ "IssueInBrowser",     "Show in procedure browser"
  Data$ "InvalidExpr",        "Invalid regular expression"
  
  CompilerIf #SpiderBasic
    Data$ "WebBrowser",  "Web browser"
    Data$ "WebServerPort",  "Default web server port"
    Data$ "JDK",  "JDK 17 path (JDK 18+ not supported)"
    Data$ "AppleTeamID",  "AppleTeam ID"
  CompilerEndIf
  
  ; ===================================================
  ;- Group - Find
  Data$ "_GROUP_",            "Find"
  ; ===================================================
  
  Data$ "FindTitle",        "Find/Replace"
  Data$ "SearchFor",        "Search for"
  Data$ "ReplaceWith",      "Replace with"
  Data$ "CaseSensitive",    "Case Sensitive"
  Data$ "WholeWord",        "Whole Words only"
  Data$ "SelectionOnly",    "Search inside Selection only"
  Data$ "AutoWrap",         "AutoWrap at end of file"
  Data$ "NoComments",       "Don't search in Comments"
  Data$ "NoStrings",        "Don't search in Strings"
  Data$ "FindNext",         "Find Next"
  Data$ "FindPrevious",     "Find Previous"
  Data$ "Replace",          "Replace"
  Data$ "ReplaceAll",       "Replace All"
  
  Data$ "NoMoreMatches",    "No more matches found"
  Data$ "ContinueSearch",   "Do you want to search from the start of the file?"
  Data$ "ContinueSearchReverse", "Do you want to search from the end of the file?"
  Data$ "SearchComplete",   "Search/Replace complete"
  Data$ "MatchesFound",     "matches found"
  
  Data$ "GrepTitle",        "Find in files"
  Data$ "OutputTitle",      "Find in files - Results"
  Data$ "RootDirectory",    "Root directory"
  Data$ "Extensions",       "Extension filters"
  Data$ "IncludeSubdirs",   "Include sub-directories"
  Data$ "Start",            "Start"
  Data$ "Stop",             "Stop"
  
  Data$ "Started",          "Search started"
  Data$ "Aborted",          "Search aborted"
  Data$ "Finished",         "Search finished"
  Data$ "LinesFound",       "Line(s) found"
  Data$ "Info",             "Info"
  Data$ "NeedString",       "You have to enter a string to find"
  Data$ "NeedPath",         "You have to choose a root path"
  Data$ "Clear",            "Clear"
  Data$ "BinaryFile",       "Binary file"
  
  ; ===================================================
  ;- Group - Diff
  Data$ "_GROUP_",            "Diff"
  ; ===================================================
  
  Data$ "Title",            "Compare Files"
  Data$ "Busy",             "Comparing, please wait..."
  Data$ "RequesterTitle",   "Choose a file to compare..."
  Data$ "CurrentEdit",      "currently edited version"
  Data$ "FileError",        "The file '%file%' could not be opened."
  Data$ "FileBinary",       "The file '%file%' is a binary file.%newline%Only text files can be compared."
  
  Data$ "Open1",            "Open left file for editing"
  Data$ "Open2",            "Open right file for editing"
  Data$ "Refresh",          "Refresh differences"
  Data$ "Swap",             "Swap file positions"
  Data$ "Colors",           "Enable Syntax coloring"
  Data$ "Vertical",         "Split View vertically"
  Data$ "ShowTool",         "Open 'Compare' tool"
  Data$ "HideFiles",        "Hide file differences"
  Data$ "Down",             "Go to next difference"
  Data$ "Up",               "Go to previous difference"
  
  Data$ "DialogTitle",      "Compare"
  Data$ "FilesTab",         "Files"
  Data$ "DirectoriesTab",   "Directories"
  Data$ "OptionsTab",       "Options"
  Data$ "File1",            "File 1"
  Data$ "File2",            "File 2"
  Data$ "Directory1",       "Directory 1"
  Data$ "Directory2",       "Directory 2"
  Data$ "IgnoreCase",       "Ignore case changes"
  Data$ "IgnoreSpaceAll",   "Ignore all space changes"
  Data$ "IgnoreSpaceLeft",  "Ignore space changes on the left side of a line"
  Data$ "IgnoreSpaceRight", "Ignore space changes on the right side of a line"
  Data$ "EmptyField",       "All fields must be filled out."
  Data$ "Compare",          "Compare"
  
  Data$ "Filename",         "Filename"
  Data$ "State",            "Status"
  Data$ "Date1",            "Date in (1)"
  Data$ "Date2",            "Date in (2)"
  Data$ "FileEqual",        "Unchanged"
  Data$ "FileAdd",          "Only in (2)"
  Data$ "FileDelete",       "Only in (1)"
  Data$ "FileModify",       "Modified"
  Data$ "DateFormat",       "%mm/%dd/%yyyy %hh:%ii"
  
  ; ===================================================
  ;- Group - History
  Data$ "_GROUP_",            "History"
  ; ===================================================
  
  Data$ "Title",            "Session History"
  Data$ "ViewFile",         "File"
  Data$ "ViewSession",      "Session"
  
  Data$ "Time",             "Time"
  Data$ "File",             "File"
  Data$ "Session",          "Session"
  Data$ "TimeFormat",       "%hh:%ii:%ss"
  Data$ "DateTimeFormat",   "%mm/%dd/%yyyy %hh:%ii:%ss"
  Data$ "DurationMinutes",  "minutes"
  Data$ "DurationHours",    "hours"
  Data$ "SessionRunning",   "running"
  Data$ "SessionCrashed",   "ended unexpectedly"
  Data$ "CurrentSession",   "Current Session"
  Data$ "UnsavedSource",    "Unsaved source"
  Data$ "CrashedInfo",      "A previous IDE session seems to have ended improperly.%newline%Do you want to open the session history to recover unsaved changes?"
  Data$ "FileError",        "Could not open history database: %newline%%filename%%newline%%newline%No history will be recorded for this session."
  Data$ "VersionError",     "The history database is from an incompatible newer version of PureBasic.%newline%No history will be recorded in this session to prevent corruption.%newline%A different database file can be specified via commandline options.%newline%%newline%Database file: %filename%"
  
  Data$ "ShutdownTitle",    #ProductName$ + ": Please wait"
  Data$ "ShutdownMessage",  "Saving session history to disk..."
  
  ; ===================================================
  ;- Group - StructureViewer
  Data$ "_GROUP_",            "StructureViewer"
  ; ===================================================
  
  Data$ "Title",            "Structure Viewer"
  Data$ "Structures",       "Structures"
  Data$ "Interfaces",       "Interfaces"
  Data$ "Constants",        "Constants"
  Data$ "Parent",           "Back"
  Data$ "StayOnTop",        "Stay on top"
  Data$ "IncludeTypes",     "Include types"
  Data$ "InsertName",       "Insert name"
  Data$ "Insert",           "Insert"
  Data$ "InsertCopy",       "Insert copy"
  Data$ "GetVarName",       "Get variable name"
  Data$ "InputVarName",     "Please input variable name"
  Data$ "DefaultVar",       "var"
  
  
  ; ===================================================
  ;- Group - Compiler
  Data$ "_GROUP_",            "Compiler"
  ; ===================================================
  
  Data$ "OptionsTitle",     "Compiler Options"
  Data$ "InputFile",        "Input source file"
  Data$ "OutputFile",       "Output executable"
  Data$ "MainFile",         "Main source file"
  Data$ "UseIcon",          "Use Icon"
  Data$ "UseCompiler",      "Use Compiler"
  Data$ "EnableDebugger",   "Enable Debugger"
  Data$ "EnablePurifier",   "Enable Purifier"
  Data$ "EnableASM",        "Enable inline ASM syntax coloring"
  Data$ "EnableXP",         "Enable modern theme support (Windows XP and above)"
  Data$ "EnableWayland",    "Enable Wayland support"
  Data$ "EnableAdmin",      "Request Administrator mode for Windows Vista and above"
  Data$ "EnableUser",       "Request User mode for Windows Vista and above (no virtualisation)"
  Data$ "DllProtection",    "Enable DLL preloading protection (Windows)"
  Data$ "SharedUCRT",       "Use shared UCRT (Windows 10 and above)"
  Data$ "EnableOnError",    "Enable OnError lines support"
  Data$ "EnableThread",     "Create threadsafe executable"
  Data$ "ExeFormat",        "Executable format"
  Data$ "SubSystem",        "Library Subsystem"
  Data$ "CommandLine",      "Executable Commandline"
  Data$ "NewLineType",      "Sourcefile Newline format"
  Data$ "TextEncoding",     "Sourcefile Text encoding"
  Data$ "UnknownVersion",   "Cannot read version"
  
  Data$ "EncodingPlain",    "Plain Text"
  Data$ "EncodingUtf8",     "UTF-8"
  
  Data$ "OpenMainFile",     "Choose a new Main Source file..."
  Data$ "SetOutputFile",    "Specify output Executable..."
  Data$ "OpenIcon",         "Choose an Icon for the Executable..."
  Data$ "CreateExe",        "Create Executable..."
  Data$ "OpenLinkerFile",   "Choose a file with linker options..."
  Data$ "Optimizer",      "Optimize generated code"
  
  CompilerIf #SpiderBasic
    Data$ "WindowTheme",     "Theme for windows"
    Data$ "GadgetTheme",     "Theme for gadgets"
    Data$ "WebServerAddress",   "Web server address"
    Data$ "ExportHtmlMissingError", "A valid HTML output filename has to be specified in 'Compiler Options/Export'"
    Data$ "ExportSuccess",   "Export successful (%target%)."
    Data$ "ExportCommandLineSuccess", "Post processing tool launched (%commandline%)."
    Data$ "ExportCommandLineError", "Post processing tool can't be launched (%commandline%)."
    Data$ "SourcePattern",   "SpiderBasic Files (*.sb, *.sbi)|*.sb;*.sbi|SpiderBasic Sourcecodes (*.sb)|*.sb|PureBasic Includefiles (*.sbi)|*.sbi|All Files (*.*)|*.*"
    Data$ "DPIAware",         "Enable DPI aware application"
  CompilerElse
    Data$ "DPIAware",         "Enable DPI aware executable (Windows and macOS)"
    Data$ "SourcePattern",   "PureBasic Files (*.pb, *.pbi)|*.pb;*.pbi|PureBasic Sourcecodes (*.pb)|*.pb|PureBasic Includefiles (*.pbi)|*.pbi|All Files (*.*)|*.*"
  CompilerEndIf
  
  Data$ "IconPattern",      "Icon files (*.ico)|*.ico|All Files (*.*)|*.*"
  Data$ "DllPattern",       "Shared DLL (*.dll)|*.DLL|All Files (*.*)|*.*"
  Data$ "ExePattern",       "Executable (*.exe)|*.EXE|All Files (*.*)|*.*"
  Data$ "AllFilesPattern",  "All Files (*.*)|*.*"
  
  Data$ "Compiling",        "Compilation in progress..."
  Data$ "Lines",            "lines"
  Data$ "Including",        "Including"
  Data$ "Details",          "Details"
  Data$ "Finishing",        "Creating executable file..."
  Data$ "Aborting",         "Aborting compilation..."
  Data$ "LinesCompiled",    "%count% lines compiled."
  
  Data$ "SaveTempError",    "Can't save Sourcecode to temporary file!"
  Data$ "ReadMainError",    "Can't read main Sourcecode!"
  
  Data$ "Busy",             "The compiler can't be restarted. It is busy."
  Data$ "NotReady",         "The compiler isn't loaded yet... please try again."
  Data$ "ResponseError",    "Wrong compiler response. Probably not the correct compiler version.%newline%Please reinstall %product%."
  Data$ "CompilerCrash",    "The compiler appears to have crashed or quit unexpectedly. %newline%It will be restarted.%newline%%newline%Please report the conditions that caused this as a bug."
  Data$ "SubsystemError",   "The following subsystem cannot be found"
  
  Data$ "ErrorLine",        "Line"
  Data$ "ErrorMainFile",    "Error in the MainFile"
  Data$ "ErrorIncludeFile", "Error in included File"
  Data$ "FileError",        "Cannot read Compiler output!"
  Data$ "Warning",          "Warning"
  Data$ "WarningTotals",    "Compilation succeeded with %warnings% warning(s)."
  Data$ "LogCompiler",      "[COMPILER]"
  
  Data$ "ProgramEnded",     "The execution of the Program has finished."
  Data$ "DebuggerWait",     "Press Enter to close the Debugger window."
  Data$ "DebuggerOn",       "On"
  Data$ "DebuggerOff",      "Off"
  
  Data$ "ExeNameError",     "Cannot execute the compiled File!"
  Data$ "RestartError",     "Compiler restart failed!"
  Data$ "StartError",       "Cannot start compiler"
  Data$ "CompilerNotFound", "The required compiler cannot be found"
  
  Data$ "AllCPU",           "All CPU"
  Data$ "DynamicCPU",       "Dynamic CPU"
  Data$ "MMX",              "CPU with MMX"
  Data$ "3DNOW",            "CPU with 3DNOW"
  Data$ "SSE",              "CPU with SSE"
  Data$ "SSE2",             "CPU with SSE2"
  
  Data$ "LinkerOptions",    "Linker options file"
  Data$ "SelectDebugger",   "Use selected Debugger"
  Data$ "SelectWarning",   "Use Warning mode"
  Data$ "ExecuteOptions",   "Run executable with"
  Data$ "CurrentDirectory", "Current directory"
  Data$ "TemporaryExe",     "Create temporary executable in the source directory"
  Data$ "ExecuteTools",     "Execute tools"
  Data$ "GlobalSetting",    "Global setting"
  
  Data$ "EditorConstants",  "Editor constants"
  Data$ "CustomConstants",  "Custom constants"
  
  Data$ "TargetList",       "Compile targets"
  Data$ "AddTarget",        "Add new target"
  Data$ "CopyTarget",       "Copy target"
  Data$ "RenameTarget",     "Rename target"
  Data$ "EditTarget",       "Edit target"
  Data$ "RemoveTarget",     "Remove target"
  Data$ "TargetUp",         "Move target up"
  Data$ "TargetDown",       "Move target down"
  Data$ "DefaultTarget",    "Set as default target"
  Data$ "EnableTarget",     "Enable in 'Build all Targets'"
  
  Data$ "DefaultTargetName","Default Target"
  Data$ "NewTargetName",    "New Target"
  Data$ "EnterTargetName",  "Enter target name"
  Data$ "TargetCopySuffix", "(Copy)"
  Data$ "NameExists",       "This name is already used by another target."
  Data$ "ConfirmTargetDelete", "Do you really want to delete this target?"
  Data$ "NoInputFile",      "The target '%target%' for this Project has no main sourcefile (to set in 'Compiler options')."
  Data$ "NoOutputFile",     "The target '%target%' for this Project has no output executable file."
  Data$ "SaveAnyway",       "Should it be saved anyway ?"
  
  Data$ "BuildWindowTitle", "Building..."
  Data$ "BuildProgress",    "Progress"
  Data$ "BuildLog",         "Log"
  Data$ "CloseWhenDone",    "Close window if completed successful"
  Data$ "StatusOk",         "Ok"
  Data$ "StatusError",      "Error"
  Data$ "StatusWarning",    "Warnings: %count%"
  Data$ "NoBuildTargets",   "No targets have been set in the compiler options for 'Build all Targets'."
  Data$ "BuildStart",       "Building '%target%'..."
  Data$ "BuildSuccess",     "Compilation successful."
  Data$ "BuildStatsNoError","%count% targets compiled successfully."
  Data$ "BuildStatsError",  "%count% targets compiled with errors."
  Data$ "BuildStatsWarning","%count% warnings total."
  Data$ "BuildStatsAborted","The build sequence was aborted."
  Data$ "BuildRunTool",     "Executing external tool"
  Data$ "BuildUseCompiler", "Using compiler"
  
  Data$ "TargetNotFound",   "Build target not found"
  Data$ "NoTargets",        "There are no targets to compile."
  Data$ "TargetBuildError", "Error building '%target%'"
  
  
  CompilerIf #SpiderBasic
    
    ; ===================================================
    ;- Group - Resources
    Data$ "_GROUP_",            "App"
    ; ===================================================
    
    Data$ "CreateAppTitle",     "Create App"
    Data$ "OK",                 "OK"
    Data$ "Create",             "Create App"
    Data$ "Cancel",             "Cancel"
    Data$ "Web",                "Web"
    Data$ "Android",            "Android"
    Data$ "iOS",                "iOS"
    Data$ "Creating",           "Creating app"
    Data$ "DownloadingTemplate","Downloading new template (~50 MB)"
    Data$ "Deploying"          ,"Deploying app..."
    Data$ "NoAppOutput"        ,"App output filename needs to be specified"
    Data$ "iOSMacOnly"         ,"iOS app can be only created on MacOS"
    Data$ "AndroidWindowsOnly" ,"Android app can be only created on Windows"
    Data$ "SelectIcon"         ,"Select an icon"
    Data$ "SelectResourceDirectory","Select resource directory"
    Data$ "SelectStartupImage" ,"Select a startup image"
    Data$ "EnableDebugger"     ,"Enable debugger"
    Data$ "KeepAppDirectory"   ,"Keep app directory"
    
    
    ; ===================================================
    ;- Group - Resources
    Data$ "_GROUP_",            "WebApp"
    ; ===================================================
    
    Data$ "Name",                 "App name"
    Data$ "Icon",                 "Icon"
    Data$ "Settings",             "Settings"
    Data$ "HtmlFilename",         "HTML filename"
    Data$ "JavaScriptFilename",   "JavaScript filename"
    Data$ "JavaScriptPath",       "SpiderBasic libraries path"
    Data$ "CopyJavaScriptLibrary","Copy SpiderBasic libraries"
    Data$ "PostProcessing",       "Post processing"
    Data$ "Script",               "Commandline"
    Data$ "ScriptParameter",      "Arguments"
    Data$ "SelectHtmlFile",       "Main HTML filename"
    Data$ "ResourceDirectory",    "Resource directory"
    
    ; ===================================================
    ;- Group - Resources
    Data$ "_GROUP_",            "AndroidApp"
    ; ===================================================
    
    Data$ "Settings",             "Settings"
    Data$ "NoJDK",                "Path to JDK 17 needs to be set in general Preferences/Compiler to create an Android App."
    Data$ "InvalidJDK",           "Invalid specified JDK directory (needs to be a full JDK, not a JRE)."
    Data$ "InvalidPackageID",     "Invalid specified package id. It should respect the following syntax: domain.yourcompany.appname" + #CR$ + #CR$ +"Each field can only contain ASCII character (a-z, 0-9) and has to start with a lowercase letter character."
    Data$ "Name",                 "App name"
    Data$ "Icon",                 "Icon"
    Data$ "Version",              "Version"
    Data$ "Code",                 "Code"
    Data$ "IAPKey",               "IAP Key"
    Data$ "PackageID",            "Package ID"
    Data$ "StartupImage",         "Startup image"
    Data$ "StartupColor",         "Back"
    Data$ "Orientation",          "Orientation"
    Data$ "FullScreen",           "Fullscreen"
    Data$ "Output",               "Output filename"
    Data$ "AutoUpload",           "Automatically upload on USB connected device (requires enabled debugger)"
    Data$ "ResourceDirectory",    "Resource directory"
    Data$ "WrongOutputExtension", "Android app filename extension needs to be '.apk'"
    Data$ "InsecureFileMode",     "Enable insecure HTTP support (not recommended)"
    Data$ "EnableDebugger",       "Enable debugger (no additional '.aab' package will be created)"
    Data$ "CheckInstall",         "Check Cordova setup"
    Data$ "DoCheckInstall",       "Do you want to launch the Cordova check ?"

    ; ===================================================
    ;- Group - Resources
    Data$ "_GROUP_",            "iOSApp"
    ; ===================================================
    
    Data$ "Settings",             "Settings"
    Data$ "NoAppleTeamID",        "An AppleTeamID needs to be set in general Preferences/Compiler to create an iOS App."
    Data$ "NoCordova",            "Cordova doesn't seems to be installed. Would you like to launch the SpiderBasic setup script to install required components (your approval will be asked before doing anything)."
    Data$ "Name",                 "App name"
    Data$ "Icon",                 "Icon"
    Data$ "Version",              "Version"
    Data$ "PackageID",            "Package ID"
    Data$ "StartupImage",         "Startup image"
    Data$ "Orientation",          "Orientation"
    Data$ "FullScreen",           "Fullscreen"
    Data$ "Output",               "Output filename"
    Data$ "AutoUpload",           "Automatically upload on USB connected device"
    Data$ "ResourceDirectory",    "Resource directory"
    Data$ "WrongOutputExtension", "iOS app filename extension needs to be '.ipa'"
    Data$ "CheckInstall"        , "Check XCode and Cordova setup"
    Data$ "DoCheckInstall"      , "Do you want to launch the XCode and Cordova check ?"
    
    
  CompilerEndIf
  
  ; ===================================================
  ;- Group - Resources
  Data$ "_GROUP_",            "Resources"
  ; ===================================================
  
  Data$ "CompilerOptions",  "Compiler Options"
  Data$ "CompileRun",       "Compile/Run"
  Data$ "Constants",        "Constants"
  Data$ "VersionInfo",      "Version Info"
  Data$ "Resources",        "Resources"
  
  Data$ "OpenResource",     "Select resource script to add..."
  Data$ "ResourcePattern",  "PORC resource scripts (*.rc)|*.rc|All Files (*.*)|*.*"
  
  Data$ "IncludeVersion",   "Include Version Information"
  
  Data$ "VersionField0",    "File Version (n,n,n,n)"
  Data$ "VersionField1",    "Product Version (n,n,n,n)"
  Data$ "VersionField2",    "Company Name"
  Data$ "VersionField3",    "Product Name"
  Data$ "VersionField4",    "Product Version"
  Data$ "VersionField5",    "File Version"
  Data$ "VersionField6",    "File Description"
  Data$ "VersionField7",    "Internal Name"
  Data$ "VersionField8",    "Original FileName"
  Data$ "VersionField9",    "Legal Copyright"
  Data$ "VersionField10",   "Legal Trademarks"
  Data$ "VersionField11",   "Private Build"
  Data$ "VersionField12",   "Special Build"
  Data$ "VersionField13",   "Email"
  Data$ "VersionField14",   "Website"
  Data$ "VersionField15",   "File OS"
  Data$ "VersionField16",   "File Type"
  Data$ "VersionField17",   "Language"
  
  Data$ "RequiredFields",   "Fields marked with a * are required."
  
  Data$ "Tokens",           "Tokens"
  Data$ "Token0",           "%OS : OS used for compilation."
  Data$ "Token1",           "%SOURCE : Source filename."
  Data$ "Token2",           "%EXECUTABLE : Executable name."
  Data$ "Token3",           "%COMPILECOUNT : The #PB_Editor_CompileCount value."
  Data$ "Token4",           "%BUILDCOUNT : The #PB_Editor_BuildCount value."
  Data$ "DateTokens",       "Furthermore, all Tokens of the FormatDate() command can be used."
  
  
  ; ===================================================
  ;- Group - AddTools
  Data$ "_GROUP_",            "AddTools"
  ; ===================================================
  
  Data$ "Title",            "Configure Tools"
  Data$ "Name",             "Name"
  Data$ "Commandline",      "Commandline"
  Data$ "Trigger",          "Trigger"
  Data$ "New",              "New"
  Data$ "Edit",             "Edit"
  Data$ "Delete",           "Delete"
  Data$ "Up",               "Move up"
  Data$ "Down",             "Move Down"
  
  Data$ "EditTitle",        "Edit Tool Settings"
  Data$ "Arguments",        "Arguments"
  Data$ "Info",             "Info"
  Data$ "WorkingDir",       "Working Directory"
  Data$ "Options",          "Options"
  Data$ "TriggerEvent",     "Event to trigger the tool"
  Data$ "Shortcut",         "Shortcut"
  Data$ "RunHidden",        "Run Hidden"
  Data$ "HideEditor",       "Hide Editor"
  Data$ "WaitForQuit",      "Wait until tool quits"
  Data$ "Reload",           "Reload Source after tool has quit"
  Data$ "ReloadNew",        "into new source"
  Data$ "ReloadOld",        "into current source"
  Data$ "CompileTemp",      "Use the temp file for compilation"
  Data$ "HideFromMenu",     "Hide Tool from the Main menu"
  Data$ "SourceSpecific",   "Enable Tool on a per-source basis"
  Data$ "None",             "None"
  Data$ "ChooseExe",        "Choose Executable to run"
  Data$ "ChooseDir",        "Choose Working Directory"
  Data$ "ConfigLine",       "Supported File extensions (ext1,ext2,...)"
  
  Data$ "NoCommandLine",    "You have to specify a command to execute."
  Data$ "NoName",           "You have to specify a name for your tool."
  Data$ "NameExists",       "The name you specified is already used."
  
  Data$ "Trigger0",         "Menu Or Shortcut"
  Data$ "Trigger1",         "Editor Startup"
  Data$ "Trigger2",         "Editor Closing"
  Data$ "Trigger3",         "Before Compile/Run"
  Data$ "Trigger4",         "After Compile/Run"
  Data$ "Trigger5",         "Run compiled Program"
  Data$ "Trigger6",         "Before Create Executable"
  Data$ "Trigger7",         "After Create Executable"
  Data$ "Trigger8",         "Sourcecode loaded"
  Data$ "Trigger9",         "Sourcecode saved"
  Data$ "Trigger10",        "Replace Fileviewer - All files"
  Data$ "Trigger11",        "Replace FileViewer - Unknown files"
  Data$ "Trigger12",        "Replace FileViewer - Special file"
  Data$ "Trigger13",        "Sourcecode closed"
  Data$ "Trigger14",        "New Sourcecode created"
  Data$ "Trigger15",        "Open File - with specific extension"
  Data$ "Trigger16",        "Open File - non-PB binary file"
  Data$ "Trigger17",        "Open File - non-PB text file"
  
  Data$ "Argument1",        "%PATH : Path of the current source. Empty if the source wasn't saved yet."
  Data$ "Argument2",        "%FILE : Filename and Path of the current source. Empty if it wasn't saved yet."
  Data$ "Argument3",        "%TEMPFILE : A temporary copy of the source file. You may modify or delete this at will."
  Data$ "Argument4",        "%COMPILEFILE : The temporary file that is sent to the compiler. You can modify it to change the actual compiled source."
  Data$ "Argument5",        "%EXECUTABLE : Before and after Compilation the name of the created executable"
  Data$ "Argument6",        "%CURSOR : The current cursor position given as 'LINExCOLUMN' (ie '15x10')"
  Data$ "Argument7",        "%SELECTION : The current selection given as 'LINESTARTxCOLUMNSTARTxLINEENDxCOLUMNEND' (ie '15x1x16x5')"
  Data$ "Argument8",        "%WORD : The word that is under the current cursor position."
  Data$ "Argument9",        "%HOME : The " + #ProductName$ + " directory."
  Data$ "Argument10",       "%PROJECT : The directory where the project file resides if there is an open project."
  
  
  ; ===================================================
  ;- Group - Shortcuts
  Data$ "_GROUP_",            "Shortcuts"
  ; ===================================================
  
  Data$ "Shortcuts",        "Shortcuts"
  Data$ "Shortcut",         "Shortcut"
  Data$ "Action",           "Action"
  Data$ "Set",              "Set"
  
  Data$ "Alt",              "Alt"
  Data$ "Shift",            "Shift"
  Data$ "Control",          "Ctrl"
  Data$ "Command",          "Cmd"
  Data$ "Numpad",           "Numpad"
  
  Data$ "NextOpenFile",     "Jump to next open File"
  Data$ "PreviousOpenFile", "Jump to previous open File"
  Data$ "ShiftCommentRight","Shift comments to the right"
  Data$ "ShiftCommentLeft", "Shift comments to the left"
  Data$ "SelectBlock",      "Select surrounding code block"
  Data$ "DeselectBlock",    "Revert to previous code block selection"
  Data$ "MoveLinesUp",      "Move selected lines up"
  Data$ "MoveLinesDown",    "Move selected lines down"
  Data$ "DeleteLines",      "Delete selected lines"
  Data$ "DuplicateSelection","Duplicate selection"
  Data$ "UpperCase",        "Upper Case selection"
  Data$ "LowerCase",        "Lower Case selection"
  Data$ "InvertCase",       "Invert Case selection"
  Data$ "SelectWord",       "Select whole word at cursor"
  Data$ "ZoomIn",           "Zoom in"
  Data$ "ZoomOut",          "Zoom out"
  Data$ "ZoomDefault",      "Zoom default"
  Data$ "AutoComplete",     "Display the AutoComplete Window"
  Data$ "AutoCompleteConfirm","Insert the selected AutoComplete word"
  Data$ "AutoCompleteAbort",  "Close the AutoComplete Window"
  Data$ "ProceduresUpdate", "Trigger Update of Procedure & Variable Viewer"
  
  Data$ "AllreadyUsed",     "The shortcut you specified is already used by" ; DO NOT FIX TYPO: AllreadyUsed
  Data$ "ReassignPrompt",   "Should the shortcut be reassigned?"
  Data$ "ExternalTool",     "External Tool"
  Data$ "Menu",             "Menu"
  Data$ "TabIntend",        "Indent/Unindent code Selection"
  Data$ "SystemShortcut",   "Reserved Shortcut for the System"
  Data$ "SelectShortcut",   "Select shortcut"
  
  Data$ "Key71",            "Backspace"
  Data$ "Key72",            "Tab"
  Data$ "Key73",            "Clear"
  Data$ "Key74",            "Return"
  Data$ "Key75",            "Alt"
  Data$ "Key76",            "Pause"
  Data$ "Key77",            "Print"
  Data$ "Key78",            "Caps Lock"
  Data$ "Key79",            "Escape"
  Data$ "Key80",            "Space"
  Data$ "Key81",            "Page Up"
  Data$ "Key82",            "Page Down"
  Data$ "Key83",            "End"
  Data$ "Key84",            "Home"
  Data$ "Key85",            "Left"
  Data$ "Key86",            "Up"
  Data$ "Key87",            "Right"
  Data$ "Key88",            "Down"
  Data$ "Key89",            "Select"
  Data$ "Key90",            "Execute"
  Data$ "Key91",            "Print Screen"
  Data$ "Key92",            "Insert"
  Data$ "Key93",            "Delete"
  Data$ "Key94",            "Help"
  Data$ "Key95",            "Left Windows Key"
  Data$ "Key96",            "Right Windows Key"
  Data$ "Key97",            "Applications"
  Data$ "Key98",            "Multiply"
  Data$ "Key99",            "Add"
  Data$ "Key100",           "Separator"
  Data$ "Key101",           "Subtract"
  Data$ "Key102",           "Decimal"
  Data$ "Key103",           "Divide"
  Data$ "Key104",           "Num Lock"
  Data$ "Key105",           "Scroll Lock"
  Data$ "Key106",           "Plus"
  Data$ "Key107",           "Minus"
  
  
  ; ===================================================
  ;- Group - Help
  Data$ "_GROUP_",            "Help"
  ; ===================================================
  
  Data$ "Title",            "Help"
  Data$ "Contents",         "Contents"
  Data$ "Index",            "Index"
  Data$ "Search",           "Search"
  Data$ "StartSearch",      "Search"
  Data$ "Back",             "Go back"
  Data$ "Forward",          "Go forward"
  Data$ "Home",             "Reference"
  Data$ "Next",             "Next Topic"
  Data$ "Previous",         "Previous Topic"
  Data$ "OpenHelp",         "Open Help"
  Data$ "OpenF1",           "Open sidebar help on F1"
  Data$ "NoResults",        "No results found."
  
  ; for Linux viewer
  Data$ "Parent",           "Up"
  Data$ "Back",             "Back"
  
  
  ; ===================================================
  ;- Group - FileViewer
  Data$ "_GROUP_",            "FileViewer"
  ; ===================================================
  
  Data$ "Title",            "File Viewer"
  Data$ "Pattern",          "Image Files (*.bmp, *.png, *.jpg, *.jpeg, *.tga, *.ico)|*.bmp;*.png;*.jpg;*.jpeg;*.tga;*.ico|HTML Documents (*.html, *.htm)|*.html;*.htm|Text Documents (*.txt)|*.txt|All Files (*.*)|*.*"
  Data$ "Open",             "Open File"
  Data$ "Close",            "Close File"
  Data$ "Next",             "Show next File"
  Data$ "Previous",         "Show previous File"
  Data$ "SizeWarning",      "Warning! This file is very large."
  Data$ "SizeError",        "This file is too large (> 10 MB)."
  Data$ "SizeQuestion",     "Do you still want to load it?"
  
  ;     ; ===================================================
  ;     ;- Group - CPUMonitor
  ;     Data$ "_GROUP_",            "CPUMonitor"
  ;     ; ===================================================
  ;
  ;       Data$ "Title",            "CPU Monitor"
  ;       Data$ "Intervall",        "Update Interval (ms)" ; DO NOT FIX TYPO: Intervall
  ;       Data$ "Free",             "Free Resources"
  ;       Data$ "All",              "Total Usage"
  ;       Data$ "Program",          "Program"
  ;       Data$ "CPUTime",          "CPU Time"
  ;       Data$ "CPUUsage",         "CPU Usage"
  ;       Data$ "MEMUsage",         "Memory"
  ;       Data$ "InvalidIntervall", "Invalid Interval size!"  ; DO NOT FIX TYPO: InvalidIntervall
  ;       Data$ "MonitorError",     "The CPU Monitor is not available on this system!"
  ;
  
  ; ===================================================
  ;- Group - Templates
  Data$ "_GROUP_",            "Templates"
  ; ===================================================
  
  Data$ "Title",           "Templates"
  Data$ "EnterName",       "Enter Template Name"
  Data$ "EnterDirName",    "Enter Directory Name"
  
  Data$ "Code",            "Code"
  Data$ "Comment",         "Comment"
  
  Data$ "New",             "New Template"
  Data$ "Edit",            "Edit Template"
  Data$ "Delete",          "Delete Template"
  Data$ "NewDir",          "New Directory"
  Data$ "DeleteDir",       "Delete Directory"
  Data$ "Up",              "Move Up"
  Data$ "Down",            "Move Down"
  
  Data$ "DeleteNonEmpty",  "The Directory is not empty.%newline%Do you still want to delete it?"
  Data$ "DeleteQuestion",  "Do you really want to delete this Template?"
  Data$ "DeletePreference","Ask before deleting any Template"
  
  Data$ "MenuUse",         "Insert into Code"
  Data$ "MenuNew",         "New"
  Data$ "MenuEdit",        "Edit"
  Data$ "MenuDelete",      "Delete"
  Data$ "MenuNewDir",      "New Directory"
  Data$ "MenuDeleteDir",   "Delete Directory"
  Data$ "MenuRename",      "Rename"
  Data$ "MenuUp",          "Up"
  Data$ "MenuDown",        "Down"
  
  Data$ "MenuCut",         "Cut"
  Data$ "MenuCopy",        "Copy"
  Data$ "MenuPaste",       "Paste"
  Data$ "MenuSelectAll",   "Select All"
  
  
  ; ===================================================
  ;- Group - Debugger
  Data$ "_GROUP_",            "Debugger"
  ; ===================================================
  
  Data$ "ShowErrorLog",     "Show Error Log"
  Data$ "LogEmpty",         "The Error Log is empty."
  
  Data$ "IsRunning",        "This Source file or Project is already being debugged by the IDE."
  Data$ "IsRunning2",       "Do you want to use the standalone debugger?"
  Data$ "ExecuteError",     "Cannot execute the file with the internal debugger. Please try the standalone one."
  Data$ "ExecutableType",   "Executable type"
  
  Data$ "TimeStamp",        "%hh:%ii:%ss"
  Data$ "ChooseStep",       "Select Number of Steps to execute:"
  
  Data$ "Waiting",          "Waiting for executable to start..."
  Data$ "ExeStarted",       "Executable started."
  Data$ "ExeEnded",         "The Program execution has finished."
  Data$ "Stopped",          "Execution stopped."
  Data$ "Continued",        "Execution continued."
  Data$ "OneStep",          "Executing one Step."
  Data$ "StepX",            "Executing %x% Steps."
  Data$ "StepOver",         "Executing procedure."
  Data$ "StepOut",          "Executing rest of the procedure."
  Data$ "ExeKilled",        "The Program was killed."
  
  Data$ "Breakpoint",       "Breakpoint"
  Data$ "BeforeEnd",        "Program about to end"
  Data$ "UserRequest",      "User request"
  Data$ "DataBreakpoint",   "Data Breakpoint"
  
  Data$ "LogError",         "[ERROR]"
  Data$ "LogWarning",       "[WARNING]"
  Data$ "EditError",        "Cannot edit sourcecode. It is being debugged."
  Data$ "MemoryError",      "Cannot allocate memory for Debugger communication!%newline%Debugger quitting..."
  Data$ "PipeError",        "Connection to debugged executable broken!%newline%Debugger quitting..."
  Data$ "VersionError",     "The Version of debugger and executable do not match!%newline%Try recompiling the executable.%newline%If the problem persists, reinstall PureBasic."
  Data$ "ExeQuitError",     "The debugged executable quit unexpectedly."
  Data$ "TimeoutError",     "The debugged executable did not respond to communication for %timeout% seconds. Disconnecting."
  Data$ "NetworkError",     "The network connection to the executable was lost."
  
  Data$ "DebugWindowTitle", "Debug Output"
  Data$ "Debug",            "Debug"
  Data$ "Clear",            "Clear"
  Data$ "Copy",             "Copy all"
  Data$ "Save",             "Save"
  
  Data$ "AsmWindowTitle",   "Asm Debugger"
  Data$ "Registers",        "Processor Registers"
  Data$ "Stack",            "Stack Trace"
  Data$ "Set",              "Set"
  Data$ "Update",           "Update"
  
  Data$ "MemoryWindowTitle","Memory Viewer"
  Data$ "Range",            "Range"
  Data$ "Display",          "Display"
  Data$ "ViewHex",          "Hex View"
  Data$ "ViewString",       "String View"
  Data$ "ViewByte",         "Byte Table"
  Data$ "ViewWord",         "Word Table"
  Data$ "ViewLong",         "Long Table"
  Data$ "ViewFloat",        "Float Table"
  Data$ "ViewChar",         "Character Table"
  Data$ "ViewDouble",       "Double Table"
  Data$ "ViewQuad",         "Quad Table"
  Data$ "CopyText",         "Copy (Text)"
  Data$ "SaveText",         "Save (Text)"
  Data$ "SaveRaw",          "Save (Raw)"
  Data$ "InvalidMemory",    "The specified memory location is not valid for reading."
  
  Data$ "VariableWindowTitle","Variable Viewer"
  Data$ "Variables",        "Variables"
  Data$ "Arrays",           "Arrays"
  Data$ "LinkedLists",      "LinkedLists"
  Data$ "Maps",             "Maps"
  Data$ "Name",             "Name"
  Data$ "Scope",            "Scope"
  Data$ "Value",            "Value"
  Data$ "Size",             "Size"
  Data$ "Current",          "Current"
  Data$ "Index",            "Index"
  Data$ "WatchlistAdd",     "Add to Watchlist"
  Data$ "ViewArrayList",    "View Array/List/Map"
  Data$ "ArrayListName",    "Array/List/Map Name"
  Data$ "ItemRange",        "Display Range"
  Data$ "NonZeroItems",     "Display Non-zero items only"
  Data$ "AllItems",         "Display all items"
  Data$ "EnterRange",       "Enter range to display"
  
  Data$ "HistoryWindowTitle", "Procedure Callstack"
  Data$ "History",          "Callstack"
  Data$ "Statistics",       "Statistics"
  Data$ "Line",             "Line"
  Data$ "File",             "File"
  Data$ "CurrentPosition",  "Current Code position"
  Data$ "ShowVariables",    "Variables"
  Data$ "Updating",         "Updating data, please wait."
  Data$ "CallCount",        "Call count"
  Data$ "Reset",            "Reset"
  Data$ "ResetAll",         "Reset All"
  
  Data$ "WatchListTitle",   "Watch List"
  Data$ "Add",              "Add"
  Data$ "Remove",           "Remove"
  Data$ "Procedure",        "Procedure"
  Data$ "Variable",         "Variable"
  Data$ "AddVariable",      "Add Variable to List"
  Data$ "NoProcedure",      "--- Main ---"
  Data$ "AllProcedures",    "--- All ---"
  Data$ "VariableError",    "Cannot add variable!"
  
  Data$ "DataBreakpoints",  "Data Breakpoints"
  Data$ "Condition",        "Condition"
  Data$ "ConditionStatus",  "Status"
  Data$ "AddBreakPoint",    "Add Data Breakpoint"
  Data$ "BreakPointError",  "Cannot add Breakpoint!"
  
  Data$ "LibraryViewerTitle","Library Viewer"
  Data$ "SelectLibrary",    "Select Library"
  Data$ "NoLibraryInfo",    "No Information"
  
  Data$ "PurifierTitle",    "Purifier Settings"
  Data$ "PurifierIntervall","Integrity check interval" ; DO NOT FIX TYPO: PurifierIntervall
  Data$ "GlobalIntervall",  "Global variable space"    ; DO NOT FIX TYPO: GlobalIntervall
  Data$ "LocalIntervall",   "Local variable space"     ; DO NOT FIX TYPO: LocalIntervall
  Data$ "StringIntervall",  "String variables"         ; DO NOT FIX TYPO: StringIntervall
  Data$ "DynamicIntervall", "Allocated memory"         ; DO NOT FIX TYPO: DynamicIntervall
  Data$ "CheckAlways",      "Every line"
  Data$ "CheckLines",       "Every %lines% lines"
  Data$ "CheckNever",       "Never"
  
  Data$ "ProfilerTitle",    "Profiler"
  Data$ "ProfilerNoData",   "No Profiler data available."
  Data$ "CalledLines",      "Called Lines"
  Data$ "CallsPerLine",     "Calls / Line"
  Data$ "Zoomin",           "Zoom in"
  Data$ "Zoomout",          "Zoom out"
  Data$ "ViewLine",         "Show code line"
  
  Data$ "NoData",           "This Data is currently not available."
  
  Data$ "SaveFileTitle",    "Save File as..."
  Data$ "SaveFilePattern",  "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
  Data$ "SaveError",        "Cannot create File: '%filename%'"
  
  Data$ "BigArray",         "The Array has more than 50000 elements.%newline%Do you really want to view them all?"
  Data$ "BigList",          "The LinkedList has more than 50000 elements.%newline%Do you really want to view them all?"
  
  ; ===================================================
  ;- Group - NetworkDebugger
  Data$ "_GROUP_",            "NetworkDebugger"
  ; ===================================================
  
  Data$ "Waiting",         "Waiting for the network connection to be established..."
  Data$ "Unavailable",     "Network access could not be established."
  Data$ "Port",            "Port"
  Data$ "ExeVersion",      "Executable Version"
  Data$ "DebuggerVersion", "Debugger Version"
  
  Data$ "ServerTitle",      "Waiting for connections on port %port% ..."
  Data$ "ServerTitleNamed", "Waiting for connection on %host% (port %port%) ..."
  Data$ "Listen",           "Waiting for incoming connection..."
  Data$ "ServerFailed",     "Could not create server on port"
  Data$ "ConnectionDenied", "Connection denied."
  
  Data$ "ConnectTitle",     "Connecting to"
  Data$ "Connect",          "Connecting to server..."
  Data$ "QueryStatus",      "Querying status..."
  Data$ "ConnectionSuccess","Connection established successfully."
  Data$ "ConnectionFailed", "Connection failed."
  Data$ "ConnectionLost",   "Connection lost."
  Data$ "ConnectFailed",    "Could not connect to server"
  Data$ "NeedPassword",     "A password is required."
  Data$ "WrongPassword",    "Password incorrect."
  
  Data$ "Error_InvalidRequest", "Invalid request."
  Data$ "Error_InvalidResponse","Invalid response."
  Data$ "Error_WrongVersion",   "The PureBasic Versions do not match."
  Data$ "Error_NoExecutable",   "The server is not a debugger enabled executable."
  Data$ "Error_NoDebugger",     "The server is not a PureBasic debugger."
  Data$ "Error_NoService",      "The server cannot provide the requested service."
  Data$ "Error_FatalError",     "Fatal error."
  
  
  ; ===================================================
  ;- Group - StandaloneDebugger
  Data$ "_GROUP_",            "StandaloneDebugger"
  ; ===================================================
  
  Data$ "CommandLine",      "Invalid commandline!%newline%You have to specify the executable name on the commandline."
  Data$ "CommandFile",      "Cannot read command file '%filename%'."
  Data$ "ExecuteError",     "Cannot execute file '%filename%'."
  Data$ "Run",              "Run"
  Data$ "Stop",             "Stop"
  Data$ "Step",             "Step"
  Data$ "StepOver",         "Step Over"
  Data$ "StepOut",          "Step Out"
  Data$ "Quit",             "Quit"
  Data$ "BreakSetRemove",   "Set/Remove Breakpoint"
  Data$ "BreakClear",       "Clear Breakpoints"
  Data$ "DataBreak",        "Data Breakpoints"
  Data$ "NoFile",           "Sourcefile not available."
  
  Data$ "VariableList",     "Variables"
  Data$ "Memory",           "Memory"
  Data$ "DebugOutput",      "Output"
  Data$ "Library",          "Library"
  Data$ "Profiler",         "Profiler"
  Data$ "Purifier",         "Purifier"
  
  ; ===================================================
  ;- Group - Misc
  Data$ "_GROUP_",            "Misc"
  ; ===================================================
  
  Data$ "Line",             "Line"
  Data$ "Column",           "Column"
  Data$ "Selection",        "Selection"
  Data$ "File",             "File"
  
  Data$ "Ok",               "Ok"
  Data$ "Cancel",           "Cancel"
  Data$ "Close",            "Close"
  Data$ "Save",             "Save"
  Data$ "Abort",            "Abort"
  Data$ "Open",             "Open"
  Data$ "New",              "New"
  Data$ "Copy",             "Copy"
  Data$ "Update",           "Update"
  Data$ "Delete",           "Delete"
  Data$ "Color",            "Color"
  
  Data$ "Up",               "Up"
  Data$ "Down",             "Down"
  Data$ "Set",              "Set"
  Data$ "Add",              "Add"
  Data$ "Remove",           "Remove"
  Data$ "Clear",            "Clear"
  Data$ "Enabled",          "Enabled"
  Data$ "Disabled",         "Disabled"
  Data$ "Status",           "Status"
  Data$ "Error",            "Error"
  
  Data$ "Start",            "Start"
  Data$ "Stop",             "Stop"
  Data$ "Yes",              "Yes"
  Data$ "No",               "No"
  
  Data$ "Weekday0",         "Sunday"
  Data$ "Weekday1",         "Monday"
  Data$ "Weekday2",         "Tuesday"
  Data$ "Weekday3",         "Wednesday"
  Data$ "Weekday4",         "Thursday"
  Data$ "Weekday5",         "Friday"
  Data$ "Weekday6",         "Saturday"
  
  Data$ "StayOnTop",        "Stay on Top"
  
  Data$ "NoQuickHelp",      "No QuickHelp available."
  Data$ "PreferenceError",  "Your settings can't be saved!%newline%The file '%filename%' cannot be created."
  Data$ "ReadError",        "Cannot open the file"
  
  Data$ "OpenFile",         "Choose File to open..."
  Data$ "SaveFile",         "Choose File to save..."
  
  Data$ "AboutWindowTitle", "About..."
  Data$ "GotoWindowTitle",  "Goto..."
  Data$ "SortSourcesTitle", "Sort Sources..."
  Data$ "MacroErrorTitle",  "Macro Error"
  Data$ "WarningsTitle",    "Compiler Warnings"
  
  Data$ "ToolbarError",     "Could not find Toolbar Icon"
  Data$ "AutomationTimeout","An Automation client failed to respond to communication.%newline%The connection will be terminated."
  Data$ "Welcome",          "Welcome aboard !"
  Data$ "AskScreenReader",  "A Screen Reader software was detected. Do you wish to enable accessibility features?%newline%%newline%(You can change this option later under File - Preferences - General)"
  
  Data$ "ImageManagerTitle","Image Manager"
  Data$ "MessageContinue",   "Do you want to continue?"

  
  ; ===================================================
  ;- Group - Form
  Data$ "_GROUP_",            "Form"
  ; ===================================================
  
  Data$ "Form",               "Form"
  Data$ "FormShort",          "Form"
  Data$ "FormLong",           "Form Panel"
  Data$ "Item",               "Item"
  Data$ "Level",              "Level"
  Data$ "Constant",           "Constant"
  Data$ "Name",               "Name"
  Data$ "Title",              "Title"
  Data$ "Separator",          "Separator"
  Data$ "Shortcut",           "Shortcut"
  Data$ "OutOfMemoryError",   "Can't render gadget of %size% pixels (out of memory)."
  Data$ "N/A",                "N/A"
  
  Data$ "MessageNewer",       "This file was created with a newer version of the designer (%s%).%newline%Any unsupported features may be lost."
  Data$ "MessageOlder",       "This file was created with an older version of the designer (%s%) and will be upgraded to the current version."
  Data$ "MessageBackward",    "This file was created with an older version of the designer (%s%).%newline%Backward compatibility may be affected if upgraded."
  Data$ "MessageNotDesign",   "This file does not appear to contain a form design.%newline%The content may not be imported properly."
  Data$ "Option_Always",      "Always"
  Data$ "Option_Backward",    "If backward compatibility is affected"
  Data$ "Option_Never",       "Never"
  
  ;Data$ "_GROUP_",            "StatusWindow"
  ; ===================================================
  Data$ "Width",       "Width"
  Data$ "Text",        "Text"
  Data$ "Image",       "Image"
  Data$ "Alignment",   "Alignment"
  Data$ "Flag",        "Flag"
  Data$ "ProgressBar", "ProgressBar?"
  Data$ "Left",        "Left"
  Data$ "Center",      "Center"
  Data$ "Right",       "Right"
  Data$ "Normal",      "Normal"
  Data$ "Raised",      "Raised"
  Data$ "Borderless",  "Borderless"
  
  ;Data$ "_GROUP_",            "ToolWindow"
  ; ===================================================
  Data$ "Constant",     "Constant"
  Data$ "Tooltip",      "Tooltip"
  Data$ "ToggleButton", "Toggle Button"
  Data$ "Separator",    "Separator?"
  
  ;Data$ "_GROUP_",            "ZOrderWindow"
  ; ===================================================
  Data$ "Variable",     "Variable"
  Data$ "Caption",      "Caption"
  
  ;Data$ "_GROUP_",            "SplitterWindow"
  ; ===================================================
  Data$ "CreateSplitterTitle",  "Create Splitter"
  Data$ "FirstGadget",          "First gadget:"
  Data$ "SecondGadget",         "Second gadget:"
  Data$ "StartDrawing",         "Start drawing"
  Data$ "Cancel",               "Cancel"
  Data$ "OK",                   "OK"
  Data$ "SelectError",          "You need to select two different gadgets."
  Data$ "GadgetListError",      "The two gadgets need to belong to the same gadget list."
  
  ;Data$ "_GROUP_",            "HelpingFunctions"
  ; ===================================================
  Data$ "Select",             "Select..."
  Data$ "SetRelativePath",    "Set Relative Path"
  
  ;Data$ "_GROUP_",            "ImageWin"
  ; ===================================================
  Data$ "ImageURL",           "Image URL"
  Data$ "SelectImage",        "Select Image"
  Data$ "RelativePath",       "Relative Path"
  
  ;Data$ "_GROUP_",            "PropGrid"
  ; ===================================================
  Data$ "Checked",            "Checked"
  Data$ "Font",               "Font"
  Data$ "Color",              "Color"
  Data$ "FrontColor",         "FrontColor"
  Data$ "BackColor",          "BackColor"
  Data$ "SelectGadget",       "Select gadget"
  Data$ "InitCode",           "Init code"
  Data$ "CreateCode",         "Create code"
  Data$ "Help",               "Help"
  Data$ "Min",                "Min"
  Data$ "Max",                "Max"
  Data$ "InnerWidth",         "Inner width"
  Data$ "InnerHeight",        "Inner height"
  Data$ "CurrentImage",       "Current Image"
  Data$ "ChangeImage",        "Change Image"
  Data$ "Variable",           "Variable"
  Data$ "CaptionIsVariable",  "Caption is a variable?"
  Data$ "Caption",            "Caption"
  Data$ "TooltipIsVariable",  "ToolTip is a variable?"
  Data$ "Tooltip",            "ToolTip"
  Data$ "WrongVarName",       "Invalid character in variable name."
  Data$ "Mask",               "Mask"
  Data$ "Width",              "Width"
  Data$ "Height",             "Height"
  Data$ "Hidden",             "Hidden"
  Data$ "Disabled",           "Disabled"
  Data$ "Objects",            "Objects"
  Data$ "Properties",         "Properties"
  Data$ "GenEventProc",       "Generate events procedure?"
  Data$ "SelectFile",         "Event file"
  Data$ "SelectProc",         "Event procedure"
  Data$ "SplitterPosition",   "Splitter position"
  Data$ "LockLeft",           "Lock Left"
  Data$ "LockRight",          "Lock Right"
  Data$ "LockTop",            "Lock Top"
  Data$ "LockBottom",         "Lock Bottom"
  Data$ "Toolbox",            "Toolbox"
  
  ;Data$ "_GROUP_",            "Window"
  ; ===================================================
  Data$ "ParentTitle",          "Set Parent For '%id%'"
  Data$ "EditItemsTitle",       "Edit Items For '%id%'"
  Data$ "EditColumnsTitle",     "Edit Columns For '%id%'"
  
  Data$ "SelectEventFileFirst", "You need to select an event file first."
  Data$ "CreateEventFile",      "The file doesn't exist - do you want to create it?"
  Data$ "FileAlreadyOpened",    "This file is already opened."
  Data$ "DeleteItemConfirm",    "Do you really want to delete this item?"
  Data$ "MoveGadgetWarning",    "This gadget cannot be moved before its parent gadget or item."
  Data$ "DeleteGadgetWarning",  "You are going to delete a gadget (and all its child items). Do you want to continue?"
  Data$ "SaveRequiredWarning",  "You need to save your project first."
  Data$ "ResizeGadgetImg",      "Do you want to resize the gadget to the image size?"
  Data$ "SelectImage",          "Select Image..."
  Data$ "MaskAllFiles",         "All files (*.*)|*.*"
  CompilerIf #SpiderBasic
    Data$ "MaskPBF",              "SpiderBasic Form (*.sbf)|*.sbf"
    Data$ "MaskPB",               "SpiderBasic File (*.sb)|*.sb;*.sbi"
  CompilerElse
    Data$ "MaskPBF",              "PureBasic Form (*.pbf)|*.pbf"
    Data$ "MaskPB",               "PureBasic File (*.pb)|*.pb;*.pbi"
  CompilerEndIf
  Data$ "OpenProject",          "Open Project..."
  Data$ "SaveProject",          "Save Project..."
  Data$ "NoGadgetSelected",     "No gadget selected (or gadget items not applicable)."
  Data$ "ChooseItemName",       "Choose the name of the item"
  Data$ "AddItemWarning",       "Cannot add an item to the selected gadget."
  Data$ "QuitMessage",          "The file <%filename%> has not been saved yet. Do you want to save it now?"
  Data$ "ChangesWarning",       "Changes will not be saved. Do you want to continue?"
  Data$ "NewTabName",           "Input the new name of the tab:"
  Data$ "Help",                 "Help"
  Data$ "File",                 "File"
  Data$ "Home",                 "Home"
  Data$ "Quit",                 "Quit"
  Data$ "New",                  "New"
  Data$ "Open",                 "Open"
  Data$ "Save",                 "Save"
  Data$ "SaveAs",               "Save As..."
  Data$ "Rename",               "Rename"
  Data$ "Delete",               "Delete"
  Data$ "SelectAll",            "Select All"
  Data$ "RemoveColour",         "Remove Colour"
  Data$ "RemoveFont",           "Remove Font"
  Data$ "Edit",                 "Edit"
  Data$ "Undo",                 "Undo"
  Data$ "Redo",                 "Redo"
  Data$ "Cut",                  "Cut"
  Data$ "Copy",                 "Copy"
  Data$ "Paste",                "Paste"
  Data$ "Duplicate",            "Duplicate"
  Data$ "AddItem",              "Add Item"
  Data$ "AddButton",            "Add Button"
  Data$ "AddToggle",            "Add Toggle Button"
  Data$ "AddImage",             "Add Image"
  Data$ "AddLabel",             "Add Label"
  Data$ "AddSeparator",         "Add Separator"
  Data$ "AddProgressBar",       "Add ProgressBar"
  Data$ "DeleteToolbar",        "Delete Toolbar"
  Data$ "DeleteToolbarItem",    "Delete Toolbar Item"
  Data$ "DeleteStatusBar",      "Delete StatusBar"
  Data$ "DeleteField",          "Delete Field"
  Data$ "DeleteMenu",           "Delete Menu"
  Data$ "DeleteMenuItem",       "Delete Menu Item"
  Data$ "EditItems",            "Edit Items"
  Data$ "EditColumns",          "Edit Columns"
  Data$ "AllForms",             "All Forms"
  Data$ "CommonControls",       "Common Controls"
  Data$ "Containers",           "Containers"
  Data$ "MenusToolbars",        "Menus & Toolbars"
  Data$ "Cursor",               "Cursor"
  Data$ "ZOrder",               "Order"
  Data$ "Menu",                 "Menu"
  Data$ "Toolbar",              "Toolbar"
  Data$ "Statusbar",            "Status Bar"
  Data$ "Images",               "Images"
  Data$ "Window",               "Window"
  Data$ "Gadgets",              "Gadgets"
  Data$ "View",                 "View"
  Data$ "Clipboard",            "Clipboard"
  Data$ "DesignView",           "Design View"
  Data$ "CodeView",             "Code View"
  Data$ "Data",                 "Data"
  Data$ "DataInput",            "Data Input"
  Data$ "DataList",             "Data List"
  Data$ "Action",               "Action"
  Data$ "DecorationContainers", "Decoration/Containers"
  Data$ "Decoration",           "Decoration"
  Data$ "Containers",           "Containers"
  Data$ "AlignLeft",            "Align selected gadgets to the left"
  Data$ "AlignTop",             "Align selected gadgets to the top"
  Data$ "AlignWidth",           "Align selected gadgets width"
  Data$ "AlignHeight",          "Align selected gadgets height"
  Data$ "Remove",               "Remove"
  Data$ "Parent",               "Parent"
  Data$ "ParentItem",           "Parent Item"
  Data$ "CustomFlags",          "Custom Flags"
  
 
  ; ===================================================
  ;- Group - Updates
  Data$ "_GROUP_",            "Updates"
  ; ===================================================
  
  Data$ "Title",            "PureBasic Updates"
  Data$ "MessageSingle",    "A new version of PureBasic is available for download on%newline%your personal account"
  Data$ "MessageMulti",     "The following new versions of PureBasic are available%newline%for download on your personal account"
  Data$ "MessageDemo",      "A new version of PureBasic is available for download"
  Data$ "VisitWebSite",     "Visit the download site"
  Data$ "ChangeSetting",    "Change settings"
  Data$ "NoUpdates",        "No new release versions available.%newline%(Versions check filtering can be changed in preferences)."
  Data$ "NoUpdatesLTS",     "No new LTS versions available.%newline%(Versions check filtering can be changed in preferences)."
  Data$ "NoUpdatesBeta",    "No new versions available (including beta).%newline%(Versions check filtering can be changed in preferences)."
  Data$ "Error",            "Could not retrieve information about new updates"
  
  
  ; ===================================================
  Data$ "_END_",              ""
  ; ===================================================
  
EndDataSection
