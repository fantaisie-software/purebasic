;
; ------------------------------------------------------------
;
;   PureBasic - Inlined asm example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

CompilerIf #PB_Compiler_Processor <> #PB_Processor_x86 And #PB_Compiler_Processor <> #PB_Processor_x64
  CompilerError "This example only works on x86 or x64 processors"
CompilerEndIf

Value.l = 10  ; Declare our own variable

EnableASM
  MOV Value, 20 ; Directly use the ASM keywords with PureBasic variable !
  INC Value
DisableASM

MessageRequester("ASM Example", "Should be 21: " + Value)
