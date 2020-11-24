OpenConsole()

a = 3
b = 5
c = 2
d = 7

; Different operators - multiplication before addition
e = a + b * c
PrintN("The value of e should be 13: "+Str(e))

; Changing the order of evaluation
e = (a + b) * c
PrintN("E should now be 16: "+Str(e))

; Multiple operators of same precedence - from left to right
e = a + b - c
PrintN("E should now be 6: "+Str(e))

DefType.f f

; Multiple operators of same precedence - from left to right
f = a / b * c
PrintN("f = "+StrF(f)+" (should be 1.2)")

; Changing the order of evaluation - but ends up the same since
; the position of the brackets mean the same order is followed
f = (a / b) * c
PrintN("f = "+StrF(f)+" (should be 1.2)")

; Changing the order of evaluation
f = a / (b * c)
PrintN("f = "+StrF(f)+" (should be 0.3)")

; Nested brackets
f = (a - ((b + d) / (c + d)))
PrintN("f = "+StrF(f)+" (should be 1.6666...)")

; Without brackets
f = a - b + d / c + d
PrintN("f = "+StrF(f)+" (should be 8.5)")

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF