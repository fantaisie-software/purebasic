; We must open a console so that we can display the result
OpenConsole()


; First we create the variables we require for this program.
; By doing this first we can keep these in the same place so
; we know where they will usually be and find them easily.

; You could probably use any type here, it depends on whether
; you want to be able to use fractional sizes or not. In this
; case we will only use whole numbers.
DefType.l width, height, length
DefType.f tin_area
DefType.f number_tins


; Since the sizes are being set in the code, we will do that here
width = 4
height = 2
length = 3

tin_area = 2.3  ; The area which one tin of paint covers


; Now perform the required calculation (which, obviously, must
; come at some point *after* we have set the values of the
; other variables.
;
; Note that it is just the area of the walls. This is simply the
; total of the area of 4 rectangles (in fact, the total of 2 sets
; of 2 identical rectangles), so very similar to the previous
; solution.
area = width * height * 2
area + length * height * 2


; Now that we have the areas of the walls, we can calculate how
; many tins of paint will be required
number_tins = area / tin_area


; Final part of the requirement - display the result.
; We do not need to display the dimensions here, but it means
; we can see all the values in the same place and may be easier to
; check the result.
PrintN("The room dimensions are (l,w,h): "+Str(length)+", "+Str(width)+", "+Str(height))
PrintN("The area of the walls is "+Str(area))
PrintN("At a coverage per tin of "+StrF(tin_area)+" this will require "+StrF(number_tins)+" tins")


; Finally, print a message telling user how to exit the program
; and wait for them to press return. This is done so we can easily
; see the output of the program.
PrintN("Press return to exit")
Input()
CloseConsole()
End

; ExecutableFormat=
; EOF