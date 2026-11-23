; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the find / replace helpers (HighlightingFunctions.pb), used by the Find/Replace window,
; Find in Files and the selection highlighting

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

; Is the first Match$ found in Text$ a whole word? (ASCII strings: chars = bytes in UTF-8)
Procedure WholeWordAt(Text$, Match$)
  Protected *Buffer = UTF8(Text$)
  Protected Offset = FindString(Text$, Match$) - 1
  Protected Result = IsWholeWordMatch(*Buffer, *Buffer + MemorySize(*Buffer) - 1, *Buffer + Offset, Len(Match$))
  FreeMemory(*Buffer)
  ProcedureReturn Result
EndProcedure

ProcedureUnit WholeWord_Basics()
  Assert(WholeWordAt("a = Window + 1", "Window"))
  Assert(WholeWordAt("Window", "Window"), "whole buffer")
  Assert(WholeWordAt("OpenWindow(0)", "Window") = #False, "word character before")
  Assert(WholeWordAt("Window2 = 1", "Window") = #False, "word character after")
  Assert(WholeWordAt("a_Window", "Window") = #False, "underscore is a word character")
EndProcedureUnit

; https://github.com/fantaisie-software/purebasic/pull/542
ProcedureUnit WholeWord_NonWordEdges()
  Assert(WholeWordAt("x = #Window", "#Window"), "match starting with a non-word character")
  Assert(WholeWordAt("x=#Window", "#Window"), "no space before")
  Assert(WholeWordAt("Data[ZC-12]", "[ZC-"), "match starting and ending with non-word characters")
  Assert(WholeWordAt("x = #WindowMain", "#Window") = #False, "the right edge is still checked")
EndProcedureUnit

ProcedureUnit GetWord_AtPosition()
  Protected Line$ = "  a = OpenWindow(#Main, x*y)"
  
  AssertString(GetWord(@Line$, Len(Line$), 8), "OpenWindow", "inside a word")
  AssertString(GetWord(@Line$, Len(Line$), 6), "OpenWindow", "at the word start")
  AssertString(GetWord(@Line$, Len(Line$), 16), "OpenWindow", "just after the word")
  AssertString(GetWord(@Line$, Len(Line$), 19), "Main", "without the # (only the AutoComplete mode keeps it)")
  AssertString(GetWord(@Line$, Len(Line$), 24), "x", "x*y is two words")
  AssertString(GetWord(@Line$, Len(Line$), 26), "y")
EndProcedureUnit

ProcedureUnit GetModulePrefix_BeforeCursor()
  Protected Line$ = "x = Module::Name"
  
  AssertString(GetModulePrefix(@Line$, Len(Line$), 12), "Module", "the cursor after ::")
  AssertString(GetModulePrefix(@Line$, Len(Line$), 4), "", "no ::")
  
  Line$ = "Mod :: x"
  AssertString(GetModulePrefix(@Line$, Len(Line$), 7), "Mod", "spaces around ::")
EndProcedureUnit

; Returns the kind of the end of the line: 0 = code, 1 = comment, 2 = string, 3 = char constant
ProcedureUnit IsCommentOrString_LineEnd()
  Assert(IsCommentOrString("x = 1") = 0)
  Assert(IsCommentOrString("x = 1 ; comment") = 1)
  Assert(IsCommentOrString(~"x = \"abc") = 2, "open string")
  Assert(IsCommentOrString(~"x = \"a;b\" + y") = 0, "; inside a closed string")
  Assert(IsCommentOrString(~"x = \"a\" ; c") = 1)
  Assert(IsCommentOrString("x = 'a") = 3, "open char constant")
  Assert(IsCommentOrString("x = ';' + y") = 0, "closed char constant")
  Assert(IsCommentOrString(~"x = ~\"a\\\"b") = 2, "an escaped quote does not end an escaped string")
  Assert(IsCommentOrString(~"x = ~\"a\\\"b\" + y") = 0, "closed escaped string")
  Assert(IsCommentOrString("x = ~" + #DQUOTE$ + "a\") = 2, "ends after a backslash")
  Assert(IsCommentOrString("") = 0)
EndProcedureUnit

; The QuickHelp shows the parameters of the function the cursor is in
ProcedureUnit FindEnclosingFunction_Parameters()
  Protected Line$, Start, Parameter
  
  Line$ = "OpenWindow(0, 10, "
  AssertString(FindEnclosingFunction(Line$, Len(Line$), @Start, @Parameter), "OPENWINDOW")
  Assert(Start = 0 And Parameter = 3, Str(Start) + "," + Str(Parameter))
  
  Line$ = "x = Left(Mid(a$, 1, 2), "
  AssertString(FindEnclosingFunction(Line$, Len(Line$), @Start, @Parameter), "LEFT", "after a closed inner call")
  Assert(Start = 4 And Parameter = 2, Str(Start) + "," + Str(Parameter))
  
  Line$ = "x = Left(Mid(a$, "
  AssertString(FindEnclosingFunction(Line$, Len(Line$), @Start, @Parameter), "MID", "in the inner call")
  Assert(Start = 9 And Parameter = 2, Str(Start) + "," + Str(Parameter))
  
  Line$ = ~"Debug(\"a(b, c\", "
  AssertString(FindEnclosingFunction(Line$, Len(Line$), @Start, @Parameter), "DEBUG", "strings are ignored")
  Assert(Parameter = 2)
  
  Line$ = "x = Sin(1) + 2"
  AssertString(FindEnclosingFunction(Line$, Len(Line$), @Start, @Parameter), "", "not inside a call")
  Assert(Start = 0 And Parameter = 0)
EndProcedureUnit

; The folding state is saved in the source settings: 6 states per char, the bits set for expanded folds
ProcedureUnit DecodeNextLineState_Bits()
  Protected i, Result$
  
  DecodeNextLineState("Bg") ; B = 1 (only the first expanded), g = 32 (only the 12th)
  For i = 1 To 14
    Result$ + Str(DecodeNextLineState(""))
  Next i
  AssertString(Result$, "10000000000111", "after the saved states, the folds are expanded: " + Result$)
  
  DecodeNextLineState(" A" + #CRLF$ + "-") ; invalid chars are removed, - = 63 (all expanded)
  Result$ = ""
  For i = 1 To 12
    Result$ + Str(DecodeNextLineState(""))
  Next i
  AssertString(Result$, "000000111111", Result$)
EndProcedureUnit
