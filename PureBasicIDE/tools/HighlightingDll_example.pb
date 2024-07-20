; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
;
;
; The SyntaxHighlighting.dll provides the syntax parser of the
; PureBasic IDE in form of a dll, so it can be easily reused
; to do other tasks as well.
;
; Some notes:
;
; - For speed reasons, the dll is not threadsafe.
;
; - The highlighter does not handle unicode. It does however handle UTF8, so if
;   Unicode text should be parsed, convert it to UTF8 first.
;
; The dll exports only one function:
;
;    SyntaxHighlight(*Buffer, Length, @Callback(), EnableAsm)
;
; *Buffer and Length specify the text buffer to parse.
;
; Callback() must have the parameters as in the example below and will be called
; for each parsed token.
;
; If EnableAsm is set to nonzero, the parser will report asm keywords also outside of
; the special ! lines, just as the InlineAsm parser does.
;

; Color values returned in the Dll callback
;
Enumeration
  #SYNTAX_Text
  #SYNTAX_Keyword
  #SYNTAX_Comment
  #SYNTAX_Constant
  #SYNTAX_String
  #SYNTAX_Function
  #SYNTAX_Asm
  #SYNTAX_Operator
  #SYNTAX_Structure
  #SYNTAX_Number
  #SYNTAX_Pointer
  #SYNTAX_Separator
  #SYNTAX_Label
  #SYNTAX_Module
EndEnumeration

#Dll    = 0
#Input  = 0
#Output = 1

; Callback that is called from the dll.
;
; NOTE: For performance reasons, whitespace characters (space, tab, newline)
; are returned together with the tokens they surround to reduce the number
; of required callback calls. If this is not desired, you must separate them
; here in the callback manually.
;
; The original buffer is not modified. The *Position parameter points to the
; current position in the original buffer.
;
;
Procedure Callback(*Position, Length, Color)
  
  ; In this example, we simply write the data as it is to the output
  ; buffer, and just apply bold to keywords, and colors to functions and comments.
  ;
  Select Color
      
    Case #SYNTAX_Keyword
      WriteString(#Output, "<b>")
      WriteData(#Output, *Position, Length)
      WriteString(#Output, "</b>")
      
    Case #SYNTAX_Function
      WriteString(#Output, "<font color=#0000FF>")
      WriteData(#Output, *Position, Length)
      WriteString(#Output, "</font>")
      
    Case #SYNTAX_Comment
      WriteString(#Output, "<font color=#808080>")
      WriteData(#Output, *Position, Length)
      WriteString(#Output, "</font>")
      
    Default
      WriteData(#Output, *Position, Length)
      
  EndSelect
  
EndProcedure

; Simple example code. It loads a PB file and outputs a HTML file with some
; coloring for functions, keywords and comments
;
If OpenLibrary(#Dll, "SyntaxHighlighting.dll")
  
  InputFile$ = OpenFileRequester("Select PB File", "*.pb", "PB Files|*.pb|All Files|*.*", 0)
  If InputFile$
    OutputFile$ = SaveFileRequester("Select Target file", InputFile$+".html", "Html Files|*.html|All Files|*.*", 0)
    
    If ReadFile(#Input, InputFile$) And CreateFile(#Output, OutputFile$)
      Length = Lof(#Input)
      *Buffer = AllocateMemory(Length)
      
      If *Buffer
        ReadData(#Input, *Buffer, Length)
        
        WriteStringN(#Output, "<html><body><pre>")
        CallFunction(#Dll, "SyntaxHighlight", *Buffer, Length, @Callback(), 0)
        WriteStringN(#Output, "</pre></html></body>")
      EndIf
      
      CloseFile(#Input)
      CloseFile(#Output)
    EndIf
    
  EndIf
  
  CloseLibrary(#Dll)
EndIf