; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

CompilerIf #CompileWindows | #CompileLinux | #CompileMac
  
  #SCI_NORM   = 0
  #SCI_SHIFT  = #SCMOD_SHIFT
  #SCI_CTRL   = #SCMOD_CTRL
  #SCI_ALT    = #SCMOD_ALT
  #SCI_CSHIFT = (#SCI_CTRL | #SCI_SHIFT)
  #SCI_ASHIFT = (#SCI_ALT | #SCI_SHIFT)
  
  ; remaining from a time when the Scintilla.res was incomplete
  Structure SCI_CharacterRange Extends SCCharacterRange
  EndStructure
  
  Structure SCI_TextToFind Extends SCTextToFind
  EndStructure
  
  ; Fix for the #SCI_COUNTCHARACTERS message. Don't use that message directly because of the below newline trouble
  ; (Fix no longer needed in newer Scintilla versions)
  ;
  Procedure CountCharacters(Gadget, startPos, endPos)
    ProcedureReturn ScintillaSendMessage(Gadget, #SCI_COUNTCHARACTERS, startPos, endPos)
  EndProcedure
  
  Procedure SendEditorFontMessage(Style, FontName$, FontSize)
    
    ; Gtk2 'Pango' need an "!" before the font name (else it will use GDK font)
    ;
    CompilerIf #CompileLinuxGtk
      FontName$ = "!"+FontName$
    CompilerEndIf
    
    SendEditorMessage(#SCI_STYLESETFONT, Style, ToAscii(FontName$))
    SendEditorMessage(#SCI_STYLESETSIZE, Style, FontSize)
  EndProcedure
  
  ; calculate really used colors (using replacements for disabled colors
  ;
  Procedure CalculateHighlightingColors()
    
    ; first set all colors to the user set value
    ;
    For i = 0 To #COLOR_Last
      Colors(i)\DisplayValue = Colors(i)\UserValue
    Next i
    
    ; for these basic colors, there is no choice (checkbox is hidden)
    ; so nothing to check for them
    ;   #COLOR_GlobalBackground
    ;   #COLOR_NormalText
    ;   #COLOR_Cursor
    ;   #COLOR_Selection
    ;   #COLOR_SelectionText
    ;   #COLOR_PlainBackground
    
    ; All other colors have another one they can fallback on, so do the fallback
    ; for them (in the right order, as sometimes even the fallback has another
    ; fallback)
    ;
    If Colors(#COLOR_CurrentLine)\Enabled = 0
      Colors(#COLOR_CurrentLine)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    If Colors(#COLOR_LineNumberBack)\Enabled = 0
      Colors(#COLOR_LineNumberBack)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    If Colors(#COLOR_LineNumber)\Enabled = 0
      Colors(#COLOR_LineNumber)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Marker)\Enabled = 0
      Colors(#COLOR_Marker)\DisplayValue = Colors(#COLOR_LineNumber)\DisplayValue
    EndIf
    
    ; Syntax coloring all falls back on NormalText
    ;
    If Colors(#COLOR_ASMKeyword)\Enabled = 0
      Colors(#COLOR_ASMKeyword)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_BasicKeyword)\Enabled = 0
      Colors(#COLOR_BasicKeyword)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_CustomKeyword)\Enabled = 0
      Colors(#COLOR_CustomKeyword)\DisplayValue = Colors(#COLOR_BasicKeyword)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Comment)\Enabled = 0
      Colors(#COLOR_Comment)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Constant)\Enabled = 0
      Colors(#COLOR_Constant)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Label)\Enabled = 0
      Colors(#COLOR_Label)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Number)\Enabled = 0
      Colors(#COLOR_Number)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Operator)\Enabled = 0
      Colors(#COLOR_Operator)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Pointer)\Enabled = 0
      Colors(#COLOR_Pointer)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_PureKeyword)\Enabled = 0
      Colors(#COLOR_PureKeyword)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Separator)\Enabled = 0
      Colors(#COLOR_Separator)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_String)\Enabled = 0
      Colors(#COLOR_String)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Structure)\Enabled = 0
      Colors(#COLOR_Structure)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Module)\Enabled = 0
      Colors(#COLOR_Module)\DisplayValue = Colors(#COLOR_NormalText)\DisplayValue
    EndIf
    
    ; Debugger stuff
    ;
    If Colors(#COLOR_DebuggerLineSymbol)\Enabled = 0
      Colors(#COLOR_DebuggerLineSymbol)\DisplayValue = Colors(#COLOR_LineNumber)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerErrorSymbol)\Enabled = 0
      Colors(#COLOR_DebuggerErrorSymbol)\DisplayValue = Colors(#COLOR_LineNumber)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerWarningSymbol)\Enabled = 0
      Colors(#COLOR_DebuggerWarningSymbol)\DisplayValue = Colors(#COLOR_LineNumber)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerBreakpointSymbol)\Enabled = 0
      Colors(#COLOR_DebuggerBreakpointSymbol)\DisplayValue = Colors(#COLOR_LineNumber)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerLine)\Enabled = 0
      Colors(#COLOR_DebuggerLine)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerError)\Enabled = 0
      Colors(#COLOR_DebuggerError)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerWarning)\Enabled = 0
      Colors(#COLOR_DebuggerWarning)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DebuggerBreakPoint)\Enabled = 0
      Colors(#COLOR_DebuggerBreakPoint)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    ; Other
    ;
    If Colors(#COLOR_GoodBrace)\Enabled = 0
      Colors(#COLOR_GoodBrace)\DisplayValue = Colors(#COLOR_Separator)\DisplayValue
    EndIf
    
    If Colors(#COLOR_BadBrace)\Enabled = 0
      Colors(#COLOR_BadBrace)\DisplayValue = Colors(#COLOR_Separator)\DisplayValue
    EndIf
    
    If Colors(#COLOR_DisabledBack)\Enabled = 0
      Colors(#COLOR_DisabledBack)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
    EndIf
    
    If Colors(#COLOR_Whitespace)\Enabled = 0
      Colors(#COLOR_Whitespace)\DisplayValue = Colors(#COLOR_Comment)\DisplayValue
    EndIf
    
    If Colors(#COLOR_ProcedureBack)\Enabled = 0
      Colors(#COLOR_ProcedureBack)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
      MarkProcedureBackground = 0
    Else
      If Colors(#COLOR_ProcedureBack)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
        MarkProcedureBackground = 0
      Else
        MarkProcedureBackground = 1
      EndIf
    EndIf
    
    If Colors(#COLOR_SelectionRepeat)\Enabled = 0
      Colors(#COLOR_SelectionRepeat)\DisplayValue = Colors(#COLOR_Selection)\DisplayValue
    EndIf
    
  EndProcedure
  
  ; translate the highlighting colors into the os specific format for a faster highlighting
  ;
  Procedure SetUpHighlightingColors()
    ; NOTE: When inventing new code styles, update the SetBackgroundColor() procedure to fit!
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
    
    ; Setup the coloring (do it here, so it affects highlighting changes)
    ;
    If *ActiveSource ; only if a source is loaded
      SendEditorFontMessage(#STYLE_DEFAULT, EditorFontName$, EditorFontSize)
      
      If EditorFontStyle & #PB_Font_Bold
        SendEditorMessage(#SCI_STYLESETBOLD, #STYLE_DEFAULT, 1)
      Else
        SendEditorMessage(#SCI_STYLESETBOLD, #STYLE_DEFAULT, 0)
      EndIf
      If EditorFontStyle & #PB_Font_Italic
        SendEditorMessage(#SCI_STYLESETITALIC, #STYLE_DEFAULT, 1)
      Else
        SendEditorMessage(#SCI_STYLESETITALIC, #STYLE_DEFAULT, 0)
      EndIf
      
      If EnableColoring
        SendEditorMessage(#SCI_STYLESETBACK, #STYLE_DEFAULT, Colors(#COLOR_GlobalBackground)\DisplayValue)
        SendEditorMessage(#SCI_STYLECLEARALL, 0, 0) ; to make the background & font change effective!
        
        SendEditorMessage(#SCI_STYLESETFORE,  1, Colors(#COLOR_NormalText)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  2, Colors(#COLOR_BasicKeyword)\DisplayValue)
        
        If EnableKeywordBolding
          SendEditorFontMessage(2, EditorBoldFontName$, EditorFontSize)
          SendEditorFontMessage(14, EditorBoldFontName$, EditorFontSize)
          SendEditorMessage(#SCI_STYLESETBOLD,  2, 1)             ; Bold (no effect on linux, but maybe on windows later)
          SendEditorMessage(#SCI_STYLESETBOLD,  14, 1)
          If EditorFontStyle & #PB_Font_Italic
            SendEditorMessage(#SCI_STYLESETITALIC, 2, 1)
            SendEditorMessage(#SCI_STYLESETITALIC, 14, 1)
          EndIf
        EndIf
        
        SendEditorMessage(#SCI_STYLESETFORE,  3, Colors(#COLOR_Comment)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  4, Colors(#COLOR_Constant)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  5, Colors(#COLOR_String)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  6, Colors(#COLOR_PureKeyword)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  7, Colors(#COLOR_ASMKeyword)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  8, Colors(#COLOR_Operator)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE,  9, Colors(#COLOR_Structure)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 10, Colors(#COLOR_Number)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 11, Colors(#COLOR_Pointer)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 12, Colors(#COLOR_Separator)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 13, Colors(#COLOR_Label)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 14, Colors(#COLOR_CustomKeyword)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 15, Colors(#COLOR_Module)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, 16, Colors(#COLOR_BadBrace)\DisplayValue)
        
        SendEditorMessage(#SCI_STYLESETBACK, #STYLE_BRACELIGHT, Colors(#COLOR_CurrentLine)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETBACK, #STYLE_BRACEBAD  , Colors(#COLOR_CurrentLine)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, #STYLE_BRACELIGHT, Colors(#COLOR_GoodBrace)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, #STYLE_BRACEBAD,   Colors(#COLOR_BadBrace)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETBOLD, #STYLE_BRACELIGHT, 1)
        SendEditorMessage(#SCI_STYLESETBOLD, #STYLE_BRACEBAD, 1)
        
        SendEditorMessage(#SCI_SETCARETLINEBACK, Colors(#COLOR_CurrentLine)\DisplayValue, 0)
        SendEditorMessage(#SCI_SETCARETFORE,     Colors(#COLOR_Cursor)\DisplayValue, 0)
        
        SendEditorMessage(#SCI_STYLESETFORE, #STYLE_INDENTGUIDE, Colors(#COLOR_Whitespace)\DisplayValue)
        SendEditorMessage(#SCI_SETWHITESPACEFORE, #True, Colors(#COLOR_Whitespace)\DisplayValue)
        
        CompilerIf #CompileWindows
          If Colors(#COLOR_Selection)\DisplayValue = -1 Or EnableAccessibility ; special accessibility scheme
            SendEditorMessage(#SCI_SETSELBACK,    1, GetSysColor_(#COLOR_HIGHLIGHT))
            SendEditorMessage(#SCI_SETELEMENTCOLOUR, #SC_ELEMENT_SELECTION_INACTIVE_BACK, GetSysColor_(#COLOR_HIGHLIGHT))
          Else
            SendEditorMessage(#SCI_SETSELBACK,    1, Colors(#COLOR_Selection)\DisplayValue)
            SendEditorMessage(#SCI_SETELEMENTCOLOUR, #SC_ELEMENT_SELECTION_INACTIVE_BACK, Colors(#COLOR_Selection)\DisplayValue)
          EndIf
          
          If Colors(#COLOR_SelectionFront)\DisplayValue = -1 Or EnableAccessibility
            SendEditorMessage(#SCI_SETSELFORE,    1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
            SendEditorMessage(#SCI_SETELEMENTCOLOUR, #SC_ELEMENT_SELECTION_INACTIVE_TEXT, GetSysColor_(#COLOR_HIGHLIGHTTEXT) | $FF000000) ; Warning, this value requiers an RGBA value, so force the alpha value to be fully visible (https://www.purebasic.fr/english/viewtopic.php?t=84160)
          Else
            SendEditorMessage(#SCI_SETSELFORE,    1, Colors(#COLOR_SelectionFront)\DisplayValue)
            SendEditorMessage(#SCI_SETELEMENTCOLOUR, #SC_ELEMENT_SELECTION_INACTIVE_TEXT, Colors(#COLOR_SelectionFront)\DisplayValue | $FF000000) ; Warning, this value requiers an RGBA value, so force the alpha value to be fully visible (https://www.purebasic.fr/english/viewtopic.php?t=84160)
          EndIf
        CompilerElse
          SendEditorMessage(#SCI_SETSELBACK,    1, Colors(#COLOR_Selection)\DisplayValue)
          SendEditorMessage(#SCI_SETELEMENTCOLOUR, #SC_ELEMENT_SELECTION_INACTIVE_BACK, Colors(#COLOR_Selection)\DisplayValue)
          
          SendEditorMessage(#SCI_SETSELFORE,    1, Colors(#COLOR_SelectionFront)\DisplayValue)
          SendEditorMessage(#SCI_SETELEMENTCOLOUR, #SC_ELEMENT_SELECTION_INACTIVE_TEXT, Colors(#COLOR_SelectionFront)\DisplayValue | $FF000000) ; Warning, this value requiers an RGBA value, so force the alpha value to be fully visible (https://www.purebasic.fr/english/viewtopic.php?t=84160)
        CompilerEndIf
        
        SendEditorMessage(#SCI_INDICSETFORE, #INDICATOR_KeywordMatch,    Colors(#COLOR_GoodBrace)\DisplayValue)
        SendEditorMessage(#SCI_INDICSETFORE, #INDICATOR_KeywordMismatch, Colors(#COLOR_BadBrace)\DisplayValue)
        SendEditorMessage(#SCI_INDICSETFORE, #INDICATOR_SelectionRepeat, Colors(#COLOR_SelectionRepeat)\DisplayValue)
        
        ; Set the line margin and symbol margin style
        ;
        SendEditorMessage(#SCI_STYLESETBACK, #STYLE_LINENUMBER, Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_STYLESETFORE, #STYLE_LINENUMBER, Colors(#COLOR_LineNumber)\DisplayValue)
        
        SendEditorMessage(#SCI_SETFOLDMARGINCOLOUR, 1, Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_SETFOLDMARGINHICOLOUR, 1, Colors(#COLOR_LineNumberBack)\DisplayValue)
        
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_Marker,            $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_CurrentLineSymbol, $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_WarningSymbol,     $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_ErrorSymbol,       $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_BreakpointSymbol,  $000000)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Marker,            Colors(#COLOR_Marker)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_CurrentLine,       Colors(#COLOR_DebuggerLine)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_CurrentLineSymbol, Colors(#COLOR_DebuggerLineSymbol)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Warning,           Colors(#COLOR_DebuggerWarning)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_WarningSymbol,     Colors(#COLOR_DebuggerWarningSymbol)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Error,             Colors(#COLOR_DebuggerError)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_ErrorSymbol,       Colors(#COLOR_DebuggerErrorSymbol)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Breakpoint,        Colors(#COLOR_DebuggerBreakpoint)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_BreakpointSymbol,  Colors(#COLOR_DebuggerBreakpointSymbol)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_ProcedureBack,     Colors(#COLOR_ProcedureBack)\DisplayValue)
        
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPEN,    Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDER,        Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEREND,     Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPENMID, Colors(#COLOR_LineNumberBack)\DisplayValue)
        
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_FoldVLine,         Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_FoldVCorner,       Colors(#COLOR_LineNumberBack)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_FoldTCorner,       Colors(#COLOR_LineNumberBack)\DisplayValue)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPEN,    Colors(#COLOR_LineNumber)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDER,        Colors(#COLOR_LineNumber)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEREND,     Colors(#COLOR_LineNumber)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPENMID, Colors(#COLOR_LineNumber)\DisplayValue)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_FoldVLine,         Colors(#COLOR_LineNumber)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_FoldVCorner,       Colors(#COLOR_LineNumber)\DisplayValue)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_FoldTCorner,       Colors(#COLOR_LineNumber)\DisplayValue)
        
        If Colors(#COLOR_ProcedureBack)\Enabled = 0 Or Colors(#COLOR_ProcedureBack)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_ProcedureBack, #SC_MARK_EMPTY)
        Else
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_ProcedureBack, #SC_MARK_BACKGROUND)
        EndIf
        
        If Colors(#COLOR_CurrentLine)\Enabled = 0 Or Colors(#COLOR_CurrentLine)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
          SendEditorMessage(#SCI_SETCARETLINEVISIBLE, 0, 0) ; disable the different color for the current line
        Else
          SendEditorMessage(#SCI_SETCARETLINEVISIBLE, 1, 0) ; enable the different color for the current line
        EndIf
        
        ; these are defined to "empty" when not used...
        If Colors(#COLOR_DebuggerLine)\Enabled = 0 Or Colors(#COLOR_DebuggerLine)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_CurrentLine, #SC_MARK_EMPTY)
        Else
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_CurrentLine, #SC_MARK_BACKGROUND)
        EndIf
        
        If Colors(#COLOR_DebuggerWarning)\Enabled = 0 Or Colors(#COLOR_DebuggerWarning)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Error, #SC_MARK_EMPTY)
        Else
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Error, #SC_MARK_BACKGROUND)
        EndIf
        
        If Colors(#COLOR_DebuggerError)\Enabled = 0 Or Colors(#COLOR_DebuggerError)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Error, #SC_MARK_EMPTY)
        Else
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Error, #SC_MARK_BACKGROUND)
        EndIf
        
        If Colors(#COLOR_DebuggerBreakpoint)\Enabled = 0 Or Colors(#COLOR_DebuggerBreakpoint)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Breakpoint, #SC_MARK_EMPTY)
        Else
          SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Breakpoint, #SC_MARK_BACKGROUND)
        EndIf
        
        ; setup markers and styles for issues
        ForEach Issues()
          If Issues()\Style <> -1
            SendEditorMessage(#SCI_STYLESETFORE, Issues()\Style , Colors(#COLOR_Comment)\DisplayValue)
            SendEditorMessage(#SCI_STYLESETBACK, Issues()\Style , Issues()\Color)
          EndIf
          
          If Issues()\Marker <> -1
            SendEditorMessage(#SCI_MARKERDEFINE, Issues()\Marker, #SC_MARK_BACKGROUND)
            SendEditorMessage(#SCI_MARKERSETBACK, Issues()\Marker, Issues()\Color)
          EndIf
        Next Issues()
        
        
      Else  ; Coloring Disabled
        SendEditorMessage(#SCI_STYLERESETDEFAULT, 0, 0)
        SendEditorMessage(#SCI_STYLESETBACK, #STYLE_DEFAULT, $FFFFFF)
        SendEditorMessage(#SCI_STYLESETFORE, #STYLE_DEFAULT, $000000)
        
        SendEditorMessage(#SCI_STYLESETBACK, #STYLE_LINENUMBER, $FFFFFF)
        SendEditorMessage(#SCI_STYLESETFORE, #STYLE_LINENUMBER, $000000)
        
        SendEditorMessage(#SCI_SETWHITESPACEFORE, #True, $000000)
        
        SendEditorMessage(#SCI_SETFOLDMARGINCOLOUR, 1, $FFFFFF)
        SendEditorMessage(#SCI_SETFOLDMARGINHICOLOUR, 1, $FFFFFF)
        
        SendEditorMessage(#SCI_INDICSETFORE, #INDICATOR_KeywordMatch,    $000000)
        SendEditorMessage(#SCI_INDICSETFORE, #INDICATOR_KeywordMismatch, $FFFFFF)
        SendEditorMessage(#SCI_INDICSETFORE, #INDICATOR_SelectionRepeat, $FFFFFF)
        
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_Marker,            $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_CurrentLineSymbol, $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_WarningSymbol,     $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_ErrorSymbol,       $000000)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_BreakpointSymbol,  $000000)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Marker,            $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_CurrentLine,       $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_CurrentLineSymbol, $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Error,             $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_ErrorSymbol,       $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Warning,           $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_WarningSymbol,     $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_Breakpoint,        $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_BreakpointSymbol,  $FFFFFF)
        
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPEN,    $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDER,        $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEREND,     $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPENMID, $FFFFFF)
        
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_FoldVLine,           $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_FoldVCorner,         $FFFFFF)
        SendEditorMessage(#SCI_MARKERSETFORE, #MARKER_FoldTCorner,         $FFFFFF)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPEN,    $000000)
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDER,        $000000)
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEREND,     $000000)
        SendEditorMessage(#SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPENMID, $000000)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_FoldVLine,         $000000)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_FoldVCorner,       $000000)
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_FoldTCorner,       $000000)
        
        SendEditorMessage(#SCI_MARKERSETBACK, #MARKER_ProcedureBack,     $FFFFFF)
        
        ; these are defined to "empty" when not used...
        SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_CurrentLine, #SC_MARK_EMPTY)
        SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Error      , #SC_MARK_EMPTY)
        SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Warning    , #SC_MARK_EMPTY)
        SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Breakpoint , #SC_MARK_EMPTY)
        SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_ProcedureBack, #SC_MARK_EMPTY)
        
        SendEditorMessage(#SCI_SETCARETLINEBACK, $FFFFFF, 0)
        SendEditorMessage(#SCI_SETCARETFORE,     $000000, 0)
        
        CompilerIf #CompileWindows
          SendEditorMessage(#SCI_SETSELBACK,    1, GetSysColor_(#COLOR_HIGHLIGHT))
          SendEditorMessage(#SCI_SETSELFORE,    1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
        CompilerElse
          SendEditorMessage(#SCI_SETSELBACK,    1, $C0C0C0)
          SendEditorMessage(#SCI_SETSELFORE,    1, $000000)
        CompilerEndIf
        
        SendEditorMessage(#SCI_SETCARETLINEVISIBLE, 0, 0) ; disable the different color for the current line
        
        ; disable issue markers
        ; no need to do anything for the issue styles, as they will have the default colors
        ForEach Issues()
          If Issues()\Marker <> -1
            SendEditorMessage(#SCI_MARKERDEFINE, Issues()\Marker, #SC_MARK_EMPTY)
          EndIf
        Next Issues()
      EndIf
      
      SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_InlineASM, #SC_MARK_EMPTY)
      
      If EnableLineNumbers
        HideLineNumbers(*ActiveSource, 0)
      Else
        HideLineNumbers(*ActiveSource, 1)
      EndIf
      
      ; Do not hide the margin as it is used for breakpoint, error etc symbols too
      ; Instead just clear any old Markers/Folding marks if they were turned off
      ;
      SendEditorMessage(#SCI_SETMARGINWIDTHN, 1, 15)
      
      If EnableFolding = 0
        lines = SendEditorMessage(#SCI_GETLINECOUNT)
        For i = 0 To lines-1
          SendEditorMessage(#SCI_SETFOLDLEVEL, i, #SC_FOLDLEVELBASE)
        Next i
        SendEditorMessage(#SCI_SHOWLINES, 0, lines-1)
        
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDEROPEN)
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDER)
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDEREND)
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDEROPENMID)
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDERSUB)
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDERTAIL)
        SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDERMIDTAIL)
        SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_FoldVLine)
        SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_FoldVCorner)
        SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_FoldTCorner)
      EndIf
      
      If EnableMarkers = 0
        SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_Marker)
      EndIf
      
      SendEditorMessage(#SCI_SETTABWIDTH, TabLength, 0)
      SendEditorMessage(#SCI_SETUSETABS, RealTab, 0)
      
      If ShowWhiteSpace
        SendEditorMessage(#SCI_SETVIEWWS, #SCWS_VISIBLEALWAYS)
      Else
        SendEditorMessage(#SCI_SETVIEWWS, #SCWS_INVISIBLE)
      EndIf
      
      If ShowIndentGuides
        SendEditorMessage(#SCI_SETINDENTATIONGUIDES, #SC_IV_LOOKBOTH)
      Else
        SendEditorMessage(#SCI_SETINDENTATIONGUIDES, #SC_IV_NONE)
      EndIf
      
    EndIf
  EndProcedure
  
  
  Procedure IsInsideASMBlock(Line)
    Markers = SendEditorMessage(#SCI_MARKERGET, Line, 0)
    If Markers & (1 << #MARKER_InlineASM)
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  
  ; Need to share the start of the buffer to get the position correctly
  ;
  Global *HighlightBuffer, HighlightOffset, HighlightGadget, NoUserChange
  
  Procedure HighlightCallback(*StringStart.Ascii, Length, *Color, IsBold, TextChanged)
    
    ; replace the text only if it was changed by the highlighting engine (case correction)
    ;
    If TextChanged
      ; Very strange: If the last line es empty and the previous has a keyword (case correction) at the end
      ; usually, the newline will be replaced with the word. This however makes scintilla act like crazy when
      ; scrolling to the last line. So we actually only replace the word itself, not any spaces/newline behind it
      ; this appearently fixes this :|
      ;
      ChangeLength = Length
      While ChangeLength > 1 And ValidCharacters(PeekA(*StringStart+ChangeLength-1)) = 0
        ChangeLength-1
      Wend
      ;
      ; note that this change appears in the undo buffer, but this can't be changed, because if you
      ; disable the undo buffer, you also clear it !
      ;
      ScintillaSendMessage(HighlightGadget, #SCI_SETTARGETSTART, *StringStart-*HighlightBuffer+HighlightOffset, 0)
      ScintillaSendMessage(HighlightGadget, #SCI_SETTARGETEND, *StringStart-*HighlightBuffer+HighlightOffset+ChangeLength, 0)
      ScintillaSendMessage(HighlightGadget, #SCI_REPLACETARGET, ChangeLength, *StringStart)
    EndIf
    
    
    ; Only the good color style is used (faster according to the docs)
    ;
    If EnableColoring
      If IsInsideASMBlock(SendEditorMessage(#SCI_LINEFROMPOSITION, *StringStart - *HighlightBuffer + HighlightOffset, 0))
        ScintillaSendMessage(HighlightGadget, #SCI_SETSTYLING, Length, *ASMKeywordColor)
      Else
        ScintillaSendMessage(HighlightGadget, #SCI_SETSTYLING, Length, *Color)
      EndIf
    EndIf
  EndProcedure
  
  Procedure HighlightArea(*StartPos, *EndPos)
    ;
    ; highlighting is done only on demand (see ScintillaCallback)
    ;
  EndProcedure
  
  Procedure UpdateIsCodeStatus()
    
    If *ActiveSource\IsCode
      
      ; re-scan everything
      FullSourceScan(*ActiveSource)                     ; re-scan autocomplete + procedurebrowser
      SortParserData(*ActiveSource\Parser, *ActiveSource) ; update sorted data in case its not the active source
      UpdateFolding(*ActiveSource, 0, -1)                 ; redo all folding
      
    Else
      ; free any parser data
      FreeSourceItemArray(@*ActiveSource\Parser)
      
      ; reset any folding
      highestline = SendEditorMessage(#SCI_GETLINECOUNT) - 1
      For i = 0 To highestline
        SendEditorMessage(#SCI_ENSUREVISIBLE, i)
      Next i
      For i = 0 To highestline
        SendEditorMessage(#SCI_SETFOLDLEVEL, i, #SC_FOLDLEVELBASE)
      Next i
      
      ; clear code-related markers
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_CurrentLine)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_CurrentLineSymbol)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_Error)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_ErrorSymbol)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_Warning)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_WarningSymbol)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_Breakpoint)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_BreakpointSymbol)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDEROPEN)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDER)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDEREND)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDEROPENMID)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDERSUB)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDERTAIL)
      SendEditorMessage(#SCI_MARKERDELETEALL, #SC_MARKNUM_FOLDERMIDTAIL)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_FoldVLine)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_FoldVCorner)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_FoldTCorner)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_ProcedureStart)
      SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_ProcedureBack)
      For i = #MARKER_FirstIssue To #MARKER_LastIssue
        SendEditorMessage(#SCI_MARKERDELETEALL, i)
      Next i
      
      ; clear indicators
      SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
      SendEditorMessage(#SCI_INDICATORCLEARRANGE, 0, SendEditorMessage(#SCI_GETTEXTLENGTH))
      SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMismatch)
      SendEditorMessage(#SCI_INDICATORCLEARRANGE, 0, SendEditorMessage(#SCI_GETTEXTLENGTH))
      
    EndIf
    
    SetBackgroundColor()
    UpdateHighlighting()
    UpdateProcedureList() ; update list for current source
    UpdateVariableViewer()
    UpdateMenuStates()
    SetDebuggerMenuStates()
    
  EndProcedure
  
  Procedure UpdateHighlighting()   ; highlight everything after a prefs update
    
    If EnableColoring Or EnableCaseCorrection
      
      If *ActiveSource\IsCode
        
        ; Seems to be a scintilla bug: when we update the highlighting (for example set EnableASM mode)
        ; and the update modifies the text content (for example case-sensitivity) inside
        ; a folded procedure, we get a mixup and a crash (at a later point)
        ; I think this is a scintilla issue.
        ;
        ; So we unfold all foldpoints, do the update, fold again
        ;
        
        ; store and undo folding info
        FoldingInfo$ = CreateFoldingInformation()
        
        count = GetLinesCount(*ActiveSource)
        For i = 0 To count-1
          If IsFoldPoint(i)
            SetFoldState(i, 1)
          EndIf
        Next i
        
        anchorPos = SendEditorMessage(#SCI_GETANCHOR, 0, 0) ; save & restore the cursor pos
        currentPos = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
        
        InBufferLength = SendEditorMessage(#SCI_GETTEXTLENGTH, 0, 0)
        
        *InBuffer = AllocateMemory(InBufferLength+1)
        
        *HighlightBuffer = *InBuffer
        HighlightOffset = 0
        HighlightGadget = *ActiveSource\EditorGadget
        
        SendEditorMessage(#SCI_GETTEXT, InBufferLength, *InBuffer)
        
        SendEditorMessage(#SCI_SETUNDOCOLLECTION, #False, 0)
        
        If EnableColoring
          SendEditorMessage(#SCI_STARTSTYLING, 0, $FFFFFF) ; also overwrites the brace highlights
        EndIf
        
        ; now call the highlighting engine
        ;
        Modified = GetSourceModified()  ; because the case correction changes the modified state!
        HighlightingEngine(*InBuffer, InBufferLength, SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0), @HighlightCallback(), 1)
        SetSourceModified(Modified)
        
        FreeMemory(*InBuffer)
        
        SendEditorMessage(#SCI_SETUNDOCOLLECTION, #True, 0)
        
        SendEditorMessage(#SCI_SETANCHOR, anchorPos, 0)
        SendEditorMessage(#SCI_SETCURRENTPOS, currentPos, 0)
        
        ApplyFoldingInformation(FoldingInfo$)
        
      ElseIf EnableColoring
        
        ; non-pb files
        InBufferLength = SendEditorMessage(#SCI_GETTEXTLENGTH, 0, 0)
        SendEditorMessage(#SCI_STARTSTYLING, 0, $FFFFFF) ; also overwrites the brace highlights
        SendEditorMessage(#SCI_SETSTYLING, InBufferLength, *NormalTextColor)
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  ; Updates the folding states only, starting at the given line until at least
  ; lastline. The update will go further as long as the folding level changes,
  ; but it will stop at lastline when no changes are made.
  ; (this way it is faster while still doing a correct update)
  ;
  ; Also updates procedure background and issue markers in the
  ; indicated line range
  ;
  Procedure UpdateFolding(*Source.SourceFile, firstline, lastline)
    
    If *Source\IsCode = 0
      ProcedureReturn
    EndIf
    
    Gadget             = *Source\EditorGadget
    *Array.ParsedLines = *Source\Parser\SourceItemArray
    
    highestline = ScintillaSendMessage(Gadget, #SCI_GETLINECOUNT) - 1
    If *Source\Parser\SourceItemCount < highestline+1
      highestline = *Source\Parser\SourceItemCount - 1
    EndIf
    
    If firstline < 0 ; could happen when re-highlighting the first line
      firstline = 0
    EndIf
    
    If lastline < 0 Or lastline > highestline
      lastline = highestline
    EndIf
    
    If EnableFolding And *Array
      
      If firstline = 0
        FoldLevel = #SC_FOLDLEVELBASE
      Else
        FoldLevel = ScintillaSendMessage(Gadget, #SCI_GETFOLDLEVEL, firstline, 0) & (~#SC_FOLDLEVELHEADERFLAG)
      EndIf
      
      ; We need to find out whether line is inside a macro for proper handling
      ; of the foldpoints from here on
      ; We also need to know if we are inside a procedure for the
      ; adding the "Procedure Background color" markers
      ;
      If firstline = 0
        InsideMacro     = 0
        InsideProcedure = 0
        InsideInlineASM = 0
      Else
        InsideMacro     = 0
        InsideProcedure = 0
        ProcedureFound  = 0 ; once we found that we are inside a procedure, there may be no more checks or it gets overwritten
        InsideInlineASM = 0
        InlineASMFound  = 0
        
        ; Note: In each line, we search left to right (because of the linkedlist),
        ;   but we look at the lines backwards. So to know if there is a Procedure/Macro
        ;   we count the open/close when we find a line with more "open" than "close",
        ;   we are inside it.
        ;
        For i = firstline-1 To 0 Step -1
          *Item.SourceItem = *Array\Line[i]\First
          While *Item
            Select *Item\Type
              Case #ITEM_Macro       : InsideMacro + 1
              Case #ITEM_MacroEnd    : InsideMacro - 1
              Case #ITEM_Procedure   : If ProcedureFound = 0: InsideProcedure + 1: EndIf
              Case #ITEM_ProcedureEnd: If ProcedureFound = 0: InsideProcedure - 1: EndIf
              
              Case #ITEM_InlineASM   : If InlineASMFound = 0: InsideInlineASM + 1: EndIf
              Case #ITEM_InlineASMEnd: If InlineASMFound = 0: InsideInlineASM - 1: EndIf
            EndSelect
            *Item = *Item\Next
          Wend
          
          If InsideMacro > 0 ; more 'Macro' on the line than 'EndMacro
            InsideMacro     = 1
            InsideProcedure = 0 ; inside a macro we ignore this
            Break
          Else
            If ProcedureFound = 0 And InsideProcedure > 0 ; more 'Procedure' than 'EndProcedure'
              InsideProcedure = 1
              ProcedureFound  = 1 ; do not abort here as we must check for a macro as well
            EndIf
            
            If InlineASMFound = 0 And InsideInlineASM > 0 ; more 'EnableJS' than 'EndEnableJS'
              InsideInlineASM = 1
              InlineASMFound  = 1 ; do not abort here as we must check for a macro as well
            EndIf
          EndIf
        Next i
      EndIf
      
      NeedRefresh = 0
      
      For line = firstline To highestline
        *Item.SourceItem = *Array\Line[line]\First
        
        CurrentLineLevel = FoldLevel
        FoldFlag         = 0
        MarkProcedure    = InsideProcedure
        MarkInlineASM    = InsideInlineASM
        IssueMarker      = -1
        IssuePriority    = 5
        
        While *Item
          If InsideMacro = 0
            Select *Item\Type
              Case #ITEM_FoldStart
                FoldFlag = #SC_FOLDLEVELHEADERFLAG
                FoldLevel + 1
              
              Case #ITEM_FoldEnd
                FoldLevel - 1
                If FoldLevel < #SC_FOLDLEVELBASE
                  FoldLevel = #SC_FOLDLEVELBASE
                EndIf
              
              Case #ITEM_Procedure
                InsideProcedure = 1
                MarkProcedure   = 1
              
              Case #ITEM_ProcedureEnd
                InsideProcedure = 0
                ; even when the procedure ends here, still mark the line
                
              Case #ITEM_InlineASM
                InsideInlineASM = 1
              
              Case #ITEM_InlineASMEnd
                InsideInlineASM = 0 
                MarkInlineASM   = 0 ; Don't mark the DisableJS line so it gets properly formatted
            EndSelect
          EndIf
          
          If *Item\Type = #ITEM_Macro
            InsideMacro = 1
            
          ElseIf *Item\Type = #ITEM_MacroEnd
            InsideMacro = 0
            
            ; Special fix when "EndMacro" is a folding keyword. As the #ITEM_FoldEnd
            ; comes before the EndMacro, it is ignored. So use the EndMacro as the
            ; trigger in this case then.
            ;
            If IsMacroFolding
              FoldLevel - 1
              If FoldLevel < #SC_FOLDLEVELBASE
                FoldLevel = #SC_FOLDLEVELBASE
              EndIf
            EndIf
            
          ElseIf *Item\Type = #ITEM_Issue And SelectElement(Issues(), *Item\Issue)
            If Issues()\Marker <> -1
              If IssueMarker = -1 Or Issues()\Priority < IssuePriority
                ; if multiple markers, the first or the one with higher priority wins
                IssueMarker   = Issues()\Marker
                IssuePriority = Issues()\Priority
              EndIf
            EndIf
            
          EndIf
          
          *Item = *Item\Next
        Wend
        
        ; the fold level changes only affect the following lines, not the current one
        ScintillaSendMessage(Gadget, #SCI_SETFOLDLEVEL, line, CurrentLineLevel|FoldFlag)
        
        ; to update our own folding markers, which have a lower priority than the default ones,
        ; which puts them below all other markers
        Markers = ScintillaSendMessage(Gadget, #SCI_MARKERGET, line, 0)
        
        ; Issue markers
        For i = #MARKER_FirstIssue To #MARKER_LastIssue
          If i = IssueMarker
            If Markers & (1<<i) = 0
              ScintillaSendMessage(Gadget, #SCI_MARKERADD, line, i)
              NeedRefresh = 1
            EndIf
          ElseIf Markers & (1<<i)
            ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, i)
            NeedRefresh = 1
          EndIf
        Next i
        
        ; Procedure background marker
        If MarkProcedureBackground And MarkProcedure
          If Markers & (1<<#MARKER_ProcedureBack) = 0
            ScintillaSendMessage(Gadget, #SCI_MARKERADD, line, #MARKER_ProcedureBack)
            NeedRefresh = 1
          EndIf
        ElseIf Markers & (1<<#MARKER_ProcedureBack)
          ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_ProcedureBack)
          NeedRefresh = 1
        EndIf
        
        ; EnableJS / EnableC / EnableASM marker
        If MarkInlineASM
          If Markers & (1 << #MARKER_InlineASM) = 0
            ScintillaSendMessage(Gadget, #SCI_MARKERADD, line, #MARKER_InlineASM)
            NeedRefresh = 1
          EndIf
        ElseIf Markers & (1 << #MARKER_InlineASM)
          ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_InlineASM)
          NeedRefresh = 1
        EndIf
        
        ; Note: the 'Header' marker has the level of its previous state (ie: 'Procedure a()' line will have level 0)
        ;
        If FoldFlag = 0
          
          If CurrentLineLevel = #SC_FOLDLEVELBASE
            
            ; Here we add or remove the marker only when necessary, which save a lot of time on nearly identical file
            ;
            If Markers & (1 << #MARKER_FoldVLine)   : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVLine)   : EndIf
            If Markers & (1 << #MARKER_FoldVCorner) : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVCorner) : EndIf
            If Markers & (1 << #MARKER_FoldTCorner) : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldTCorner) : EndIf
            
          ElseIf FoldLevel < CurrentLineLevel
            
            If FoldLevel = #SC_FOLDLEVELBASE
              
              
              If Markers & (1 << #MARKER_FoldVLine)       : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVLine)   : EndIf
              If Markers & (1 << #MARKER_FoldVCorner) = 0 : ScintillaSendMessage(Gadget, #SCI_MARKERADD,    line, #MARKER_FoldVCorner) : EndIf
              If Markers & (1 << #MARKER_FoldTCorner)     : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldTCorner) : EndIf
              
            Else
              
              If Markers & (1 << #MARKER_FoldVLine)       : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVLine)   : EndIf
              If Markers & (1 << #MARKER_FoldVCorner)     : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVCorner) : EndIf
              If Markers & (1 << #MARKER_FoldTCorner) = 0 : ScintillaSendMessage(Gadget, #SCI_MARKERADD,    line, #MARKER_FoldTCorner) : EndIf
              
            EndIf
            
          ElseIf FoldLevel = CurrentLineLevel
            
            If Markers & (1 << #MARKER_FoldVLine) = 0 : ScintillaSendMessage(Gadget, #SCI_MARKERADD,    line, #MARKER_FoldVLine)   : EndIf
            If Markers & (1 << #MARKER_FoldVCorner)   : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVCorner) : EndIf
            If Markers & (1 << #MARKER_FoldTCorner)   : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldTCorner) : EndIf
            
          Else ; No need to test, it's the last case: LastFoldLevel > FoldLevel
            
            If Markers & (1 << #MARKER_FoldVLine) = 0 : ScintillaSendMessage(Gadget, #SCI_MARKERADD,    line, #MARKER_FoldVLine)   : EndIf
            If Markers & (1 << #MARKER_FoldVCorner)   : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVCorner) : EndIf
            If Markers & (1 << #MARKER_FoldTCorner)   : ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldTCorner) : EndIf
            
          EndIf
          
        Else
          
          ; Here the mask doesn't work, so don't use it and make sure all the markers are removed
          ;
          If CurrentLineLevel = FoldLevel And CurrentLineLevel > #SC_FOLDLEVELBASE
            ; Special case: Fold start mark with no content inside of another fold. Add a normal | line
            ScintillaSendMessage(Gadget, #SCI_MARKERADD, line, #MARKER_FoldVLine)
          Else
            ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVLine)
          EndIf
          ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldVCorner)
          ScintillaSendMessage(Gadget, #SCI_MARKERDELETE, line, #MARKER_FoldTCorner)
          
        EndIf
        
        ; When removing a fold mark of a folded line, all sublines are no longer viewable.
        ; To prevent this on folding updates, this command checks the folding structure
        ; and shows such lines.
        ;
        ; only check if the line is currently hidden
        If ScintillaSendMessage(Gadget, #SCI_GETLINEVISIBLE, line, 0) = 0
          ; If there is no parent, we must show the line
          ; If the parent is visible and unfolded, we must show it as well
          ;
          parentline = ScintillaSendMessage(Gadget, #SCI_GETFOLDPARENT, line, 0)
          If parentline = -1 Or (ScintillaSendMessage(Gadget, #SCI_GETLINEVISIBLE, parentline, 0) And ScintillaSendMessage(Gadget, #SCI_GETFOLDEXPANDED, parentline, 0))
            ScintillaSendMessage(Gadget, #SCI_SHOWLINES, line, line)
          EndIf
        EndIf
        
        ; If we passed the 'lastline', and the folding level does not change anymore,
        ; we can stop the update as the following lines should not change anymore as well
        ; this gains a lot of speed on large sources
        ;
        ; Note that we have to check the level of the next line as 'FoldLevel' always affects the following line!
        ; Note: just checking until we reach the base level is not enough, as there may be further change required
        If line > lastline+1 And ScintillaSendMessage(Gadget, #SCI_GETFOLDLEVEL, line+1, 0) & (~#SC_FOLDLEVELHEADERFLAG) = FoldLevel
          Break
        EndIf
        
      Next line
      
      ; there seems to be a refresh bug here sometimes, so force it
      If NeedRefresh
        RedrawGadget(Gadget)
      EndIf
      
    EndIf
    
    
  EndProcedure
  
  
  Procedure StreamTextIn(*Buffer, Length)
    NoUserChange = 1
    SendEditorMessage(#SCI_CLEARALL, 0, 0) ; should completely erase the old document and create a new one
    SendEditorMessage(#SCI_SETTEXT, 0, *Buffer)
    SendEditorMessage(#SCI_EMPTYUNDOBUFFER, 0, 0) ; so this loading cannot be undone
    NoUserChange = 0
  EndProcedure
  
  Procedure StreamTextOut(*Buffer, Length)  ; length is always equal to the full source size
    NoUserChange = 1
    SendEditorMessage(#SCI_GETTEXT, Length+1, *Buffer) ; #SCI_GETTEXT returns length-1 bytes... very inconsistent of scintilla
    NoUserChange = 0
  EndProcedure
  
  Procedure GetSourceLength()
    ProcedureReturn SendEditorMessage(#SCI_GETLENGTH, 0, 0)
  EndProcedure
  
  
  Procedure RefreshEditorGadget()
  EndProcedure
  
  
  Procedure ChangeActiveLine(Line, TopOffset)  ; Line is 1 based
                                               ; *ActiveSource\CurrentLineOld = 0 ; do not scan procedurelist again!
    SendEditorMessage(#SCI_LINESCROLL, -99999, -99999)
    SendEditorMessage(#SCI_ENSUREVISIBLE, Line-1, 0) ; Ensure the block is unfolded, if it was folded. Needs to be before #SCI_GOTOLINE (https://www.purebasic.fr/english/viewtopic.php?f=4&t=44871)
    SendEditorMessage(#SCI_LINESCROLL, 0, Line+TopOffset)
    SendEditorMessage(#SCI_GOTOLINE, Line-1, 0)
    SetActiveGadget(*ActiveSource\EditorGadget)
    SendEditorMessage(#SCI_GRABFOCUS, 0, 0)
  EndProcedure
  
  
  Procedure SetBackgroundColor(Gadget = -1)
    If Gadget = -1
      Gadget = *ActiveSource\EditorGadget
    EndIf
    
    If EnableColoring
      If ScintillaSendMessage(Gadget, #SCI_GETREADONLY, 0, 0)
        Color = Colors(#COLOR_DisabledBack)\DisplayValue
        If Colors(#COLOR_DisabledBack)\DisplayValue <> Colors(#COLOR_GlobalBackground)\DisplayValue
          ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #MARKER_ProcedureBack, #SC_MARK_EMPTY) ; disable special procedure background color
        EndIf
        
      ElseIf Gadget <> *ActiveSource\EditorGadget Or *ActiveSource\IsCode
        Color = Colors(#COLOR_GlobalBackground)\DisplayValue
        
        If Colors(#COLOR_ProcedureBack)\Enabled <> 0 Or Colors(#COLOR_ProcedureBack)\DisplayValue <> Colors(#COLOR_GlobalBackground)\DisplayValue
          ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #MARKER_ProcedureBack, #SC_MARK_BACKGROUND)
        EndIf
        
      Else
        Color = Colors(#COLOR_PlainBackground)\DisplayValue
        
      EndIf
    Else
      Color = $FFFFFF
    EndIf
    
    ; Apply the change to all styles, for the background change to disabled mode
    ; (which does not setup all coloring again!)
    ;
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, Color)
    For i = 1 To 16
      ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, i, Color)
    Next i
    
  EndProcedure
  
  Procedure SetLineNumberColor()
  EndProcedure
  
  Procedure RemoveAllColoring()
    
    SendEditorMessage(#SCI_STYLECLEARALL, 0, 0)
    
  EndProcedure
  
  
  Procedure SetSourceModified(Modified)
    If *ActiveSource ; Fix a weird crash on OS X
      If Modified
        *ActiveSource\ScintillaModified = 1
      Else
        *ActiveSource\ScintillaModified = 0
        SendEditorMessage(#SCI_SETSAVEPOINT, 0, 0)
      EndIf
    EndIf
  EndProcedure
  
  
  Procedure GetSourceModified(*Source.SourceFile = 0) ; sometimes called when ActiveSource=0 on linux !?
    If *Source = 0
      *Source = *ActiveSource
    EndIf
    
    ; if the file was deleted on disk while open in the IDE, report it as edited as well
    If *Source And (*Source\ScintillaModified Or ScintillaSendMessage(*Source\EditorGadget, #SCI_GETMODIFY, 0, 0))
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure GetFirstVisibleLine()
    ProcedureReturn SendEditorMessage(#SCI_GETFIRSTVISIBLELINE, 0, 0)
  EndProcedure
  
  Procedure GetLinesCount(*Source.SourceFile)
    ProcedureReturn ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINECOUNT, 0, 0)
  EndProcedure
  
  Procedure GetCursorPosition()
    Position = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
    *ActiveSource\CurrentLine = SendEditorMessage(#SCI_LINEFROMPOSITION, Position, 0) + 1
    
    LineStart = SendEditorMessage(#SCI_POSITIONFROMLINE, *ActiveSource\CurrentLine-1, 0)
    *ActiveSource\CurrentColumnBytes = Position - LineStart + 1
    *ActiveSource\CurrentColumnChars = CountCharacters(*ActiveSource\EditorGadget, LineStart, Position) + 1
    *ActiveSource\CurrentColumnDisplay = SendEditorMessage(#SCI_GETCOLUMN, Position, 0) + 1
  EndProcedure
  
  
  Procedure GetSelection(*LineStart.INTEGER, *RowStart.INTEGER, *LineEnd.INTEGER, *RowEnd.INTEGER)
    
    StartPosition = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
    EndPosition   = SendEditorMessage(#SCI_GETSELECTIONEND, 0, 0)
    
    LineStart = SendEditorMessage(#SCI_LINEFROMPOSITION, StartPosition, 0)
    LineEnd   = SendEditorMessage(#SCI_LINEFROMPOSITION, EndPosition, 0)
    RowStart  = CountCharacters(*ActiveSource\EditorGadget, SendEditorMessage(#SCI_POSITIONFROMLINE, LineStart, 0), StartPosition)
    RowEnd    = CountCharacters(*ActiveSource\EditorGadget, SendEditorMessage(#SCI_POSITIONFROMLINE, LineEnd, 0), EndPosition)
    
    If *LineStart: *LineStart\i = LineStart + 1: EndIf
    If *RowStart : *Rowstart\i  = RowStart  + 1: EndIf
    If *LineEnd  : *LineEnd\i   = LineEnd   + 1: EndIf
    If *RowEnd   : *RowEnd\i    = RowEnd    + 1: EndIf
    
  EndProcedure
  
  
  Procedure SetSelection(LineStart, RowStart, LineEnd, RowEnd)
    
    FlushEvents() ; some event causes this to not work! (dirty hack)
    
    StartPosition = SendEditorMessage(#SCI_POSITIONRELATIVE, SendEditorMessage(#SCI_POSITIONFROMLINE, LineStart-1, 0), RowStart - 1)
    
    If LineEnd = -1
      LineEnd = SendEditorMessage(#SCI_GETLINECOUNT, 0, 0)
    EndIf
    LineEnd-1
    
    EndPosition = SendEditorMessage(#SCI_POSITIONFROMLINE, LineEnd, 0)
    
    If RowEnd = -1
      If LineEnd = SendEditorMessage(#SCI_GETLINECOUNT, 0, 0) - 1  ; the last line has no newline
        EndPosition = SendEditorMessage(#SCI_GETLENGTH, 0, 0)
      Else
        EndPosition + SendEditorMessage(#SCI_LINELENGTH, LineEnd, 0) - 1
      EndIf
    Else
      EndPosition = SendEditorMessage(#SCI_POSITIONRELATIVE, EndPosition, RowEnd - 1)
    EndIf
    
    SendEditorMessage(#SCI_SETSEL, StartPosition, EndPosition)
    
    UpdateCursorPosition()
  EndProcedure
  
  
  Procedure.s GetLine(Index, *Source.SourceFile = 0)
    If *Source = 0
      *Source = *ActiveSource
    EndIf
    
    range.TextRange\chrg\cpMin = ScintillaSendMessage(*Source\EditorGadget, #SCI_POSITIONFROMLINE, Index, 0)
    range\chrg\cpMax           = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINEENDPOSITION, Index, 0)
    
    If range\chrg\cpMax > range\chrg\cpMin
      range\lpstrText = AllocateMemory(range\chrg\cpMax-range\chrg\cpMin+1)
      
      If range\lpstrText
        length = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXTRANGE, 0, @range)
        
        If *ActiveSource\Parser\Encoding = 1
          Line$ = PeekS(range\lpstrText, length, #PB_UTF8|#PB_ByteLength)
        Else
          Line$ = PeekS(range\lpstrText, length, #PB_Ascii)
        EndIf
        
        FreeMemory(range\lpstrText)
      EndIf
    EndIf
    
    ProcedureReturn Line$
  EndProcedure
  
  ; return true if Index line ends with a continuation
  Procedure HasLineContinuation(Index, *Source.SourceFile = 0)
    If (*Source And *Source\IsCode = 0) Or (*Source = 0 And *ActiveSource\IsCode = 0)
      ProcedureReturn #False ; non-pb file
    EndIf
    Line$ = GetLine(Index, *Source)
    ProcedureReturn IsContinuedLineStart(Line$)
  EndProcedure
  
  ; Get line with index, including any continued lines before or after
  ; *Offset\i will be filled with the char of set of the requested line in the returned string
  ; (will be > 0 if the requested line is a continuation of the line before it)
  ;
  ; Note: To return the exact multiline content (including the correct newline chars) from
  ;   the source, don't just call GetLine() and append the lines, but calculate the position
  ;   of the first and last line and get it as one buffer
  ;
  Procedure.s GetContinuationLine(Index, *Offset.INTEGER = 0, *Source.SourceFile = 0)
    If *Source = 0
      *Source = *ActiveSource
    EndIf
    
    ; non-pb files have no continuations
    If *Source\IsCode = 0
      If *Offset: *Offset\i = 0: EndIf
      ProcedureReturn GetLine(Index, *Source)
    EndIf
    
    ; add any preceding lines
    FirstLine = Index
    While FirstLine > 0 And HasLineContinuation(FirstLine-1, *Source)
      FirstLine - 1
    Wend
    
    ; add any following lines
    LineCount = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINECOUNT, 0, 0)
    LastLine = Index
    While LastLine < LineCount-1 And HasLineContinuation(LastLine, *Source)
      LastLine + 1
    Wend
    
    ; get the content
    range.TextRange\chrg\cpMin = ScintillaSendMessage(*Source\EditorGadget, #SCI_POSITIONFROMLINE, FirstLine, 0)
    range\chrg\cpMax           = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINEENDPOSITION, LastLine, 0)
    
    If range\chrg\cpMax > range\chrg\cpMin
      range\lpstrText = AllocateMemory(range\chrg\cpMax-range\chrg\cpMin+1)
      
      If range\lpstrText
        length = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXTRANGE, 0, @range)
        
        If *Source\Parser\Encoding = 1
          Line$ = PeekS(range\lpstrText, length, #PB_UTF8)
        Else
          Line$ = PeekS(range\lpstrText, length, #PB_Ascii)
        EndIf
        
        FreeMemory(range\lpstrText)
      EndIf
    EndIf
    
    ; fill start offset (if requested)
    If *Offset
      *Offset\i = CountCharacters(*Source\EditorGadget, range\chrg\cpMin, ScintillaSendMessage(*Source\EditorGadget, #SCI_POSITIONFROMLINE, Index, 0))
    EndIf
    
    ;  Debug "[GetContinuationLine] " + Line$
    ;  Debug "[GetContinuationLine] " + Str(*Offset\i)
    
    ProcedureReturn Line$
  EndProcedure
  
  Procedure SetLine(Index, NewLine$)
    
    SendEditorMessage(#SCI_SETTARGETSTART, SendEditorMessage(#SCI_POSITIONFROMLINE, Index, 0), 0)
    SendEditorMessage(#SCI_SETTARGETEND, SendEditorMessage(#SCI_GETLINEENDPOSITION, Index, 0), 0)
    
    If *ActiveSource\Parser\Encoding = 1 ; ugly hack.. to be changed for unicode compatibility
      *NewLine = UTF8(NewLine$)
    Else
      *NewLine = Ascii(NewLine$)
    EndIf
    
    SendEditorMessage(#SCI_REPLACETARGET, -1, *NewLine)
    
    FreeMemory(*NewLine)
  EndProcedure
  
  Procedure BuildIndentVT()
    
    SortStructuredArray(IndentKeywords(), #PB_Sort_NoCase|#PB_Sort_Ascending, OffsetOf(IndentEntry\Keyword$), #PB_String, 0, NbIndentKeywords-1)
    For i = 0 To 255
      IndentKeywordVT(i) = -1
    Next i
    
    old = 0
    For i = 0 To NbIndentKeywords-1
      ; update length field
      IndentKeywords(i)\Length = Len(IndentKeywords(i)\Keyword$)
      
      new = Asc(UCase(Left(IndentKeywords(i)\Keyword$, 1)))
      If new <> old
        IndentKeywordVT(new) = i
        old = new
      EndIf
    Next i
    
    ; Set the index for the small letters to the same as the ucase one,
    ; as our sort is case insensitive (so we can save one ucase on the check later)
    ;
    For i = 'A' To 'Z'
      IndentKeywordVT(i-'A'+'a') = IndentKeywordVT(i)
    Next i
    
  EndProcedure
  
  ; Cursor must point to a 0-terminated string!
  ; returns keyword index or -1
  ;
  Procedure IsIndentKeyword(*Cursor.Character)
    c = IndentKeywordVT(*Cursor\c)
    If c <> -1
      Repeat
        r = CompareMemoryString(*Cursor, @IndentKeywords(c)\Keyword$, #PB_String_NoCaseAscii, IndentKeywords(c)\Length)
        If r = #PB_String_Equal And ValidCharacters(PeekC(*Cursor + IndentKeywords(c)\Length * #CharSize)) = 0
          ProcedureReturn c
        Else
          c + 1
        EndIf
      Until r = #PB_String_Lower Or c >= NbIndentKeywords
    EndIf
    
    ProcedureReturn -1
  EndProcedure
  
  Procedure GetIndentBalance(*Cursor.Character, *Before.INTEGER, *After.INTEGER)
    *Before\i = 0
    *After\i = 0
    
    ; First skip whitespace
    While *Cursor\c = ' ' Or *Cursor\c = 9
      *Cursor + SizeOf(Character)
    Wend
    
    ; Check for direct ASM/JS lines
    If *Cursor\c = '!'
      ProcedureReturn 0 ; ignore this line for indent purposes
    EndIf
    
    
    While *Cursor\c
      ; Keyword check first, so something like ";>>" could be an indent keyword
      ;
      c = IsIndentKeyword(*Cursor)
      If c = -1
        
        ; Skip things like strings, comments, constants
        Select *Cursor\c
            
          Case '"'
            Repeat
              *Cursor + SizeOf(Character)
            Until *Cursor\c = 0 Or *Cursor\c = '"'
            If *Cursor\c
              *Cursor + SizeOf(Character)
            EndIf
            
          Case '~'
            *Cursor + SizeOf(Character)
            If *Cursor\c = '"'
              *Cursor + SizeOf(Character)
              While *Cursor\c And *Cursor\c <> '"'
                If *Cursor\c = '\' And PeekC(*Cursor + SizeOf(Character)) <> 0
                  *Cursor + (2 * SizeOf(Character))
                Else
                  *Cursor + SizeOf(Character)
                EndIf
              Wend
            EndIf
            If *Cursor\c
              *Cursor + SizeOf(Character)
            EndIf
            
          Case 39 ; '
            Repeat
              *Cursor + SizeOf(Character)
            Until *Cursor\c = 0 Or *Cursor\c = 39
            If *Cursor\c
              *Cursor + SizeOf(Character)
            EndIf
            
          Case '#'
            *Cursor + SizeOf(Character)
            While ValidCharacters(*Cursor\c)
              *Cursor + SizeOf(Character)
            Wend
            
          Case '\', '*'
            ; don't detect structure member or variables starting with * as indent keywords!
            ; (do so while skipping whitespace between \ and the word)
            *Cursor + SizeOf(Character)
            While *Cursor\c = ' ' Or *Cursor\c = 9
              *Cursor + SizeOf(Character)
            Wend
            While ValidCharacters(*Cursor\c)
              *Cursor + SizeOf(Character)
            Wend
            
          Case ';'
            ; break the search
            Break
            
          Default
            ; skip the entire word, to not detect a word at the end of another
            If ValidCharacters(*Cursor\c)
              While ValidCharacters(*Cursor\c)
                *Cursor + SizeOf(Character)
              Wend
            Else
              *Cursor + SizeOf(Character)
            EndIf
            
        EndSelect
        
      Else
        
        *Before\i + IndentKeywords(c)\Before
        If *After\i And *Before\i  ; If this is not the first keyword on this line, any before 'indent' of this keyword cancels out a previous 'after'
          *After\i + *Before\i
          *Before\i = 0
        EndIf
        *After\i  + IndentKeywords(c)\After
        
        *Cursor   + IndentKeywords(c)\Length * SizeOf(Character)
        
      EndIf
    Wend
    
  EndProcedure
  
  Procedure.s GetIndentPrefix(Line$)
    Length = 0
    *Cursor.Character = @Line$
    
    While *Cursor\c = 9 Or *Cursor\c = ' '
      Length + 1
      *Cursor + SizeOf(Character)
    Wend
    
    ProcedureReturn Left(Line$, Length)
  EndProcedure
  
  ; From one or more previous lines that end in a continuation, calculate
  ; the proper indent prefix for the following line
  ;
  ; for a good value, look at the expression that ends in the continuation
  ; and get the first token from that expression.
  ;
  ; Note that the only line separation here is always a single chr(10) (unix style)
  ;
  ; Example:
  ; a$ = foo(a, (b +
  ;              1),
  ;          c)
  ;
  Procedure.s GetIndentContinuationPrefix(Previous$)
    ; Use this for a simple "block mode" indentation
    If UseTabIndentForSplittedLines
      If RealTab
        ProcedureReturn GetIndentPrefix(Previous$) + #TAB$
      Else
        ProcedureReturn GetIndentPrefix(Previous$) + Space(TabLength)
      EndIf
    EndIf
    
    ; the code below assumes a non-empty string
    If Previous$ = ""
      ProcedureReturn ""
    EndIf
    
    ; first block out any comments, as they cannot be read
    ; backward. further, replace and Strings or char constants
    ; by 'a' to mark them as a token so we can later ignore them
    *Cursor.Character = @Previous$
    Repeat
      Select *Cursor\c
          
        Case 0
          Break
          
        Case '"'
          *Cursor\c = 'a'
          *Cursor + #CharSize
          While *Cursor\c And *Cursor\c <> '"' And *Cursor\c <> 10
            *Cursor\c = 'a'
            *Cursor + #CharSize
          Wend
          If *Cursor\c = '"'
            *Cursor\c = 'a'
            *Cursor + #CharSize
          EndIf
          
        Case '~'
          If PeekC(*Cursor + #CharSize) = '"'
            *Cursor\c = 'a'
            *Cursor + #CharSize
            *Cursor\c = 'a'
            *Cursor + #CharSize
            While *Cursor\c And *Cursor\c <> '"' And *Cursor\c <> 10
              If *Cursor\c = '\' And PeekC(*Cursor + #CharSize) <> 0 And PeekC(*Cursor + #CharSize) <> 10
                *Cursor\c = 'a'
                *Cursor + #CharSize
                *Cursor\c = 'a'
                *Cursor + #CharSize
              Else
                *Cursor\c = 'a'
                *Cursor + #CharSize
              EndIf
            Wend
            If *Cursor\c = '"'
              *Cursor\c = 'a'
              *Cursor + #CharSize
            EndIf
          Else
            *Cursor + #CharSize
          EndIf
          
        Case 39
          *Cursor\c = 'a'
          *Cursor + #CharSize
          While *Cursor\c And *Cursor\c <> 39 And *Cursor\c <> 10
            *Cursor\c = 'a'
            *Cursor + #CharSize
          Wend
          If *Cursor\c = 39
            *Cursor\c = 'a'
            *Cursor + #CharSize
          EndIf
          
        Case ';'
          While *Cursor\c And *Cursor\c <> 10
            *Cursor\c = ' '
            *Cursor + #CharSize
          Wend
          
        Default
          *Cursor + #CharSize
          
      EndSelect
    ForEver
    
    ; now scan backwards
    *Cursor = @Previous$ + (Len(Previous$) - 1) * #CharSize
    *Start = @Previous$
    
    ; skip whitespace
    While *Cursor > *Start And (*Cursor\c = ' ' Or *Cursor\c = 9)
      *Cursor - #CharSize
    Wend
    
    ; check the continuation token. we need to know the kind:
    ; 0: ,
    ; 1: + |
    ; 2: And Or XOr
    If *Cursor\c = ','
      Token = 0
    ElseIf *Cursor\c = '+' Or *Cursor\c = '|'
      Token = 1
    Else
      Token = 2
    EndIf
    
    ; skip token
    If ValidCharacters(*Cursor\c)
      ; a logical operator
      While *Cursor > *Start And ValidCharacters(*Cursor\c)
        *Cursor - #CharSize
      Wend
    Else
      ; | or +
      *Cursor - #CharSize
    EndIf
    
    ; parse backwards until the beginning of the expression that is cut in half
    ; track braced expressions properly
    Braces = 0
    *ExpressionStart.PTR = 0
    
    While *Cursor > *Start
      
      ; skip space
      While *Cursor > *Start And (*Cursor\c = ' ' Or *Cursor\c = 9)
        *Cursor - #CharSize
      Wend
      
      ; check token
      Select *Cursor\c
          
        Case ')', ']', '}'
          Braces + 1
          *Cursor - #CharSize
          
        Case '(', '[', '{'
          If Braces = 0
            *ExpressionStart = *Cursor + #CharSize
            Break ; beginning of the expression
          EndIf
          Braces - 1
          *Cursor - #CharSize
          
        Case ','
          If Braces = 0 And Token <> 0
            *ExpressionStart = *Cursor + #CharSize
            Break ; beginning of the expression
          EndIf
          *Cursor - #CharSize
          
        Case ':'
          If *Cursor > *Start And PeekC(*Cursor - #CharSize) = ':'
            ; a module separator. keep going beyond this
            *Cursor - #CharSize*2
          Else
            ; an expression separator. this is always the beginning of the expression
            *ExpressionStart = *Cursor + #CharSize
            Break
          EndIf
          
        Case '='
          If Braces = 0 And Token = 1
            *ExpressionStart = *Cursor + #CharSize
            Break ; for + or |, an '=' is considered the start
          EndIf
          *Cursor - #CharSize
          
        Case '+', '-', '*', '/', '|', '&', '!'
          If Braces = 0 And Token = 1
            ; keep on searching, but use this as a fallback, so in case of lines like
            ; 'a + b +' (no = in the line), the first '+' is used as the expression start
            *ExpressionStart = *Cursor + #CharSize
          EndIf
          *Cursor - #CharSize
          
        Default
          If ValidCharacters(*Cursor\c)
            ; a word. isolate it
            *WordEnd = *Cursor
            While *Cursor > *Start And ValidCharacters(*Cursor\c)
              *Cursor - #CharSize
            Wend
            *WordStart.PTR = *Cursor
            If ValidCharacters(*WordStart\c) = 0
              *WordStart + #CharSize
            EndIf
            
            ; check if the word is preceded by a '\' or a '.' or a '#' (then it is never a keyword)
            While *Cursor > *Start And (*Cursor\c = ' ' Or *Cursor\c = 9)
              *Cursor - #CharSize
            Wend
            
            If *Cursor\c <> '\' And *Cursor\c <> '.' And *Cursor\c <> '#' And *Cursor\c <> '*'
              ; identify the keyword
              Word$ = PeekS(*WordStart, (*WordEnd - *WordStart) / #CharSize + 1)
              Keyword = IsBasicKeyword(Word$)
              
              ; check if it is a keyword that begins an expression that can have a line continuation
              Select Keyword
                Case #KEYWORD_Align,
                     #KEYWORD_Break,
                     #KEYWORD_Debug,
                     #KEYWORD_Define,
                     #KEYWORD_Dim, ; in case of "Global Dim"
                     #KEYWORD_Case,
                     #KEYWORD_CompilerCase,
                     #KEYWORD_CompilerElseIf,
                     #KEYWORD_CompilerError,
                     #KEYWORD_CompilerIf,
                     #KEYWORD_CompilerWarning,
                     #KEYWORD_Debug,
                     #KEYWORD_DebugLevel,
                     #KEYWORD_ElseIf,
                     #KEYWORD_End,
                     #KEYWORD_Enumeration,
                     #KEYWORD_EnumerationBinary,
                     #KEYWORD_Global,
                     #KEYWORD_If,
                     #KEYWORD_Import,
                     #KEYWORD_ImportC,
                     #KEYWORD_IncludeBinary,
                     #KEYWORD_IncludeFile,
                     #KEYWORD_IncludePath,
                     #KEYWORD_NewList,
                     #KEYWORD_NewMap,
                     #KEYWORD_ProcedureReturn,
                     #KEYWORD_Protected,
                     #KEYWORD_Select,
                     #KEYWORD_Shared,
                     #KEYWORD_Static,
                     #KEYWORD_Step,
                     #KEYWORD_Threaded,
                     #KEYWORD_Until,
                     #KEYWORD_While,
                     #KEYWORD_XIncludeFile
                  *ExpressionStart = *WordEnd + #CharSize
                  Break
                  
                Case #KEYWORD_To
                  ; Special case. We want all these results to work:
                  ;
                  ;   Case 1 To 10,
                  ;        20 To 30
                  ;
                  ;   Case 1 To 10 +
                  ;             1
                  ;
                  ;   For i = 1 To 1 +
                  ;                1
                  ;
                  ; In one case we can't to ignore the "To" in the other case it is the stop keyword.
                  ; Fortunately, in one case, the token is "," and in the other it is "+" or "|" and there is
                  ; no overlap. So just check what continuation token we have to decide whether to ignore the To
                  ; or not.
                  ;
                  If Token <> 0
                    *ExpressionStart = *WordEnd + #CharSize
                    Break
                  EndIf
                  
                  
                Case #KEYWORD_Data
                  ; special case as it can be "Data$ or Data.i"
                  ; note that "Data.s{10}" is not allowed which makes this simpler
                  *ExpressionStart = *WordEnd + #CharSize
                  If *ExpressionStart\c = '$'
                    *ExpressionStart + #CharSize
                  Else
                    ; skip whitespace
                    While *ExpressionStart\c = ' ' Or *ExpressionStart\c = 9
                      *ExpressionStart + #CharSize
                    Wend
                    ; skip type
                    If *ExpressionStart\c = '.'
                      *ExpressionStart + #CharSize
                      While *ExpressionStart\c = ' ' Or *ExpressionStart\c = 9
                        *ExpressionStart + #CharSize
                      Wend
                      While ValidCharacters(*ExpressionStart\c)
                        *ExpressionStart + #CharSize
                      Wend
                    EndIf
                  EndIf
                  Break
                  
                  ; if not an expression start, just continue
              EndSelect
              
            Else
              *Cursor - #CharSize
            EndIf
          Else
            ; any other character
            *Cursor - #CharSize
          EndIf
          
      EndSelect
      
    Wend
    
    ; no start found
    If *ExpressionStart = 0
      ProcedureReturn ""
    EndIf
    
    ; skip any further whitespace until the first expression token
    While *ExpressionStart\c = ' ' Or *ExpressionStart\c = 9
      *ExpressionStart + #CharSize
    Wend
    
    ; if we ended here on a newline, it means the first expression token
    ; is actually on the next line
    ; after this we can not hit a newline again, because the line must have at least a continuation token
    If *ExpressionStart\c = 10
      *ExpressionStart + #CharSize
      
      ; skip more whitespace
      While *ExpressionStart\c = ' ' Or *ExpressionStart\c = 9
        *ExpressionStart + #CharSize
      Wend
    EndIf
    
    ; find the start of this line
    *LineStart.PTR = *ExpressionStart
    While *LineStart > *Start And *LineStart\c <> 10
      *LineStart - #CharSize
    Wend
    If *LineStart\c = 10
      *LineStart + #CharSize
    EndIf
    
    ; get the prefix
    Prefix$ = PeekS(*LineStart, (*ExpressionStart-*LineStart) / #CharSize)
    
    ; in the prefix, replace anything that is not whitespace with spaces
    *Cursor = @Prefix$
    While *Cursor\c
      If *Cursor\c <> 9
        *Cursor\c = ' '
      EndIf
      *Cursor + #CharSize
    Wend
    
    ; done
    ProcedureReturn Prefix$
  EndProcedure
  
  ; Get the position of the comment sign in the given line (character index, not tab position)
  ; If the line has no comment sign, then the result is -1
  Procedure GetCommentPosition(Line$)
    
    HasCode = 0
    *Cursor.Character = @Line$
    
    Repeat
      Select *Cursor\c
          
        Case 0
          ; no comment sign found
          ProcedureReturn -1
          
        Case ';'
          ProcedureReturn (*Cursor - @Line$) / #CharSize
          
        Case '!'
          If HasCode = 0
            ; it is an inline asm or JS line, so do not see ; as a comment anymore
            ProcedureReturn -1
          Else
            *Cursor + #CharSize
          EndIf
          
        Case '"'
          HasCode = 1
          *Cursor + #CharSize
          While *Cursor\c And *Cursor\c <> '"'
            *Cursor + #CharSize
          Wend
          If *Cursor\c = '"'
            *Cursor + #CharSize
          EndIf
          
        Case '~'
          HasCode = 1
          *Cursor + #CharSize
          If *Cursor\c = '"'
            *Cursor + #CharSize
            While *Cursor\c And *Cursor\c <> '"'
              If *Cursor\c = '\' And PeekC(*Cursor + #CharSize) <> 0
                *Cursor + (2 * #CharSize)
              Else
                *Cursor + #CharSize
              EndIf
            Wend
            If *Cursor\c = '"'
              *Cursor + #CharSize
            EndIf
          EndIf
          
        Case 39 ; ' char
          HasCode = 1
          *Cursor + #CharSize
          While *Cursor\c And *Cursor\c <> 39
            *Cursor + #CharSize
          Wend
          If *Cursor\c = 39
            *Cursor + #CharSize
          EndIf
          
        Case 9, ' '
          *Cursor + #CharSize
          
        Default
          HasCode = 1
          *Cursor + #CharSize
          
      EndSelect
    ForEver
    
  EndProcedure
  
  ; returns true if the line is only whitespace (maybe with a comment)
  Procedure IsWhitespaceOnly(Line$)
    
    ; cut comments
    Comment = GetCommentPosition(Line$)
    If Comment >= 0
      Line$ = Left(Line$, Comment)
    EndIf
    
    If RemoveString(RemoveString(Line$, " "), Chr(9)) = ""
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ; Count the columns that the string takes including real tab chars (starts at 0)
  Procedure CountColumns(String$)
    Position = 0
    *Cursor.Character = @String$
    
    While *Cursor\c
      If *Cursor\c = 9
        Position = (Position - (Position % TabLength)) + TabLength
      Else
        Position + 1
      EndIf
      *Cursor + #CharSize
    Wend
    
    ProcedureReturn Position
  EndProcedure
  
  
  ; If Line$ and Previous$ both have a comment inside and it is possible, line up the comment sign
  ; in Line$ with the one in Previous$. If not possible, return Line$ without modification
  Procedure.s AlignLineComments(Line$, Previous$)
    
    PreviousComment = GetCommentPosition(Previous$)
    LineComment     = GetCommentPosition(Line$)
    
    If PreviousComment < 0 Or LineComment < 0
      ; one does not have a comment
      ProcedureReturn Line$
    EndIf
    
    PreviousPrefix$ = Left(Previous$, PreviousComment)
    
    ; Cut from the Line$ prefix all trailing whitespace (in case the ; must be moved left)
    LinePrefix$ = Left(Line$, LineComment)
    While Right(LinePrefix$, 1) = " " Or Right(LinePrefix$, 1) = Chr(9)
      LinePrefix$ = Left(LinePrefix$, Len(LinePrefix$)-1)
    Wend
    
    PreviousColumns = CountColumns(PreviousPrefix$)
    LineColumns     = CountColumns(LinePrefix$)
    
    If LineColumns > PreviousColumns
      ; the Line$ has a longer non-whitespace prefix than Previous$, so we cannot move the ;
      ProcedureReturn Line$
    EndIf
    
    ; calculate the right whitespace to add
    If RealTab
      MaxTabColumn = PreviousColumns - (PreviousColumns % TabLength)
      Whitespace$ = ""
      While CountColumns(LinePrefix$ + Whitespace$) < MaxTabColumn
        Whitespace$ + Chr(9)
      Wend
      ; may still need to add some space after the last tab if it is not tab-aligned
      Whitespace$ + Space(PreviousColumns - CountColumns(LinePrefix$ + Whitespace$))
    Else
      Whitespace$ = Space(PreviousColumns - LineColumns)
    EndIf
    
    ProcedureReturn LinePrefix$ + Whitespace$ + Right(Line$, Len(Line$)-LineComment)
    
  EndProcedure
  
  
  Procedure UpdateIndent(FirstLine, LastLine)
    
    If *ActiveSource\IsCode = 0
      ProcedureReturn
    EndIf
    
    ; make sure the first line to update is not a continued line
    While FirstLine > 0 And HasLineContinuation(FirstLine-1)
      FirstLine - 1
    Wend
    
    ; do not move lastline, even if it has continuations, as this is the
    ; line that is being edited (in sensitive indentation mode), so moving the line below is wrong (next edited line)
    
    If FirstLine > 0
      ; Use the previous non-empty line as anchor for the balance and the prefix
      line = FirstLine - 1
      Line$ = GetLine(line)
      While line > 0 And IsWhitespaceOnly(Line$)
        line - 1
        Line$ = GetLine(line)
      Wend
      If line = 0 And IsWhitespaceOnly(Line$)
        Line$ = GetLine(FirstLine-1)  ; no non-empty line found, just use the previous line then
      Else
        Line$ = GetContinuationLine(line) ; make sure we have a line with all continuations for the prefix and balance
      EndIf
      
      Prefix$ = GetIndentPrefix(Line$)
      GetIndentBalance(@Line$, @BalanceBefore, @BalanceAfter)
      CommentAnchor$ = GetLine(FirstLine - 1)
    Else
      Prefix$ = ""
      CommentAnchor$ = ""
      BalanceBefore = 0
      BalanceAfter = 0
    EndIf
    
    Line = FirstLine
    While Line <= LastLine
      
      ; We don't want auto indent in an inline asm block as it's the not the same keywords
      If IsInsideASMBlock(Line)
        Line + 1
        Continue
      EndIf
      
      ; this is always a fresh line (not a continuated one)
      Line$ = GetLine(Line)
      *Cursor.Character = @Line$
      
      ; cut the old prefix
      While *Cursor\c = 9 Or *Cursor\c = ' '
        *Cursor + SizeOf(Character)
      Wend
      *LineStart.Character = *Cursor
      
      ; The new balance is the 'after' balance from the previous line + the 'before' from this one
      ; use the full one (including continuations) for the balance calc
      FullLine$ = GetContinuationLine(Line)
      Balance = BalanceAfter
      GetIndentBalance(@FullLine$, @BalanceBefore, @BalanceAfter)
      Balance + BalanceBefore
      
      ; Modify the Prefix$ according to the before balance for this line
      If Balance > 0
        If RealTab
          Prefix$ + RSet("", Balance, Chr(9))
        Else
          Prefix$ + Space(Balance * TabLength)
        EndIf
        
      Else
        ; we must cut away from the Prefix$ string, which could be a combination
        ; of tab and spaces if the user has a messy style :)
        PrefixLength = Len(Prefix$)
        While Prefix$ And Balance < 0
          If Right(Prefix$, 1) = Chr(9)
            Prefix$ = Left(Prefix$, PrefixLength-1)
            PrefixLength - 1
          Else
            ; Cut up to TabLength spaces, unless another Tab is reached
            Cut = 0
            While Cut < PrefixLength And Cut < TabLength And Mid(Prefix$, PrefixLength-Cut, 1) = " "
              Cut + 1
            Wend
            Prefix$ = Left(Prefix$, PrefixLength-Cut)
            PrefixLength - Cut
          EndIf
          Balance + 1
        Wend
        
      EndIf
      
      If *LineStart\c = 0
        
        ; Apply the line change (whitespace only line)
        SetLine(Line, Prefix$)
        CommentAnchor$ = ""
        
      Else
        
        ; Apply the line change and adjust comment position (if needed)
        CommentAnchor$ = AlignLineComments(Prefix$ + PeekS(*LineStart), CommentAnchor$)
        SetLine(Line, CommentAnchor$)
        
      EndIf
      
      ; now process any continuations of the line
      If Line < LastLine And IsContinuedLineStart(Line$)
        
        ; for a smart indentation, we must track all continued lines in this block
        Previous$ = Prefix$ + PeekS(*LineStart)
        Repeat
          Line + 1
          
          ; get prefix
          ContinuedPrefix$ = GetIndentContinuationPrefix(Previous$)
          
          ; get line and cut old prefix
          Line$ = GetLine(Line)
          *Cursor.Character = @Line$
          While *Cursor\c = 9 Or *Cursor\c = ' '
            *Cursor + SizeOf(Character)
          Wend
          
          ; update line and adjust comment position if needed
          CommentAnchor$ = AlignLineComments(ContinuedPrefix$ + PeekS(*Cursor), CommentAnchor$)
          SetLine(Line, CommentAnchor$)
          Previous$ + Chr(10) + ContinuedPrefix$ + PeekS(*Cursor)
        Until Line = LastLine Or IsContinuedLineStart(Line$) = 0
        
      EndIf
      
      ; on to next line
      Line + 1
    Wend
    
  EndProcedure
  
  
  Procedure UpdateBraceHighlight(Cursor, SecondTry=#False)
    
    If EnableBraceMatch And (Colors(#COLOR_GoodBrace)\Enabled Or Colors(#COLOR_BadBrace)\Enabled) And *ActiveSource\IsCode
      
      Line      = SendEditorMessage(#SCI_LINEFROMPOSITION, Cursor, 0)
      LineStart = SendEditorMessage(#SCI_POSITIONFROMLINE, line, 0)
      
      If Cursor > LineStart ; we want to highlight the brace before, not after the cursor!
        Cursor-1
      EndIf
      
      ;
      ; Note: the automatic SCI_BRACEMATCH does not handle '' or ; correctly, also
      ;       it returns ( [ ) as correct, which it is not, so do our own search
      ;
      char = SendEditorMessage(#SCI_GETCHARAT, Cursor, 0)
      
      ; check first that we have a brace that is outside of string/comment
      If (char = '(' Or char = ')' Or char = '[' Or char = ']' Or char = '{' Or char = '}') And CheckStringComment(Cursor) = 0
        
        ; include any line continuation in the search
        Line$ = GetContinuationLine(Line, @StartOffset)
        LineStart = SendEditorMessage(#SCI_POSITIONRELATIVE, LineStart, -StartOffset)
        
        ClearList(BraceStack())
        AddElement(BraceStack())
        BraceStack() = char
        goodbrace = 0
        bracepos  = Cursor ; position of the other brace
        
        ; search in the needed direction
        If char = '(' Or char = '[' Or char = '{' ; forward
          *Cursor.Character = @Line$ + (CountCharacters(*ActiveSource\EditorGadget, LineStart, Cursor)+1) * #CharSize
          
          While *Cursor\c
            
            If *Cursor\c = '"' ; we found a string
              Repeat
                *Cursor + SizeOf(Character)
              Until *Cursor\c = 0 Or *Cursor\c = '"'
              
            ElseIf *Cursor\c = '~' And PeekC(*Cursor + #CharSize) = '"'
              *Cursor + (2 * #CharSize)
              While *Cursor\c And *Cursor\c <> '"'
                If *Cursor\c = '\' And PeekC(*Cursor + #CharSize) <> 0
                  *Cursor + 2*SizeOf(Character)
                Else
                  *Cursor + SizeOf(Character)
                EndIf
              Wend
              
            ElseIf *Cursor\c = 39 ; ' string
              Repeat
                *Cursor + SizeOf(Character)
              Until *Cursor\c = 0 Or *Cursor\c = 39
              
            ElseIf *Cursor\c = ';' ; comment
                                   ; skip the comment but continue in case of a line continuation
              While *Cursor\c And *Cursor\c <> 10 And *Cursor\c <> 13
                *Cursor + #CharSize
              Wend
              
            ElseIf *Cursor\c = '(' Or *Cursor\c = '[' Or *Cursor\c = '{'
              AddElement(BraceStack())
              BraceStack() = *Cursor\c
              
            ElseIf (*Cursor\c = ')' And BraceStack() = '(') Or (*Cursor\c = ']' And BraceStack() = '[') Or (*Cursor\c = '}' And BraceStack() = '{')
              DeleteElement(BraceStack())
              If ListSize(BraceStack()) = 0 ; we found the matching brace
                bracepos = SendEditorMessage(#SCI_POSITIONRELATIVE, LineStart, (*Cursor - @Line$) / #CharSize)
                goodbrace = 1
                Break
              EndIf
              
            ElseIf *Cursor\c = ')' Or *Cursor\c = ']' Or *Cursor\c = '}'
              ; we found a mismatch here, so highlight both with BRACEGOOD, but change the color to indicate a mismatch
              bracepos = SendEditorMessage(#SCI_POSITIONRELATIVE, LineStart, (*Cursor - @Line$) / #CharSize)
              goodbrace = -1
              Break
              
            EndIf
            
            *Cursor + #CharSize
          Wend
          
        Else ; backward search
          *Cursor.Character = @Line$ + (CountCharacters(*ActiveSource\EditorGadget, LineStart, Cursor)-1) * #CharSize
          
          ; Note: Comments after a line continuation will mess up the backward search
          ; So first do a forward run to block out comments, strings and char constants
          *Forward.PTR = @Line$
          While *Forward < *Cursor
            If *Forward\c = '"'
              *Forward\c = ' ': *Forward +  #CharSize
              While *Forward\c And *Forward\c <> '"'
                *Forward\c = ' ': *Forward + #CharSize
              Wend
              If *Forward\c
                *Forward\c = ' ': *Forward +  #CharSize
              EndIf
              
            ElseIf *Forward\c = '~' And *Forward\c[1] = '"'
              *Forward\c = ' ': *Forward +  #CharSize
              *Forward\c = ' ': *Forward +  #CharSize
              While *Forward\c And *Forward\c <> '"'
                If *Forward\c = '\' And *Forward\c[1] <> 0
                  *Forward\c = ' ': *Forward + #CharSize
                  *Forward\c = ' ': *Forward + #CharSize
                Else
                  *Forward\c = ' ': *Forward + #CharSize
                EndIf
              Wend
              If *Forward\c
                *Forward\c = ' ': *Forward +  #CharSize
              EndIf
              
            ElseIf *Forward\c = 39
              *Forward + #CharSize
              While *Forward\c And *Forward\c <> 39
                *Forward\c = ' ': *Forward + #CharSize
              Wend
              If *Forward\c
                *Forward + #CharSize
              EndIf
              
            ElseIf *Forward\c = ';'
              While *Forward\c And *Forward\c <> 10 And *Forward\c <> 13
                *Forward\c = ' ': *Forward + #CharSize
              Wend
              
            Else
              *Forward + #CharSize
            EndIf
          Wend
          
          ; no more need to check string or comment now
          While *Cursor >= @Line$
            
            If *Cursor\c = ')' Or *Cursor\c = ']' Or *Cursor\c = '}'
              AddElement(BraceStack())
              BraceStack() = *Cursor\c
              
            ElseIf (*Cursor\c = '(' And BraceStack() = ')') Or (*Cursor\c = '[' And BraceStack() = ']') Or (*Cursor\c = '{' And BraceStack() = '}')
              DeleteElement(BraceStack())
              If ListSize(BraceStack()) = 0 ; we found the matching brace
                bracepos = SendEditorMessage(#SCI_POSITIONRELATIVE, LineStart, (*Cursor - @Line$) / #CharSize)
                goodbrace = 1
                Break
              EndIf
              
            ElseIf *Cursor\c = '(' Or *Cursor\c = '[' Or *Cursor\c = '{'
              ; we found a mismatch here, so highlight both with BRACEGOOD, but change the color to indicate a mismatch
              bracepos = SendEditorMessage(#SCI_POSITIONRELATIVE, LineStart, (*Cursor - @Line$) / #CharSize)
              goodbrace = -1
              Break
              
            EndIf
            
            *Cursor - #CharSize
          Wend
          
        EndIf
        
        ; Note: the bad brace highlighting is only capable of marking one brace, but if we
        ; find 2 mismatching braces (ie "[ ... )") we use the "good brace" mark but change the
        ; color so it indicates the right thing:
        ;
        If goodbrace = 1
          ; highlight 2 braces in good color
          SendEditorMessage(#SCI_STYLESETFORE, #STYLE_BRACELIGHT, Colors(#COLOR_GoodBrace)\DisplayValue)
          SendEditorMessage(#SCI_BRACEHIGHLIGHT, Cursor, bracepos)
        ElseIf goodbrace = -1
          ; highlight 2 braces in bad color
          SendEditorMessage(#SCI_STYLESETFORE, #STYLE_BRACELIGHT, Colors(#COLOR_BadBrace)\DisplayValue)
          SendEditorMessage(#SCI_BRACEHIGHLIGHT, Cursor, bracepos)
        Else
          ; highlight one brace as bad (no color change)
          SendEditorMessage(#SCI_BRACEBADLIGHT, bracepos, 0)
        EndIf
        
      ElseIf SecondTry = #False And char <> 10 And char <> 13
        ; Try again with the character following the cursor if there was no brace before
        ; The Cursor+2 is because we subtract 1 again inside the call
        UpdateBraceHighlight(Cursor+2, #True)
        
      Else
        ; remove all brace highlighting
        SendEditorMessage(#SCI_BRACEBADLIGHT, -1, 0)
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  
  Procedure UpdateKeywordHighlight(selStart, SetHighlight)
    Static NewList Items.SourceItemPair() ; static to avoid re-creation on every call
    
    ; Clear any old highlight
    ;
    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
    SendEditorMessage(#SCI_INDICATORCLEARRANGE, 0, SendEditorMessage(#SCI_GETTEXTLENGTH))
    
    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMismatch)
    SendEditorMessage(#SCI_INDICATORCLEARRANGE, 0, SendEditorMessage(#SCI_GETTEXTLENGTH))
    
    SendEditorMessage(#SCI_SETHIGHLIGHTGUIDE, 0)
    
    ; Try to locate a matching keyword
    ;
    If EnableKeywordMatch And SetHighlight And *ActiveSource\IsCode And (Colors(#COLOR_GoodBrace)\Enabled Or Colors(#COLOR_BadBrace)\Enabled) And CheckStringComment(selStart) = 0
      Line$ = GetCurrentLine()
      
      If Line$
        If GetWordBoundary(@Line$, Len(Line$), *ActiveSource\CurrentColumnChars-1, @StartIndex, @EndIndex, 0) And EndIndex-StartIndex+1 > 0
          Word$   = PeekS(@Line$ + StartIndex * #CharSize, EndIndex - StartIndex + 1)
          Keyword = IsBasicKeyword(Word$)
          
          If Keyword
            OriginalLine = *ActiveSource\CurrentLine-1
            
            ; Re-scan the current line to ensure all scanned tokens are up to date
            ; (also update procedure browser etc if needed, as any changes are missed there else)
            If ScanLine(*ActiveSource, OriginalLine)
              UpdateFolding(*ActiveSource, OriginalLine, OriginalLine+2)
              
              ; defere other updates to a later time
              *ActiveSource\ParserDataChanged = #True
            EndIf
            
            ; find the SourceItem in that represents this keyword
            *OriginalItem.SourceItem = LocateSourceItem(@*ActiveSource\Parser, OriginalLine, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, StartIndex))
            If *OriginalItem And *OriginalItem\Type = #ITEM_Keyword
              IsMismatch = 0
              IsMatch    = 0
              
              *StartItem.SourceItem = *OriginalItem
              StartLine = OriginalLine
              
              If Keyword = #KEYWORD_ProcedureReturn
                If FindProcedureStart(@*ActiveSource\Parser, @StartLine, @*StartItem)
                  ; This is not the actual start keyword (the token is the procedure name here)
                  While *StartItem
                    If *StartItem\Type = #ITEM_Keyword And (*StartItem\Keyword = #KEYWORD_Procedure Or *StartItem\Keyword = #KEYWORD_ProcedureC Or *StartItem\Keyword = #KEYWORD_ProcedureDLL Or *StartItem\Keyword = #KEYWORD_ProcedureCDLL)
                      Break
                    EndIf
                    Parser_PreviousItem(*ActiveSource\Parser, *StartItem, StartLine)
                  Wend
                Else
                  *StartItem = 0
                EndIf
                
                If *StartItem
                  IsMatch = 1
                  If Colors(#COLOR_GoodBrace)\Enabled
                    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
                    SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, StartLine)+*StartItem\Position, *StartItem\Length)
                  EndIf
                Else
                  IsMismatch = 1
                  *StartItem = *OriginalItem ; reset to our original item (so we have no 0 pointer below)
                  StartLine  = OriginalLine
                EndIf
                
              ElseIf Keyword = #KEYWORD_Break Or Keyword = #KEYWORD_Continue
                If FindLoopStart(@*ActiveSource\Parser, @StartLine, @*StartItem)
                  IsMatch = 1
                  If Colors(#COLOR_GoodBrace)\Enabled
                    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
                    SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, StartLine)+*StartItem\Position, *StartItem\Length)
                  EndIf
                Else
                  IsMismatch = 1
                  *StartItem = *OriginalItem ; reset to our original item (so we have no 0 pointer below)
                  StartLine  = OriginalLine
                EndIf
              EndIf
              
              FirstMatchColumn = *StartItem\Position
              LastMatchColumn  = *StartItem\Position
              FirstMatchLine   = StartLine
              
              ; Search and mark all backward matches/mismatches
              *Item.SourceItem = *StartItem
              Line             = StartLine
              Repeat
                If MatchKeywordBackward(@*ActiveSource\Parser, @Line, @*Item)
                  If *Item
                    IsMatch = 1
                    If Colors(#COLOR_GoodBrace)\Enabled
                      SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
                      SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, Line)+*Item\Position, *Item\Length)
                    EndIf
                    FirstMatchColumn = *Item\Position
                    FirstMatchLine   = Line
                  Else
                    Break ; reached the end of the match chain
                  EndIf
                Else
                  If *Item And Colors(#COLOR_BadBrace)\Enabled
                    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMismatch)
                    SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, Line)+*Item\Position, *Item\Length)
                  EndIf
                  
                  IsMismatch = 1 ; always break here
                  Break
                EndIf
              ForEver
              
              ; Search and mark all forward matches/mismatches
              *Item.SourceItem = *StartItem
              Line             = StartLine
              Repeat
                If MatchKeywordForward(@*ActiveSource\Parser, @Line, @*Item)
                  If *Item
                    IsMatch = 1
                    If Colors(#COLOR_GoodBrace)\Enabled
                      SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
                      SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, Line)+*Item\Position, *Item\Length)
                    EndIf
                    LastMatchColumn = *Item\Position
                  Else
                    Break ; reached the end of the match chain
                  EndIf
                Else
                  If *Item And Colors(#COLOR_BadBrace)\Enabled
                    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMismatch)
                    SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, Line)+*Item\Position, *Item\Length)
                  EndIf
                  
                  IsMismatch = 1 ; always break here
                  Break
                EndIf
              ForEver
              
              ; Check for Break, Continue, ProcedureReturn keywords to mark
              ; We can pass anything here
              If FindBreakKeywords(@*ActiveSource\Parser, *StartItem, StartLine, Items())
                If Colors(#COLOR_GoodBrace)\Enabled
                  ForEach Items()
                    If Items()\Item <> *OriginalItem
                      SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
                      SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, Items()\Line)+Items()\Item\Position, Items()\Item\Length)
                    EndIf
                  Next Items()
                EndIf
                
                IsMatch = 1
                ClearList(Items())
              EndIf
              
              ; Mark the original item
              If IsMatch
                If Colors(#COLOR_GoodBrace)\Enabled
                  SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMatch)
                  SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, OriginalLine)+StartIndex, EndIndex-StartIndex+1)
                  
                  ; Unfortunately, this does not seem to work. Would have been cool to highlight the matching indent guide,
                  ; but it just never changes the color. Dunno what to do about it.
                  ;                 If ShowIndentGuides And FirstMatchColumn = LastMatchColumn
                  ;                   SendEditorMessage(#SCI_STYLESETFORE, #STYLE_BRACELIGHT, Colors(#COLOR_GoodBrace)\DisplayValue)
                  ;                   Column = SendEditorMessage(#SCI_GETCOLUMN, SendEditorMessage(#SCI_POSITIONFROMLINE, FirstMatchLine) + FirstMatchColumn)
                  ;                   SendEditorMessage(#SCI_SETHIGHLIGHTGUIDE, Column)
                  ;                 EndIf
                EndIf
                
              ElseIf IsMismatch
                If Colors(#COLOR_BadBrace)\Enabled
                  SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_KeywordMismatch)
                  SendEditorMessage(#SCI_INDICATORFILLRANGE, SendEditorMessage(#SCI_POSITIONFROMLINE, OriginalLine)+StartIndex, EndIndex-StartIndex+1)
                EndIf
                
              EndIf
              
            EndIf
          EndIf
          
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure UpdateSelectionRepeat(selStart=-1, selEnd=-1)
    Static *LastActiveGadget, LastSelStart, LastSelEnd, LastHasMarks ; reduce number of updates
    
    ; exit if nothing changed
    If selStart <> -1 And *LastActiveGadget = *ActiveGadget And LastSelStart = selStart And LastSelEnd = selEnd
      ProcedureReturn
    EndIf
    
    ; get these values if not passed by the caller
    If selStart = -1
      selStart = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
      selEnd = SendEditorMessage(#SCI_GETSELECTIONEND  , 0, 0)
    EndIf
    
    SendEditorMessage(#SCI_SETINDICATORCURRENT, #INDICATOR_SelectionRepeat)
    
    ; clear any old marks if needed (always clear when switching gadgets to be sure)
    If *LastActiveGadget <> *ActiveGadget Or LastHasMarks
      SendEditorMessage(#SCI_INDICATORCLEARRANGE, 0, SendEditorMessage(#SCI_GETTEXTLENGTH))
    EndIf
    
    ; remember these for next time
    *LastActiveGadget = *ActiveGadget
    LastSelStart = selStart
    LastSelEnd = selEnd
    LastHasMarks = #False
    
    ; only mark anything if a full word is selected, to avoid slow updates on large selections
    ; use the scintilla definition of a full word as the check
    ;
    If Colors(#COLOR_SelectionRepeat)\Enabled And
       selStart <> selEnd And
       SendEditorMessage(#SCI_WORDSTARTPOSITION, selStart, #True) = selStart And
       SendEditorMessage(#SCI_WORDENDPOSITION, selStart, #True) = selEnd ; use 'selStart' here too to know if it is the same word!
      
      ; do the scan on the scintilla internal buffer to avoid copying the whole source
      ; note that this still has some cost, as Scintilla must close the editing gap within its buffer
      *BufferStart = SendEditorMessage(#SCI_GETCHARACTERPOINTER, 0, 0)
      *BufferEnd = *BufferStart + GetSourceLength() - (selEnd-selStart)
      *Pointer.Ascii = *BufferStart
      
      *Selection = *BufferStart + selStart
      SelectionLength = selEnd-selStart
      
      ; Look for repetitions of the selection
      While *Pointer <= *BufferEnd
        If CompareMemoryString(*Pointer, *Selection, #PB_String_NoCaseAscii, SelectionLength, #PB_UTF8) = #PB_String_Equal
          Position = *Pointer-*BufferStart
          ; don't mark the selection itself and check that this is a whole word before marking it
          If Position <> selStart And
             SendEditorMessage(#SCI_WORDSTARTPOSITION, Position, #True) = Position And
             SendEditorMessage(#SCI_WORDENDPOSITION, Position, #True) = Position + SelectionLength
            SendEditorMessage(#SCI_INDICATORFILLRANGE, *Pointer-*BufferStart, SelectionLength)
            LastHasMarks = #True
          EndIf
          *Pointer + SelectionLength
        Else
          *Pointer + 1
        EndIf
      Wend
      
    EndIf
  EndProcedure
  
  
  Procedure JumpToMatchingKeyword()
    Protected NewList Items.SourceItemPair() ; No need for static as this is not called that often
    
    If *ActiveSource\IsCode = 0
      ProcedureReturn
    EndIf
    
    UpdateCursorPosition() ; make sure the position is up to date
    
    selStart = SendEditorMessage(#SCI_GETSELECTIONSTART)
    selEnd   = SendEditorMessage(#SCI_GETSELECTIONEND)
    
    ; Try to locate a matching keyword
    ;
    If selStart = selEnd And CheckStringComment(selStart) = 0
      Line$ = GetCurrentLine()
      
      If Line$
        If GetWordBoundary(@Line$, Len(Line$), *ActiveSource\CurrentColumnChars-1, @StartIndex, @EndIndex, 0) And EndIndex-StartIndex+1 > 0
          Word$   = PeekS(@Line$ + StartIndex * #CharSize, EndIndex - StartIndex + 1)
          Keyword = IsBasicKeyword(Word$)
          
          If Keyword
            OriginalLine = *ActiveSource\CurrentLine-1
            
            ; Re-scan the current line to ensure all scanned tokens are up to date
            ; (also update procedure browser etc if needed, as any changes are missed there else)
            If ScanLine(*ActiveSource, OriginalLine)
              UpdateFolding(*ActiveSource, OriginalLine, *ActiveSource\CurrentLine+2)
              UpdateProcedureList()
              UpdateVariableViewer()
              *ActiveSource\ModifiedSinceUpdate = 0
              *ActiveSource\ParserDataChanged = #False ; full update was done here
            EndIf
            
            ; find the SourceItem in that represents this keyword
            *OriginalItem.SourceItem = LocateSourceItem(@*ActiveSource\Parser, OriginalLine, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, StartIndex))
            If *OriginalItem And *OriginalItem\Type = #ITEM_Keyword
              *Item.SourceItem = 0
              
              ; special treatment is needed for some keywords
              Select *OriginalItem\Keyword
                  
                Case #KEYWORD_For, #KEYWORD_ForEach, #KEYWORD_Repeat, #KEYWORD_While, #KEYWORD_Procedure, #KEYWORD_ProcedureC, #KEYWORD_ProcedureDLL, #KEYWORD_ProcedureCDLL
                  ; Loop/procedure start, check for Break & Continue
                  If FindBreakKeywords(@*ActiveSource\Parser, *OriginalItem, OriginalLine, Items())
                    If FirstElement(Items())
                      *Item = Items()\Item
                      Line  = Items()\Line
                    EndIf
                  EndIf
                  
                Case #KEYWORD_Break, #KEYWORD_Continue, #KEYWORD_ProcedureReturn
                  ; Find the loop/procedure start and check if there are break/continue/procedurereturn _after_ this one
                  *Item = *OriginalItem
                  Line  = OriginalLine
                  If *OriginalItem\Keyword = #KEYWORD_ProcedureReturn
                    Result = FindProcedureStart(@*ActiveSource\Parser, @Line, @*Item)
                    If Result
                      ; This is not the actual start keyword (the token is the procedure name here)
                      While *Item
                        If *Item\Type = #ITEM_Keyword And (*Item\Keyword = #KEYWORD_Procedure Or *Item\Keyword = #KEYWORD_ProcedureC Or *Item\Keyword = #KEYWORD_ProcedureDLL Or *Item\Keyword = #KEYWORD_ProcedureCDLL)
                          Break
                        EndIf
                        Parser_PreviousItem(*ActiveSource\Parser, *Item, Line)
                      Wend
                      If *Item = 0
                        Result = 0
                      EndIf
                    EndIf
                  Else
                    Result = FindLoopStart(@*ActiveSource\Parser, @Line, @*Item)
                  EndIf
                  
                  If Result
                    *OriginalItem = *Item ; this is now our reference item, if we find no more 'Break', look for the end keyword below (So Break->Until matches correctly)
                    OriginalLine = Line
                    *Item = 0
                    
                    If FindBreakKeywords(@*ActiveSource\Parser, *OriginalItem, OriginalLine, Items())
                      ForEach Items()
                        If Items()\Line > *ActiveSource\CurrentLine-1 Or (Items()\Line = *ActiveSource\CurrentLine-1 And Items()\Item\Position > EndIndex)
                          *Item = Items()\Item
                          Line  = Items()\Line
                          Break
                        EndIf
                      Next Items()
                    EndIf
                  Else
                    *Item = 0
                  EndIf
                  
              EndSelect
              
              ; default search
              If *Item = 0
                *Item = *OriginalItem
                Line  = OriginalLine
                
                ; search forward first
                If MatchKeywordForward(@*ActiveSource\Parser, @Line, @*Item) = #False Or *Item = 0
                  ; In case of failure, search backward, but go as far as possible (so we jump to the beginning keyword always then)
                  While MatchKeywordBackward(@*ActiveSource\Parser, @OriginalLine, @*OriginalItem) And *OriginalItem ; *Item is zero if no matches needed
                    *Item = *OriginalItem
                    Line  = OriginalLine
                  Wend
                EndIf
              EndIf
              
              ; jump there
              If *Item
                SendEditorMessage(#SCI_GOTOPOS, SendEditorMessage(#SCI_POSITIONFROMLINE, Line) + *Item\Position)
                SendEditorMessage(#SCI_ENSUREVISIBLE, line, 0)
                
                UpdateCursorPosition()
              EndIf
              
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndProcedure
  
  ; Check if zoom level has really changed, and if so, apply it to all open files
  Procedure HandleZoomChange()
    If *ActiveSource And *ActiveSource\IsForm = 0 And *ActiveSource <> *ProjectInfo
      NewZoom = SendEditorMessage(#SCI_GETZOOM)
      If NewZoom <> CurrentZoom
        SynchronizingZoom = #True
        ForEach FileList()
          If FileList()\IsForm = 0 And @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource
            ScintillaSendMessage(FileList()\EditorGadget, #SCI_SETZOOM, NewZoom)
          EndIf
        Next
        ChangeCurrentElement(FileList(), *ActiveSource)
        CurrentZoom = NewZoom
        SynchronizingZoom = #False
      EndIf
    EndIf
  EndProcedure
  
  ; This is used by the Template/ MacroError windows
  ; CompilerIf #CompileWindows | #CompileMac
  ProcedureDLL EmptyScintillaCallback(EditorGadget, *scinotify.SCNotification)
    ; CompilerElse
    ;   ProcedureCDLL EmptyScintillaCallback(EditorWindow.l, EditorGadget.l, *scinotify.SCNotification, lParam.l)
    ; CompilerEndIf
    ;
    ; Empty scintillacallback. Needed because the scintilla lib on windows can not do
    ; without one!
    ;
  EndProcedure
  
  ; CompilerIf #CompileWindows | #CompileMac  ; this function must be stdcall on windows and cdecl on linux
  ProcedureDLL ScintillaCallBack(EditorGadget, *scinotify.SCNotification)
    ; CompilerElse
    ;   ProcedureCDLL ScintillaCallBack(EditorWindow.l, EditorGadget.l, *scinotify.SCNotification, lParam.l)
    ; CompilerEndIf
    
    
    ; some functions here use ScintillaSendMessage instead of SendEditorMessage, because also not the
    ; active source may receive some events!
    
    Select *scinotify\nmhdr\code
        
      Case #SCN_MODIFYATTEMPTRO
        ChangeStatus(Language("Debugger","EditError"), -1)
        CompilerIf #CompileWindows
          MessageBeep_(#MB_OK)
        CompilerEndIf
        
      Case #SCN_SAVEPOINTLEFT
        UpdateSourceStatus(-1)
        
      Case #SCN_SAVEPOINTREACHED
        UpdateSourceStatus(-1)
        
        
        ; Note: This check is done in a separate event callback for linux,
        ;   as we have no way of knowing the modifier keys here in the
        ;   scintilla callback
        ;
        CompilerIf #CompileLinuxGtk = 0
          
        Case #SCN_DOUBLECLICK
          If *ActiveSource And EditorGadget = *ActiveSource\EditorGadget And *ActiveSource\IsCode
            AutoCompleteKeywordInserted = 0
            
            ; Note: there is a focus problem when switching the active source from here
            ;       (the new file never gets the editing focus (though it is in the foreground)
            ;       To prevent this, defer the actual action to the main loop
            ;       See EventLoopCallback() in UserInterface.pb
            CtrlDoubleClickHappened = #True
          EndIf
          
        CompilerEndIf
        
      Case #SCN_UPDATEUI
        If *ActiveSource
          selStart = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
          selEnd = SendEditorMessage(#SCI_GETSELECTIONEND  , 0, 0)
          
          ; clear block selection stack on any manual change of the selection
          If *scinotify\updated = #SC_UPDATE_SELECTION And BlockSelectionUpdated = #False And LastElement(BlockSelectionStack())
            Debug "---- BlockSelectionStack clear ------"
            ClearList(BlockSelectionStack())
          EndIf
          ; reset the flag so the next selection change clears the block selection stack
          BlockSelectionUpdated = #False
          
          If IsWindow(#WINDOW_Find)
            If selStart = selEnd
              SetGadgetState(#GADGET_Find_SelectionOnly, 0)
              DisableGadget(#GADGET_Find_SelectionOnly, 1)
            Else
              DisableGadget(#GADGET_Find_SelectionOnly, 0)
            EndIf
          EndIf
          
          UpdateCursorPosition()
          
          If *ActiveSource\IsCode And selStart = selEnd And SendEditorMessage(#SCI_GETREADONLY, 0, 0) = 0 ; do not update quickhelp when in debugger mode
            QuickHelpFromLine(*ActiveSource\CurrentLine-1, *ActiveSource\CurrentColumnChars-1)
          EndIf
          
          ; add the old line to the lines history, if the jump since the last #SCN_UPDATEUI
          ; was more than 20 lines. (ie, not moved by keyboard, but by mouse or something else)
          ;
          If *ActiveSource\CurrentLine > *ActiveSource\LineHistory[0]+20 Or *ActiveSource\CurrentLine < *ActiveSource\LineHistory[0]-20
            ; move the buffer...
            MoveMemory(@*ActiveSource\LineHistory[0], @*ActiveSource\LineHistory[1], (#MAX_LineHistory-1)*4)
          EndIf
          *ActiveSource\LineHistory[0] = *ActiveSource\CurrentLine ; the 0 index is always the last seen line
          
          ; an update is only needed if the user typed something since the last one
          ; since we have this check, we can do an update even when the user is selecting stuff (as no typing happens between the selections)
          If *ActiveSource\ModifiedSinceUpdate = 1 And *ActiveSource\IsCode
            
            If *ActiveSource\CurrentLine <> *ActiveSource\CurrentLineOld And *ActiveSource\CurrentLineOld > 0
              foldlevel = ScintillaSendMessage(EditorGadget, #SCI_GETFOLDLEVEL, *ActiveSource\CurrentLineOld-1, 0)
              OldLine$ = GetLine(*ActiveSource\CurrentLineOld-1) ; use the case corrected line!
              
              ; update highlighting of the old line, as now keywords are not highlighted with the cursor inside (so do it when the mouse is moved away)
              ;
              If (EnableColoring Or EnableCaseCorrection) And OldLine$ <> ""
                HighlightLine$ = OldLine$+#NewLine
                anchorPos = SendEditorMessage(#SCI_GETANCHOR, 0, 0) ; save & restore the cursor pos
                currentPos = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
                
                If *ActiveSource\Parser\Encoding = 1
                  *HighlightBuffer = UTF8(HighlightLine$)
                Else
                  *HighlightBuffer = Ascii(HighlightLine$)
                EndIf
                
                HighlightOffset = SendEditorMessage(#SCI_POSITIONFROMLINE, *ActiveSource\CurrentLineOld-1, 0)
                HighlightGadget = *ActiveSource\EditorGadget
                
                ScintillaSendMessage(EditorGadget, #SCI_SETUNDOCOLLECTION, #False, 0)
                
                If EnableColoring
                  SendEditorMessage(#SCI_STARTSTYLING, HighlightOffset, $FFFFFF)
                EndIf
                
                ; now call the highlighting engine
                ;
                Modified = GetSourceModified()  ; because the case correction changes the modified state!
                HighlightingEngine(*HighlightBuffer, MemoryAsciiLength(*HighlightBuffer), -1, @HighlightCallback(), 1, IsInsideASMBlock(*ActiveSource\CurrentLineOld-1))
                SetSourceModified(Modified)
                
                FreeMemory(*HighlightBuffer)
                
                ScintillaSendMessage(EditorGadget, #SCI_SETUNDOCOLLECTION, #True, 0)
                SendEditorMessage(#SCI_SETANCHOR, anchorPos, 0)
                SendEditorMessage(#SCI_SETCURRENTPOS, currentPos, 0)
              EndIf
              
              ; re-scanning one line is very fast now, so do it always
              If ScanLine(*ActiveSource, *ActiveSource\CurrentLineOld-1) ; returns true if line content changed, very cool
                UpdateFolding(*ActiveSource, *ActiveSource\CurrentLineOld-1, *ActiveSource\CurrentLineOld+2)
                UpdateProcedureList()
                UpdateVariableViewer()
                *ActiveSource\ModifiedSinceUpdate = 0
                *ActiveSource\ParserDataChanged = #False ; full update done here
              EndIf
              
              ; If the parse data changed (because of autocomplete scan for example) do any
              ; needed update of parser data now
              If *ActiveSource\ParserDataChanged
                UpdateProcedureList()
                UpdateVariableViewer()
                *ActiveSource\ParserDataChanged = #False
              EndIf
              
            EndIf
          EndIf
          
          If IsInsideASMBlock(*ActiveSource\CurrentLine-1) = #False
            
            ; highlight matching braces
            UpdateBraceHighlight(selStart)
            
            ; highlight matching keywords
            If selStart = selEnd
              UpdateKeywordHighlight(selStart, #True)
            Else
              UpdateKeywordHighlight(selStart, #False)  ; remove any old highlight
            EndIf
            
          EndIf
          
          ; highlight strings matching the selection
          UpdateSelectionRepeat(selStart, selEnd)
          
          *ActiveSource\CurrentLineOld = *ActiveSource\CurrentLine
        EndIf
        
        
      Case #SCN_MODIFIED
        If *ActiveSource\IsCode
          *ActiveSource\ModifiedSinceUpdate = 1 ; the source has been modified
          If EnableLineNumbers And *scinotify\modificationType & (#SC_MOD_INSERTTEXT | #SC_MOD_DELETETEXT)
            UpdateLineNumbers(*ActiveSource)
          EndIf
          
          ; Separate open/close handling to allo close+direct re-open (important in structure mode)
          If AutoCompleteWindowOpen And *scinotify\modificationType & #SC_MOD_DELETETEXT And *scinotify\length = 1
            AutoComplete_WordUpdate()
          EndIf
          
          If AutoCompleteWindowOpen = 0 And *scinotify\modificationType & #SC_MOD_DELETETEXT And *scinotify\length = 1 And AutoComplete_CheckAutoPopup()
            position = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
            line = SendEditorMessage(#SCI_LINEFROMPOSITION, position, 0)
            position = CountCharacters(*ActiveSource\EditorGadget, SendEditorMessage(#SCI_POSITIONFROMLINE, line, 0), position)
            If CheckSearchStringComment(line, position, 1)
              OpenAutoCompleteWindow()
            EndIf
          EndIf
          
          If *scinotify\modificationType & (#SC_MOD_INSERTTEXT | #SC_MOD_DELETETEXT) And NoUserChange = 0
            If *scinotify\linesAdded >= 1 Or *scinotify\linesAdded <= -1
              line = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, *scinotify\position, 0)
              
              ; correct the line structure
              SourceLineCorrection(*ActiveSource, line, *scinotify\linesAdded)
              
              ; scan all new lines and update folding markers (for Ctrl+D etc)
              If *scinotify\linesAdded > 0
                PartialSourceScan(*ActiveSource, line, line+*scinotify\linesAdded)
                UpdateFolding(*ActiveSource, line, line+*scinotify\linesAdded+1) ; this is quite fast now, but doing the full source is still a bit costly
              Else
                PartialSourceScan(*ActiveSource, line, line+1)
                UpdateFolding(*ActiveSource, line-1, line+10) ; must go line-1 because the foldlevel of the line itself could change due to the update
              EndIf
              
              UpdateProcedureList()
              UpdateVariableViewer()
            EndIf
            
          EndIf
        EndIf
        
        
      Case #SCN_NEEDSHOWN
        firstLine = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, *scinotify\position, 0)
        lastLine = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, *scinotify\position+*scinotify\length-1, 0)
        For line = firstLine To lastLine
          ScintillaSendMessage(EditorGadget, #SCI_ENSUREVISIBLE, line, 0)
        Next line
        
        ; if the last line needed visible is a fold point we must expand that!
        ; -> fixes a problem when hitting enter on a folded procedure line
        ; -> second problem: typing "Procedure" above a folded procedure expands that one too!
        ;    (so check If the cursor is actually on this last line (to check for the 1st condition))
        ;
        If ScintillaSendMessage(EditorGadget, #SCI_GETFOLDLEVEL, lastLine, 0) & #SC_FOLDLEVELHEADERFLAG And ScintillaSendMessage(EditorGadget, #SCI_GETFOLDEXPANDED, lastLine, 0) = 0
          cursorLine = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, ScintillaSendMessage(EditorGadget, #SCI_GETCURRENTPOS, 0, 0), 0)
          If cursorLine = lastLine
            ScintillaSendMessage(EditorGadget, #SCI_TOGGLEFOLD, lastLine, 0)
          EndIf
        EndIf
        
      Case #SCN_MARGINCLICK
        line = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, *scinotify\position, 0)
        If *scinotify\modifiers = #SCI_CTRL ; set marker
          If SendEditorMessage(#SCI_MARKERGET, line, 0) & 1<<#MARKER_Marker
            SendEditorMessage(#SCI_MARKERDELETE, line, #MARKER_Marker)
          Else
            SendEditorMessage(#SCI_MARKERADD, line, #MARKER_Marker)
          EndIf
          
        ElseIf *scinotify\modifiers = #SCI_ALT And *ActiveSource\IsCode ; set breakpoint
          Debugger_BreakPoint(line)
          
        ElseIf *ActiveSource\IsCode ; check folding points
          If ScintillaSendMessage(EditorGadget, #SCI_GETFOLDLEVEL, line, 0) & #SC_FOLDLEVELHEADERFLAG
            ScintillaSendMessage(EditorGadget, #SCI_TOGGLEFOLD, line, 0)
          EndIf
        EndIf
        
      Case #SCN_ZOOM
        UpdateLineNumbers(*ActiveSource)
        If SynchronizingZoom = 0
          HandleZoomChange()
        EndIf
        
      Case #SCN_CHARADDED
        If *ActiveSource And EditorGadget = *ActiveSource\EditorGadget
          *ActiveSource\ModifiedSinceUpdate = 1 ; the source has been modified
          
          ; With structure autocomplete, while typing a \, we can have one autocomplete to close
          ; and then directly re-open in structure mode for the structure, so handle this case
          If AutoCompleteWindowOpen
            If *scinotify\ch = '\' ; this always has to force a close! (AutoComplete_WordUpdate() cannot detect this in structure mode)
              AutoComplete_Close()
            Else
              AutoComplete_WordUpdate()
            EndIf
          EndIf
          
          If AutoCompleteWindowOpen = 0 And (*scinotify\ch = '\' Or *scinotify\ch = ':' Or ValidCharacters(*scinotify\ch & $FF)) And AutoComplete_CheckAutoPopup()
            position = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
            line = SendEditorMessage(#SCI_LINEFROMPOSITION, position, 0)
            position = CountCharacters(*ActiveSource\EditorGadget, SendEditorMessage(#SCI_POSITIONFROMLINE, line, 0), position)
            If CheckSearchStringComment(line, position, 1)
              OpenAutoCompleteWindow()
            EndIf
          EndIf
          
          
          ; We also get a #SCN_MODIFIED for newlines, so the source scanning
          ; for autocomplete is done there.
          ;
          If *scinotify\ch = 10 And IndentMode <> #INDENT_None ; Check only for the '10' as on Windows, '13' and '10' are both sent ! '10' also works on Linux
            
            line = SendEditorMessage(#SCI_LINEFROMPOSITION, SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0), 0)
            If IndentMode = #INDENT_Block Or (*ActiveSource\IsCode = 0) ; always fallback to block mode in non-pb files
              
              ; block mode, just get the previous indent
              Prefix$ = GetIndentPrefix(GetLine(line-1))
              If Prefix$ <> ""
                
                ; This trick allows us to undo the whole newline action including the
                ; indent in one step without glitches. We first undo the return operation,
                ; then insert the newline + prefix for the next line.
                ;
                ; All other combinations (#SCI_BEGINUNDOACTION etc) will cause the cursor
                ; to be in the wrong position after an undo.
                ;
                ; NOTE: leads to ugly flicker on linux
                ;
                ; NOTE: This trick is a problem in the following situation
                ;       - On a line like "  Foo: Bar", select the "Bar" and hit enter
                ;       - The SCI_UNDO will remove the selection, so after the SCI_REPLACESEL
                ;         the "Bar" will remain even though it should have been removed by the enter press!
                ;
                ; So just don't use this trick at all. Two UNDO steps are not so bad as a wrong
                ; behavior on an enter press!
                ;
                ;CompilerIf #CompileWindows
                ;  SendEditorMessage(#SCI_UNDO, 0, 0)
                ;  Prefix$ = #NewLine + Prefix$
                ;CompilerEndIf
                
                SendEditorMessage(#SCI_REPLACESEL, 0, ToAscii(Prefix$))
              EndIf
              
            ElseIf *ActiveSource\IsCode ; only in pb-mode
                                        ; sensitive mode
                                        ; update the previous and current line, then just set the cursor correctly
                                        ; do not propagate indent changes past the new line
              SendEditorMessage(#SCI_BEGINUNDOACTION)
              UpdateIndent(line-1, line)
              SendEditorMessage(#SCI_ENDUNDOACTION)
              Position = SendEditorMessage(#SCI_POSITIONFROMLINE, line)+Len(GetIndentPrefix(GetLine(line)))
              SendEditorMessage(#SCI_SETSEL, Position, Position)
              
            EndIf
          EndIf
          
        EndIf
        UpdateBraceHighlight(SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0))
        AutoCompleteKeywordInserted = 0 ; in everycase, set this variable to 0 now!
        
        
      Case #SCN_STYLENEEDED
        If EnableColoring Or EnableCaseCorrection
          If *ActiveSource\IsCode
            range.TextRange\chrg\cpMin  = ScintillaSendMessage(EditorGadget, #SCI_GETENDSTYLED, 0, 0)
            lineNumber                  = ScintillaSendMessage(EditorGadget, #SCI_LINEFROMPOSITION, range\chrg\cpMin, 0)
            range\chrg\cpMin            = ScintillaSendMessage(EditorGadget, #SCI_POSITIONFROMLINE, lineNumber, 0)
            range\chrg\cpMax            = *scinotify\position
            
            ;Debug Str(range\chrg\cpMin) +"->"+ Str(range\chrg\cpMax)
            
            *Buffer = AllocateMemory(range\chrg\cpMax - range\chrg\cpMin + 1)
            If *Buffer
              anchorPos = ScintillaSendMessage(EditorGadget, #SCI_GETANCHOR, 0, 0) ; save & restore the cursor pos
              currentPos = ScintillaSendMessage(EditorGadget, #SCI_GETCURRENTPOS, 0, 0)
              
              range\lpstrText = *Buffer
              reallength = ScintillaSendMessage(EditorGadget, #SCI_GETTEXTRANGE, 0, @range)
              *HighlightBuffer = *Buffer
              HighlightOffset = range\chrg\cpMin
              HighlightGadget = EditorGadget
              
              If reallength > range\chrg\cpMax - range\chrg\cpMin
                reallength = range\chrg\cpMax - range\chrg\cpMin ; just a safeguard. seen some weird overflow problem here
              EndIf
              
              ScintillaSendMessage(EditorGadget, #SCI_SETUNDOCOLLECTION, #False, 0)
              
              If EnableColoring
                ScintillaSendMessage(EditorGadget, #SCI_STARTSTYLING, HighlightOffset, $1F) ; do not overwrite indicators (brace highlight)
              EndIf
              
              Modified = GetSourceModified()
              HighlightingEngine(*Buffer, reallength, currentPos-range\chrg\cpMin , @HighlightCallback(), 1, IsInsideASMBlock(lineNumber))
              SetSourceModified(Modified)
              
              ScintillaSendMessage(EditorGadget, #SCI_SETUNDOCOLLECTION, #True, 0)
              
              FreeMemory(*Buffer)
              
              ScintillaSendMessage(EditorGadget, #SCI_SETANCHOR, anchorPos, 0)
              ScintillaSendMessage(EditorGadget, #SCI_SETCURRENTPOS, currentPos, 0)
            EndIf
            
          ElseIf EnableColoring
            ; non-pb files
            HighlightOffset = ScintillaSendMessage(EditorGadget, #SCI_GETENDSTYLED, 0, 0)
            ScintillaSendMessage(EditorGadget, #SCI_STARTSTYLING, HighlightOffset, $1F)
            ScintillaSendMessage(EditorGadget, #SCI_SETSTYLING, *scinotify\position-HighlightOffset, *NormalTextColor)
          EndIf
        EndIf
        
        ScintillaSendMessage(EditorGadget, #SCI_BEGINUNDOACTION, 0, 0)  ; will make any typed word undoable
        ScintillaSendMessage(EditorGadget, #SCI_ENDUNDOACTION, 0, 0)
        
      Case #SCN_DWELLSTART
        ; warning: scintilla also fires this event when we dwell outside of the
        ;   window with the mouse, *scinotify\position is -1 in this case, so
        ;   filter it. (also filters cases where we are not near any character)
        ;
        If *scinotify\position > 0 And *ActiveSource And GetActiveGadget() = *ActiveSource\EditorGadget And *ActiveSource\IsCode
          IsMouseDwelling    = 1 ; to know if the mouse still dwells when the result is received
          MouseDwellPosition = *scinotify\position
          
          *Debugger.DebuggerData = 0
          If *ActiveSource <> *ProjectInfo
            *Debugger = GetDebuggerForFile(*ActiveSource)
          EndIf
          
          If *Debugger
            Debugger_EvaluateAtCursor(*scinotify\position)  ; evaluate by debugger
          Else
            ; Todo: find a less intrusive way to display this info
            ; DisplayItemAtCursor(*scinotify\position)  ; display type info by source parser
          EndIf
        EndIf
        
      Case #SCN_DWELLEND
        IsMouseDwelling = 0
        ScintillaSendMessage(EditorGadget, #SCI_CALLTIPCANCEL)
        
    EndSelect
    
  EndProcedure
  
  CompilerIf #CompileLinuxGtk
    
    ; Workaround for the Scintilla shortcut *eating* on Linux.
    ; Enter key handling for the other OS is done via #MENU_Scintilla_Enter shortcut
    ;
    ProcedureCDLL ScintillaShortcutHandler(*Widget, *Event.GdkEventKey, user_data)
      
      If *Event\keyval = $FF09 Or *Event\keyval = $FF0D Or *Event\keyval = $FF8D ; handle the autocomplete events
        
        If AutoCompleteKeywordInserted And *Event\keyval = $FF09 And *Event\state & (1 << 2) = 0 And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Tab
          AutoComplete_InsertEndKEyword()
          ProcedureReturn 1 ; drop this message
          
        ElseIf AutoCompleteKeywordInserted And (*Event\keyval = $FF0D Or *Event\keyval = $FF8D) And *Event\state & (1 << 2) = 0 And KeyboardShortcuts(#MENU_AutoComplete_OK) = #PB_Shortcut_Return
          AutoComplete_InsertEndKEyword()
          ProcedureReturn 1 ; drop this message
          
        ElseIf *Event\keyval = $FF09 And *Event\state & (1 << 2) = 0 ; it was a tab
          GetSelection(@LineStart, 0, @LineEnd, 0)
          If LineStart = LineEnd ; normal tab
            If *Event\state & 1  ; shift key
              SendEditorMessage(#SCI_BACKTAB, 0, 0)
            Else
              SendEditorMessage(#SCI_TAB, 0, 0)
            EndIf
          Else
            If *Event\state & 1 ; shift key
              RemoveTab()
            Else
              InsertTab()
            EndIf
          EndIf
          ProcedureReturn 1
          
        ElseIf *Event\keyval = $FF09 And *Event\state & (1 << 2) ;  Ctrl+Tab... switch sources
          If *Event\state & 1
            If KeyboardShortcuts(#MENU_NextOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_Tab
              ChangeCurrentFile(0)
              ProcedureReturn 1
            ElseIf KeyboardShortcuts(#MENU_PreviousOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_Tab
              ChangeCurrentFile(1)
              ProcedureReturn 1
            EndIf
          Else
            If KeyboardShortcuts(#MENU_NextOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Tab
              ChangeCurrentFile(0)
              ProcedureReturn 1
            ElseIf KeyboardShortcuts(#MENU_PreviousOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Tab
              ChangeCurrentFile(1)
              ProcedureReturn 1
            EndIf
          EndIf
          
          
        ElseIf *Event\keyval = $FF0D Or *Event\keyval = $FF8D  ; it was an enter (second one is numpad enter)
          SendEditorMessage(#SCI_NEWLINE, 0, 0)
          ProcedureReturn 1
          
        EndIf
        
      ElseIf *Event\keyval = $FE20 ; #GDK_Multi_Key.. simulated through a shift+tab newer keyboards ?
        If *Event\state & (1 << 2) And KeyboardShortcuts(#MENU_NextOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_Tab
          ChangeCurrentFile(0)
        ElseIf *Event\state & (1 << 2) And KeyboardShortcuts(#MENU_PreviousOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_Tab
          ChangeCurrentFile(1)
        Else
          GetSelection(@LineStart, 0, @LineEnd, 0)
          If LineStart = LineEnd  ; normal tab
            SendEditorMessage(#SCI_TAB, 0, 0)
          Else
            RemoveTab()
          EndIf
        EndIf
        ProcedureReturn 1
        
      EndIf
      
      ; Get the accelerator table from the top window and try to fire the accelerator
      ; If it is in the table, it will return 1 (the event is stopped) and the accelerator
      ; will be fired -> the event will be generated.
      ;
      Accelerators = g_object_get_data_(gtk_widget_get_toplevel_(*Widget), "pb_accelerators")
      If Accelerators
        
        ; gtk_accel_groups_activate_() works as well for our case, but it's not sure than the shortcut is
        ; really in our accelerator list, so check it. Note the '& $F' for the query, without which it fails
        ;
        If gtk_accel_group_query_(Accelerators, *Event\keyval, *Event\state & $F, @NbEntriesFound)
          ProcedureReturn gtk_accel_groups_activate_(gtk_widget_get_toplevel_(*Widget), Key, *Event\state)
        EndIf
      EndIf
      
      ProcedureReturn 0
    EndProcedure
    
    ; Special handler for the double-click on linux, as the Scintilla event does
    ; not provide the modifier keys, so we do not know if Ctrl+Double-click was done.
    ;
    ProcedureC ScintillaDoubleclickHandler(*Widget, *Event.GdkEventButton, user_data)
      
      If *Event\type = #GDK_2BUTTON_PRESS And *Event\button = 1
        
        AutoCompleteKeywordInserted = 0
        If *ActiveSource
          Word$ = LCase(GetCurrentWord())
          If Word$ = "includefile" Or Word$ = "xincludefile" Or Word$ = "includebinary"
            OpenIncludeOnDoubleClick()
            
          ElseIf *Event\state & #GDK_CONTROL_MASK
            JumpToProcedure()
            ProcedureReturn #True ; prevent event from reaching the gadget (messes up selection!)
            
          EndIf
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
  CompilerEndIf
  
  
  
  Procedure ApplyWordChars(Gadget = #PB_All)
    
    ; Do not allow whitespace characters!
    ExtraWordChars$ = RemoveString(ExtraWordChars$, " ")
    ExtraWordChars$ = RemoveString(ExtraWordChars$, #TAB$)
    ExtraWordChars$ = RemoveString(ExtraWordChars$, #CR$)
    ExtraWordChars$ = RemoveString(ExtraWordChars$, #LF$)
    
    ; Do not allow empty string
    If ExtraWordChars$ = ""
      ExtraWordChars$ = #WORDCHARS_Default
    EndIf
    
    ; add *@$# (or custom) to the word characters, so they get included in the selection
    ; when you double-click a word (to so select constants/variables easily)
    
    WordChars$ = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_" + ExtraWordChars$
    For k = 192 To 255
      WordChars$+Chr(k) ; For ASCII mode, to have "é, à" etc. (https://www.purebasic.fr/english/viewtopic.php?f=4&t=57421)
    Next
    *Ascii = ToAscii(WordChars$)
    
    If Gadget <> #PB_All
      ; Apply to one specific gadget
      ScintillaSendMessage(Gadget, #SCI_SETWORDCHARS, 0, *Ascii)
    Else
      ; Apply to all sources
      *Source = @FileList()
      ForEach FileList()
        If @FileList() <> *ProjectInfo
          If Not FileList()\IsForm
            ScintillaSendMessage(FileList()\EditorGadget, #SCI_SETWORDCHARS, 0, *Ascii)
          EndIf
        EndIf
      Next
      ChangeCurrentElement(FileList(), *Source)
    EndIf
    
  EndProcedure
  
  
  
  Procedure CreateEditorGadget()
    
    FileList()\EditorGadget = ScintillaGadget(#PB_Any, 0, 0, 1, 1, @ScintillaCallBack())   ; do not create with size 0 as on linux that means as small as possible and looks ugly
    FileList()\CurrentLineOld = 1                                                          ; fix a problem with folding on new source
    
    ; Note: The ChangeActiveSourceCode() here is not really needed. It is only used to set *ActiveSource,
    ;   This produces a flicker in the ErrorLog though, as the empty source has "log hidden" set,
    ;   so it is hidden and when later the "log shown" is set it is shown again which looks ugly.
    ;   So just change *ActiveSource here and not switch sources yet.
    ;   This is called later again anyway.
    ;
    ;ChangeActiveSourcecode()
    *ActiveSource = @FileList()
    
    ; use all bits for styling (in newer scintilla versions, indicators work differently anyway)
    ; this allows 255 style definitions (room for the dynamic issue styles)
    SendEditorMessage(#SCI_SETSTYLEBITS, 8)
    
    ; remove the tab and enter shortcut to handle it ourselves (for the autocomplete)
    ;
    SendEditorMessage(#SCI_CLEARCMDKEY, #SCK_TAB, 0)
    SendEditorMessage(#SCI_CLEARCMDKEY, #SCK_TAB | (#SCMOD_SHIFT << 16), 0)
    SendEditorMessage(#SCI_CLEARCMDKEY, #SCK_RETURN, 0)
    
    ; remove all shortcuts involving text chars. They produce strange output, and some
    ; even make the IDE crash. Also some will collide with the IDE ones on linux.
    ;
    For c = 'A' To 'Z'
      If c <> 'D' ; do not remove CTRL+D
        SendEditorMessage(#SCI_CLEARCMDKEY, c | ((#SCMOD_CTRL) << 16), 0)
      EndIf
      SendEditorMessage(#SCI_CLEARCMDKEY, c | ((#SCMOD_ALT) << 16), 0)
      SendEditorMessage(#SCI_CLEARCMDKEY, c | ((#SCMOD_SHIFT|#SCMOD_CTRL) << 16), 0)
      SendEditorMessage(#SCI_CLEARCMDKEY, c | ((#SCMOD_SHIFT|#SCMOD_ALT) << 16), 0)
      SendEditorMessage(#SCI_CLEARCMDKEY, c | ((#SCMOD_ALT|#SCMOD_CTRL) << 16), 0)
      SendEditorMessage(#SCI_CLEARCMDKEY, c | ((#SCMOD_SHIFT|#SCMOD_CTRL|#SCMOD_ALT) << 16), 0)
    Next c
    
    ; they somehow don't work with shift, so use ctrl
    SendEditorMessage(#SCI_ASSIGNCMDKEY, #SCK_ADD | (#SCMOD_CTRL << 16), #SCI_ZOOMIN)
    SendEditorMessage(#SCI_ASSIGNCMDKEY, #SCK_SUBTRACT | (#SCMOD_CTRL << 16), #SCI_ZOOMOUT)
    
    ; workaround for the linux shortcut problem
    ;
    CompilerIf #CompileLinuxGtk
      GtkSignalConnect(GadgetID(*ActiveSource\EditorGadget), "key-press-event", @ScintillaShortcutHandler(), 0)
      GtkSignalConnect(GadgetID(*ActiveSource\EditorGadget), "button-press-event", @ScintillaDoubleClickHandler(), 0)
    CompilerEndIf
    
    ; We stay with WM_DROPFILES for Windows, as somehow PB's own D+D stuff is
    ; not working right as Scintilla has its own D+D handling...
    ;
    CompilerIf #CompileWindows = 0
      EnableGadgetDrop(*ActiveSource\EditorGadget, #PB_Drop_Files, #PB_Drag_Copy)
    CompilerEndIf
    
    SendEditorMessage(#SCI_SETZOOM, CurrentZoom)
    
    SendEditorMessage(#SCI_SETTABINDENTS, 0, 0) ; just write tabs/spaces as normal
    SendEditorMessage(#SCI_USEPOPUP, 0, 0)      ; disable the scintilla popup to enable the ide one.
    
    SendEditorMessage(#SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
    SendEditorMessage(#SCI_SETMARGINTYPEN, 1, #SC_MARGIN_SYMBOL)
    
    SendEditorMessage(#SCI_SETMARGINMASKN, 1, -1)
    SendEditorMessage(#SCI_SETMARGINSENSITIVEN, 1, 1)
    
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Marker           , #SC_MARK_SHORTARROW)  ; editor bookmark
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_CurrentLine      , #SC_MARK_BACKGROUND)  ; current line back
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_CurrentLineSymbol, #SC_MARK_ARROW)       ; current line symbol
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Error            , #SC_MARK_BACKGROUND)  ; error back
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_ErrorSymbol      , #SC_MARK_CIRCLE)      ; error symbol
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Warning          , #SC_MARK_BACKGROUND)  ; warning back
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_WarningSymbol    , #SC_MARK_CHARACTER+'!')   ; warning symbol
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_Breakpoint       , #SC_MARK_BACKGROUND)      ; breakpoint back
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_BreakpointSymbol , #SC_MARK_SMALLRECT)       ; breakpoint symbol
    
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPEN,    #SC_MARK_BOXMINUS)
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDER,        #SC_MARK_BOXPLUS)
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEREND,     #SC_MARK_BOXPLUSCONNECTED)
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPENMID, #SC_MARK_BOXMINUSCONNECTED)
    
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERSUB,     #SC_MARK_EMPTY)
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERTAIL,    #SC_MARK_EMPTY)
    SendEditorMessage(#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERMIDTAIL, #SC_MARK_EMPTY)
    
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_FoldVLine,         #SC_MARK_VLINE)
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_FoldVCorner,       #SC_MARK_LCORNER)
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_FoldTCorner,       #SC_MARK_TCORNER)
    
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_ProcedureStart,    #SC_MARK_EMPTY)      ; this is invisible to track procedure lines
    SendEditorMessage(#SCI_MARKERDEFINE, #MARKER_ProcedureBack,     #SC_MARK_BACKGROUND) ; this is the actual visible mark
    
    SendEditorMessage(#SCI_SETFOLDFLAGS, 0, 0)
    
    *AsciiOne = Ascii("1")
    SendEditorMessage(#SCI_SETPROPERTY , ToAscii("fold"), *AsciiOne)
    FreeMemory(*AsciiOne)
    
    SendEditorMessage(#SCI_INDICSETSTYLE, #INDICATOR_KeywordMatch, #INDIC_PLAIN)
    SendEditorMessage(#SCI_INDICSETSTYLE, #INDICATOR_KeywordMismatch, #INDIC_PLAIN)
    
    SendEditorMessage(#SCI_INDICSETSTYLE, #INDICATOR_SelectionRepeat, #INDIC_STRAIGHTBOX)
    SendEditorMessage(#SCI_INDICSETALPHA, #INDICATOR_SelectionRepeat, 255)
    SendEditorMessage(#SCI_INDICSETOUTLINEALPHA, #INDICATOR_SelectionRepeat, 255)
    SendEditorMessage(#SCI_INDICSETUNDER, #INDICATOR_SelectionRepeat, #True)
    
    
    ApplyWordChars(*ActiveSource\EditorGadget)
    
    SendEditorMessage(#SCI_SETMOUSEDWELLTIME, 750, 0)
    
    ; Auto adjust the horizontal scrollbar. Could have a performance impact according to the doc, to verify in practice
    ; https://www.purebasic.fr/english/viewtopic.php?f=23&t=50693
    ;
    ; Note: with new scintilla on OS X, this is broken (the horizontal scroll doesn't adjust at all)
    ; Also on OS X 10.8+ the scrollbar is hidden by default (new OS X scroll, so it's not an issue anymore)
    ; It fixes this issue:
    ;
    CompilerIf #CompileMacCocoa = 0
      SendEditorMessage(#SCI_SETSCROLLWIDTH, 1) ; 10 pixels width at start, and will grow if necessary
      SendEditorMessage(#SCI_SETSCROLLWIDTHTRACKING, 1)
    CompilerEndIf
    
    ;   ; Test for the Trond guy
    ;  SendEditorMessage(#SCI_SETBUFFEREDDRAW, 0, 0)
    ;  SendEditorMessage(#SCI_SETTWOPHASEDRAW, 0, 0) ; this produces no flickering, so we can turn it off
    
    ; Set up the highlighting for this GAdget: (moved to affect Prefs changes as well)
    SetUpHighlightingColors()
    
  EndProcedure
  
  
  Procedure SetReadOnly(Gadget, State)
    
    CompilerIf #SpiderBasic
      ; As a Javascript app is never blocking, we can't know if it finished running, so never disable the sources
      ProcedureReturn
    CompilerEndIf
      
    
    ScintillaSendMessage(Gadget, #SCI_SETREADONLY, State, 0)
    
    If State
      ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, #False)
      ;ScintillaSendMessage(Gadget, #SCI_SETCARETSTYLE, 0) ; Hide the caret - Don't hide it as we can still select block of code, so it does look weird
    Else
      ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, #True)
      ;ScintillaSendMessage(Gadget, #SCI_SETCARETSTYLE, 1) ; Show the caret

      ; When hiding the caret line, the back color is reset on new Scintilla 5.3.6. So re-apply it.
      If EnableColoring
        ScintillaSendMessage(Gadget, #SCI_SETCARETLINEBACK, Colors(#COLOR_CurrentLine)\DisplayValue, 0) 
      Else
        ScintillaSendMessage(Gadget, #SCI_SETCARETLINEBACK, $FFFFFF, 0)
      EndIf
    EndIf
    
    SetBackgroundColor(Gadget) ; updates the 'disabled background color'
  EndProcedure
  
  Procedure InsertCodeString(String$, MoveCursor = #False)
    ; String$: The string to insert.
    ; MoveCursor: If #True, the cursor will be relocated to the location of the caret symbol after insertion and the symbol deleted.
    ;             Otherwise, caret symbols will be inserted literally.
    
    Define Find.Sci_TextToFind
    
    If *ActiveSource\Parser\Encoding = 1 ; utf8
      Format = #PB_UTF8
    Else
      Format = #PB_Ascii
    EndIf
      
    ; Embed insertion into a single transaction, otherwise the caret symbol will reappear in an Undo action.
    SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
    
    BeforePos = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
    Converted$ = Space(StringByteLength(String$, Format))
    PokeS(@Converted$, String$, -1, Format)
    SendEditorMessage(#SCI_REPLACESEL, 0, @Converted$)
    
    ; Remove caret symbol and move cursor, if a position is specified.
    If MoveCursor And FindString(String$, "^")
      If *ActiveSource\Parser\Encoding = 1 ; utf8
        Find\lpstrText = UTF8("^")
      Else
        Find\lpstrText = Ascii("^")
      EndIf
      
      AfterPos = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
      Find\chrg\cpMin = BeforePos
      Find\chrg\cpMax = AfterPos
      FindPos = SendEditorMessage(#SCI_FINDTEXT, #SCFIND_NONE, @Find)
      SendEditorMessage(#SCI_DELETERANGE, FindPos, 1)
      SendEditorMessage(#SCI_GOTOPOS, FindPos)
      
      FreeMemory(Find\lpstrText)
    
    EndIf
    
    SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
    
  EndProcedure
  
  Procedure Undo()
    SendEditorMessage(#SCI_UNDO, 0, 0)
  EndProcedure
  
  Procedure Redo()
    SendEditorMessage(#SCI_REDO, 0, 0)
  EndProcedure
  
  Procedure Cut()
    SendEditorMessage(#SCI_CUT, 0, 0)
  EndProcedure
  
  Procedure Copy()
    SendEditorMessage(#SCI_COPY, 0, 0)
  EndProcedure
  
  Procedure Paste()
    ; update our foldmark fix as there are some problems
    ;lineOld = SendEditorMessage(#SCI_LINEFROMPOSITION, SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0), 0)
    SendEditorMessage(#SCI_PASTE, 0, 0)
    ;lineNew = SendEditorMessage(#SCI_LINEFROMPOSITION, SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0), 0)
    ;UpdateFoldingMarks(*ActiveSource\EditorGadget, lineOld, lineNew)
  EndProcedure
  
  Procedure PasteAsComment()
    ClipboardText$ = GetClipboardText()
    If ClipboardText$ <> ""
      ClipboardText$ = ReplaceString(ClipboardText$, #CRLF$, #LF$)
      ClipboardText$ = ReplaceString(ClipboardText$, #CR$,   #LF$)
      NumLines = 1 + CountString(ClipboardText$, #LF$)
      For i = 1 To NumLines
        If i > 1
          NewText$ + #LF$
        EndIf
        NewText$ + "; " + StringField(ClipboardText$, i, #LF$)
      Next i
      InsertCodeString(NewText$)
    EndIf
  EndProcedure
  
  Procedure.s InvertCase(Text$)
    Protected *C.CHARACTER = @Text$
    While (*C\c)
      Protected Upper.c = Asc(UCase(Chr(*C\c)))
      Protected Lower.c = Asc(LCase(Chr(*C\c)))
      If Upper <> Lower
        If *C\c = Upper
          *C\c = Lower
        Else
          *C\c = Upper
        EndIf
      EndIf
      *C + SizeOf(CHARACTER)
    Wend
    ProcedureReturn Text$
  EndProcedure
  
  Procedure AdjustSelection(Mode)
    ; Mode
    ; 0  = Upper case selection
    ; 1  = Lower case selection
    ; 2  = Invert case selection (Hello --> hELLO)
    ; 3  = Select whole word at cursor
    If *ActiveSource And *ActiveSource\IsForm = 0
      Current  = SendEditorMessage(#SCI_GETCURRENTPOS)
      Anchor   = SendEditorMessage(#SCI_GETANCHOR)
      SelStart = SendEditorMessage(#SCI_GETSELECTIONSTART)
      SelEnd   = SendEditorMessage(#SCI_GETSELECTIONEND)
      If (SelStart = SelEnd) Or (Mode = 3)
        WordStart = SendEditorMessage(#SCI_WORDSTARTPOSITION, SelStart, #True)
        WordEnd   = SendEditorMessage(#SCI_WORDENDPOSITION, SelEnd, #True)
        If WordStart < WordEnd
          SelStart = WordStart
          SelEnd   = WordEnd
          SendEditorMessage(#SCI_SETSEL, SelStart, SelEnd)
        EndIf
      EndIf
      If SelStart < SelEnd
        SendEditorMessage(#SCI_BEGINUNDOACTION)
        Select Mode
          Case 0 ; Upper Case
            SendEditorMessage(#SCI_UPPERCASE)
          Case 1 ; Lower Case
            SendEditorMessage(#SCI_LOWERCASE)
          Case 2 ; Invert Case
            BufferSize = SendEditorMessage(#SCI_GETSELTEXT, 0, #Null)
            If BufferSize > 0
              *Buffer = AllocateMemory(BufferSize)
              If *Buffer
                SendEditorMessage(#SCI_GETSELTEXT, 0, *Buffer)
                If (*ActiveSource\Parser\Encoding = 1) ; UTF-8
                  PokeS(*Buffer, InvertCase(PeekS(*Buffer, BufferSize, #PB_UTF8 | #PB_ByteLength)), -1, #PB_UTF8)
                Else
                  PokeS(*Buffer, InvertCase(PeekS(*Buffer, BufferSize, #PB_Ascii)), -1, #PB_Ascii)
                EndIf
                SendEditorMessage(#SCI_REPLACESEL, 0, *Buffer)
                FreeMemory(*Buffer)
              EndIf
            EndIf
          Case 3 ; Select Word
            ;
        EndSelect
        If Mode <> 3
          SendEditorMessage(#SCI_SETCURRENTPOS, Current)
          SendEditorMessage(#SCI_SETANCHOR, Anchor)
        EndIf
        SendEditorMessage(#SCI_ENDUNDOACTION)
      EndIf
    EndIf
  EndProcedure
  
  Procedure SelectAll()
    SendEditorMessage(#SCI_SELECTALL, 0, 0)
  EndProcedure
  
  Procedure ZoomStep(Direction)
    If Direction > 0
      SendEditorMessage(#SCI_ZOOMIN)
    ElseIf Direction < 0
      SendEditorMessage(#SCI_ZOOMOUT)
    EndIf
  EndProcedure
  
  Procedure ZoomDefault()
    SendEditorMessage(#SCI_SETZOOM, #ZOOM_Default)
  EndProcedure
  
  Procedure AddMarker()
    
    UpdateCursorPosition()
    If SendEditorMessage(#SCI_MARKERGET, *ActiveSource\CurrentLine-1, 0) & 1<<#MARKER_Marker  ; marker set
      SendEditorMessage(#SCI_MARKERDELETE, *ActiveSource\CurrentLine-1, #MARKER_Marker)
    Else
      SendEditorMessage(#SCI_MARKERADD, *ActiveSource\CurrentLine-1, #MARKER_Marker)
    EndIf
    
  EndProcedure
  
  Procedure ClearMarkers()
    SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_Marker, 0)
  EndProcedure
  
  Procedure MarkerJump()
    
    UpdateCursorPosition()
    line = SendEditorMessage(#SCI_MARKERNEXT, *ActiveSource\CurrentLine, 1<<#MARKER_Marker)
    If line = -1
      line = SendEditorMessage(#SCI_MARKERNEXT, 0, 1<<#MARKER_Marker)
    EndIf
    
    If line <> -1
      ChangeActiveLine(line+1, 0)
    EndIf
    
  EndProcedure
  
  Procedure.s GetMarkerString()  ; get a list of all markers as a string
    marker = SendEditorMessage(#SCI_MARKERNEXT, 0, 1<<#MARKER_Marker)
    If marker <> -1
      string$ = Str(marker+1)
      Repeat
        marker = SendEditorMessage(#SCI_MARKERNEXT, marker+1, 1<<#MARKER_Marker)
        If marker <> -1
          string$ + ","+Str(marker+1)
        EndIf
      Until marker = -1
      ProcedureReturn string$
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  
  Procedure ApplyMarkerString(Markers$) ; apply a string of marker numbers to the file
    SendEditorMessage(#SCI_MARKERDELETEALL, #MARKER_Marker, 0)
    index = 1
    Repeat
      field$ = StringField(Markers$, index, ",")
      If field$ <> ""
        SendEditorMessage(#SCI_MARKERADD, Val(field$)-1, #MARKER_Marker)
      EndIf
      index + 1
    Until field$ = ""
  EndProcedure
  
  Procedure SetFoldLevel(Line, Level)
    ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_SETFOLDLEVEL, Line, #SC_FOLDLEVELBASE+Level)
  EndProcedure
  
  Procedure SetFoldPoint(Line)
    ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_SETFOLDLEVEL, Line, ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_GETFOLDLEVEL, Line, 0) | #SC_FOLDLEVELHEADERFLAG)
  EndProcedure
  
  Procedure IsFoldPoint(Line)
    ProcedureReturn ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_GETFOLDLEVEL, Line, 0) & #SC_FOLDLEVELHEADERFLAG
  EndProcedure
  
  Procedure SetFoldState(Line, State)
    If State  ; SCI_SETFOLDEXPANDED acts strange when loading the file, so do it like this
      If ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_GETFOLDEXPANDED, Line, 0) = 0
        ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_TOGGLEFOLD, Line, 0)
      EndIf
    Else
      If ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_GETFOLDEXPANDED, Line, 0)
        ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_TOGGLEFOLD, Line, 0)
      EndIf
    EndIf
  EndProcedure
  
  Procedure GetFoldState(Line)
    ProcedureReturn ScintillaSendMessage(*ActiveSource\EditorGadget, #SCI_GETFOLDEXPANDED, Line, 0)
  EndProcedure
  
  
  Procedure HideLineNumbers(*Source.SourceFile, Hide)
    
    If Hide
      ScintillaSendMessage(*Source\EditorGadget, #SCI_SETMARGINWIDTHN, 0, 0)
    Else
      UpdateLineNumbers(*Source)
    EndIf
    
  EndProcedure
  
  
  Procedure UpdateLineNumbers(*Source.SourceFile)
    
    If EnableLineNumbers
      NbLines = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINECOUNT, 0, 0)
      
      If NbLines < 10 ; When editing small sources, the width is always jumping from 9<->10, so let's have at least 2 digits space always displayed
        NbLines = 10
      EndIf
      
      Lines$ = "_" + RSet("9", Len(Str(NbLines)), "9")
      ScintillaSendMessage(*Source\EditorGadget, #SCI_SETMARGINWIDTHN, 0, ScintillaSendMessage(*Source\EditorGadget, #SCI_TEXTWIDTH, #STYLE_LINENUMBER, ToAscii(Lines$)))
    EndIf
    
  EndProcedure
  
  
  Procedure AutoComplete_GetWordPosition(*X.INTEGER, *Y.INTEGER, *W.INTEGER, *H.INTEGER)
    
    ; *X\i and *Y\i MUST be set.
    ; *W\i and *H\i CAN be changed, otherwise they are the user default.
    
    Position = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
    
    ; Try to get the position of the word start, which looks better
    ;
    Line$ = GetCurrentLine()
    If Line$
      If GetWordBoundary(@Line$, Len(Line$), *ActiveSource\CurrentColumnChars-1, @StartIndex, @EndIndex, 1)
        Position = SendEditorMessage(#SCI_POSITIONFROMLINE, -1, 0) + StartIndex
      EndIf
    EndIf
    
    OffsetX = GadgetX(*ActiveSource\EditorGadget, #PB_Gadget_ScreenCoordinate)
    OffsetY = GadgetY(*ActiveSource\EditorGadget, #PB_Gadget_ScreenCoordinate) + EditorFontSize
    
    CompilerIf #CompileWindows
      ; Doesn't work the same on OSX (#SCI_POINTXFROMPOSITION probably doesn't return unscaled coordinates)
      OffsetX = DesktopScaledX(OffsetX)
      OffsetY = DesktopScaledY(OffsetY)
    CompilerEndIf
    
    *X\i = SendEditorMessage(#SCI_POINTXFROMPOSITION, 0, Position) + OffsetX
    *Y\i = SendEditorMessage(#SCI_POINTYFROMPOSITION, 0, Position) + OffsetY
    
    CompilerIf #CompileWindows
      *Y\i + 8
      
      GetWindowRect_(WindowID(#WINDOW_Main), @size.RECT)
      
      If *X\i + *W\i > size\right
        *X\i = size\right - *W\i - 5
      EndIf
      
      If *Y\i + *H\i > size\bottom - 5
        *H\i = size\bottom - *Y\i - 5
      EndIf
      
      *X\i = DesktopUnscaledX(*X\i)
      *Y\i = DesktopUnscaledY(*Y\i)
    CompilerEndIf
    
    CompilerIf #CompileLinux
      *Y\i + 8
      
      If *X\i + *W\i > WindowX(#WINDOW_Main)+WindowWidth(#WINDOW_Main)
        *X\i = WindowX(#WINDOW_Main)+WindowWidth(#WINDOW_Main)-*W\i - 5
      EndIf
      
      If *Y\i + *H\i > WindowY(#WINDOW_Main)+WindowHeight(#WINDOW_Main)+16
        *H\i = (WindowY(#WINDOW_Main)+WindowHeight(#WINDOW_Main)+16)-*Y\i-5 ; cannot move the window up, so make it smaller
      EndIf
    CompilerEndIf
    
    CompilerIf #CompileMac
      *Y\i + 6
      
      If *X\i + *W\i > WindowX(#WINDOW_Main)+WindowWidth(#WINDOW_Main)
        *X\i = WindowX(#WINDOW_Main)+WindowWidth(#WINDOW_Main)-*W\i - 5
      EndIf
      
      If *Y\i + *H\i > WindowY(#WINDOW_Main)+WindowHeight(#WINDOW_Main)+16
        *H\i = (WindowY(#WINDOW_Main)+WindowHeight(#WINDOW_Main)+16)-*Y\i-5 ; cannot move the window up, so make it smaller
      EndIf
    CompilerEndIf
    
  EndProcedure
  
  
  Procedure AutoComplete_SelectWord()
    
    Line$ = GetCurrentLine()
    If Line$
      Column = *ActiveSource\CurrentColumnChars-1
      
      If GetWordBoundary(@Line$, Len(Line$), Column, @StartIndex, @EndIndex, 1)
        LinePosition = SendEditorMessage(#SCI_POSITIONFROMLINE, -1, 0)
        InsertPosition = SendEditorMessage(#SCI_POSITIONRELATIVE, LinePosition, StartIndex)
        SendEditorMessage(#SCI_SETSEL, InsertPosition, LinePosition+*ActiveSource\CurrentColumnBytes-1)
      EndIf
    EndIf
    
  EndProcedure
  
  
  Procedure FindText(Mode, Reverse = #False) ; 1=find, 2=replace, 3=replace all
    Static LastSetSelection, LastSearchString$, SearchContinueMarker
    
    MatchesFound = 0
    ContinueQuestionAsked = 0
    
    If FindSearchString$ <> ""
      
      SelectionStart = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
      SelectionEnd   = SendEditorMessage(#SCI_GETSELECTIONEND  , 0, 0)
      
      Find.SCI_TextToFind
      
      If *ActiveSource\Parser\Encoding = 1 ; UTF8
        StringMode = #PB_UTF8
        Find\lpstrText = UTF8(FindSearchString$)
        *ReplaceString = UTF8(FindReplaceString$)
      Else
        StringMode = #PB_Ascii
        Find\lpstrText = Ascii(FindSearchString$)
        *ReplaceString = Ascii(FindReplaceString$)
      EndIf
      
      If FindSelectionOnly
        Find\chrg\cpMin = SelectionStart
        Find\chrg\cpMax = SelectionEnd
        
      ElseIf Mode = 3
        Find\chrg\cpMin = 0
        Find\chrg\cpMax = SendEditorMessage(#SCI_GETTEXTLENGTH, 0, 0)
        
      Else
        If Reverse
          ; Reverse search: #SCI_FINDTEXT support it if 'max' is lower than 'min'
          ;
          If Mode <> 2 And SelectionStart = LastSetSelection And LastSearchString$ = FindSearchString$
            Find\chrg\cpMin = SearchContinueMarker-1
          Else
            Find\chrg\cpMin = SelectionEnd
          EndIf
          Find\chrg\cpMax = 0
          
        Else
          If Mode <> 2 And SelectionStart = LastSetSelection And LastSearchString$ = FindSearchString$
            Find\chrg\cpMin = SearchContinueMarker
          Else
            Find\chrg\cpMin = SelectionStart
          EndIf
          Find\chrg\cpMax = SendEditorMessage(#SCI_GETTEXTLENGTH, 0, 0)
        EndIf
        
      EndIf
      
      If FindCaseSensitive: Flags | #SCFIND_MATCHCASE: EndIf
      If FindWholeWord    : Flags | #SCFIND_WHOLEWORD: EndIf
      
      Repeat
        Result = SendEditorMessage(#SCI_FINDTEXT, Flags, @Find)
        If Result <> -1
          line = SendEditorMessage(#SCI_LINEFROMPOSITION, Find\chrgText\cpMin, 0)
          linestart = SendEditorMessage(#SCI_POSITIONFROMLINE, line, 0)
          position = CountCharacters(*ActiveSource\EditorGadget, linestart, Find\chrgText\cpMin)
          Success = CheckSearchStringComment(line, position, 0)
        Else
          Success = 0
        EndIf
        
        If Success
          MatchesFound + 1
          
          Select Mode
              
            Case 1 ; find
              
              SendEditorMessage(#SCI_ENSUREVISIBLE, line, 0)
              SendEditorMessage(#SCI_LINESCROLL, -99999, -99999)
              SendEditorMessage(#SCI_LINESCROLL, 0, Line-3)
              SendEditorMessage(#SCI_SETSEL, Find\chrgText\cpMin, Find\chrgText\cpMax)
              LastSetSelection = Find\chrgText\cpMin
              SearchContinueMarker = Find\chrgText\cpMin + StringByteLength(FindSearchString$, StringMode) ; skip the found string on the next search
              Mode = 1                                                                                     ; make sure the 'replace' mode is not done twice
              
            Case 2 ; replace
                   ; do a replace only, if the result is what is marked before
              If Find\chrgText\cpMin = SelectionStart And Find\chrgText\cpMax = SelectionEnd
                SendEditorMessage(#SCI_ENSUREVISIBLE, line, 0)
                SendEditorMessage(#SCI_LINESCROLL, -99999, -99999)
                SendEditorMessage(#SCI_LINESCROLL, 0, Line-3)
                SendEditorMessage(#SCI_SETSEL, Find\chrgText\cpMin, Find\chrgText\cpMax)
                SendEditorMessage(#SCI_REPLACESEL, 0, *ReplaceString)
                SendEditorMessage(#SCI_SETSEL, Find\chrgText\cpMin, Find\chrgText\cpMin + StringByteLength(FindReplaceString$, StringMode))
                
                ; scan changed line and do updates as needed
                If PartialSourceScan(*ActiveSource, line, line) ; returns true if changed
                  UpdateFolding(*ActiveSource, line, line+5)
                  UpdateProcedureList()
                  UpdateVariableViewer()
                EndIf
                
                LastSetSelection = Find\chrgText\cpMin
                SearchContinueMarker = Find\chrgText\cpMin + StringByteLength(FindReplaceString$, StringMode) ; skip the replaced string on the next search
                                                                                                              ; after this, a normal "find" is done
                
                
              Else ; otherwise, act like "find"
                SendEditorMessage(#SCI_ENSUREVISIBLE, line, 0)
                SendEditorMessage(#SCI_LINESCROLL, -99999, -99999)
                SendEditorMessage(#SCI_LINESCROLL, 0, Line-3)
                SendEditorMessage(#SCI_SETSEL, Find\chrgText\cpMin, Find\chrgText\cpMax)
                LastSetSelection = Find\chrgText\cpMin
                SearchContinueMarker = Find\chrgText\cpMin ; so the next 'replace' will find this again
                Mode = 1
              EndIf
              
            Case 3 ; replace all
              
              SendEditorMessage(#SCI_SETSEL, Find\chrgText\cpMin, Find\chrgText\cpMax)
              SendEditorMessage(#SCI_REPLACESEL, 0, *ReplaceString)
              LastSetSelection = -1
              SearchContinueMarker = 0
              
          EndSelect
          
          Find\chrg\cpMin = Find\chrgText\cpMin + StringByteLength(FindReplaceString$, StringMode)
          SelectionEnd + StringByteLength(FindReplaceString$, StringMode) - StringByteLength(FindSearchString$, StringMode)
          Find\chrg\cpMax + StringByteLength(FindReplaceString$, StringMode) - StringByteLength(FindSearchString$, StringMode)
          
        Else
          
          If Mode = 1 Or FindReplaceString$ = ""
            Find\chrg\cpMin = Find\chrgText\cpMin + StringByteLength(FindSearchString$, StringMode)
          Else
            Find\chrg\cpMin = Find\chrgText\cpMin + StringByteLength(FindReplaceString$, StringMode)
          EndIf
          
        EndIf
        
        If Result = -1 And Success = 0 And Mode <> 3
          SendEditorMessage(#SCI_SETSEL, SelectionStart, SelectionEnd)
          If ContinueQuestionAsked = 0
            ContinueQuestionAsked = 1
            
            ; We use OkCancel instead of YesNo as the 'Esc' key is handled with a 'Cancel' button
            ;
            If Reverse
              If FindAutoWrap Or (MessageRequester(#ProductName$, Language("Find","NoMoreMatches")+"."+#NewLine+Language("Find","ContinueSearchReverse"), #FLAG_Question|#PB_MessageRequester_OkCancel) = #PB_MessageRequester_ResultOk)
                Find\chrg\cpMin = SendEditorMessage(#SCI_GETTEXTLENGTH, 0, 0)
                Find\chrg\cpMax = 0
                Result = 0 ; do not end the loop yet!
              EndIf
            Else
              If FindAutoWrap Or (MessageRequester(#ProductName$, Language("Find","NoMoreMatches")+"."+#NewLine+Language("Find","ContinueSearch"), #FLAG_Question|#PB_MessageRequester_OkCancel) = #PB_MessageRequester_ResultOk)
                Find\chrg\cpMin = 0
                Result = 0 ; do not end the loop yet!
              EndIf
            EndIf
          Else
            MessageRequester(#ProductName$, Language("Find","NoMoreMatches")+".", #FLAG_Info)
          EndIf
          
        ElseIf Result <> -1 And Success = 0 And Mode <> 3
          ; If an occurrence was found, but ignored (comment or string), must continue
          If Reverse
            Find\chrg\cpMin = Result - StringByteLength(FindSearchString$, StringMode)
          Else
            Find\chrg\cpMin = Result + StringByteLength(FindSearchString$, StringMode)
          EndIf
          
        EndIf
        
      Until Result = -1 Or (Success And Mode <> 3)
      
      LastSearchString$ = FindSearchString$
      
      FreeMemory(Find\lpstrText) ; its the utf8/ascii buffer
      FreeMemory(*ReplaceString)
      
      If Mode = 2 And Success ; in case of Mode 2, do a normal find too!
        ProcedureReturn FindText(1, Reverse)
        
      Else
        
        If Mode = 3 And FindSelectionOnly
          SendEditorMessage(#SCI_SETSEL, SelectionStart, SelectionEnd)
        EndIf
        If Mode = 3
          
          If MatchesFound > 0 And *ActiveSource\IsCode
            ; rescan source and update lists
            FullSourceScan(*ActiveSource)
            UpdateFolding(*ActiveSource, 0, -1)
            UpdateProcedureList()
            UpdateVariableViewer()
          EndIf
          
          MessageRequester(#ProductName$, Language("Find","SearchComplete")+"."+#NewLine+Str(MatchesFound)+" "+Language("Find","MatchesFound")+".", #FLAG_Info)
        EndIf
        
        SetActiveGadget(*ActiveSource\EditorGadget)
      EndIf
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
  Procedure ResizeEditorGadget(Gadget, X, Y, Width, Height)
    ResizeGadget(Gadget, x, y, Width, Height)
  EndProcedure
  
  Procedure FreeEditorGadget(Gadget)
    FreeGadget(Gadget)
  EndProcedure
  
  Procedure HideEditorGadget(Gadget, Hide)
    HideGadget(Gadget, Hide)
  EndProcedure
  
  Procedure MarkCurrentLine(LineNumber) ; works on current source
    SendEditorMessage(#SCI_MARKERADD, LineNumber-1, #MARKER_CurrentLine)  ; line background
    SendEditorMessage(#SCI_MARKERADD, LineNumber-1, #MARKER_CurrentLineSymbol)  ; marker symbol
    
    ; set the line into view (don't use ChangeActiveLine() here as it will scroll the line to top
    Position = SendEditorMessage(#SCI_POSITIONFROMLINE, LineNumber-1, 0)
    SendEditorMessage(#SCI_ENSUREVISIBLE, LineNumber-1, 0) ; Ensure the block is unfolded, if it was folded. Needs to be before #SCI_GOTOLINE (https://www.purebasic.fr/english/viewtopic.php?f=4&t=44871)
    SendEditorMessage(#SCI_SETSEL, Position, Position)
    SendEditorMessage(#SCI_SCROLLCARET, 0, 0)
  EndProcedure
  
  Procedure ClearCurrentLine(*Source.SourceFile)  ; works on all sources
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_CurrentLine, 0)
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_CurrentLineSymbol, 0)
    If *Source = *ActiveSource ; removing background markers sometimes is only done when redrawing.. really annoying!
      RedrawGadget(*Source\EditorGadget)
    EndIf
  EndProcedure
  
  Procedure MarkErrorLine(LineNumber)  ; works on current source
    SendEditorMessage(#SCI_MARKERADD, LineNumber-1, #MARKER_Error)
    SendEditorMessage(#SCI_MARKERADD, LineNumber-1, #MARKER_ErrorSymbol)
  EndProcedure
  
  Procedure MarkWarningLine(LineNumber)  ; works on current source
    SendEditorMessage(#SCI_MARKERADD, LineNumber-1, #MARKER_Warning)
    SendEditorMessage(#SCI_MARKERADD, LineNumber-1, #MARKER_WarningSymbol)
  EndProcedure
  
  Procedure ClearErrorLines(*Source.SourceFile)  ; works on all sources
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_Warning, 0)
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_WarningSymbol, 0)
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_Error, 0)
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_ErrorSymbol, 0)
    If *Source = *ActiveSource ; removing background markers sometimes is only done when redrawing.. really annoying!
      RedrawGadget(*Source\EditorGadget)
    EndIf
  EndProcedure
  
  Procedure GetBreakPoint(*Source.SourceFile, LineNumber)
    ProcedureReturn ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERNEXT, LineNumber, 1<<#MARKER_Breakpoint)
  EndProcedure
  
  Procedure ClearBreakPoint(LineNumber)
    SendEditorMessage(#SCI_MARKERDELETE, LineNumber, #MARKER_Breakpoint)
    SendEditorMessage(#SCI_MARKERDELETE, LineNumber, #MARKER_BreakpointSymbol)
    RedrawGadget(*ActiveSource\EditorGadget)
  EndProcedure
  
  Procedure MarkBreakPoint(LineNumber)
    SendEditorMessage(#SCI_MARKERADD, LineNumber, #MARKER_Breakpoint)
    SendEditorMessage(#SCI_MARKERADD, LineNumber, #MARKER_BreakpointSymbol)
  EndProcedure
  
  Procedure ClearAllBreakPoints(*Source.SourceFile)
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_Breakpoint, 0)
    ScintillaSendMessage(*Source\EditorGadget, #SCI_MARKERDELETEALL, #MARKER_BreakpointSymbol, 0)
    If *Source = *ActiveSource ; removing background markers sometimes is only done when redrawing.. really annoying!
      RedrawGadget(*Source\EditorGadget)
    EndIf
  EndProcedure
  
CompilerEndIf
