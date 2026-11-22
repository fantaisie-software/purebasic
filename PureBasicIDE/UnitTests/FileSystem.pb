; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the path functions (FileSystem.pb), which only needs the declarations of Common.pb.
; No PureUnitOptions(MainCode) here: these files have no main code to run, and it keeps the test fast.

IncludePath "../"
XIncludeFile "CompilerFlags.pb"
XIncludeFile "Common.pb"
XIncludeFile "Macro.pb"
XIncludeFile "FileSystem.pb"

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
