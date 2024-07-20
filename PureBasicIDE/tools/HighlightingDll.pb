; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



XIncludeFile "../HighlightingEngine.pb"

Prototype UserCallback(*Position, Length, Color)
Global    UserCallback.UserCallback
Global    DummySource.SourceFile

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

Procedure DllCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
  UserCallback(*StringStart, Length, *Color)
EndProcedure

ProcedureDLL AttachProcess(Instance)
  
  ; Set up the global stuff here
  ;
  *NormalTextColor    = #SYNTAX_Text
  *BasicKeywordColor  = #SYNTAX_Keyword
  *CommentColor       = #SYNTAX_Comment
  *ConstantColor      = #SYNTAX_Constant
  *StringColor        = #SYNTAX_String
  *PureKeywordColor   = #SYNTAX_Function
  *ASMKeywordColor    = #SYNTAX_Asm
  *OperatorColor      = #SYNTAX_Operator
  *StructureColor     = #SYNTAX_Structure
  *NumberColor        = #SYNTAX_Number
  *PointerColor       = #SYNTAX_Pointer
  *SeparatorColor     = #SYNTAX_Separator
  *LabelColor         = #SYNTAX_Label
  *ModuleColor        = #SYNTAX_Module
  *BadEscapeColor     = #SYNTAX_String
  
  ; We do no case corrections from the dll
  ;
  EnableColoring = 1
  EnableCaseCorrection = 0
  EnableKeywordBolding = 0
  LoadHighlightingFiles = 0
  
  ; This is to enable InlineAsm parsing
  ;
  DummySource\EnableASM = 1
  *ActiveSource = @DummySource
  
  ; Call the init functions
  ;
  InitSyntaxCheckArrays()
  InitSyntaxHighlighting()
  
EndProcedure

ProcedureDLL SyntaxHighlight(*Buffer, Length, Callback.UserCallback, EnableASM)
  If *Buffer And Length > 0 And Callback
    UserCallback = Callback
    
    ; If EnableAsm is set, it will treat it as a source file, and use the
    ; setting from DummySource, so InlineASM will be detected
    ;
    HighlightingEngine(*Buffer, Length, -1, @DllCallback(), EnableASM)
    
  EndIf
EndProcedure
