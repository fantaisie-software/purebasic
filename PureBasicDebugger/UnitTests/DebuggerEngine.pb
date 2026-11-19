; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the debugger engine (Communication.pb & co, shared by the IDE and the standalone debugger)
; with real programs compiled with the debugger (Targets/*.pb)

PureUnitOptions(MainCode)
XIncludeFile "DebuggerTestHost.pbi"

; 0-based line of the "; @Marker$" comment in Targets/<Name$>.pb
Procedure TargetLine(Name$, Marker$)
  Protected File = ReadFile(#PB_Any, "Targets" + #Separator + Name$ + ".pb"), Line = 0, Result = -1
  If File
    ReadStringFormat(File)
    While Eof(File) = 0
      If FindString(ReadString(File), "; @" + Marker$)
        Result = Line
        Break
      EndIf
      Line + 1
    Wend
    CloseFile(File)
  EndIf
  If Result = -1
    Fail("No '; @" + Marker$ + "' in Targets/" + Name$ + ".pb")
  EndIf
  ProcedureReturn Result
EndProcedure

ProcedureUnit Engine_StartAndEnd()
  Assert(RunDebugged(BuildTarget("DebugOutput")), "the program did not end")
  
  FirstElement(ReceivedCommands())
  Assert(ReceivedCommands() = #COMMAND_Init, "the first command is Init")
  LastElement(ReceivedCommands())
  Assert(ReceivedCommands() = #COMMAND_End, "the last command is End")
  Assert(ListSize(Errors()) = 0)
EndProcedureUnit

ProcedureUnit Engine_DebugOutput()
  Assert(RunDebugged(BuildTarget("DebugOutput")), "the program did not end")
  AssertString(DebugOutput(), "Hello|7|12345678901|1.5|0.25|été €|a=42", DebugOutput())
EndProcedureUnit

ProcedureUnit Engine_RuntimeError()
  Assert(RunDebugged(BuildTarget("RuntimeError")) = #False, "the program must stop on the error")
  
  Assert(ListSize(Errors()) = 1)
  FirstElement(Errors())
  Assert(Errors()\Line = TargetLine("RuntimeError", "Error"), "error line: " + Str(Errors()\Line))
  Assert(FindString(Errors()\Text$, "Array index out of bounds"), Errors()\Text$)
  Assert(ListSize(DebugLines()) = 0, "the program stopped at the error")
EndProcedureUnit

ProcedureUnit Engine_Breakpoints()
  Protected LoopLine = TargetLine("Breakpoints", "Loop")
  
  ClearList(BreakPoints())
  AddElement(BreakPoints()) : BreakPoints() = LoopLine
  Assert(RunDebugged(BuildTarget("Breakpoints")), "the program did not end")
  ClearList(BreakPoints())
  
  ; 3 times on the breakpoint in the loop, then the CallDebugger
  Assert(ListSize(Stops()) = 4, Str(ListSize(Stops())) + " stops")
  ForEach Stops()
    If ListIndex(Stops()) < 3
      Assert(Stops()\Line = LoopLine, "breakpoint line: " + Str(Stops()\Line))
    Else
      Assert(Stops()\Line = TargetLine("Breakpoints", "CallDebugger"), "CallDebugger line: " + Str(Stops()\Line))
      Assert(Stops()\Reason = 3, "CallDebugger reason: " + Str(Stops()\Reason))
    EndIf
  Next Stops()
  AssertString(DebugOutput(), "6|end", DebugOutput())
EndProcedureUnit
