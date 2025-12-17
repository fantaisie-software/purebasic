; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
; This file should contain *all* function declarations that are meant to be used publicly.
; This means that any function that is being used outside of the file it is written in
; is to be declared here. This will rule out any conflicts with non-declared functions, and make the overview easier.
; If necessary, specify a short comment on the function purpose and the file that it is in!
;

; ===========================================
; Platform specific files
; ===========================================

;- CompilerInterface.pb
;
Declare StartCompiler(*Compiler.Compiler); start the compiler at editor start
Declare WaitForCompilerReady(NoReadyCall=0) ; wait until the compiler is fully loaded (calls FlushEvents!)
Declare RestartCompiler(*Compiler.Compiler, NoReadyCall=0); user triggered compiler restart
Declare ForceDefaultCompiler()                            ; make sure the default compiler is currently loaded
Declare KillCompiler()                                    ; kill compiler
Declare CompilerCleanup()                                 ; clean up all temp files at the end
Declare MatchCompilerVersion(Version1$, Version2$, Flags = #MATCH_Exact)
Declare FindCompiler(Version$)
Declare GetCompilerVersion(Executable$, *Compiler.Compiler) ; get the version info for the given exe
Declare.s Compiler_TemporaryFilename(*Target.CompileTarget)
Declare Compiler_CompileRun(SourceFileName$, *Source.SourceFile, CheckSyntax)           ; compilerun with the given source (no Project targsts used here!)
Declare Compiler_Run(*Target.CompileTarget, IsFirstRun)                                 ; run the target
Declare Compiler_BuildTarget(SourceFileName$, TargetFileName$, *Target.CompileTarget, CreateExe, CheckSyntax)  ; create executable with the given source

;- HelpViewer.pb
;- WindowsHelp.pb
;
Declare DisplayHelp(CurrentWord$)  ; display the help for the given word (all os)
CompilerIf #CompileLinux | #CompileMac
  Declare OpenHelpWindow()           ; linux/mac only
  Declare UpdateHelpWindow()         ; linux/mac only
  Declare HelpWindowEvents(EventID)  ; linux/mac only
CompilerEndIf
CompilerIf #CompileWindows
  Declare ClosePlatformSDKWindow()          ; windows only (called at program end)
CompilerEndIf

;- LinuxExtensions.pb
;- WindowsExtensions.pb
;
Declare GetFocusGadgetID(Window)    ; get the ID of the gadget with the keyboard focus (in the given window)
Declare ShowWindowMaximized(Window) ; maximize window
Declare IsWindowMaximized(Window)   ; return true if window is maximized
Declare IsWindowMinimized(Window)   ; return true if window is minimized
Declare SetWindowForeground(Window) ; put window in foreground
Declare SetWindowForeground_NoActivate(Window) ; set window to the foreground without giving it the focus (and without a focus event!)
Declare SetWindowStayOnTop(Window, StayOnTop)  ; make window stay on top
Declare GetPanelWidth(Gadget)                  ; get width of panelgadget items
Declare GetPanelHeight(Gadget)                 ; get height of panelgadget items
Declare RedrawGadget(Gadget)                   ; trigger an update of the gadget (must work with the EditorGadget!)
Declare SelectComboBoxText(Gadget)             ; select all text in editable combobox
Declare SetStringBufferSize(NewSize)           ; set the size of the string manipoulation buffer (for debugger)
Declare GetButtonBackgroundColor()             ; get the default background for a button
Declare StartFlickerFix(Window)                ; stop window redrawing to fix flickering
Declare StopFlickerFix(Window, DoRedraw)       ; enable window redrawing again, and immediately redraw (if DoRedraw is set)
Declare StartGadgetFlickerFix(Gadget)          ; stop gadget redrawing
Declare StopGadgetFlickerFix(Gadget)           ; redraw gadget again
Declare ZeroMemory(*Buffer, Size)              ; ZeroMemory
Declare.s GetExplorerName()                    ; returns the name of the system "explorer" program
Declare ShowExplorerDirectory(Directory$)      ; open a directory in the system file viewer
Declare ModifierKeyPressed(Key)                ; Check if #PB_Shortcut_Control, _Alt, _Shift, _Command is pressed
Declare OpenWebBrowser(Url$)                   ; open the default web browser
Declare GetListViewScroll(Gadget)              ; Get listview vertical scroll position
Declare SetListViewScroll(Gadget, Position)    ; Set listview vertical scroll position

CompilerIf #CompileWindows
  Declare SetWindowForeground_Real(Window) ; grab focus from other apps
CompilerEndIf
CompilerIf #CompileLinuxGtk
  Declare GTKSignalConnect(*Widget, Signal$, Function, user_data)
CompilerEndIf

;- LinuxMisc.pb
;- WindowsMisc.pb
;
Declare OSStartupCode()               ; code to execute before everything else (get paths etc)
Declare OSEndCode()                   ; code to execute after everything else (close dlls etc)
Declare GetWindowMetrics()            ; executed after main window is open (get statusbarheight, setup callbacks, etc)
Declare LoadEditorFonts()             ; load editor fonts, determine bold font name if needed, load bold font if needed
Declare UpdateToolbarView()           ; hide/show main toolbar according to settings
Declare RunOnce_Startup(InitialSourceLine) ; handle all RunOnce stuff on startup (return true if IDE should exit)
Declare RunOnce_UpdateSetting()            ; set/unset the mutex for runonce according to the prefs
Declare Session_IsRunning(OSSessonID$)     ; detection of running sessions. must be independent of runOnce handling!
Declare.s Session_Start()                  ; start session. return OSSessionID$ for detection later
Declare Session_End(OSSessonID$)           ; end session
Declare AutoComplete_SetFocusCallback()    ; set up a callback that ends the autocomplete if the autocomplete window looses focus
Declare AutoComplete_AdjustWindowSize(MaxWidth, MaxHeight) ; allows to dynamically resize the autocomplete window
Declare ToolsPanel_ApplyColors(Gadget)                     ; change gadget colors & font. (for toolspanel gadgets), currently supports listview, listicon, explorertree, explorerlist
Declare IsScreenReaderActive()        ; attempt to detect running screen reader software

CompilerIf #CompileWindows
  Declare CreateSYSTEMMenu()           ; adds the Debugger menu to the window systemmenu
  Declare IsAdmin()
CompilerEndIf
CompilerIf #CompileMac
  Declare AutoComplete_SetupRawKeyHandler()
CompilerEndIf

; ===========================================
; Editor specific files
; ===========================================

;- RichEditHighlighting.pb
;- ScintillaHighlighting.pb
;
;Declare SendEditorMessage(Message, wParam, lParam)

; Little wrapper to enhance the code lisibility
Macro SendEditorMessage(Message, wParam=0, lParam=0)
  ScintillaSendMessage(*ActiveSource\EditorGadget, Message, wParam, lParam)
EndMacro

Declare CountCharacters(Gadget, startPos, endPos)  ; Fix for the #SCI_COUNTCHARACTERS message. Don't use that message directly because of the below newline trouble

Declare BuildIndentVT()
Declare UpdateIndent(FirstLine, LastLine)
Declare UpdateFolding(*Source.SourceFile, firstline, lastline) ; redo all folding (no rescan) from the given line to at least lastline
Declare CalculateHighlightingColors()                          ; calculate really used colors (call once after a prefs load/update)
Declare SetUpHighlightingColors()                              ; set up the colors for highlighting (called for each source when the prefs change, or when loading)
Declare HighlightArea(*StartPos, *EndPos)                      ; highlight a given area of text (0, -1) highlights all!
Declare UpdateHighlighting()                                   ; highlight everything after a prefs update
Declare StreamTextIn(*Buffer, Length)                          ; put the given buffer into the current source
Declare StreamTextOut(*Buffer, Length)                         ; get the contents of the current source into the buffer
Declare GetSourceLength()                                      ; get the source length in bytes
Declare ApplyWordChars(Gadget = #PB_All)                       ; update the word chars for a specific ScintillaGadget, or all sources if #PB_All
Declare RefreshEditorGadget()                                  ; redraw the editorgadget
Declare ChangeActiveLine(Line, TopOffset)                      ; change the currently active line
Declare SetBackgroundColor(Gadget = -1)                        ; set the bacground color fur this source (also for linenumbers)
Declare SetLineNumberColor()                                   ; set the line numbers (foreground) color for this source
Declare RemoveAllColoring()                                    ; remove all coloring stuff (also backgrounds... all should be black&white)
Declare SetSourceModified(Modified)                            ; change the modified state of the active source
Declare GetSourceModified(*Source.SourceFile = 0)              ; get the modified starte of the active source
Declare GetFirstVisibleLine()                                  ; return the number of the first visible line
Declare GetLinesCount(*Source.SourceFile)                      ; returns the number of lines in the current source
Declare GetCursorPosition()                                    ; update the CurrentRow, CurrentColumn fields in the *ActiveSource structure
Declare GetSelection(*LineStart.INTEGER, *RowStart.INTEGER, *LineEnd.INTEGER, *RowEnd.INTEGER) ; get the current selection (result is in PB chars, not UTF-8 bytes!)
Declare SetSelection(LineStart, RowStart, LineEnd, RowEnd)                                     ; set the current selection (column values are in PB chars, not UTF-8 bytes!)
Declare.s GetLine(Index, *Source.SourceFile = 0)                                               ; Return the line With the given index (0 based)
Declare HasLineContinuation(Index, *Source.SourceFile = 0)                                     ; Returns true if the given line (0 based) ends with a line continuation
Declare.s GetContinuationLine(Index, *Offset.INTEGER = 0, *Source.SourceFile = 0)              ; Return the line with given index (0 based) including any continued lines before or after)
Declare SetLine(Index, NewLine$)                                                               ; replace the indexed line with the given text (and highlight it again)
Declare CreateEditorGadget()                                                                   ; create the editing gadget for this source (must call ChangeActiveSource() right after creating the gadget!)
Declare SetReadOnly(Gadget, State)                                                             ; set the editing gadget to readonly
Declare InsertCodeString(String$, MoveCursor = #False)                                         ; insert given string at the current position (also converts to utf8 if needed)
Declare Undo()                                                                                 ; perform the standard editior function
Declare Redo()
Declare Cut()
Declare Copy()
Declare Paste()
Declare PasteAsComment()
Declare AdjustSelection(Mode)
Declare ZoomStep(Direction)
Declare ZoomDefault()
Declare SelectAll()
Declare AddMarker()                       ; handle the marker functionality
Declare ClearMarkers()
Declare MarkerJump()
Declare.s GetMarkerString()               ; get a list of all markers as a string
Declare ApplyMarkerString(Markers$)       ; apply a string of marker numbers to the file
Declare HideLineNumbers(*Source.SourceFile, Hide)   ; hide/show the linenumbers gadget
Declare AutoComplete_GetWordPosition(*X.INTEGER, *Y.INTEGER, *W.INTEGER, *H.INTEGER) ; get the position of the current word on the screen and size for the autocomplete window
Declare AutoComplete_SelectWord()                                                    ; select the current word to insert the autocomplete result
Declare FindText(Mode, Reverse = #False)                                             ; perform a search, 1=find, 2=replace, 3=replace all (other params are globals)
Declare SetFoldLevel(Line, Level)                                                    ; folding functions (scintilla only for now)
Declare SetFoldPoint(Line)
Declare IsFoldPoint(Line)
Declare SetFoldState(Line, State)
Declare GetFoldState(Line)
Declare ResizeEditorGadget(Gadget, X, Y, Width, Height) ; resize the editor gadget
Declare FreeEditorGadget(Gadget)                        ; free the editor gadget
Declare HideEditorGadget(Gadget, Hide)                  ; hide/show the editor gadget
Declare UpdateLineNumbers(*Source.SourceFile)           ; update the linenumbers completely (number of lines has changed)
Declare MarkCurrentLine(LineNumber)                     ; mark and show the linenumber as the current line for the debugger (current source) (-1 = remove mark)
Declare ClearCurrentLine(*Source.SourceFile)            ; clear any current line marks (in the given source)
Declare MarkErrorLine(LineNumber)                       ; mark the given line for an error (current source)
Declare MarkWarningLine(LineNumber)                     ; mark the given line for a warning (current source)
Declare ClearErrorLines(*Source.SourceFile)             ; clear all error/warning marks (in the given source)
Declare GetBreakPoint(*Source.SourceFile, LineNumber)   ; return the nearest BReakpoint on or after LineNumber. (returns -1 if no more found)
Declare MarkBreakPoint(LineNumber)                      ; set breakpoint mark
Declare ClearBreakPoint(LineNumber)                     ; remove a breakpoint mark
Declare ClearAllBreakPoints(*Source.SourceFile)         ; clears all breakpoint marks in this source
Declare UpdateBraceHighlight(Cursor, SecondTry=#False)  ; add/update brace highlighting with cursor at this position
Declare JumpToMatchingKeyword()                         ; jump to the matching keyword to the one on the cursor
Declare UpdateKeywordHighlight(selStart, SetHighlight)  ; highlight the matching keyword to the one at the cursor
Declare GetCommentPosition(Line$)                       ; get the char index of the comment in the given line (-1 if none)
Declare IsWhitespaceOnly(Line$)                         ; returns true if the line only contains whitespace (and maybe a comment)
Declare CountColumns(String$)
Declare UpdateSelectionRepeat(selStart=-1, selEnd=-1) ; highlight repeated occurrences of the current selection
Declare UpdateIsCodeStatus()                          ; The pb-file non-pb-file mode has changed

; Used by Templates/Macro Error window
; CompilerIf #CompileWindows | #CompileMac
;   DeclareDLL EmptyScintillaCallback(EditorWindow.l, EditorGadget.l, *scinotify.SCNotification, lParam.l)
; CompilerElse
;   DeclareCDLL EmptyScintillaCallback(EditorWindow.l, EditorGadget.l, *scinotify.SCNotification, lParam.l)
; CompilerEndIf

; ===========================================
; other files
; ===========================================

;- AboutWindow.pb
;
Declare OpenAboutWindow()               ; open window
Declare AboutWindowEvents(EventID)      ; handle window events
Declare UpdateAboutWindow()             ; update after prefs change

;- AddHElpFiles.pb
;
Declare AddHelpFiles_Init()             ; scan for available files (call before CreateGUI()!)
Declare AddHelpFiles_AddMenuEntries()   ; add help menu entries to the current menu (doesn't create submenu)
Declare AddHelpFiles_Display(MenuID)    ; display a help file by given menu id.

;- AddTools.pb
;
Declare AddTools_AddMenuEntries()       ; adds tools entries to the main menu
Declare AddTools_Execute(Trigger, *Target.CompileTarget) ; execute all assigned tools with the given trigger
Declare AddTools_Init()                                  ; init tools (call before CreateGUI!)
Declare UpdateEditToolsWindow()                          ; The open edit window function is only called from within the file
Declare AddTools_EditWindowEvents(EventID)
Declare AddTools_OpenWindow()
Declare UpdateAddToolsWindow()
Declare AddTools_WindowEvents(EventID)

;- AutoComplete.pb
;
Declare CreateAutoCompleteWindow()        ; create the autocomplete window (only called on startup)
Declare OpenAutoCompleteWindow()          ; display the autocomplete window
Declare AutoCompleteWindowEvents(EventID) ; handle autocomplete events
Declare AutoComplete_CheckAutoPopup()     ; checks if the conditions of auto-popup are met
Declare AutoComplete_WordUpdate(IsInitial=#False); while the autocomplete window is open, call that when the user continues typing
Declare AutoComplete_Close()                     ; abort autocomplete
Declare AutoComplete_Insert()                    ; confirm autocomplete
Declare AutoComplete_InsertEndKEyword()          ; insert "end" keyword on second keypress
Declare AutoComplete_ChangeSelectedItem(Direction)
Declare AutoComplete_InitContextConstants()

;- CodeViewer.pb
;
Declare UpdateCodeViewer(Gadget)                ; update preferences for code viewer
Declare SetCodeViewer(Gadget, *Buffer, Encoding); Put code into the viewer, must be null-terminated
Declare CreateCodeViewer(Gadget, x, y, width, height, LineNumbers)   ; create code viewer
Declare InitCodeViewer(Gadget, LineNumbers)                          ; init an existing gadget as code viewer

;- Commandline.pb
;
Declare CommandlineProjectBuild()
Declare ParseCommandline()

;- CompilerOptions.pb
;
Declare OpenOptionWindow(ForceProjectOptions, *InitialTarget.CompileTarget = 0) ; compiler options
Declare OptionWindowEvents(EventID)
Declare UpdateOptionWindow()
Declare ProjectTargetImage(*Target.CompileTarget)

CompilerIf #SpiderBasic
  
  ;- CreateApp.pb
  ;
  Declare OpenCreateAppWindow(*Target.CompileTarget, IsProject) ; compiler options
  Declare CreateAppWindowEvents(EventID)
  Declare UpdateCreateAppWindow()
CompilerEndIf


;- CompilerWarnings.pb
;
Declare WarningWindowEvents(EventID)
Declare UpdateWarningWindow()
Declare DisplayCompilerWarnings()       ; show the warning window
Declare HideCompilerWarnings()          ; hide warning window and clear warning list

;- CompilerWindow.pb
;
Declare GetActiveCompileTarget()        ; returns the currently active compile target structure
Declare FindTargetFromID(ID)            ; find a target by its unique ID
Declare SetCompileTargetDefaults(*Target.CompileTarget) ; set defaults for a new compiletarget
Declare CompilerReady()                                 ; called after compiler is loaded
Declare DisplayCompilerWindow()                         ; display 'compileing in progress'
Declare HideCompilerWindow()
Declare AddCompilerWindowItem(Text$)
Declare CompilerWindowEvents(EventID)
Declare BuildWindowEvents(EventID)
Declare UpdateBuildWindow()
Declare BuildLogEntry(Message$, InfoIndex = -1)
Declare CompileRun(CheckSyntax)         ; execute compile/run
Declare CreateExecutable()              ; execute create executable
Declare Run()                           ; run compiled source
Declare CompileRunProject(CheckSyntax)  ; project mode actions
Declare RunProject()
Declare CreateExecutableProject()
Declare BuildTarget(*Target.CompileTarget)
Declare BuildAll()



; ;- CPUMonitor.pb
; ;
; Declare OpenCPUMonitorWindow()
; Declare CPUMonitorWindowEvents(EventID)
; Declare UpdateCPUMonitorWindow()
; Declare RefreshCPUMonitor()             ; update the cpu monitor contents

;- Debugging.pb
CompilerIf #DEBUG
  Declare DebuggingWindowEvents(EventID)
  Declare OpenDebuggingWindow()
CompilerEndIf

;- DiffAlgorithm.pb
;
Declare Diff(*Ctx.DiffContext, *BufferA, SizeA, *BufferB, SizeB, Flags = 0)

;- DiffWindow.pb
;
Declare DiffWindowEvents(EventID)
Declare UpdateDiffWindow()
Declare DiffFileToFile(File1$, File2$, SwapOutput = #False, DirectoryMode = 0)
Declare DiffSourceToFile(*Source.SourceFile, Filename$, SwapOutput = #False)
Declare CheckDiffFileClose(*Source.SourceFile)
Declare DiffDirectories(Directory1$, Directory2$, Pattern$, SwapOutput = #False, DirectoryMode = 2)
Declare DiffDialogWindowEvents(EventID)
Declare OpenDiffDialogWindow()
Declare UpdateDiffDialogWindow()


;- DisplayMacroError.pb
;
Declare DisplayMacroError(MacroErrorLine, List MacroLines.s())
Declare MacroErrorWindowEvents(EventID)
Declare UpdateMacroErrorWindow()

;- Explorer.pb
;
Declare UpdateExplorerPatterns()        ; create an array with patterns for the explorer (from tools & explorer patterns)
Declare Explorer_FavoritesDropEvent()

;- FileViewer.pb
;
Declare OpenFileViewerWindow()
Declare FileViewer_OpenFile(Filename$)  ; load any given file in the fileviewer (if unknown, as hex, or with external tool)
Declare FileViewerWindowEvents(EventID)
Declare UpdateFileViewerWindow()
Declare IsBinaryFile(*Buffer, Length) ; returns true if the buffer contains nontext characters

;- FindWindow.pb
;
Declare OpenFindWindow(Replace = #False)
Declare UpdateFindWindow()
Declare FindWindowEvents(EventID)


;- FileSystem.pb
;
Declare.s UniqueFilename(File$)                     ; return a unique representation of the filename (by removing ../ for example and replacing / by \ on windows)
Declare   IsEqualFile(File1$, File2$)               ; returns true if the 2 filenames identify the same file
Declare.s CreateRelativePath(BasePath$, FileName$)  ; turn the full path FileName$ into a relative one to BasePath$
Declare.s ResolveRelativePath(BasePath$, FileName$) ; merge a base path and a relative path to a full path
Declare   CreateDirectoryRecursive(Directory$)      ; create a directory and its parent directories, recursively if necessary

;- GotoWindow.pb
;
Declare OpenGotoWindow()
Declare GotoWindowEvents(EventID)
Declare UpdateGotoWindow()

;- GrepWindow.pb
;
Declare UpdateFindComboBox(GadgetID)   ; after a search is done, add the text in the editgadget to the combobox (for grep and find)
Declare UpdateGrepOutputWindow()
Declare GrepOutputWindowEvents(EventID)
Declare OpenGrepWindow()
Declare UpdateGrepWindow()
Declare GrepWindowEvents(EventID)

;- HighlightingEngine.pb
;
Declare InitSyntaxCheckArrays()       ; create arrays like the ValidCharacters of TriggerCharacters
Declare InitSyntaxHighlighting()      ; initialize the highlighting
Declare BuildCustomKeywordTable()     ; build the needed HT etc from the CustomKeywordList() list and file
Declare HighlightingEngine(*InBuffer, InBufferLength, CursorPosition, *HighlightCallback, IsSourceCode, DisableFormatting = 0) ; call the engine
Declare IsBasicKeyword(Word$, *LineStart = 0, *WordStart = 0)

;- HighlightingFunctions.pb
;
Declare GetWordBoundary(*Buffer, BufferLength, Position, *StartIndex.INTEGER, *EndIndex.INTEGER, Mode)   ; Retrieve the boundary of a word
Declare.s GetWord(*Buffer, BufferLength, Position)                                                       ; extract the word at position from *Buffer
Declare.s GetModulePrefix(*Buffer, BufferLength, Position)                                               ; get module prefix from the given (Wordstart) position
Declare.s GetCurrentWord()                                                                               ; get the current word of the source file.
Declare.s GetCurrentLine()                                                                               ; return the text of the current line
Declare.s GetNumber(Line$, Position)                                                                     ; position is 0-based
Declare.s FindEnclosingFunction(Line$, Cursor, *StartPosition.INTEGER, *Parameter.INTEGER)               ; all arguments 0-based
Declare InsertComments()                                                                                 ; comment this block
Declare RemoveComments()                                                                                 ; uncomment this block
Declare InsertTab()                                                                                      ; tab intend a block
Declare RemoveTab()                                                                                      ; tab unintend a block
Declare AutoIndent()
Declare SelectBlock()
Declare DeselectBlock()
Declare ShiftComments(IsRight)
Declare CheckSearchStringComment(line, column, IsAutoComplete) ; returns if the line/column (both 0 based) is in comment/string and returns 1 if that complies with the search settings
Declare CheckStringComment(Cursor)                             ; returns 1 if the cursor position is inside a string or comment
Declare QuickHelpFromLine(line, cursorposition)
; Declare DisplayItemAtCursor(Position)
Declare.s CreateFoldingInformation()   ; creates a string representing the file's folding state
Declare ApplyFoldingInformation(Folding$) ; applies a string from CreateFoldingInformation() to the file

;- EditHistory.pb
;
Declare StartHistorySession()                   ; start session for history recording
Declare HistoryCompilerLoaded()                 ; tell history that the (default compiler) is loaded
Declare DetectCrashedHistorySession()           ; detect previously crashed session and open an info dialog if so
Declare HistoryShutdownEvents()                 ; write final close events for any open files on shutdown
Declare EndHistorySession()                     ; end history recording session
Declare HistoryEvent(*Source.SourceFile, Event) ; history event on source file
Declare HistoryTimer()
Declare OpenEditHistoryWindow(DisplaySID = -1)
Declare UpdateEditHistoryWindow()
Declare EditHistoryWindowEvent(EventID)
Declare.s History_MakeUniqueId()

;- IDEDebugger.pb
;
Declare FindDebuggerFromID(ID)            ; find the debugger with this unique id
Declare IsDebuggedFile(*Source.SourceFile); find out if the given source is included in any debugged program
Declare GetDebuggerForFile(*Source.SourceFile) ; get the debugger for this source, or for its project
Declare Debugger_UpdateWindowStates(*Debugger.DebuggerData) ; update the states of the debugger windows according to the program state
Declare Debugger_AddLog(*Debugger.DebuggerData, Message$, TimeStamp)  ; add a log message
Declare Debugger_Started(*Debugger.DebuggerData)                      ; called after the exe is loaded (disables sourcefiles and such)
Declare Debugger_Ended(*Debugger.DebuggerData)                        ; called after the exe is unloaded (reenables sourcefiles and such)
Declare UpdateErrorLogMenuState()                                     ; update menu state of the error log submenu
Declare SetDebuggerMenuStates()                                       ; update all debugger menus if debugger is enabled/disabled
Declare ProcessDebuggerEvent()                                        ; replacement for WaitWindowEvent, that respects the debugger thread and the CPU monitor updates
Declare Debugger_Run(*Debugger.DebuggerData = 0)                      ; execute the menu command (optionally specifying the debugger to do it on)
Declare Debugger_Stop(*Debugger.DebuggerData = 0)                     ; execute the menu command
Declare Debugger_Step(*Debugger.DebuggerData = 0)                     ; execute the menu command
Declare Debugger_StepX(*Debugger.DebuggerData = 0)                    ; execute the menu command
Declare Debugger_StepOver(*Debugger.DebuggerData = 0)                 ; execute the menu command
Declare Debugger_StepOver(*Debugger.DebuggerData = 0)                 ; execute the menu command
Declare Debugger_Kill(*Debugger.DebuggerData = 0)                     ; execute the menu command
Declare Debugger_BreakPoint(line)                                     ; set/remove breakpoint. (line is 0 based!)
Declare Debugger_ClearBreakPoints()
Declare Debugger_EvaluateAtCursor(position)           ; evaluate word/expression at position

;- IDEMisc.pb
;
Declare.s CheckPureBasicKeyWords(CurrentWord$) ; return the help path for a given PB keyword
Declare RegisterDeleteFile(FileName$)          ; register a file for deletion at IDE end
Declare DeleteRegisteredFiles()                ; delete registered files at end
Declare CompareDirectories(Directory1$, Directory2$)

;- Issues.pb
;
Declare InitIssueList()               ; init runtime data in issue list (like regexes)
Declare ClearIssueList()              ; clear runtime data in issue list (like regexes)
Declare ScanCommentIssues(Comment$, List Found.FoundIssue(), IsHighlight)
Declare UpdateIssueList()             ; called from UpdateProcedureList() too, so in most places there is no need to call this explicitly

;- Language.pb
;
Declare CollectLanguageInfo()         ; scan and check available language files
Declare LoadLanguage()                ; load the current set language (or english if impossible)
Declare.s Language(Group$, Name$)     ; return a string of the language set
Declare.s LanguagePattern(Group$, Name$, Pattern$, ReplacementString$) ; return a string of the language set, with a pattern replacement

;- Misc.pb
;
Declare EnsureWindowOnDesktop(Window)
Declare GetUniqueID()
Declare OptionalImageID(Image)
Declare FindMemoryString(*Buffer, Length, String$, Mode) ; searches for the String$ in the memory buffer and returns a pointer to it, or 0 if not found
Declare FindMemoryCharacter(*Buffer.Character, Length, Byte.c) ; find the byte in the memory block
Declare ParseString(String$)                                   ; parse a string into whitespace separated tokens
Declare.s GetStringToken(Index)                                ; return token from previously parsed string
Declare.s StrByteSize(Size.q)                                  ; get a nice looking filesize / memory size value (with KB, MB, GB attached)
Declare IsNumeric(Text$, *Output.INTEGER)                      ; check if a text is a valid number and return it if true
Declare.s RGBString(Color)                                     ; turns a color into a string "RGB(a,b,c)" as a platform independent color representation
Declare ColorFromRGBString(String$)                            ; turns the result of RGBString() back into a color
Declare.s ModulePrefix(Name$, ModuleName$)                     ; prefix a module name (if not empty)
Declare StringToCodePage(CodePage, String$)                    ; transform string to Scintilla compatible code page (must be freed!)
Declare CodePageLength(CodePage, String$)                      ; get length of string in Scintilla compatible code page

;- Preferences.pb
;
Declare LoadPreferences()             ; load the preferences file
Declare SavePreferences()             ; save the prefs to file
Declare ApplyPreferences()            ; apply prefs changes to the editor and all open windows
Declare OpenPreferencesWindow()
Declare UpdatePreferenceWindow()
Declare PreferencesWindowEvents(EventID)
Declare UpdatePreferenceSyntaxColor(ColorIndex, Color)
Declare UpdateImageColorGadget(Gadget, Image, Color)

;- ProcedureBrowser.pb
;
Declare UpdateProcedureList(ScrollPosition.l = -1) ; scan active source and update the procedure list and the autocomplete lists
                              ;Declare ProcedureList_LineUpdate()    ; check if the current line is in the procedure list and update if necessary.
Declare JumpToProcedure()     ; jump to procedure under cursor (for double-click)

;- WebView.pb
;
Declare SetWebViewUrl(Url$)
Declare OpenSpiderWebBrowser(Url$)

;- ProjectManagement.pb
;
Declare AddProjectDefaultMenuEntries()
Declare AddProjectBuildMenuEntries()
Declare IsProjectFile(FileName$)
Declare.s ProjectName(FileName$) ; Get the project name from a project file
Declare UpdateProjectFile(*File.ProjectFile)
Declare ClearProjectFile(*File.ProjectFile)
Declare LinkSourceToProject(*Source.SourceFile, *File.ProjectFile = 0)
Declare UnlinkSourceFromProject(*Source.SourceFile, RescanFile)
Declare SetProjectDefaultTarget()
Declare UpdateProjectInfo()
Declare UpdateProjectInfoPreferences()
Declare ResizeProjectInfo(Width, Height)
Declare LoadProject(Filename$)
Declare SaveProject(ShowErrors)
Declare OpenProject()
Declare CloseProject(IsIDEShutdown = #False)
Declare AddProjectFile()
Declare RemoveProjectFile()
Declare ProjectOptionsEvents(EventID)
Declare OpenProjectOptions(NewProject)
Declare UpdateProjectOptionsWindow()
Declare IsCodeFile(FileName$)         ; returns true for PB and SB files
Declare IsPureBasicFile(FileName$)    ; returns true only for PB files (in PB mode) or SB files (in SB mode), but also for the respective project files

;- ProjectPanel.pb
;
Declare StoreProjectPanelStates()
Declare UpdateProjectPanel()
Declare DisplayProjectPanelMenu(*Entry.ToolsPanelEntry, SourceGadget)
Declare ProjectPanelMenuEvent(MenuItemID)

;- PureBasic.pb

Declare CloseSplashScreen()

Procedure MessageRequesterSafe(Title$, Text$, Flags=0)
  CloseSplashScreen()
  ProcedureReturn MessageRequester(Title$, Text$, Flags)
EndProcedure

Macro MessageRequester
  MessageRequesterSafe
EndMacro

Declare ShutdownIDE() ; perform all code for an orderly shutdown.

;- RadixTree.pb
;
Declare RadixFree(*Tree.RadixTree)                                              ; Free all tree nodes
Declare RadixFindPrefix(*Tree.RadixTree, Prefix$, ExactMatchOnly = #False)      ; Lookup RadixNode by prefix. Returns RadixNode, not node value!
Declare RadixLookupValue(*Tree.RadixTree, Name$)                                ; Lookup stored value by exact name match (case insensitive)
Declare RadixFindRange(*Tree.RadixTree, Prefix$, *First.INTEGER, *Last.INTEGER) ; Lookup first and last value matching the given prefix. Returns true/false if any match is found
Declare RadixEnumerateAll(*Tree.RadixTree, List *Values())                      ; Enumerate all stored values (sorted alphabetically). Clears the list
Declare RadixEnumeratePrefix(*Tree.RadixTree, Name$, List *Values())            ; Enumerate all stored values with given prefix (sorted alphabetically). Clears the list
Declare RadixInsert(*Tree.RadixTree, Name$, *Value)                             ; Insert a value into the tree

;- RecentFiles.pb
;
Declare RecentFiles_AddMenuEntries(IsProject)  ; add entries to the recentfiles menu (doesn't create submenu)
Declare RecentFiles_AddFile(FileName$, IsProject); add new file to the recentfile list
Declare RecentFiles_Open(MenuItemID)             ; open file by given menuid

;- ShortcutManagement.pb
;
Declare BuildShortcutNamesTable()     ; build the shortcut table from the current language
Declare CreateKeyboardShortcuts(Window)     ; set/update all keyboard shortcuts in the given window
Declare.s GetShortcutText(Shortcut)         ; get the text for any shortcut
Declare ShortcutMenuItem(MenuItemID, Text$) ; create a menuitem with or without the shortcut name (when one is set)
Declare FillShortcutList()                  ; fill the combobox with all shortcut names
Declare.s GetShortcutOwner(Shortcut)        ; get the name where a shortcut is assigned to
Declare IsShortcutUsed(Shortcut, CurrentPrefsItem, *CurrentAddTool) ; check if a given shortcut is already used
Declare.s ShortcutToIndependentName(Shortcut)                       ; translate shortcut into a OS independent name
Declare IndependentNameToShortcut(Name$)                            ; trandlate os independent name back to shortcut
CompilerIf #CompileMac
  Declare SetupMacPrefsShortcutCallback()
CompilerEndIf

;- SourceManagement.pb
;
Declare UpdateCursorPosition()        ; update the currentline / column values
Declare RefreshSourceTitle(*Source.SourceFile) ; refresh the tab title for the given source
Declare.s GetSourceTitle(*Source.SourceFile)   ; get the title text for the given source
Declare UpdateSourceStatus(Modified)           ; set the source to modified/unmodified
Declare ChangeActiveSourcecode(*OldSource.SourceFile = 0) ; change the active source to the current item in SourceFile()
Declare NewSource(FileName$, ExecuteTool)                 ; create a new source (with optional name to load a file in)
Declare SaveProjectSettings(*Target.CompileTarget, IsCodeFile, IsTempFile, ReportErrors) ; save the settings of *ActiveSource (a file must be open in write mode!)
Declare AnalyzeProjectSettings(*Source.SourceFile, *Buffer, Length, IsTempFile)          ; fill the *Source structure with the project settings from *Buffer. (return new project length)
Declare LoadSourceFile(FileName$, Activate = 1, AddToRecentFiles = 1)                    ; load the given file into a new source (if not already open)
Declare SaveSourceFile(FileName$)                                                        ; save the current source to the given name
Declare LoadTempFile(FileName$)                                                          ; load the specified file over the current opened source
Declare SaveTempFile(FileName$)                                                          ; save the current source to a temp name (no change of modified/unmodified by this!)
Declare LoadSource()                                                                     ; open the 'load source' dialog and load any chosen files
Declare OpenIncludeOnDoubleClick()                                                       ; after double-click on Includefile, open that file
Declare SaveSourceAs()                                                                   ; open the save as dialog and save any files
Declare SaveSource()                                                                     ; save the current source (if new, open SaveSourceAs())
Declare RemoveSource(*Source.SourceFile = 0)                                             ; close the current source (no saving done here, do it separately!)
Declare CheckSourceSaved(*Source.SourceFile = 0)                                         ; check if the current source is saved or modified
Declare SaveAll()                                                                        ; saves all sources
Declare CheckAllSourcesSaved()                                                           ; this function is called when exiting the editor. saves all sources and closes them
Declare ChangeTextEncoding(*Source.SourceFile, NewEncoding)                              ; Change the encoding of the source to the new format
Declare AutoSave()                                                                       ; called before compiling / creating executable to do the autosave
Declare ReloadSource()                                                                   ; reload the active source from disk
Declare SetupFileMonitor()                                                               ; setup or change file monitor settings
Declare FileMonitorEvent()                                                               ; check all open files for changes
Declare FileMonitorWindowEvents(EventID)                                                 ; the monitor requester is a PB window

;- SourceParser.pb
;
Declare BuildFoldingVT()                        ; the procedurebrowser also manages folding.
Declare FreeSourceItemArray(*Parser.ParserData) ; free the SourceItem Array and all contained items
Declare FullSourceScan(*Source.SourceFile)      ; rescan entire source
Declare PartialSourceScan(*Source.SourceFile, StartLine, EndLine)  ; rescan some lines (returns true if line(s) changed)
Declare ScanLine(*Source.SourceFile, Line)                         ; scan single line ( + continuations) returns true if line(s) changed
Declare ScanFile(FileName$, *Parser.ParserData)                    ; scan a file from disk (for project management)
Declare SortParserData(*Parser.ParserData, *Source.SourceFile=0)   ; update the sorted parser data
Declare SourceLineCorrection(*Source.SourceFile, Line, LinesAdded) ; adjust line offset in scanned tree
Declare LocateSourceItem(*Parser.ParserData, Line, Position)       ; Return the SourceItem pointer for the item at the given location (if any)
Declare ClosestSourceItem(*Parser.ParserData, *Line.INTEGER, Position) ; Return the closest SourceItem to the given position if  (searching backward)
Declare FindProcedureStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER) ; Find the item that starts the current procedure (if any)
Declare ItemInsideProcedure(*Parser.ParserData, Line, *Item.SourceItem)       ; returns true if the given item is inside a procedure
Declare MatchKeywordBackward(*Parser.ParserData, *pLine.INTEGER, *pItem.INTEGER)      ; locate a matching keyword in the parser data
Declare MatchKeywordForward(*Parser.ParserData, *pLine.INTEGER, *pItem.INTEGER)
Declare FindLoopStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER)
Declare FindBreakKeywords(*Parser.ParserData, *Item.SourceItem, Line, List Items.SourceItemPair())
Declare FindModuleStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER, List OpenModules.s())
Declare FindBlockStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER, IncludeSelf)
Declare.s ResolveStructureType(*Parser.ParserData, *Item.SourceItem, Line, Type$)
Declare.s ResolveItemType(*InputItem.SourceItem, InputLine, *OutType.INTEGER)
Declare LocateStructureBaseItem(Line$, Position, *pItem.INTEGER, *pLine.INTEGER, List StructureStack.s())
Declare IsLineContinuation(*Buffer, *Pointer.PTR) ; returns true if *Pointer is the end of a line with continuation
Declare IsContinuedLineStart(Line$)               ; returns true if Line$ is the beginning of a line with line continuation at the end
Declare.s Parser_Cleanup(Input$)                  ; cleanup a prototype string (remove newlines, line continutaions and extra whitespace)
Declare CharsToBytes(Line$, Start, Encoding, Chars)   ; Convert a char offset (0-based) to a byte offset in the specified encoding
Declare BytesToChars(Line$, Start, Encoding, Bytes)   ; Convert a byte offset (0-based) to a char offset in the specified encoding

;- StandaloneDebuggerControl.pb
;
Declare ExecuteStandaloneDebugger(*Target.CompileTarget, DebuggerCMD$, Executable$, Directory$, Parameters$ = "") ; executes the external debugger (with watchlist and all)
Declare StandaloneDebuggers_CheckExits()                                                                          ; checks if a standalone debugger has quit and updates the watchlist
Declare StandaloneDebuggers_IsRunning()                                                                           ; returns true if at least one debugger is still running (so StandaloneDebuggers_CheckExits() needs to be called)

;- Templates.pb
;
Declare OpenTemplateWindow()
Declare TemplateWindowEvents(EventID)
Declare UpdateTemplateWindow()
Declare Template_DropEvent()          ; #PB_Event_GadgetDrop happened...

;- StructureFunctions.pb
;
Declare ParseStructure(*Buffer, Length, List Output.s())           ; parse structure content
Declare ParseInterface(*Buffer, Length, List Output.s())           ; parse interface content
Declare FindStructureInterface(Name$, Type, List Output.s(), Recursion)
Declare FindStructure(Name$, List Output.s())                      ; find Structure
Declare FindInterface(Name$, List Output.s())                      ; find interface
Declare FindPrototype(Name$)                                       ; Returns the SourceItem of the prototype declaration (or 0)
Declare.s StructureFieldKind(Entry$)
Declare.s StructureFieldName(Entry$)
Declare.s StructureFieldType(Entry$)
Declare.s InterfaceFieldName(Entry$)

;- StructureViewer.pb
;
Declare InitStructureViewer()         ; initialize the viewer arrays
Declare DisplayStructureRootList()    ; display the root list in the viewer
Declare OpenStructureViewerWindow()
Declare UpdateStructureViewerWindow()
Declare StructureViewerWindowEvents(EventID)

;- ThemeManagement.pb
;
Declare CreatePrefsThemeList()
Declare FreePrefsThemeList()
Declare PrefsThemeChanged()
Declare ApplyPrefsTheme()
Declare LoadTheme()


;- ToolbarManagement.pb
;
Declare InitToolbar()                 ; initialize the toolbar data on startup (must be before loadpreferences!)
Declare.s ConvertToolbarIconName(OldName$) ; convert old (pre 4.40) internal icon names to new naming
                                           ;Declare ApplyMenuIcons()             ; add the buildin icons to the ide menu (called on windows only)
Declare ToolbarMenuImage(MenuItem)         ; get the ImageID of a toolbar image for the menu
Declare CreateIDEToolBar()                 ; create the main toolbar
Declare FreeIDEToolbar()                   ; free the main toolbar and all loaded images (call this before changing the toolbar settings)
Declare UpdatePrefsToolbarItem(FirstCall=#False); update the list of items in the toolbar prefs
Declare UpdatePrefsToolbarList()                ; enable/disable the correct gadgets for the toolbar item prefs

;- ToolsPanel.pb
Declare ActivateTool(Name$)           ; used when a toolspanel tool (build in ones) is selected from the menu. (either selects the right tab or opens it in separate window)
Declare ToolsPanel_Create(IsUpdate)   ; create the initial Panel
Declare ToolsPanel_Update()           ; toolspanel update after prefs change
Declare ToolsPanel_CheckAutoHide()    ; update the autohide state of the toolspanel
Declare ToolsPanel_Hide()
Declare ToolsPanel_Show()

;- UpdateCheck.pb
Declare UpdateWindowEvents(EventID)
Declare UpdateCheckTimer()            ; timer for update check fired
Declare CheckForUpdatesManual()       ; perform an update check now (for the menu item)
Declare CheckForUpdatesSchedule()     ; perform an update check if the configured interval has elapsed

;- UserInterface.pb
;
Declare StartupCheckScreenReader()    ; Check for screen reader on first IDE start and ask to set accessibility mode
Declare CreateIDEMenu()               ; (re)create the main menu
Declare CreateIDEPopupMenu()          ; (re)create the popup menu
Declare CreateGUI()                   ; create the main window gui
Declare ActivateMainWindow()          ; set focus to the main window+editorgadget
Declare UpdateMenuStates()            ; Update menu item states after a source switch (except debugger/error log)
Declare UpdateMainWindowTitle()       ; update main window title
Declare ChangeStatus(Message$, StickyTime); set a new message to the statusbar
Declare MainMenuEvent(MenuItemID)         ; handle (or simulate) a main window menu event
Declare MainWindowEvents(EventID)         ; handle main window events
Declare ResizeMainWindow()                ; resize all main window components
Declare UpdateMainWindow()                ; update the main window after prefs update (updating the edit gadgets is done from ApplyPreferences())
Declare EventLoopCallback()               ; A callback to be called between (Wait)WindowEvent() calls
Declare DispatchEvent(EventID)            ; Main event processor... dispatches the event to the correct window procedure
Declare FlushEvents()                     ; remove all events from the queue
Declare ErrorLog_Refresh()                ; refresh the error log content
Declare ErrorLog_Show()                   ; show the error log
Declare ErrorLog_Hide()                   ; hide the error log
Declare ErrorLog_SyncState(DoResize = #True) ; sync the logs display state to the current source
Declare DisableMenuAndToolbarItem(MenuItemID, State)


;- VariableViewer.pb
;
Declare UpdateVariableViewer()        ; After the source has been scanned, call this to update the list.

;- Debugging.pb
CompilerIf #DEBUG
  Declare DebuggingWindowEvents(EventID)
  Declare OpenDebuggingWindow()
CompilerEndIf

;- ZipManagement.pb
Declare ScanZip(*Buffer, Size, List Files.ZipEntry())
Declare ExtractZip(*Entry.ZipEntry)
