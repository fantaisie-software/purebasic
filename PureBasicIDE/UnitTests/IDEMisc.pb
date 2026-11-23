; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the misc helpers of the IDE (IDEMisc.pb)

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

; F1 on a keyword opens its help page
ProcedureUnit IDEMisc_CheckPureBasicKeyWords()
  AssertString(CheckPureBasicKeyWords("For"), "Reference/for_next")
  AssertString(CheckPureBasicKeyWords("NEXT"), "Reference/for_next", "case insensitive")
  AssertString(CheckPureBasicKeyWords("procedurereturn"), "Reference/procedures")
  AssertString(CheckPureBasicKeyWords("EndStructureUnion"), "Reference/structures")
  AssertString(CheckPureBasicKeyWords("CompilerIf"), "Reference/compilerdirectives")
  AssertString(CheckPureBasicKeyWords("SizeOf"), "Reference/compilerfunctions")
  AssertString(CheckPureBasicKeyWords("Shared"), "Reference/shared")
  AssertString(CheckPureBasicKeyWords("Data$"), "Reference/data", "a $ suffix is ignored")
  AssertString(CheckPureBasicKeyWords("OpenWindow"), "", "not a keyword")
  AssertString(CheckPureBasicKeyWords(""), "")
EndProcedureUnit

Macro Dir(Path)
  ReplaceString(Path, "/", #Separator)
EndMacro

; Used to sort the directories in the explorer and project panel
ProcedureUnit IDEMisc_CompareDirectories()
  Assert(CompareDirectories(Dir("a/b/"), Dir("a/b/")) = #PB_String_Equal)
  Assert(CompareDirectories(Dir("a/"), Dir("b/")) = #PB_String_Lower)
  Assert(CompareDirectories(Dir("b/"), Dir("a/")) = #PB_String_Greater)
  Assert(CompareDirectories(Dir("a/"), Dir("a/b/")) = #PB_String_Lower, "the parent first")
  Assert(CompareDirectories(Dir("a/b/"), Dir("a/")) = #PB_String_Greater)
  Assert(CompareDirectories(Dir("x/a/"), Dir("x/b/c/")) = #PB_String_Lower, "after the common part")
  Assert(CompareDirectories(Dir("x/c/"), Dir("x/b/c/")) = #PB_String_Greater)
EndProcedureUnit

ProcedureUnit IDEMisc_RegisterDeleteFile()
  Protected File$ = WriteTestSource("x", "Temp.pb")
  
  ClearList(TempFiles())
  RegisterDeleteFile(File$)
  RegisterDeleteFile(File$)
  Assert(ListSize(TempFiles()) = 1, "registered once")
  
  DeleteRegisteredFiles()
  Assert(FileSize(File$) = -1, "deleted")
  ClearList(TempFiles())
EndProcedureUnit
