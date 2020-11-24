OpenConsole()

; Part 1 - Adding items and using the result as a parameter
fruit.l = 8
PrintN("Total number of fruit is: " + Str(fruit))

; Part 2 - Adding multiple items
DefType.s forename, surname
forename = "John"
surname = "Smith"
person$ = surname + ", " + forename
PrintN(person$)

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=Windows
; EOF