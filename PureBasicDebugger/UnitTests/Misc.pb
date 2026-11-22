; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the misc helpers of the debugger (Misc.pb), used by the variable viewer, watchlist, Debug output...

PureUnitOptions(MainCode)
XIncludeFile "DebuggerTestHost.pbi"

ProcedureUnit Misc_GetValueSize()
  Protected *Text = AllocateMemory(64)
  
  Assert(GetValueSize(#TYPE_BYTE, 0, #True) = 1)
  Assert(GetValueSize(#TYPE_ASCII, 0, #True) = 1)
  Assert(GetValueSize(#TYPE_WORD, 0, #True) = 2)
  Assert(GetValueSize(#TYPE_UNICODE, 0, #True) = 2)
  Assert(GetValueSize(#TYPE_LONG, 0, #True) = 4)
  Assert(GetValueSize(#TYPE_FLOAT, 0, #True) = 4)
  Assert(GetValueSize(#TYPE_CHARACTER, 0, #True) = 4, "sent as a long")
  Assert(GetValueSize(#TYPE_DOUBLE, 0, #False) = 8)
  Assert(GetValueSize(#TYPE_QUAD, 0, #False) = 8)
  Assert(GetValueSize(#TYPE_STRUCTURE, 0, #True) = 0, "no value")
  
  Assert(GetValueSize(#TYPE_INTEGER, 0, #True) = 8, "integer of a 64-bit program")
  Assert(GetValueSize(#TYPE_INTEGER, 0, #False) = 4, "integer of a 32-bit program")
  Assert(GetValueSize(#TYPE_BYTE | #POINTERMASK, 0, #True) = 8, "a pointer")
  Assert(GetValueSize(#TYPE_BYTE | #POINTERMASK, 0, #False) = 4)
  Assert(GetValueSize(#TYPE_LINKEDLIST, 0, #True) = 16, "size and current element")
  Assert(GetValueSize(#TYPE_LINKEDLIST, 0, #False) = 8)
  
  PokeS(*Text, "abc")
  Assert(GetValueSize(#TYPE_STRING, *Text, #True) = 4 * SizeOf(Character), "with the null")
  PokeS(*Text, "1,2", -1, #PB_Ascii)
  Assert(GetValueSize(#TYPE_ARRAY, *Text, #True) = 4, "ascii dimensions, with the null")
  
  ; map: size (integer), IsCurrent (byte), current key (string) if IsCurrent
  FillMemory(*Text, 64)
  Assert(GetValueSize(#TYPE_MAP, *Text, #True) = 9, "no current element")
  PokeB(*Text + 4, 1)
  PokeS(*Text + 5, "key")
  Assert(GetValueSize(#TYPE_MAP, *Text, #False) = 5 + 4 * SizeOf(Character), "with the current key")
  
  FreeMemory(*Text)
EndProcedureUnit

ProcedureUnit Misc_ScopeName()
  AssertString(ScopeName(#SCOPE_MAIN), "Main")
  AssertString(ScopeName(#SCOPE_GLOBAL), "Global")
  AssertString(ScopeName(#SCOPE_THREADED), "Threaded")
  AssertString(ScopeName(#SCOPE_LOCAL), "Local")
  AssertString(ScopeName(#SCOPE_LOCAL, #TYPE_ARRAY | #PARAMMASK), "ByRef", "an array parameter")
  AssertString(ScopeName(#SCOPE_STATIC), "Static")
  AssertString(ScopeName(#SCOPE_SHARED), "Shared")
  AssertString(ScopeName(#SCOPE_PARAMETER), "ByRef")
  AssertString(ScopeName(99), "")
EndProcedureUnit

ProcedureUnit Misc_ModuleName()
  AssertString(ModuleName("x", "Geo"), "Geo::x")
  AssertString(ModuleName("x", ""), "x")
EndProcedureUnit

ProcedureUnit Misc_ValHex()
  Assert(ValHex("FF") = 255)
  Assert(ValHex("ff") = 255, "lowercase")
  Assert(ValHex("0") = 0)
  Assert(ValHex("") = 0)
  Assert(ValHex("7FFFFFFF") = $7FFFFFFF)
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64 Or #PB_Compiler_Processor = #PB_Processor_Arm64
    Assert(ValHex("123456789ABCDEF0") = $123456789ABCDEF0, "64-bit addresses")
  CompilerEndIf
EndProcedureUnit

ProcedureUnit Misc_StrF_Debug()
  AssertString(StrF_Debug(1.5), "1.5", "trailing zeros are cut")
  AssertString(StrF_Debug(2), "2.0", "one zero is kept after the dot")
  AssertString(StrF_Debug(-0.25), "-0.25")
  AssertString(StrF_Debug(0), "0.0")
EndProcedureUnit

ProcedureUnit Misc_StrD_Debug()
  AssertString(StrD_Debug(1.5), "1.5")
  AssertString(StrD_Debug(100), "100.0")
  AssertString(StrD_Debug(0.1), "0.1")
  AssertString(StrD_Debug(1.0 / 3.0), "0.3333333333333333")
  AssertString(StrD_Debug(2.5, 2), "2.5", "fewer digits")
EndProcedureUnit

ProcedureUnit Misc_StrD_Science()
  AssertString(StrD_Science(0), "0")
  AssertString(StrD_Science(5.5), "5.5", "1 <= x < 10: no exponent")
  AssertString(StrD_Science(-5.5), "-5.5")
  AssertString(StrD_Science(1234.5), "1.2345E3")
  AssertString(StrD_Science(-0.00125), "-1.25E-3")
EndProcedureUnit

ProcedureUnit Misc_DebuggerTitle()
  Protected File$ = "folder" + #Separator + "Test.pb"
  DisplayFullPath = #False
  AssertString(DebuggerTitle(File$), "Test.pb")
  DisplayFullPath = #True
  AssertString(DebuggerTitle(File$), File$)
  DisplayFullPath = #False
EndProcedureUnit
