﻿;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------



;
; Gather some build information to include in the IDE About box (for better debugging)
; Crossplatform
;

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #Compiler    = "Compilers/PBCompiler.exe"
  #Git  = "git.exe"
CompilerElse
  #Compiler    = "/compilers/pbcompiler"
  #Git  = "git"
CompilerEndIf

Global GitBranch$, GitRevision$

OpenConsole()

Procedure.s FetchGitInfo()
  Revision$ = ""
  
  ; Get branch name (ie: master)
  ;
  git = RunProgram(#Git, "rev-parse --abbrev-ref HEAD", "C:\PureBasic\Svn\v5.70\GitHub\purebasic\PureBasicIDE\", #PB_Program_Open|#PB_Program_Read|#PB_Program_Hide|#PB_Program_Ascii)
  If git
    While ProgramRunning(git)
      GitBranch$ + ReadProgramString(git)
    Wend
    CloseProgram(git)
  EndIf
  
  ; Get current commit hash
  ;
  git = RunProgram(#Git, "rev-parse HEAD", GetCurrentDirectory(), #PB_Program_Open|#PB_Program_Read|#PB_Program_Hide|#PB_Program_Ascii)
  If git
    While ProgramRunning(git)
      GitRevision$ + ReadProgramString(git)
    Wend
    CloseProgram(git)
  EndIf
  
  GitRevision$ = Left(GitRevision$, 12)  ; Keep only a small part of the hash
EndProcedure

Procedure.s GetCompilerVersion()
  Version$ = ""
  
  Compiler$ = GetEnvironmentVariable("PUREBASIC_HOME")
  If Right(Compiler$, 1) <> "/"
    Compiler$ + "/"
  EndIf
  Compiler$ + #Compiler
  
  compiler = RunProgram(Compiler$, "--version", "", #PB_Program_Open|#PB_Program_Read|#PB_Program_Hide)
  If compiler
    Version$ = ReadProgramString(compiler)
    
    ; purge any remaining output
    While ProgramRunning(compiler)
      ReadProgramString(compiler)
    Wend
    CloseProgram(compiler)
  EndIf
  
  ; Cut the copyright notice
  Version$ = StringField(Version$, 1, ")") + ")"
  
  ProcedureReturn Version$
EndProcedure

;- Start
;
BuildDirectory$ = ProgramParameter()
If Right(BuildDirectory$, 1) <> "/"
  BuildDirectory$ + "/"
EndIf

FetchGitInfo()
Compiler$ = GetCompilerVersion()
Version$ = Trim(StringField(Compiler$, 1, "(")) ; remove "(Windows - x86)"
Version$ = Right(Version$, Len(Version$) - 10)  ; remove "PureBasic "

;- Write output
;
If CreateFile(0, BuildDirectory$+"BuildInfo.pb")
  WriteStringN(0, "; Autogenerated by makebuildinfo.pb")
  WriteStringN(0, ";")
  
  WriteStringN(0, "#BUILDINFO_Branch   = "+Chr(34)+GitBranch$+Chr(34))
  WriteStringN(0, "#BUILDINFO_Revision = "+Chr(34)+GitRevision$+Chr(34))
  WriteStringN(0, "#BUILDINFO_Compiler = "+Chr(34)+Compiler$+Chr(34))
  WriteStringN(0, "#BUILDINFO_Version  = "+Chr(34)+Version$+Chr(34))
  WriteStringN(0, "#BUILDINFO_User     = "+Chr(34)+UserName()+Chr(34))
  
  CloseFile(0)
  End 0 ; success
  
Else
  PrintN("makebuildinfo - could not write output file!")
  End 1 ; failure
  
EndIf
