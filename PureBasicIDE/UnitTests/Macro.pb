; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the conversion helpers of Macro.pb, which only need the declarations of Common.pb.
; No PureUnitOptions(MainCode) here: these files have no main code to run, and it keeps the test fast.

IncludePath "../"
XIncludeFile "CompilerFlags.pb"
XIncludeFile "Common.pb"
XIncludeFile "Macro.pb"

ProcedureUnit Macro_ToAscii()
  Protected *Buffer = ToAscii("Hello")
  Assert(MemorySize(*Buffer) = 6, "with the null terminator")
  AssertString(PeekAscii(*Buffer), "Hello")
  AssertString(PeekAsciiLength(*Buffer, 3), "Hel")
  
  *Buffer = ToAscii("") ; frees the previous buffer
  Assert(PeekA(*Buffer) = 0)
EndProcedureUnit

ProcedureUnit Macro_ToUTF8()
  Protected *Buffer = ToUTF8("été €")
  Assert(MemorySize(*Buffer) = 10, "2 + 1 + 2 + 1 + 3 bytes, and the null terminator")
  AssertString(PeekUTF8(*Buffer), "été €")
EndProcedureUnit
