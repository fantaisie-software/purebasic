; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Environment for the tests of the IDE code: the whole IDE (PureBasicIncludes.pb), without its startup
; code, initialized like the IDE does at startup, with default preferences.
;
; Use it like this (see README.md):
;
;   PureUnitOptions(MainCode, ThreadOnly)
;   XIncludeFile "TestEnvironment.pbi"
;
; MainCode is required, so the main code of the IDE (globals, NewList, Dim...) and of this file runs
; before the tests. ThreadOnly, as the IDE must be compiled in thread mode.
;
; Nothing in the user's PureBasic configuration is read or written: all the configuration files point
; to an empty temporary directory.

CompilerIf #PureUnit_ResidentVersion < 201
  CompilerError "The IDE tests need PureUnit 1.5 or newer (for PureUnitOptions(MainCode, ThreadOnly))"
CompilerEndIf

CompilerIf #PB_Compiler_Thread = 0
  CompilerError "The IDE tests must be compiled in thread mode: use PureUnitOptions(MainCode, ThreadOnly)"
CompilerEndIf

IncludePath "../"
XIncludeFile "PureBasicIncludes.pb"

;- Procedures of PureBasic.pb (not included)

; Called by MessageRequesterSafe() before any requester of the IDE: a requester would block the tests
; forever (and the IDE code must not need one when it is used correctly)
Procedure CloseSplashScreen()
  Fail("The IDE code opened a MessageRequester()")
EndProcedure

Procedure ShutdownIDE()
  Fail("The IDE code called ShutdownIDE()")
EndProcedure

;- Startup, like in PureBasic.pb (without ParseCommandline() and OSStartupCode())

Global UnitTestDirectory$ = GetTemporaryDirectory() + "PureBasicIDE_UnitTests_" + Hex(Date()) + Hex(Random($FFFFFF)) + #Separator
CreateDirectory(UnitTestDirectory$)

CompilerIf #SpiderBasic
  PureBasicPath$ = GetEnvironmentVariable("SPIDERBASIC_HOME")
CompilerElse
  PureBasicPath$ = GetEnvironmentVariable("PUREBASIC_HOME")
CompilerEndIf
If PureBasicPath$ <> "" And Right(PureBasicPath$, 1) <> #Separator
  PureBasicPath$ + #Separator
EndIf

PreferencesFile$     = UnitTestDirectory$ + #PreferenceFileName$
TemplatesFile$       = UnitTestDirectory$ + "Templates.prefs"
AddToolsFile$        = UnitTestDirectory$ + "Tools.prefs"
HistoryDatabaseFile$ = UnitTestDirectory$ + "History.db"
UpdateCheckFile$     = UnitTestDirectory$ + "UpdateCheck.xml"

InitToolbar()           ; must be before LoadPreferences()
InitSyntaxCheckArrays() ; must be before LoadPreferences()
LoadPreferences()       ; no file: all the default settings
LoadLanguage()
InitSyntaxHighlighting()

;- Helpers

ProcedureUnitShutdown TestEnvironmentShutdown()
  DeleteDirectory(UnitTestDirectory$, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
EndProcedureUnit

; Write Code$ to a file of the temporary directory (UTF-8 with BOM, like the IDE), returns the full path
Procedure.s WriteTestSource(Code$, Name$ = "Test.pb")
  Protected File$ = UnitTestDirectory$ + Name$
  If CreateFile(#FILE_ScanSource, File$, #PB_UTF8)
    WriteStringFormat(#FILE_ScanSource, #PB_UTF8)
    WriteString(#FILE_ScanSource, Code$)
    CloseFile(#FILE_ScanSource)
  Else
    Fail("Cannot create " + File$)
  EndIf
  ProcedureReturn File$
EndProcedure
