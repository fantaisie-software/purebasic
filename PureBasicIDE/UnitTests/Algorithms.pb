; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of self-contained algorithms of the IDE, which only need the declarations of Common.pb.
; No PureUnitOptions(MainCode) here: these files have no main code to run, and it keeps the test fast.

IncludePath "../"
XIncludeFile "CompilerFlags.pb"
XIncludeFile "Common.pb"
XIncludeFile "Macro.pb"
XIncludeFile "FileSystem.pb"
XIncludeFile "RadixTree.pb"
XIncludeFile "DiffAlgorithm.pb"

;- RadixTree.pb

ProcedureUnit Radix_InsertLookup()
  Protected Tree.RadixTree
  
  RadixInsert(@Tree, "OpenWindow", 1)
  RadixInsert(@Tree, "OpenFile", 2)
  RadixInsert(@Tree, "Open", 3)
  
  Assert(RadixLookupValue(@Tree, "OpenWindow") = 1)
  Assert(RadixLookupValue(@Tree, "openfile") = 2, "lookup is case-insensitive")
  Assert(RadixLookupValue(@Tree, "Open") = 3, "a prefix of other entries can be a value too")
  Assert(RadixLookupValue(@Tree, "Ope") = 0, "a prefix is not a value")
  Assert(RadixLookupValue(@Tree, "OpenWindows") = 0)
  
  RadixFree(@Tree)
EndProcedureUnit

ProcedureUnit Radix_Enumerate()
  Protected Tree.RadixTree, Result$
  Protected NewList *Values()
  
  RadixInsert(@Tree, "OpenWindow", 1)
  RadixInsert(@Tree, "OpenFile", 2)
  RadixInsert(@Tree, "CloseWindow", 3)
  
  RadixEnumeratePrefix(@Tree, "open", *Values())
  Assert(ListSize(*Values()) = 2)
  
  RadixEnumerateAll(@Tree, *Values())
  ForEach *Values() : Result$ + Str(*Values()) : Next
  AssertString(Result$, "321", "sorted alphabetically: " + Result$)
  
  RadixFree(@Tree)
EndProcedureUnit

;- FileSystem.pb

ProcedureUnit FileSystem_RelativePaths()
  CompilerIf #CompileWindows
    AssertString(CreateRelativePath("C:\a\b\", "C:\a\c\x.pb"), "..\c\x.pb")
    AssertString(CreateRelativePath("C:\a\b\", "C:\a\b\x.pb"), "x.pb")
    AssertString(CreateRelativePath("C:\a\b\", "D:\x.pb"), "D:\x.pb", "another drive stays absolute")
    AssertString(ResolveRelativePath("C:\a\b\", "..\c\x.pb"), "C:\a\c\x.pb")
  CompilerElse
    AssertString(CreateRelativePath("/home/a/b/", "/home/a/c/x.pb"), "../c/x.pb")
    AssertString(CreateRelativePath("/home/a/b/", "/home/a/b/x.pb"), "x.pb")
    AssertString(ResolveRelativePath("/home/a/b/", "../c/x.pb"), "/home/a/c/x.pb")
    AssertString(UniqueFilename("/home/a/./b/../c/x.pb"), "/home/a/c/x.pb")
  CompilerEndIf
EndProcedureUnit

;- DiffAlgorithm.pb

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
