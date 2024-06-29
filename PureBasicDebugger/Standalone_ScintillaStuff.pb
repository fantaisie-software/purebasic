; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


CompilerIf #CompileWindows | #CompileLinux | #CompileMac
  
  ; Retrieve the boundary of a word (start index and end index from a buffer, given the
  ; position in the buffer)
  ;
  ; NOTE: When modifying this function, be sure to report to the IDE
  ;
  Procedure GetWordBoundary(*Buffer, BufferLength, Position, *StartIndex.INTEGER, *EndIndex.INTEGER, Mode)
    *WordStart.Character = *Buffer
    *WordEnd.Character   = *Buffer + BufferLength
    
    If Position >= 0 And Position < BufferLength+#CharSize And (Mode = 1 Or Position < BufferLength)
      *Cursor.Character = *Buffer + Position*#CharSize
      
      If Mode = 1 ; Needed for Auto-complete
        *Cursor-#CharSize
      ElseIf ValidCharacters(*Cursor\c) = 0 ; Needed, so F1 help works nicely
        *Cursor-#CharSize
      EndIf
      
      While *Cursor >= *Buffer
        If ValidCharacters(*Cursor\c) = 0 And (Mode = 0 Or (*Cursor\c <> '#' And *Cursor\c <> '*'))
          *WordStart = *Cursor + #CharSize
          Break
        EndIf
        *Cursor - #CharSize
        Found = 1
      Wend
      
      *Cursor.Character = *Buffer + Position*#CharSize
      While *Cursor\c
        If ValidCharacters(*Cursor\c) = 0 And *Cursor\c <> '$'
          *WordEnd = *Cursor - #CharSize
          Break
        EndIf
        *Cursor + #CharSize
        Found = 1
      Wend
      
      ; Special case: "var1*var2" is detected as one word! (also handle 1*2*3*4*word correctly)
      If Found
        Repeat
          *Cursor = FindMemoryCharacter(*WordStart+#CharSize, *WordEnd-*WordStart-1, '*')
          If *Cursor
            If *Cursor <= *Buffer + Position*#CharSize ; the cursor is on the second word
              *WordStart = *Cursor+#CharSize
            ElseIf *Cursor < *WordEnd ; cursor on the first word
              *WordEnd = *Cursor
            EndIf
          EndIf
        Until *Cursor = 0
        
        ; Another special case: *#CONSTANT (https://www.purebasic.fr/english/viewtopic.php?f=4&t=40104)
        *NextCharacter.Character = *WordStart+#CharSize
        If *WordStart\c = '*' And *NextCharacter\c = '#'
          *WordStart+1
        EndIf
      EndIf
    EndIf
    
    CompilerIf #PB_Compiler_Unicode
      *StartIndex\i = (*WordStart - *Buffer)/#CharSize
      *EndIndex\i   = (*WordEnd   - *Buffer)/#CharSize
    CompilerElse
      *StartIndex\i = *WordStart - *Buffer
      *EndIndex\i   = *WordEnd   - *Buffer
    CompilerEndIf
    
    ProcedureReturn Found
  EndProcedure
  
  
  Procedure.s GetLine(EditorGadget, Index)
    
    range.TextRange\chrg\cpMin = ScintillaSendMessage(EditorGadget, #SCI_POSITIONFROMLINE, Index, 0)
    range\chrg\cpMax           = ScintillaSendMessage(EditorGadget, #SCI_GETLINEENDPOSITION, Index, 0)
    
    If range\chrg\cpMax > range\chrg\cpMin
      range\lpstrText            = AllocateMemory(range\chrg\cpMax-range\chrg\cpMin+1)
      
      If range\lpstrText
        length = ScintillaSendMessage(EditorGadget, #SCI_GETTEXTRANGE, 0, @range)
        Line$ = PeekS(range\lpstrText, length, #PB_Ascii) ; load the maybe utf8 as ascii too, as that is what the positions mean
        FreeMemory(range\lpstrText)
      EndIf
    EndIf
    
    ProcedureReturn Line$
  EndProcedure
  
  
  
  Procedure HighlightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
    Shared HighlightGadget
    ScintillaSendMessage(HighlightGadget, #SCI_SETSTYLING, Length, *Color)
  EndProcedure
  
  ; CompilerIf #CompileWindows | #CompileMac; this function must be stdcall on windows and cdecl on linux (on mac, it MUST be ProcedureDLL for the callback to work!)
  ProcedureDLL ScintillaCallBack(EditorGadget, *scinotify.SCNotification)  ;}
                                                                           ; CompilerElse
                                                                           ;   ProcedureCDLL ScintillaCallBack(EditorWindow.l, EditorGadget.l, *scinotify.SCNotification, lParam.l)
                                                                           ; CompilerEndIf
    
    Shared HighlightGadget
    
    Select *scinotify\nmhdr\code
        
      Case #SCN_STYLENEEDED
        range.TextRange\chrg\cpMin  = ScintillaSendMessage(EditorGadget, #SCI_GETENDSTYLED, 0, 0)
        lineNumber                  = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, range\chrg\cpMin, 0)
        range\chrg\cpMin            = ScintillaSendMessage(EditorGadget, #SCI_POSITIONFROMLINE, lineNumber, 0)
        range\chrg\cpMax            = *scinotify\position
        
        ;       ScintillaSendMessage(EditorGadget, #SCI_STARTSTYLING, range\chrg\cpMin, $FFFFFF)
        ;       ScintillaSendMessage(EditorGadget, #SCI_SETSTYLING, range\chrg\cpMax - range\chrg\cpMin, 1) ; always use text color for now
        *Buffer = AllocateMemory(range\chrg\cpMax - range\chrg\cpMin + 1)
        If *Buffer
          range\lpstrText = *Buffer
          reallength = ScintillaSendMessage(EditorGadget, #SCI_GETTEXTRANGE, 0, @range)
          HighlightGadget = EditorGadget
          
          ScintillaSendMessage(EditorGadget, #SCI_STARTSTYLING, range\chrg\cpMin, $FFFFFF)
          HighlightingEngine(*Buffer, reallength, -1, @HighlightCallback(), 0)
          FreeMemory(*Buffer)
        EndIf
        
      Case #SCN_DWELLSTART
        ; warning: scintilla also fires this event when we dwell outside of the
        ;   window with the mouse, *scinotify\position is -1 in this case, so
        ;   filter it. (also filters cases where we are not near any character)
        ;
        If *scinotify\position <> -1
          
          IsMouseDwelling    = 1 ; to know if the mouse still dwells when the result is received
          MouseDwellPosition = *scinotify\position
          
          Expr$ = ""
          
          ; if the mouse is over a selection, evaluate the
          ; entire selection
          ;
          selStart = ScintillaSendMessage(EditorGadget, #SCI_GETSELECTIONSTART, 0, 0)
          selEnd = ScintillaSendMessage(EditorGadget, #SCI_GETSELECTIONEND  , 0, 0)
          If selStart > selEnd
            Swap selStart, selEnd
          EndIf
          
          If selStart <= *scinotify\position And selStart <> selEnd And *scinotify\position <= selEnd
            ; multiline is now allowed, as there could be a line continuation
            Expr$ = Space(selEnd - selStart)
            range.TextRange\chrg\cpMin  = selStart
            range\chrg\cpMax            = selEnd
            range\lpstrText             = @Expr$
            ScintillaSendMessage(EditorGadget, #SCI_GETTEXTRANGE, 0, @range)
            
            If ScintillaSendMessage(EditorGadget, #SCI_GETCODEPAGE) = #SC_CP_UTF8
              Expr$ = PeekS(@Expr$, -1, #PB_UTF8)
            Else
              Expr$ = PeekS(@Expr$, -1, #PB_Ascii)
            EndIf
            
            Expr$ = Trim(Expr$)
            IsVariableExpression = 0
          EndIf
          
          ; try the current word now if the selection is not ok
          ;
          If Expr$ = ""
            line      = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, *scinotify\position, 0)
            linestart = ScintillaSendMessage(EditorGadget, #SCI_POSITIONFROMLINE, line, 0)
            Line$     = GetLine(EditorGadget, line)
            
            If Line$ <> "" And GetWordBoundary(@Line$, Len(Line$), *scinotify\position - linestart, @selStart, @selEnd, 1) ; include * or #
              If Mid(Line$, selEnd+2, 2) = "()"
                selEnd + 2
              EndIf
              If Mid(Line$, selEnd+2, 2) = "()"
                selEnd + 2
              EndIf
              If Mid(Line$, selStart, 1) = "$" Or Mid(Line$, selStart, 1) = "%"
                selStart-1
              EndIf
              
              Expr$ = Mid(Line$, selStart+1, selEnd - selStart + 1)
              IsVariableExpression = 1
            EndIf
          EndIf
          
          ; Evaluate if there is a debugger...
          ; Use the context of the selected line (not the currently executed one)
          ;
          If Expr$ <> ""
            Command.CommandInfo\Command = #COMMAND_EvaluateExpressionWithStruct ; structures allowed
            Command\Value1 = AsciiConst('S','C','I','N')                        ; to identify the sender
            Command\Value2 = MakeDebuggerLine(CurrentSource, ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, *scinotify\position, 0))
            Command\DataSize = (Len(Expr$)+1) * SizeOf(Character)
            SendDebuggerCommandWithData(*DebuggerData, @Command, @Expr$)
          EndIf
          
        EndIf
        
      Case #SCN_DWELLEND
        IsMouseDwelling = 0
        ScintillaSendMessage(EditorGadget, #SCI_CALLTIPCANCEL)
        
    EndSelect
    
  EndProcedure
  
  ; creates a new editorgadget and loads the given buffer into it
  ; returns GadgetId
  Procedure LoadSourceBuffer(*Buffer, Length, Format)
    Result = 0
    UseGadgetList(WindowID(#WINDOW_Main))
    
    Result = ScintillaGadget(#PB_Any, 0, 0, 0, 0, @ScintillaCallBack())
    If Result
      
      If Format = #PB_UTF8
        ScintillaSendMessage(Result, #SCI_SETCODEPAGE, #SC_CP_UTF8, 0)
      Else
        ScintillaSendMessage(Result, #SCI_SETCODEPAGE, 0, 0)
      EndIf
      
      ScintillaSendMessage(Result, #SCI_SETTABWIDTH, TabLength, 0)
      
      ; load the text
      ; use #SCI_APPENDTEXT so we do not need a 0 terminateion
      ScintillaSendMessage(Result, #SCI_APPENDTEXT, Length, *Buffer)
      
      Font$ = EditorFontName$
      BoldFont$ = EditorBoldFontName$
      
      ; Gtk2 'Pango' need an "!" before the font name (else it will use GDK font)
      ;
      CompilerIf #CompileLinuxGtk
        Font$ = "!" + Font$
        BoldFont$ = "!" + BoldFont$
      CompilerEndIf
      
      ScintillaSendMessage(Result, #SCI_STYLESETFONT, #STYLE_DEFAULT, ToAscii(Font$))
      ScintillaSendMessage(Result, #SCI_STYLESETSIZE, #STYLE_DEFAULT, EditorFontSize)
      
      If EditorFontStyle & #PB_Font_Bold
        ScintillaSendMessage(Result, #SCI_STYLESETBOLD, #STYLE_DEFAULT, 1)
      EndIf
      If EditorFontStyle & #PB_Font_Italic
        ScintillaSendMessage(Result, #SCI_STYLESETITALIC, #STYLE_DEFAULT, 1)
      EndIf
      
      ScintillaSendMessage(Result, #SCI_STYLESETBACK, #STYLE_DEFAULT, BackgroundColor)
      
      ; make all the #STYLE_DEFAULT changes effective on the other styles
      ScintillaSendMessage(Result, #SCI_STYLECLEARALL, 0, 0)
      
      If EnableKeywordBolding
        ScintillaSendMessage(Result, #SCI_STYLESETFONT, 2, ToAscii(BoldFont$))
        ScintillaSendMessage(Result, #SCI_STYLESETSIZE, 2, EditorFontSize)
        ScintillaSendMessage(Result, #SCI_STYLESETBOLD,  2, 1)             ; Bold (no effect on linux, but maybe on windows later)
        ScintillaSendMessage(Result, #SCI_STYLESETFONT, 14, ToAscii(BoldFont$))
        ScintillaSendMessage(Result, #SCI_STYLESETSIZE, 14, EditorFontSize)
        ScintillaSendMessage(Result, #SCI_STYLESETBOLD,  14, 1)
        If EditorFontStyle & #PB_Font_Italic
          ScintillaSendMessage(Result, #SCI_STYLESETITALIC, 2, 1)
          ScintillaSendMessage(Result, #SCI_STYLESETITALIC, 14, 1)
        EndIf
      EndIf
      
      ScintillaSendMessage(Result, #SCI_SETREADONLY, 1, 0)
      ScintillaSendMessage(Result, #SCI_SETCARETLINEVISIBLE, 1, 0) ; enable the different color for the current line
      
      ScintillaSendMessage(Result, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
      ScintillaSendMessage(Result, #SCI_SETMARGINTYPEN, 1, #SC_MARGIN_SYMBOL)
      
      ScintillaSendMessage(Result, #SCI_SETMARGINMASKN, 1, -1)
      
      Lines$ = "_" + RSet("", Len(Str(ScintillaSendMessage(Result, #SCI_GETLINECOUNT, 0, 0))), "9")
      ScintillaSendMessage(Result, #SCI_SETMARGINWIDTHN, 0, ScintillaSendMessage(Result, #SCI_TEXTWIDTH, #STYLE_LINENUMBER, ToAscii(Lines$)))
      ScintillaSendMessage(Result, #SCI_SETMARGINWIDTHN, 1, 15)
      
      
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  1, NormalTextColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  2, BasicKeywordColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  3, CommentColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  4, ConstantColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  5, StringColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  6, PureKeywordColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  7, ASMKeywordColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  8, OperatorColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE,  9, StructureColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 10, NumberColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 11, PointerColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 12, SeparatorColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 13, LabelColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 14, CustomKeywordColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 15, ModuleColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, 16, BadBraceColor)
      
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 1, #SC_MARK_BACKGROUND)  ; current line back
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 2, #SC_MARK_ARROW)       ; current line symbol
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 3, #SC_MARK_BACKGROUND)  ; warning back
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 4, #SC_MARK_CHARACTER+'!') ; warning symbol
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 5, #SC_MARK_BACKGROUND)    ; error back
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 6, #SC_MARK_CIRCLE)        ; error symbol
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 7, #SC_MARK_BACKGROUND)    ; breakpoint back
      ScintillaSendMessage(Result, #SCI_MARKERDEFINE, 8, #SC_MARK_SMALLRECT)     ; breakpoint symbol
      
      ScintillaSendMessage(Result, #SCI_MARKERSETFORE, 2, $000000)
      ScintillaSendMessage(Result, #SCI_MARKERSETFORE, 4, $000000)
      ScintillaSendMessage(Result, #SCI_MARKERSETFORE, 6, $000000)
      ScintillaSendMessage(Result, #SCI_MARKERSETFORE, 8, $000000)
      
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 1, DebuggerLineColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 2, DebuggerLineSymbolColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 3, DebuggerWarningColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 4, DebuggerWarningSymbolColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 5, DebuggerErrorColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 6, DebuggerErrorSymbolColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 7, DebuggerBreakPointColor)
      ScintillaSendMessage(Result, #SCI_MARKERSETBACK, 8, DebuggerBreakpointSymbolColor)
      
      ScintillaSendMessage(Result, #SCI_SETCARETFORE,     CursorColor, 0)
      ScintillaSendMessage(Result, #SCI_SETCARETLINEBACK, CurrentLineColor, 0)
      ScintillaSendMessage(Result, #SCI_STYLESETBACK, #STYLE_LINENUMBER, LineNumberBackColor)
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, #STYLE_LINENUMBER, LineNumberColor)
      ScintillaSendMessage(Result, #SCI_SETFOLDMARGINCOLOUR, 1, LineNumberBackColor)
      ScintillaSendMessage(Result, #SCI_SETFOLDMARGINHICOLOUR, 1, LineNumberBackColor)
      
      ScintillaSendMessage(Result, #SCI_SETMOUSEDWELLTIME, 1000) ; for variable viewing in mouseover
      
      ScintillaSendMessage(Result, #SCI_STYLESETFORE, #STYLE_INDENTGUIDE, IndentColor)
      ScintillaSendMessage(Result, #SCI_SETWHITESPACEFORE, #True, IndentColor)
      
      If ShowWhiteSpace
        ScintillaSendMessage(Result, #SCI_SETVIEWWS, #SCWS_VISIBLEALWAYS)
      Else
        ScintillaSendMessage(Result, #SCI_SETVIEWWS, #SCWS_INVISIBLE)
      EndIf
      
      If ShowIndentGuides
        ScintillaSendMessage(Result, #SCI_SETINDENTATIONGUIDES, #SC_IV_LOOKBOTH)
      Else
        ScintillaSendMessage(Result, #SCI_SETINDENTATIONGUIDES, #SC_IV_NONE)
      EndIf
      
      CompilerIf #CompileWindows
        If SelectionColor = -1 ; special accessibility scheme
          ScintillaSendMessage(Result, #SCI_SETSELBACK,    1, GetSysColor_(#COLOR_HIGHLIGHT))
        Else
          ScintillaSendMessage(Result, #SCI_SETSELBACK,    1, SelectionColor)
        EndIf
        
        If SelectionFrontColor = -1
          ScintillaSendMessage(Result, #SCI_SETSELFORE,    1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
        Else
          ScintillaSendMessage(Result, #SCI_SETSELFORE,    1, SelectionFrontColor)
        EndIf
      CompilerElse
        ScintillaSendMessage(Result, #SCI_SETSELBACK,    1, SelectionColor)
        ScintillaSendMessage(Result, #SCI_SETSELFORE,    1, SelectionFrontColor)
      CompilerEndIf
      
      ; mark all breakpoints that are already set for this file (passed with optionsfile)
      ;
      ForEach BreakPoints()
        If DebuggerLineGetFile(BreakPoints()) = CurrentSource
          ScintillaSendMessage(Result, #SCI_MARKERADD, DebuggerLineGetLine(BreakPoints()), 7)
          ScintillaSendMessage(Result, #SCI_MARKERADD, DebuggerLineGetLine(BreakPoints()), 8)
        EndIf
      Next BreakPoints()
      
    EndIf
    
    
    ProcedureReturn Result
  EndProcedure
  
  ; create a new editorgadget and loads the given file into it
  ; returns the GadgetID of the loaded source
  Procedure LoadSource(FileName$)
    Result = 0
    
    If ReadFile(0, FileName$)
      Format = ReadStringFormat(0) ; try to detect string format
      Length = Lof(0)-Loc(0)
      
      *Buffer = AllocateMemory(Length+1) ; for the terminating 0 !
      If *Buffer
        Length = ReadData(0, *Buffer, Length)
        Result = LoadSourceBuffer(*Buffer, Length, Format)
        
        FreeMemory(*Buffer)
      EndIf
      CloseFile(0)
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure SetupHighlighting()
    EnableColoring = 1        ; set the highlighting options to on.
    EnableCaseCorrection = 1
    ;EnableKeywordBolding = 1 ; this one is loaded from the IDE preferences
    
    LoadHighlightingFiles = 0 ; do not try to load the functions files
    
    CompilerIf #CompileLinuxGtk
      
      ; find the part of the fontname that specifies the font wheight (3rd field)
      count = 0
      For i = 1 To Len(EditorFontName$)
        If Mid(EditorFontName$, i, 1) = "-"
          count + 1
          If count = 3
            BoldFontName$ = Left(EditorFontName$, i) + "bold-"
          ElseIf count = 4
            BoldFontName$ + Right(EditorFontName$, Len(EditorFontName$)-i)
            Break
          EndIf
        EndIf
      Next i
      
      If count < 4  ; something is wrong with the name.. just use the same font
        BoldFontName$ = EditorFontName$
      EndIf
      
      If EnableKeywordBolding
        ; bold font isn't loaded, as it is only used in the scintilla gadget
        EditorBoldFontName$ = BoldFontName$
      Else
        EditorBoldFontName$ = EditorFontName$
      EndIf
      
    CompilerElse
      EditorBoldFontName$ = EditorFontName$
    CompilerEndIf
    
    
    *NormalTextColor    = 1
    *BasicKeywordColor  = 2
    *CommentColor       = 3
    *ConstantColor      = 4
    *StringColor        = 5
    *PureKeywordColor   = 6
    *ASMKeywordColor    = 7
    *OperatorColor      = 8
    *StructureColor     = 9
    *NumberColor        = 10
    *PointerColor       = 11
    *SeparatorColor     = 12
    *LabelColor         = 13
    *CustomKeywordColor = 14
    *ModuleColor        = 15
    *BadEscapeColor     = 16
    
    InitSyntaxCheckArrays()
    InitSyntaxHighlighting()
  EndProcedure
  
  Declare Standalone_ResizeGUI()
  
  Procedure SourceLineAction(Line.l, Action)
    
    If Action = #ACTION_MarkCurrentLine
      For i = 0 To NbSourceFiles
        If SourceFiles(i)\IsLoaded
          ScintillaSendMessage(SourceFiles(i)\Gadget, #SCI_MARKERDELETEALL, 1, 0)
          ScintillaSendMessage(SourceFiles(i)\Gadget, #SCI_MARKERDELETEALL, 2, 0)
        EndIf
      Next i
      
      If Line = -1 ; clear all marks
        RedrawGadget(SourceFiles(CurrentSource)\Gadget)
        ProcedureReturn ; do not add any new mark
      EndIf
    EndIf
    
    If SourceFiles(CurrentSource)\IsLoaded
      HideGadget(SourceFiles(CurrentSource)\Gadget, 1)
    EndIf
    
    CurrentSource = DebuggerLineGetFile(Line)
    SetGadgetState(#GADGET_SelectSource, CurrentSource)
    
    If SourceFiles(CurrentSource)\IsLoaded
      HideGadget(SourceFiles(CurrentSource)\Gadget, 0)
    Else
      SourceFiles(CurrentSource)\Gadget = LoadSource(SourceFiles(CurrentSource)\FileName$)
      If SourceFiles(CurrentSource)\Gadget
        SourceFiles(CurrentSource)\IsLoaded = 1
      Else
        HideGadget(#GADGET_Waiting, 0) ; display this again
        
        If *DebuggerData\IsNetwork And *DebuggerData\ProgramState <> -1 And SourceFiles(CurrentSource)\IsRequested = 0
          Command.CommandInfo\Command = #COMMAND_GetFile
          Command\Value1 = CurrentSource
          SendDebuggerCommand(*DebuggerData, @Command)
          SourceFiles(CurrentSource)\IsRequested = 1
          
          ; Add this action to the delayed action lists
          ; As this can only happen for each file once, this list does not grow forever
          LastElement(DelayedActions()) ; add at the end
          AddElement(DelayedActions())
          DelayedActions()\FileIndex = CurrentSource
          DelayedActions()\Line      = Line
          DelayedActions()\Action    = Action
          
          Standalone_ResizeGUI()
        EndIf
        
        ProcedureReturn
      EndIf
    EndIf
    
    Standalone_ResizeGUI()
    
    Select Action
        
      Case #ACTION_MarkCurrentLine
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, DebuggerLineGetLine(Line), 1)
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, DebuggerLineGetLine(Line), 2)
        
        ; set the line into view
        Position = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_POSITIONFROMLINE, DebuggerLineGetLine(Line), 0)
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_SETSEL, Position, Position)
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_SCROLLCARET, 0, 0)
        
      Case #ACTION_MarkError
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, DebuggerLineGetLine(Line), 5)
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, DebuggerLineGetLine(Line), 6)
        
      Case #ACTION_MarkWarning
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, DebuggerLineGetLine(Line), 3)
        ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, DebuggerLineGetLine(Line), 4)
        
    EndSelect
    
    RedrawGadget(SourceFiles(CurrentSource)\Gadget)
    
  EndProcedure
  
  Procedure SetCurrentLine(Line.l)
    SourceLineAction(Line, #ACTION_MarkCurrentLine)
  EndProcedure
  
  Procedure MarkError(Line.l)
    SourceLineAction(Line, #ACTION_MarkError)
  EndProcedure
  
  Procedure MarkWarning(Line.l)
    SourceLineAction(Line, #ACTION_MarkWarning)
  EndProcedure
  
  ; return true if the current line is a breakpoint
  Procedure IsBreakPoint()
    
    If SourceFiles(CurrentSource)\IsLoaded
      Line = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_LINEFROMPOSITION, ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETCURRENTPOS, 0, 0), 0)
      Markers = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERGET, Line)
      
      If Markers & (1 << 7)
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure MarkBreakPoint() ; mark the current line as breakpoint and return the line number (including file)
    
    If SourceFiles(CurrentSource)\IsLoaded
      Line = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_LINEFROMPOSITION, ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETCURRENTPOS, 0, 0), 0)
      ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, Line, 7)
      ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERADD, Line, 8)
      RedrawGadget(SourceFiles(CurrentSource)\Gadget)
      ProcedureReturn MakeDebuggerLine(CurrentSource, Line)
    Else
      ProcedureReturn -1
    EndIf
    
  EndProcedure
  
  Procedure UnmarkBreakPoint() ; unmark the current line as breakpoint and return the line number (including file)
    
    If SourceFiles(CurrentSource)\IsLoaded
      Line = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_LINEFROMPOSITION, ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_GETCURRENTPOS, 0, 0), 0)
      ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERDELETE, Line, 7)
      ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERDELETE, Line, 8)
      RedrawGadget(SourceFiles(CurrentSource)\Gadget)
      ProcedureReturn MakeDebuggerLine(CurrentSource, Line)
    Else
      ProcedureReturn -1
    EndIf
    
  EndProcedure
  
  Procedure ClearBreakPoints() ; clear all breakpoint marks
    ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERDELETEALL, 7, 0)
    ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_MARKERDELETEALL, 8, 0)
    RedrawGadget(SourceFiles(CurrentSource)\Gadget)
  EndProcedure
  
  ; must be implemented for the Profiler
  Procedure Debugger_ShowLine(*Debugger.DebuggerData, Line)
    
    If SourceFiles(CurrentSource)\IsLoaded
      HideGadget(SourceFiles(CurrentSource)\Gadget, 1)
    EndIf
    
    CurrentSource = DebuggerLineGetFile(Line)
    SetGadgetState(#GADGET_SelectSource, CurrentSource)
    
    If SourceFiles(CurrentSource)\IsLoaded
      HideGadget(SourceFiles(CurrentSource)\Gadget, 0)
    Else
      SourceFiles(CurrentSource)\Gadget = LoadSource(SourceFiles(CurrentSource)\FileName$)
      If SourceFiles(CurrentSource)\Gadget
        SourceFiles(CurrentSource)\IsLoaded = 1
      Else
        HideGadget(#GADGET_Waiting, 0) ; display this again
        
        If *DebuggerData\IsNetwork And *DebuggerData\ProgramState <> -1 And SourceFiles(CurrentSource)\IsRequested = 0
          Command.CommandInfo\Command = #COMMAND_GetFile
          Command\Value1 = CurrentSource
          SendDebuggerCommand(*DebuggerData, @Command)
          SourceFiles(CurrentSource)\IsRequested = 1
        EndIf
        
        ProcedureReturn
      EndIf
    EndIf
    
    Standalone_ResizeGUI()
    
    ; set the line into view
    Position = ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_POSITIONFROMLINE, DebuggerLineGetLine(Line), 0)
    ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_SETSEL, Position, Position)
    ScintillaSendMessage(SourceFiles(CurrentSource)\Gadget, #SCI_SCROLLCARET, 0, 0)
    
    RedrawGadget(SourceFiles(CurrentSource)\Gadget)
    SetWindowForeground(#WINDOW_Main)
    SetActiveGadget(SourceFiles(CurrentSource)\Gadget)
    
  EndProcedure
  
CompilerEndIf
