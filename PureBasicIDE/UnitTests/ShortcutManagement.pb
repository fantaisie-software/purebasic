; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the keyboard shortcuts (ShortcutManagement.pb)

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

ProcedureUnit Shortcut_BaseKeyIndex()
  Assert(GetBaseKeyIndex(#PB_Shortcut_0) = 1)
  Assert(GetBaseKeyIndex(#PB_Shortcut_A) = 11)
  Assert(GetBaseKeyIndex(#PB_Shortcut_Control | #PB_Shortcut_Shift | #PB_Shortcut_F1) = 37, "the modifiers are ignored")
  Assert(GetBaseKeyIndex(0) = 0)
EndProcedureUnit

ProcedureUnit Shortcut_Text()
  CompilerIf #CompileWindows = 0 ; Windows displays the modifier names of the language, the other OS need the English ones
    AssertString(GetShortcutText(#PB_Shortcut_Control | #PB_Shortcut_S), "Ctrl+S")
    AssertString(GetShortcutText(#PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_Shift | #PB_Shortcut_F5), "Ctrl+Alt+Shift+F5")
  CompilerEndIf
  AssertString(GetShortcutText(#PB_Shortcut_F12), "F12")
  AssertString(GetShortcutText(#PB_Shortcut_9), "9")
  AssertString(GetShortcutText(-1), "")
EndProcedureUnit

; The shortcuts are saved in the preferences with names that do not depend on the language
ProcedureUnit Shortcut_IndependentName()
  Assert(Left(ShortcutToIndependentName(#PB_Shortcut_Control | #PB_Shortcut_A), 8) = "CONTROL+", "#PB_Shortcut_Command is the same value on some OS")
  Assert(Right(ShortcutToIndependentName(#PB_Shortcut_Control | #PB_Shortcut_A), 3) = "+11")
  AssertString(ShortcutToIndependentName(#PB_Shortcut_Alt | #PB_Shortcut_Shift | #PB_Shortcut_F1), "ALT+SHIFT+37")
  AssertString(ShortcutToIndependentName(#PB_Shortcut_F1), "37")
  AssertString(ShortcutToIndependentName(-1), "")
  
  Assert(IndependentNameToShortcut("37") = #PB_Shortcut_F1)
  Assert(IndependentNameToShortcut("Alt + Shift + 37") = #PB_Shortcut_Alt | #PB_Shortcut_Shift | #PB_Shortcut_F1, "case and spaces are ignored")
  Assert(IndependentNameToShortcut("") = 0)
  Assert(IndependentNameToShortcut("999") = 0, "unknown key")
EndProcedureUnit

ProcedureUnit Shortcut_IndependentNameRoundTrip()
  Protected Index, Shortcut
  For Index = 1 To #NbShortcutKeys
    Shortcut = ShortcutValues(Index) | #PB_Shortcut_Alt | #PB_Shortcut_Shift
    CompilerIf #CompileMac = 0 ; on macOS, CONTROL also sets the Command modifier
      Shortcut | #PB_Shortcut_Control
    CompilerEndIf
    Assert(IndependentNameToShortcut(ShortcutToIndependentName(Shortcut)) = Shortcut, "key " + Str(Index))
  Next Index
EndProcedureUnit
