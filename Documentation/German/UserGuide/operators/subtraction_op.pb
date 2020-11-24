OpenConsole()

; Part 1 - Simple example of using the subtraction operator
x2 = 50
x1 = 25
distance = x2 - x1
PrintN("Distance between two points: " + Str(distance))

; Part 2 - Multiple operators can be used in the same calculation
total = 100
half = 50
quarter = 25
tenth = 10
leftovers = total - half - quarter - tenth - 2
PrintN("Remaining quantity: " + Str(leftovers))

; Part 3 - Shortcut version of the subtraction operator
leftovers - 3
PrintN("After decreasing using shortcut method: " + Str(leftovers))

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF