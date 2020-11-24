;
; ------------------------------------------------------------
;
;   PureBasic - Runtime example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Note: this example doesn't make much sens as a standalone file
; as the runtime concept is to allow to access any procedure,
; variable etc once the program is compiled (for exemple from
; an xml file, like in the Dialog library)


Runtime Procedure RuntimeProcedure()
  Debug "Runtime procedure"
EndProcedure


Debug "RuntimeProcedure() address: " + GetRuntimeInteger("RuntimeProcedure()")


RuntimeVariable.i = 128
Runtime RuntimeVariable
Debug "RuntimeVariable: " + GetRuntimeInteger("RuntimeVariable")
SetRuntimeInteger("RuntimeVariable", 256)

; The internal variable value has been changed
;
Debug "RuntimeVariable: " + RuntimeVariable
