; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the tokenizer used by the syntax highlighting (HighlightingEngine.pb), built on its own
; like tools/HighlightingDll.pb (the SDK SyntaxHighlighting.dll): only the PureBasic keywords are known,
; not the library functions (those are read from the compiler by the IDE).

PureUnitOptions(MainCode) ; HighlightingEngine.pb creates its tables in its main code
CompilerIf #PureUnit_ResidentVersion < 201
  CompilerError "This test needs PureUnit 1.5 or newer (for PureUnitOptions(MainCode))"
CompilerEndIf

IncludePath "../"
XIncludeFile "HighlightingEngine.pb"

; The "colors" passed to the callback are the index of the token kind in this list
#TokenKinds$ = "Text,Keyword,Comment,Constant,String,Function,Asm,Operator,Structure,Number,Pointer,Separator,Label,Module"

Global DummySource.SourceFile
Global Tokens$, *LastEnd, *LastColor

; Adjacent pieces of the same color are merged, as they look the same in the editor (the engine can
; report a token in several pieces). The runs of spaces are not interesting here and are dropped.
Procedure TokenCallback(*Start, Length, *Color, IsBold, TextChanged)
  Protected Text$ = PeekS(*Start, Length, #PB_UTF8 | #PB_ByteLength)
  If Trim(Text$) <> ""
    If *Start = *LastEnd And *Color = *LastColor
      Tokens$ = Left(Tokens$, Len(Tokens$) - 1) + Text$ + "]"
    Else
      Tokens$ + " " + StringField(#TokenKinds$, *Color + 1, ",") + "[" + Trim(Text$) + "]"
    EndIf
    *LastEnd   = *Start + Length
    *LastColor = *Color
  Else
    *LastEnd = 0
  EndIf
EndProcedure

; Tokenize one line of code, returns "Kind[text] Kind[text] ..."
Procedure.s Tokenize(Line$)
  Protected *Buffer = UTF8(Line$)
  Tokens$ = ""
  *LastEnd = 0
  HighlightingEngine(*Buffer, MemorySize(*Buffer) - 1, -1, @TokenCallback(), #True)
  FreeMemory(*Buffer)
  ProcedureReturn Trim(Tokens$)
EndProcedure

; Same setup as AttachProcess() in tools/HighlightingDll.pb
ProcedureUnitStartup Setup()
  *NormalTextColor   = 0 : *BasicKeywordColor = 1 : *CommentColor   = 2  : *ConstantColor  = 3
  *StringColor       = 4 : *PureKeywordColor  = 5 : *ASMKeywordColor = 6 : *OperatorColor  = 7
  *StructureColor    = 8 : *NumberColor       = 9 : *PointerColor   = 10 : *SeparatorColor = 11
  *LabelColor        = 12 : *ModuleColor      = 13 : *BadEscapeColor = 4
  EnableColoring = 1
  EnableCaseCorrection = 0
  EnableKeywordBolding = 0
  LoadHighlightingFiles = 0
  *ActiveSource = @DummySource
  InitSyntaxCheckArrays()
  InitSyntaxHighlighting()
EndProcedureUnit

ProcedureUnit Tokens_KeywordsAndComments()
  Protected Result$ = Tokenize("If a = 1 ; done")
  AssertString(Result$, "Keyword[If] Text[a] Operator[=] Number[1] Comment[; done]", Result$)
  
  Result$ = Tokenize("EndIf;no space")
  AssertString(Result$, "Keyword[EndIf] Comment[;no space]", Result$)
EndProcedureUnit

ProcedureUnit Tokens_Strings()
  Protected Result$ = Tokenize(~"x$ = \"a;b\" + ~\"\\n\"")
  AssertString(Result$, ~"Text[x$] Operator[=] String[\"a;b\"] Operator[+] String[~\"\\n\"]", Result$)
  
  Result$ = Tokenize("c = 'A'")
  AssertString(Result$, "Text[c] Operator[=] Constant['A']", "a character is a constant: " + Result$)
EndProcedureUnit

ProcedureUnit Tokens_ConstantsPointersStructures()
  Protected Result$ = Tokenize("*p.POINT = #Null : x = MyMod::Value")
  Assert(FindString(Result$, "Pointer[*p]"), Result$)
  Assert(FindString(Result$, "Structure[POINT]"), Result$)
  Assert(FindString(Result$, "Constant[#Null]"), Result$)
  Assert(FindString(Result$, "Separator[:]"), Result$)
  Assert(FindString(Result$, "Module[MyMod] Operator[::] Text[Value]"), Result$)
EndProcedureUnit

ProcedureUnit Tokens_Numbers()
  Protected Result$ = Tokenize("a = $FF + %101 + 1.5e3")
  AssertString(Result$, "Text[a] Operator[=] Number[$FF] Operator[+] Number[%101] Operator[+] Number[1.5e3]", Result$)
EndProcedureUnit

ProcedureUnit Tokens_Unicode()
  Protected Result$ = Tokenize(~"a$ = \"été\" ; ça")
  AssertString(Result$, ~"Text[a$] Operator[=] String[\"été\"] Comment[; ça]", Result$)
EndProcedureUnit
