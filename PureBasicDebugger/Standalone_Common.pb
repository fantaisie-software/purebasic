; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; GUI constants

#WINDOW_Main = 1
#WINDOW_Preferences = 2

#STATUSBAR = 0


Enumeration 1
  #GADGET_Run
  #GADGET_Stop
  #GADGET_Step
  #GADGET_StepCount
  #GADGET_StepOver
  #GADGET_StepOut
  #GADGET_Quit
  #GADGET_Log
  
  #GADGET_Debug
  #GADGET_Watchlist
  #GADGET_Variables
  #GADGET_Profiler
  #GADGET_History
  #GADGET_Memory
  #GADGET_Assembly
  #GADGET_Library
  #GADGET_Purifier
  
  #GADGET_Waiting
  
  #GADGET_BreakSet
  #GADGET_BreakClear
  #GADGET_DataBreak
  #GADGET_SelectSource
  
  #GADGET_Minimize
  #GADGET_Maximize
EndEnumeration

Enumeration #DEBUGGER_MENU_LAST ; add after the debuggers own shortcuts
  #MENU_Stop
  #MENU_Run
  #MENU_Step
  #MENU_StepOver
  #MENU_StepOut
EndEnumeration

Enumeration
  #IMAGE_LinuxWindowIcon
EndEnumeration

; Constants for SourceLineAction()
;
Enumeration
  #ACTION_MarkCurrentLine
  #ACTION_MarkError
  #ACTION_MarkWarning
EndEnumeration

; Queued Actions for SourceLineAction() if sources are not received
; from the exe yet
;
Structure DelayedAction
  FileIndex.l
  Line.l
  Action.l
EndStructure

Global NewList DelayedActions.DelayedAction()

; representing the displeyed source files
;
Structure DisplayedSource
  FileName$
  IsLoaded.l
  IsRequested.l ; network mode
  Gadget.i      ; #PB_Any
EndStructure

Global NbSourceFiles, CurrentSource

; the index array is the same number as used in the LineNumbers values
Global Dim SourceFiles.DisplayedSource(1)  ; will be redimed when executing the exe

Global PreferenceFile$
Global StatusbarHeight
Global MainFileName$
Global Standalone_Quit ; quit flag for the main loop

Global NewList Watchlist.s()
Global NewList BreakpointStrings.s() ; breakpoints as they come from the options file
Global NewList Breakpoints.l()

; As the GUI debugger can have only one debugged file, the LinkedList RunningDebuggers()
; will of course have only one entry. this is a direct access to that to ease things up
; It cannot be named *Debugger, as that is locally used in the shared debugger functions
;
Global *DebuggerData.DebuggerData

; preferences, additional to the ones declared in DebuggerCommon.pb
Global CurrentLanguage$
Global EnableKeywordBolding, TabLength, WarningMode

Global ASMKeywordColor, BackgroundColor, BasicKeywordColor, CommentColor
Global ConstantColor, LabelColor, NormalTextColor, NumberColor, OperatorColor
Global PointerColor, PureKeywordColor, SeparatorColor, StringColor, StructureColor
Global LineNumberColor, LineNumberBackColor, CurrentLineColor, CursorColor
Global SelectionColor, SelectionFrontColor, CustomKeywordColor, DisplayFullPath
Global WhitespaceColor, ModuleColor, BadBraceColor

Global DebuggerWarningColor, DebuggerWarningSymbolColor
Global DebuggerLineColor, DebuggerErrorColor, DebuggerBreakPointColor
Global DebuggerLineSymbolColor, DebuggerErrorSymbolColor, DebuggerBreakpointSymbolColor
Global DebugOutUseFont, DebugOutFont$, DebugOutFontSize, DebugOutFontStyle, DebugOutFontID

Global EditorFontName$, EditorFontSize, EditorFontStyle, EditorBoldFontName$
Global Shortcut_Run, Shortcut_Stop, Shortcut_Step, Shortcut_StepOut, Shortcut_StepOver ; shortcuts as defined by the ide
Global LanguageFile$, CustomKeywordFile$
Global ShowWhitespace, ShowIndentGuides


Global IsMouseDwelling, MouseDwellPosition, IsVariableExpression
Global Standalone_Quit
Global PurifierSettings$

Global NewList CustomKeywordList.s()


; this is required for Language.pb of the ide
Procedure BuildShortcutNamesTable()
EndProcedure
