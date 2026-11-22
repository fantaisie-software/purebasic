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
