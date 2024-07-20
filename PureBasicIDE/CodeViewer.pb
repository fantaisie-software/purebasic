; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
; Methods to create a readonly scintilla gadget for code display
; With the configured IDE colors
;

Global HighlightCodeViewer

Procedure CodeViewer_HighlightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
  ScintillaSendMessage(HighlightCodeViewer, #SCI_SETSTYLING, Length, *Color)
EndProcedure

Procedure CodeViewer_UpdateHighlight(Gadget)
  
  HighlightCodeViewer = Gadget
  
  ; re-highlight the text
  Size = ScintillaSendMessage(Gadget, #SCI_GETTEXTLENGTH)
  *Buffer = AllocateMemory(Size+1)
  If *Buffer
    ScintillaSendMessage(Gadget, #SCI_GETTEXT, Size+1, *Buffer)
    ScintillaSendMessage(Gadget, #SCI_STARTSTYLING, 0, $FFFFFF)
    HighlightingEngine(*Buffer, Size, 0, @CodeViewer_HighlightCallback(), 0)
    FreeMemory(*Buffer)
  EndIf
  
  ; update line numbers size (if enabled)
  If ScintillaSendMessage(Gadget, #SCI_GETMARGINWIDTHN, 0) > 0
    NbLines = ScintillaSendMessage(Gadget, #SCI_GETLINECOUNT, 0, 0)
    
    If NbLines < 10 ; 2 digits minimum, as with the main code area
      NbLines = 10
    EndIf
    
    Lines$ = "_" + RSet("9", Len(Str(NbLines)), "9")
    ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 0, ScintillaSendMessage(Gadget, #SCI_TEXTWIDTH, #STYLE_LINENUMBER, ToAscii(Lines$)))
  EndIf
  
EndProcedure



Procedure UpdateCodeViewer(Gadget)
  
  If ScintillaSendMessage(Gadget, #SCI_GETMARGINWIDTHN, 0) > 0
    LineNumbers = #True
  Else
    LineNumbers = #False
  EndIf
  
  ; Gtk2+ 'Pango' need an "!" before the font name (else it will use GDK font)
  ;
  CompilerIf #CompileLinuxGtk
    FontName$ = "!"+EditorFontName$
    ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, #STYLE_DEFAULT, ToAscii(FontName$))
  CompilerElse
    ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, #STYLE_DEFAULT, ToAscii(EditorFontName$))
  CompilerEndIf
  
  ScintillaSendMessage(Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT,  EditorFontSize)
  
  If EditorFontStyle & #PB_Font_Bold
    ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD, #STYLE_DEFAULT, 1)
  Else
    ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD, #STYLE_DEFAULT, 0)
  EndIf
  If EditorFontStyle & #PB_Font_Italic
    ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, #STYLE_DEFAULT, 1)
  Else
    ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, #STYLE_DEFAULT, 0)
  EndIf
  
  If EnableColoring
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, Colors(#COLOR_GlobalBackground)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLECLEARALL, 0, 0) ; to make the background & font change effective!
    
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  1, Colors(#COLOR_NormalText)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  2, Colors(#COLOR_BasicKeyword)\DisplayValue)
    
    If EnableKeywordBolding
      ; Gtk2 'Pango' need an "!" before the font name (else it will use GDK font)
      ;
      CompilerIf #CompileLinuxGtk
        FontName$ = "!"+EditorBoldFontName$
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT,  2, ToAscii(FontName$))
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, 14, ToAscii(FontName$))
      CompilerElse
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT,  2, ToAscii(EditorBoldFontName$))
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, 14, ToAscii(EditorBoldFontName$))
      CompilerEndIf
      
      ScintillaSendMessage(Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT, EditorFontSize)
      ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD,  2, 1)             ; Bold (no effect on linux, but maybe on windows later)
      ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD,  14, 1)
      If EditorFontStyle & #PB_Font_Italic
        ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, 2, 1)
        ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, 14, 1)
      EndIf
    EndIf
    
    If LineNumbers
      ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_LINENUMBER, Colors(#COLOR_LineNumberBack)\DisplayValue)
      ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_LINENUMBER, Colors(#COLOR_LineNumber)\DisplayValue)
    EndIf
    
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  3, Colors(#COLOR_Comment)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  4, Colors(#COLOR_Constant)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  5, Colors(#COLOR_String)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  6, Colors(#COLOR_PureKeyword)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  7, Colors(#COLOR_ASMKeyword)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  8, Colors(#COLOR_Operator)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  9, Colors(#COLOR_Structure)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 10, Colors(#COLOR_Number)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 11, Colors(#COLOR_Pointer)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 12, Colors(#COLOR_Separator)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 13, Colors(#COLOR_Label)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 14, Colors(#COLOR_CustomKeyword)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 15, Colors(#COLOR_Module)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 16, Colors(#COLOR_BadBrace)\DisplayValue)
    
    CompilerIf #CompileWindows
      If Colors(#COLOR_Selection)\DisplayValue = -1 Or EnableAccessibility ; special accessibility scheme
        ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, GetSysColor_(#COLOR_HIGHLIGHT))
      Else
        ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, Colors(#COLOR_Selection)\DisplayValue)
      EndIf
      
      If Colors(#COLOR_SelectionFront)\DisplayValue = -1 Or EnableAccessibility
        ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
      Else
        ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, Colors(#COLOR_SelectionFront)\DisplayValue)
      EndIf
    CompilerElse
      ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, Colors(#COLOR_Selection)\DisplayValue)
      ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, Colors(#COLOR_SelectionFront)\DisplayValue)
    CompilerEndIf
    
    ScintillaSendMessage(Gadget, #SCI_SETCARETLINEBACK, Colors(#COLOR_CurrentLine)\DisplayValue, 0)
    ScintillaSendMessage(Gadget, #SCI_SETCARETFORE,     Colors(#COLOR_Cursor)\DisplayValue, 0)
    
    If Colors(#COLOR_CurrentLine)\Enabled = 0 Or Colors(#COLOR_CurrentLine)\DisplayValue = Colors(#COLOR_GlobalBackground)\DisplayValue
      ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, 0, 0) ; disable the different color for the current line
    Else
      ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, 1, 0) ; enable the different color for the current line
    EndIf
    
  Else  ; Coloring Disabled
    ScintillaSendMessage(Gadget, #SCI_STYLERESETDEFAULT, 0, 0)
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, $FFFFFF)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_DEFAULT, $000000)
    ScintillaSendMessage(Gadget, #SCI_STYLECLEARALL, 0, 0) ; to make the background & font change effective!
    
    ScintillaSendMessage(Gadget, #SCI_SETCARETLINEBACK, $FFFFFF, 0)
    ScintillaSendMessage(Gadget, #SCI_SETCARETFORE,     $000000, 0)
    
    CompilerIf #CompileWindows
      ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, GetSysColor_(#COLOR_HIGHLIGHT))
      ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
    CompilerElse
      ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, $C0C0C0)
      ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, $000000)
    CompilerEndIf
    
    If LineNumbers
      ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_LINENUMBER, $FFFFFF)
      ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_LINENUMBER, $000000)
    EndIf
    
    ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, 0, 0) ; disable the different color for the current line
  EndIf
  
  ScintillaSendMessage(Gadget, #SCI_SETTABWIDTH, TabLength)
  ScintillaSendMessage(Gadget, #SCI_SETUSETABS, RealTab)
  
  CodeViewer_UpdateHighlight(Gadget)
  
EndProcedure

; Note: *Buffer must be null-terminated!
Procedure SetCodeViewer(Gadget, *Buffer, Encoding)
  ; set writable for the update
  ScintillaSendMessage(Gadget, #SCI_SETREADONLY, 0)
  
  If Encoding <> 0
    ScintillaSendMessage(Gadget, #SCI_SETCODEPAGE, #SC_CP_UTF8)
  Else
    ScintillaSendMessage(Gadget, #SCI_SETCODEPAGE, 0)
  EndIf
  
  ScintillaSendMessage(Gadget, #SCI_SETTEXT, 0, *Buffer)
  
  ; back to readonly
  ScintillaSendMessage(Gadget, #SCI_SETREADONLY, 1)
  
  CodeViewer_UpdateHighlight(Gadget)
EndProcedure


Procedure CreateCodeViewer(Gadget, x, y, width, height, LineNumbers)
  GadgetID = ScintillaGadget(Gadget, x, y, width, height, @EmptyScintillaCallback())
  If Gadget = #PB_Any
    Gadget = GadgetID
  EndIf
  InitCodeViewer(Gadget, LineNumbers)
  
  ProcedureReturn GadgetID
EndProcedure

Procedure InitCodeViewer(Gadget, LineNumbers)
  ScintillaSendMessage(Gadget, #SCI_CLEARCMDKEY, #SCK_TAB) ; to enable the window shortcuts
  ScintillaSendMessage(Gadget, #SCI_CLEARCMDKEY, #SCK_RETURN)
  ApplyWordChars(Gadget)
  ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 1, 0)
  
  If LineNumbers
    ; set to something > 0 to indicate that they are enabled
    ; see CodeViewer_UpdateHighlight()
    ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 0, 16)
    ScintillaSendMessage(Gadget, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
  EndIf
  
  ScintillaSendMessage(Gadget, #SCI_SETREADONLY, 1)
  UpdateCodeViewer(Gadget)
EndProcedure



