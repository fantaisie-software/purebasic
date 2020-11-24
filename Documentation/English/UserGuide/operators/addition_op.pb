OpenConsole()

; Part 1 - Simple example of using the addition operator
DefType.l apples
DefType.l oranges
apples = 5
oranges = 3
fruit.l = apples + oranges
PrintN("Total number of fruit is:")
PrintN(Str(fruit))

; Part 2 - Multiple operators can be used in the same calculation
fruit = 2 + 4 + 1 + apples + 6 + 2 + oranges + 9
PrintN("New fruit total:")
PrintN(Str(fruit))

; Part 3 - Shortcut version of the addition operator
apples + 2
PrintN("New number of apples:")
PrintN(Str(apples))

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=Windows
; EOF