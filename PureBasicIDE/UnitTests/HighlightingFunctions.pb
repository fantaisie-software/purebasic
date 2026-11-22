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
