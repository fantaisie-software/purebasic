; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the templates (Templates.pb)

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

; The templates are saved one per line in Templates.prefs, with escaped newlines and backslashes
ProcedureUnit Templates_Escape()
  AssertString(Template_Escape("a" + #NewLine + "b"), "a\nb")
  AssertString(Template_Escape("C:\dir\n.pb"), "C:\\dir\\n.pb", "a backslash before 'n' is not a newline")
  AssertString(Template_Escape(""), "")
EndProcedureUnit

ProcedureUnit Templates_Unescape()
  AssertString(Template_Unescape("a\nb"), "a" + #NewLine + "b")
  AssertString(Template_Unescape("a\nb", #LF$), "a" + #LF$ + "b", "custom newline sequence")
  AssertString(Template_Unescape("C:\\dir\\n.pb"), "C:\dir\n.pb")
  AssertString(Template_Unescape("\\n"), "\n", "an escaped backslash followed by n")
  AssertString(Template_Unescape("\n\n"), #NewLine + #NewLine)
  AssertString(Template_Unescape("x\"), "x\", "a backslash at the end")
EndProcedureUnit

ProcedureUnit Templates_RoundTrip()
  Protected Text$ = "Procedure X()" + #NewLine + "  Debug " + #DQUOTE$ + "\n\\n" + #DQUOTE$ + #NewLine + "EndProcedure\"
  AssertString(Template_Unescape(Template_Escape(Text$)), Text$)
EndProcedureUnit
