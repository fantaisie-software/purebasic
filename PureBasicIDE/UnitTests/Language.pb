; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the language strings (Language.pb), with the default (English) language

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

#NotFound$ = "##### String not found! #####"

ProcedureUnit Language_Strings()
  AssertString(Language("MenuTitle", "File"), "&File")
  AssertString(Language("menutitle", "FILE"), "&File", "group and name are case insensitive")
  AssertString(Language("Misc", "Weekday0"), "Sunday")
  AssertString(Language("History", "TimeFormat"), "%hh:%ii:%ss")
  AssertString(Language("MenuTitle", "File"), "&File", "again, from the cached group")
EndProcedureUnit

ProcedureUnit Language_NotFound()
  AssertString(Language("MenuTitle", "NoSuchString"), #NotFound$)
  AssertString(Language("NoSuchGroup", "File"), #NotFound$)
  AssertString(Language("MenuTitle", "File"), "&File", "a failed lookup does not break the next one")
EndProcedureUnit

ProcedureUnit Language_Newline()
  Protected Text$ = Language("FileStuff", "Modified")
  Assert(FindString(Text$, "%newline%", 1, #PB_String_NoCase) = 0, "%newline% is replaced")
  Assert(FindString(Text$, #NewLine), Text$)
EndProcedureUnit

ProcedureUnit Language_Pattern()
  Protected Text$ = LanguagePattern("FileStuff", "Modified", "%FILENAME%", "Test.pb")
  Assert(FindString(Text$, "'Test.pb'"), "the pattern is case insensitive: " + Text$)
  AssertString(PeekS(LanguageStringAddress("MenuTitle", "File")), "&File")
EndProcedureUnit
