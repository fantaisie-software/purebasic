;
; ------------------------------------------------------------
;
;   PureBasic - Inlined asm example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And (#PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64)

  Value.l = 10  ; Declare our own variable

  EnableASM
    MOV Value, 20 ; Directly use the ASM keywords with PureBasic variable !
    INC Value
  DisableASM

  MessageRequester("ASM Example", "Should be 21: " + Value)

CompilerElse

  MessageRequester("ASM Example", "No supported ASM backend detected.")

CompilerEndIf
