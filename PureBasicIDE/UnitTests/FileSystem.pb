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

ProcedureUnit FileSystem_ResolveRelativePath()
  CompilerIf #CompileWindows
    AssertString(ResolveRelativePath("C:\a\b\", "x.pb"), "C:\a\b\x.pb")
    AssertString(ResolveRelativePath("C:\a\b\", ".\x.pb"), "C:\a\b\x.pb")
    AssertString(ResolveRelativePath("C:\a\b\", "..\..\x.pb"), "C:\x.pb")
    AssertString(ResolveRelativePath("C:\a\b\", "D:\x.pb"), "D:\x.pb", "already absolute")
  CompilerElse
    AssertString(ResolveRelativePath("/home/a/b/", "x.pb"), "/home/a/b/x.pb")
    AssertString(ResolveRelativePath("/home/a/b/", "./x.pb"), "/home/a/b/x.pb")
    AssertString(ResolveRelativePath("/home/a/b/", "../../x.pb"), "/home/x.pb")
    AssertString(ResolveRelativePath("/home/a/b/", "/tmp/x.pb"), "/tmp/x.pb", "already absolute")
    AssertString(UniqueFilename("/home//a/b/./../x.pb"), "/home/a/x.pb")
  CompilerEndIf
EndProcedureUnit

ProcedureUnit FileSystem_RelativePathRoundTrip()
  Protected Base$, File$
  CompilerIf #CompileWindows
    Base$ = "C:\Projects\Game\"
    File$ = "C:\Projects\Lib\Include\Sprite.pbi"
  CompilerElse
    Base$ = "/home/user/Game/"
    File$ = "/home/user/Lib/Include/Sprite.pbi"
  CompilerEndIf
  AssertString(ResolveRelativePath(Base$, CreateRelativePath(Base$, File$)), File$)
EndProcedureUnit

ProcedureUnit FileSystem_Directories()
  Protected Base$ = GetTemporaryDirectory() + "PureBasicIDE_UnitTests_" + Hex(Date()) + Hex(Random($FFFFFF)) + #Separator
  Protected Deep$ = Base$ + "a" + #Separator + "b" + #Separator + "c" + #Separator
  
  Assert(CreateDirectoryRecursive(Deep$), "create a, b and c")
  Assert(FileSize(Deep$) = -2)
  Assert(CreateDirectoryRecursive(Deep$), "already exists")
  
  If CreateFile(0, Deep$ + "x.pb")
    CloseFile(0)
  EndIf
  Assert(IsEqualFile(Deep$ + "x.pb", Base$ + "a" + #Separator + "b" + #Separator + ".." + #Separator + "b" + #Separator + "c" + #Separator + "x.pb"), "same file through ..")
  Assert(IsEqualFile(Deep$ + "x.pb", Deep$ + "y.pb") = #False)
  CompilerIf #CompileWindows Or #CompileMac
    Assert(IsEqualFile(Deep$ + "x.pb", Deep$ + "X.PB"), "the file system is case insensitive")
  CompilerEndIf
  
  DeleteDirectory(Base$, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
EndProcedureUnit
