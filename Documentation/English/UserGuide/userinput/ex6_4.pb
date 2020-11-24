; We must open a console so that we can display the result
; Only continue with the main part of the program if the console was opened successfully
If OpenConsole()

    ; First we create the variables we require for this program.
    ; By doing this first we can keep these in the same place so
    ; we know where they will usually be and find them easily.
    
    DefType.f width, height, length
    DefType.f tin_area
    DefType.f number_tins

    ; The area which one tin of paint covers
    tin_area = 2.3
    
    ; Get the sizes of the room from the user
    Repeat
        Print("Please enter the width of the room: ")
        width = ValF(Input())
        
        ; Move onto the line after the one the user typed their value onto
        PrintN("")
        
        ; Check if the value was invalid
        If width <= 0
            PrintN("Invalid width. It must be more than 0.")
        EndIf
    Until width>0


    Repeat
        Print("Please enter the length of the room: ")
        length = ValF(Input())
        
        ; Move onto the line after the one the user typed their value onto
        PrintN("")
        
        ; Check if the value was invalid
        If length <= 0
            PrintN("Invalid length. It must be more than 0.")
        EndIf
    Until length>0
    
    
    Repeat
        Print("Please enter the height of the room: ")
        height = ValF(Input())
        
        ; Move onto the line after the one the user typed their value onto
        PrintN("")
        
        ; Check if the value was invalid
        If height <= 0
            PrintN("Invalid height. It must be more than 0.")
        EndIf
    Until height>0
    


    ; Now perform the required calculation (which, obviously, must
    ; come at some point *after* we have set the values of the
    ; other variables.
    ;
    ; Note that it is just the area of the walls. This is simply the
    ; total of the area of 4 rectangles (in fact, the total of 2 sets
    ; of 2 identical rectangles), so very similar to the previous
    ; solution.
    area.f = width * height * 2
    area + length * height * 2


    ; Now that we have the areas of the walls, we can calculate how
    ; many tins of paint will be required
    number_tins = area / tin_area


    ; Final part of the requirement - display the result.
    ; We do not need to display the dimensions here, but it means
    ; we can see all the values in the same place and may be easier to
    ; check the result.
    PrintN("The room dimensions are (l,w,h): "+StrF(length)+", "+StrF(width)+", "+StrF(height))
    PrintN("The area of the walls is "+StrF(area))
    PrintN("At a coverage per tin of "+StrF(tin_area)+" this will require "+StrF(number_tins)+" tins")

    ; Finally, print a message telling user how to exit the program
    ; and wait for them to press return. This is done so we can easily
    ; see the output of the program.
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End

; ExecutableFormat=Console
; EOF