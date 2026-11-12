; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Test host for the debugger engine (DebuggerIncludes.pb, also used by the IDE and the standalone debugger):
; it runs real executables compiled with the debugger (Targets/*.pb) through the engine, and records what
; the engine reports to its host, for the tests to check.
;
; Use it like this (see ../../PureBasicIDE/UnitTests/README.md):
;
;   PureUnitOptions(MainCode)
;   XIncludeFile "DebuggerTestHost.pbi"
;
;   Exe$ = BuildTarget("DebugOutput")  ; compiles Targets/DebugOutput.pb with the debugger
;   Assert(RunDebugged(Exe$))          ; runs it until it ends, then check DebugLines(), Errors()...

CompilerIf #PureUnit_ResidentVersion < 201
  CompilerError "The debugger tests need PureUnit 1.5 or newer (for PureUnitOptions(MainCode))"
CompilerEndIf

IncludePath "../"
XIncludeFile "DebuggerIncludes.pb"

;- What the engine reported

Structure TestDebuggerEvent
  Line.l     ; 0-based line in the main file
  Text$      ; error message
  Reason.l   ; #COMMAND_Stopped reason
EndStructure

Global NewList ReceivedCommands.l()             ; #COMMAND_ ids received by DebuggerCallback(), in order
Global NewList DebugLines.s()                   ; Debug output, as displayed (without "[Debug] ")
Global NewList Errors.TestDebuggerEvent()       ; runtime errors (#COMMAND_Error)
Global NewList Stops.TestDebuggerEvent()        ; program stops (#COMMAND_Stopped): breakpoints, CallDebugger...
Global ProgramEnded                             ; #COMMAND_End received
Global KillProgram                              ; set by the callback when the program must be killed

; Set by the tests before RunDebugged(): 0-based lines of the main file
Global NewList BreakPoints()

;- Host procedures declared in DebuggerCommon.pb

Procedure FindBreakpoint(Line)
  ForEach BreakPoints()
    If BreakPoints() = Line
      ProcedureReturn 1
    EndIf
  Next BreakPoints()
  ProcedureReturn 0
EndProcedure

Procedure FlushEvents()
  While WindowEvent() : Wend
EndProcedure

Procedure Debugger_AddShortcuts(Window)
EndProcedure

Procedure Debugger_ShowLine(*Debugger.DebuggerData, Line)
EndProcedure

; Does like the standalone debugger (StandaloneDebugger.pb) for the startup, and records the rest
Procedure DebuggerCallback(*Debugger.DebuggerData)
  Protected Command.CommandInfo
  
  AddElement(ReceivedCommands())
  ReceivedCommands() = *Debugger\Command\Command
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_Procedures
      ; end of the startup: send the breakpoints, then let the program run
      ForEach BreakPoints()
        Command\Command = #COMMAND_BreakPoint
        Command\Value1  = 1 ; add
        Command\Value2  = MakeDebuggerLine(0, BreakPoints())
        SendDebuggerCommand(*Debugger, @Command)
      Next BreakPoints()
      
      Command\Command = #COMMAND_Run
      Command\Value1  = 0
      Command\Value2  = 0
      SendDebuggerCommand(*Debugger, @Command)
      
    Case #COMMAND_Debug
      AddElement(DebugLines())
      Select *Debugger\Command\Value1 ; type
        Case 5 ; long
          DebugLines() = Str(*Debugger\Command\Value2)
        Case 8 ; string, in the program's string format
          DebugLines() = PeekS(*Debugger\CommandData, *Debugger\Command\DataSize / SizeOf(Character))
        Case 9 ; float
          DebugLines() = StrF_Debug(PeekF(@*Debugger\Command\Value2))
        Default
          DebugLines() = "<unknown type " + Str(*Debugger\Command\Value1) + ">"
      EndSelect
      
    Case #COMMAND_DebugDouble
      AddElement(DebugLines())
      DebugLines() = StrD_Debug(PeekD(@*Debugger\Command\Value1))
      
    Case #COMMAND_DebugQuad
      AddElement(DebugLines())
      DebugLines() = Str(PeekQ(@*Debugger\Command\Value1))
      
    Case #COMMAND_Error
      AddElement(Errors())
      Errors()\Line  = DebuggerLineGetLine(*Debugger\Command\Value1)
      Errors()\Text$ = PeekUTF8(*Debugger\CommandData)
      KillProgram = #True ; the program waits after an error, like in the IDE
      
    Case #COMMAND_Stopped
      AddElement(Stops())
      Stops()\Line   = DebuggerLineGetLine(*Debugger\Command\Value1)
      Stops()\Reason = *Debugger\Command\Value2
      
      Command\Command = #COMMAND_Run ; continue
      Command\Value1  = 0
      Command\Value2  = 0
      SendDebuggerCommand(*Debugger, @Command)
      
    Case #COMMAND_End, #COMMAND_FatalError
      ProgramEnded = #True
      Debugger_End(*Debugger)
      
  EndSelect
EndProcedure

;- Startup, like in StandaloneDebugger.pb (but without its preferences)

PureBasicPath$ = GetEnvironmentVariable("PUREBASIC_HOME")
If PureBasicPath$ <> "" And Right(PureBasicPath$, 1) <> #Separator
  PureBasicPath$ + #Separator
EndIf

CompilerIf #CompileLinux
  SetEnvironmentVariable("LD_LIBRARY_PATH", PureBasicPath$ + "compilers/:" + GetEnvironmentVariable("LD_LIBRARY_PATH"))
CompilerEndIf

DebuggerTimeout = 10000
CurrentLanguage$ = "English"
LoadLanguage()

Global TargetDirectory$ = GetTemporaryDirectory() + "PureBasicDebugger_UnitTests_" + Hex(Date()) + Hex(Random($FFFFFF)) + #Separator
CreateDirectory(TargetDirectory$)

;- Helpers

ProcedureUnitShutdown DebuggerTestHostShutdown()
  DeleteDirectory(TargetDirectory$, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
EndProcedureUnit

; Compile Targets/<Name>.pb with the debugger, returns the executable (fails the test on error)
Procedure.s BuildTarget(Name$)
  Protected Compiler$, Exe$ = TargetDirectory$ + Name$, Program, Output$
  Protected Source$ = GetCurrentDirectory() + "Targets" + #Separator + Name$ + ".pb"
  
  CompilerIf #CompileWindows
    Compiler$ = PureBasicPath$ + "Compilers\pbcompiler.exe"
    Exe$ + ".exe"
    Program = RunProgram(Compiler$, "/QUIET /DEBUGGER " + #DQUOTE$ + Source$ + #DQUOTE$ + " /EXE " + #DQUOTE$ + Exe$ + #DQUOTE$, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  CompilerElse
    Compiler$ = PureBasicPath$ + "compilers/pbcompiler"
    Program = RunProgram(Compiler$, "-q -d " + #DQUOTE$ + Source$ + #DQUOTE$ + " -e " + #DQUOTE$ + Exe$ + #DQUOTE$, "", #PB_Program_Open | #PB_Program_Read)
  CompilerEndIf
  
  If Program
    While ProgramRunning(Program)
      If AvailableProgramOutput(Program)
        Output$ + ReadProgramString(Program) + " "
      Else
        Delay(10)
      EndIf
    Wend
    If ProgramExitCode(Program) <> 0
      Output$ + "(exit code " + Str(ProgramExitCode(Program)) + ")"
    EndIf
    CloseProgram(Program)
  EndIf
  
  If FileSize(Exe$) <= 0
    Fail("Cannot compile " + Source$ + " with " + Compiler$ + ": " + Output$)
  EndIf
  ProcedureReturn Exe$
EndProcedure

; Run Executable$ through the engine until it ends (killed after a runtime error, or after Timeout ms)
; Returns #True if the program ended by itself
Procedure RunDebugged(Executable$, Timeout = 10000)
  Protected *Debugger.DebuggerData, Start = ElapsedMilliseconds()
  
  ClearList(ReceivedCommands())
  ClearList(DebugLines())
  ClearList(Errors())
  ClearList(Stops())
  ProgramEnded = #False
  KillProgram  = #False
  
  *Debugger = Debugger_ExecuteProgram(Executable$, "", GetPathPart(Executable$))
  If *Debugger = 0
    Fail("Debugger_ExecuteProgram() failed for " + Executable$)
  EndIf
  
  While ProgramEnded = #False And KillProgram = #False And ElapsedMilliseconds() - Start < Timeout
    If Debugger_ProcessIncomingCommands() = 0
      Delay(5)
    EndIf
  Wend
  
  If ProgramEnded = #False
    Debugger_ForceDestroy(*Debugger) ; never leave a program waiting for a debugger
  EndIf
  
  ProcedureReturn ProgramEnded
EndProcedure

; The Debug output, joined by "|"
Procedure.s DebugOutput()
  Protected Result$
  ForEach DebugLines()
    Result$ + DebugLines() + "|"
  Next DebugLines()
  ProcedureReturn RTrim(Result$, "|")
EndProcedure
