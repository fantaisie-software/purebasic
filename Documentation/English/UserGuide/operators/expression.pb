OpenConsole()

; A simple expression
simple.l = 8
expression.f = simple * 3 + 2

; More complex example
detail$ = "This is the value of "
var_name.s = " expression"
output_string.s = detail$ + var_name + ": " + StrF(expression)
PrintN(output_string)

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF