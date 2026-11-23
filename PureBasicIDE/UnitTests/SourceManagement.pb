; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the source file handling (SourceManagement.pb)

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

; Read the settings of Code$ (as loaded from a file) into *Source, return the code that stays in the editor
Procedure.s LoadSettings(*Source.SourceFile, Code$, IsTempFile = #False)
  Protected *Buffer = UTF8(Code$), Length
  *Source\Parser\Encoding = 1
  Length = AnalyzeProjectSettings(*Source, *Buffer, MemorySize(*Buffer) - 1, IsTempFile)
  Code$ = PeekS(*Buffer, Length, #PB_UTF8 | #PB_ByteLength)
  FreeMemory(*Buffer)
  ProcedureReturn Code$
EndProcedure

ProcedureUnit Settings_EndOfFile()
  Protected Source.SourceFile, Saved = SaveProjectSettings
  SaveProjectSettings = #SAVESETTINGS_EndOfFile
  
  AssertString(LoadSettings(@Source, "Debug 1" + #LF$ + "; IDE Options = PureBasic 6.50 (Linux - x64)" + #LF$ + "; CommandLine = -x" + #LF$ + "; EnableXP" + #LF$), "Debug 1", "the settings are cut")
  AssertString(Source\CommandLine$, "-x")
  Assert(Source\EnableXP = 1)
  
  AssertString(LoadSettings(@Source, "Debug 1" + #CRLF$ + "; IDE Options = PureBasic 6.50" + #CRLF$ + "; EnableXP" + #CRLF$, #True), "Debug 1", "CRLF, temporary file")
  
  SaveProjectSettings = Saved
EndProcedureUnit

; The settings format of PureBasic 3.x (ending with "; EOF") is not read anymore: a source ending with such
; comments keeps them (they were cut from the source before)
ProcedureUnit Settings_NoOldFormat()
  Protected Source.SourceFile, Saved = SaveProjectSettings, Code$
  
  Code$ = "Debug 1" + #LF$ + "; Executable=Test.exe" + #LF$ + "; EnableXP" + #LF$ + "; EOF"
  SaveProjectSettings = #SAVESETTINGS_EndOfFile
  AssertString(LoadSettings(@Source, Code$), Code$)
  SaveProjectSettings = #SAVESETTINGS_PerFileCfg
  AssertString(LoadSettings(@Source, Code$), Code$)
  
  SaveProjectSettings = Saved
EndProcedureUnit
