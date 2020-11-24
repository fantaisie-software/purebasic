; We must open a console so that we can display the result
OpenConsole()


; First we create the variables we require for this program.
; By doing this first we can keep these in the same place so
; we know where they will usually be and find them easily.

; You could probably use any type here, it depends on whether
; you want to be able to use fractional sizes or not. In this
; case we will only use whole numbers.
DefType.l width, height, area


; Since the sizes are being set in the code, we will do that here
width = 4
height = 5


; Now perform the required calculation (which, obviously, must
; come at some point *after* we have set the values of the
; other variables
area = width * height


; Final part of the requirement - display the result
PrintN("The calculated area is "+Str(area))


; Finally, print a message telling user how to exit the program
; and wait for them to press return. This is done so we can easily
; see the output of the program.
PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF