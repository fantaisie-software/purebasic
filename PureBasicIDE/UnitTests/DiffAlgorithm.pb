; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the diff algorithm (DiffAlgorithm.pb), which only needs the declarations of Common.pb.
; No PureUnitOptions(MainCode) here: these files have no main code to run, and it keeps the test fast.

IncludePath "../"
XIncludeFile "CompilerFlags.pb"
XIncludeFile "Common.pb"
XIncludeFile "Macro.pb"
XIncludeFile "DiffAlgorithm.pb"

; Diff A$ and B$ (lines separated by #LF$), returns the edit script as "=1 +2 -1" (op and lines)
Procedure.s DiffText(A$, B$, Flags = 0)
  Protected Context.DiffContext, Result$
  Protected *A = UTF8(A$), *B = UTF8(B$)
  
  Diff(@Context, *A, MemorySize(*A) - 1, *B, MemorySize(*B) - 1, Flags)
  ForEach Context\Edits()
    Result$ + Mid("=+-", Context\Edits()\Op, 1) + Str(Context\Edits()\Lines) + " "
  Next
  
  FreeMemory(*A)
  FreeMemory(*B)
  ProcedureReturn RTrim(Result$)
EndProcedure

ProcedureUnit Diff_Edits()
  AssertString(DiffText("a" + #LF$ + "b" + #LF$ + "c", "a" + #LF$ + "b" + #LF$ + "c"), "=3", "identical")
  AssertString(DiffText("a" + #LF$ + "c", "a" + #LF$ + "b" + #LF$ + "c"), "=1 +1 =1", "insert")
  AssertString(DiffText("a" + #LF$ + "b" + #LF$ + "c", "a" + #LF$ + "c"), "=1 -1 =1", "delete")
  AssertString(DiffText("", "a"), "+1", "from an empty file")
EndProcedureUnit

ProcedureUnit Diff_Flags()
  AssertString(DiffText("Hello", "HELLO"), "+1 -1", "a changed line")
  AssertString(DiffText("Hello", "HELLO", #DIFF_IgnoreCase), "=1")
  AssertString(DiffText("  x = 1", "x = 1", #DIFF_IgnoreSpaceLeft), "=1")
  AssertString(DiffText("x = 1  ", "x = 1", #DIFF_IgnoreSpaceRight), "=1")
  AssertString(DiffText(~"x  =\t 1 ", "x = 1", #DIFF_IgnoreSpaceAll), "=1", "runs of spaces/tabs are collapsed")
  AssertString(DiffText("x=1", "x = 1", #DIFF_IgnoreSpaceAll), "+1 -1", "an added space is still a change (like diff -b)")
EndProcedureUnit

ProcedureUnit Diff_LineEndings()
  AssertString(DiffText("a" + #CRLF$ + "b" + #CRLF$, "a" + #CRLF$ + "b" + #CRLF$), "=2", "CRLF")
  AssertString(DiffText("a" + #CR$ + "b", "a" + #CR$ + "b"), "=2", "CR alone")
  AssertString(DiffText("a" + #CRLF$ + "b", "a" + #LF$ + "b"), "+1 -1 =1", "the line ending is part of the line")
  AssertString(DiffText("a" + #LF$, "a"), "+1 -1", "a missing last newline")
EndProcedureUnit

; Random edits of a random text: the edit script must rebuild B from A, and be minimal: the number
; of deleted + inserted lines is N + M - 2 * (longest common subsequence)
Procedure CheckRandomDiff(LinesA, LinesB)
  Protected Context.DiffContext, A$, B$, i, j, Rebuilt$, Changes
  Protected *A, *B, *Cursor
  
  For i = 1 To LinesA : A$ + Chr('a' + Random(3)) + #LF$ : Next i
  For i = 1 To LinesB : B$ + Chr('a' + Random(3)) + #LF$ : Next i
  *A = UTF8(A$) : *B = UTF8(B$)
  
  Diff(@Context, *A, MemorySize(*A) - 1, *B, MemorySize(*B) - 1)
  
  *Cursor = *A
  ForEach Context\Edits()
    Select Context\Edits()\Op
      Case #DIFF_MATCH
        Assert(Context\Edits()\Start = *Cursor, "a match is the next part of A")
        Rebuilt$ + PeekS(*Cursor, Context\Edits()\Length, #PB_UTF8 | #PB_ByteLength)
        *Cursor + Context\Edits()\Length
      Case #DIFF_DELETE
        Assert(Context\Edits()\Start = *Cursor, "a delete is the next part of A")
        *Cursor + Context\Edits()\Length
        Changes + Context\Edits()\Lines
      Case #DIFF_INSERT
        Rebuilt$ + PeekS(Context\Edits()\Start, Context\Edits()\Length, #PB_UTF8 | #PB_ByteLength)
        Changes + Context\Edits()\Lines
    EndSelect
  Next
  Assert(*Cursor = *A + MemorySize(*A) - 1, "all of A is used")
  AssertString(Rebuilt$, B$, "B is rebuilt")
  
  ; longest common subsequence of the lines (one char each)
  Protected Dim LCS(LinesA, LinesB)
  For i = 1 To LinesA
    For j = 1 To LinesB
      If Mid(A$, i * 2 - 1, 1) = Mid(B$, j * 2 - 1, 1)
        LCS(i, j) = LCS(i - 1, j - 1) + 1
      ElseIf LCS(i - 1, j) > LCS(i, j - 1)
        LCS(i, j) = LCS(i - 1, j)
      Else
        LCS(i, j) = LCS(i, j - 1)
      EndIf
    Next j
  Next i
  Assert(Changes = LinesA + LinesB - 2 * LCS(LinesA, LinesB), "minimal: " + Str(Changes) + " changed lines instead of " + Str(LinesA + LinesB - 2 * LCS(LinesA, LinesB)))
  
  FreeMemory(*A) : FreeMemory(*B)
EndProcedure

ProcedureUnit Diff_RandomEdits()
  Protected i
  RandomSeed(547)
  For i = 1 To 200
    CheckRandomDiff(Random(30), Random(30))
  Next i
  CheckRandomDiff(1500, 1400) ; more lines than the initial size of the line arrays
EndProcedureUnit
