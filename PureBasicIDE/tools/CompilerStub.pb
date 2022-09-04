; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Compiler stub
;

OpenConsole()

Compiler = RunProgram(#PB_Compiler_Home + "compilers/pbcompiler", "--standby", "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Write)
If Compiler
  
  ; Wait for the version string
  PrintN(ReadProgramString(Compiler))
  
  ; Wait for the READY string
  PrintN(ReadProgramString(Compiler))
  
  
  WriteProgramStringN(Compiler, "FUNCTIONLIST")
  NbLines = Val(ReadProgramString(Compiler))
  PrintN(Str(NbLines))
  For k=0 To NbLines
    ReadProgramString(Compiler)
  Next
  
  
  WriteProgramStringN(Compiler, "STRUCTURELIST")
  NbLines = Val(ReadProgramString(Compiler))
  PrintN(Str(NbLines))
  For k=0 To NbLines
    ReadProgramString(Compiler)
  Next
  
  
  WriteProgramStringN(Compiler, "INTERFACELIST")
  NbLines = Val(ReadProgramString(Compiler))
  PrintN(Str(NbLines))
  For k=0 To NbLines
    ReadProgramString(Compiler)
  Next
  
  
  WriteProgramStringN(Compiler, "SOURCE"+Chr(9)+"/tmp/PB_EditorOutput.pb")
  WriteProgramStringN(Compiler, "TARGET"+Chr(9)+"/tmp/PureBasic0.app")
  WriteProgramStringN(Compiler, "INCLUDEPATH"+Chr(9)+"/Users/fred/Desktop/IncludeBug/")
  WriteProgramStringN(Compiler, "SOURCEALIAS"+Chr(9)+"/Users/fred/Desktop/IncludeBug/XMLtest4.pb")
  WriteProgramStringN(Compiler, "COMPILE"+Chr(9)+"PROGRESS"+Chr(9)+"DEBUGGER")
  
  Repeat
    
    Output$ = ReadProgramString(Compiler)
    PrintN(Output$)
    
  Until Output$ = "OUTPUT"+Chr(9)+"COMPLETE"
  
  
  
Else
  MessageRequester("Error", "Can't launch the compiler in standby mode")
EndIf