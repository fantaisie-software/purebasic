; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the misc helpers of the IDE (Misc.pb)

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

ProcedureUnit Misc_GetUniqueID()
  Protected First = GetUniqueID()
  Assert(First <> 0, "0 is the invalid ID")
  Assert(GetUniqueID() = First + 1)
  Assert(GetUniqueID() = First + 2)
EndProcedureUnit

ProcedureUnit Misc_FindMemoryCharacter()
  Protected Text$ = "OpenWindow(*Win)"

  Assert(FindMemoryCharacter(@Text$, Len(Text$), '*') = @Text$ + 11 * SizeOf(Character))
  Assert(FindMemoryCharacter(@Text$, Len(Text$), 'O') = @Text$, "first char")
  Assert(FindMemoryCharacter(@Text$, Len(Text$), ')') = @Text$ + 15 * SizeOf(Character), "last char")
  Assert(FindMemoryCharacter(@Text$, Len(Text$), '#') = 0, "not found")
  Assert(FindMemoryCharacter(@Text$, 11, '*') = 0, "the length is in characters")
  Assert(FindMemoryCharacter(@Text$, 0, 'O') = 0, "empty buffer")
EndProcedureUnit

ProcedureUnit Misc_ParseString()
  Assert(ParseString("  Compile" + #TAB$ + "  /tmp/a.pb   -d ") = 3, "runs of spaces and tabs are one separator")
  AssertString(GetStringToken(1), "Compile")
  AssertString(GetStringToken(2), "/tmp/a.pb")
  AssertString(GetStringToken(3), "-d")
  AssertString(GetStringToken(0), "", "index is 1 based")
  AssertString(GetStringToken(4), "", "after the last token")

  Assert(ParseString("a b " + #CRLF$ + "c d") = 2, "a newline ends the line")
  AssertString(GetStringToken(2), "b")

  Assert(ParseString("") = 0)
  Assert(ParseString("   ") = 0)
  AssertString(GetStringToken(1), "")
EndProcedureUnit

ProcedureUnit Misc_StrByteSize()
  AssertString(StrByteSize(0), "0 Byte")
  AssertString(StrByteSize(1023), "1023 Byte")
  AssertString(StrByteSize(1024), "1.00 Kb")
  AssertString(StrByteSize(1536), "1.50 Kb")
  AssertString(StrByteSize(1024 * 1024), "1.00 Mb")
  AssertString(StrByteSize(5 * 1024 * 1024 * 1024), "5.00 Gb", "more than 32-bit")
EndProcedureUnit

ProcedureUnit Misc_IsNumeric()
  Protected Value

  Assert(IsNumeric("123", @Value)) : Assert(Value = 123)
  Assert(IsNumeric(" 1 2 ", @Value), "spaces are removed") : Assert(Value = 12)
  Assert(IsNumeric("$FF", @Value)) : Assert(Value = 255)
  Assert(IsNumeric("$ff", @Value), "lowercase hex") : Assert(Value = 255)
  Assert(IsNumeric("%101", @Value)) : Assert(Value = 5)

  Value = 42
  Assert(IsNumeric("", @Value) = #False)
  Assert(IsNumeric("$", @Value) = #False, "a prefix alone")
  Assert(IsNumeric("$$1", @Value) = #False)
  Assert(IsNumeric("12a", @Value) = #False)
  Assert(IsNumeric("FF", @Value) = #False, "hex needs the $")
  Assert(IsNumeric("%102", @Value) = #False)
  Assert(IsNumeric("-1", @Value) = #False, "no sign")
  Assert(IsNumeric("1.5", @Value) = #False, "no float")
  Assert(Value = 42, "the output is untouched on failure")
EndProcedureUnit

ProcedureUnit Misc_RGBString()
  AssertString(RGBString(RGB(1, 128, 255)), "RGB(1, 128, 255)")
  Assert(ColorFromRGBString("RGB(1, 128, 255)") = RGB(1, 128, 255))
  Assert(ColorFromRGBString("rgb( 1 ," + #TAB$ + "128,255 )") = RGB(1, 128, 255), "case and whitespace are ignored")
  Assert(ColorFromRGBString(RGBString($123456)) = $123456, "round trip")
EndProcedureUnit

ProcedureUnit Misc_ModulePrefix()
  AssertString(ModulePrefix("Open", "Win"), "Win::Open")
  AssertString(ModulePrefix("Open", ""), "Open")
EndProcedureUnit

ProcedureUnit Misc_CodePage()
  Protected *Buffer

  Assert(CodePageLength(#SC_CP_UTF8, "été") = 5)
  Assert(CodePageLength(0, "été") = 3)

  *Buffer = StringToCodePage(#SC_CP_UTF8, "été")
  Assert(MemorySize(*Buffer) = 6, "with the null terminator")
  AssertString(PeekS(*Buffer, -1, #PB_UTF8), "été")
  FreeMemory(*Buffer)

  *Buffer = StringToCodePage(0, "abc")
  Assert(PeekA(*Buffer) = 'a' And PeekA(*Buffer + 3) = 0)
  FreeMemory(*Buffer)
EndProcedureUnit
