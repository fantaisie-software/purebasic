; Open console and only continue with main program if successful
If OpenConsole()
    DefType.l   width, height       ; Width and height of rectangle
    DefType.s   draw_character      ; The character that will be used to draw the rectangle
    DefType.l   row, column         ; Counters for the row and column, when displaying the rectangle
    DefType.l   top, left           ; Top and left positions to start drawing the rectangle from
    
    ; Loop to ask for and validate width of rectangle
    Repeat
        ; Prompt the user and read number from keyboard
        PrintN("Please enter the width of the rectangle (1 to 80): ")
        width = Val(Input())
        PrintN("")
        
        ; Check for invalid values and warn the user
        If width<=0 Or width > 80
            PrintN("Invalid width - it must be more than 0 and less than 81")
        EndIf
    Until width>0 And width<=80

    ; Loop to ask for and validate height of rectangle
    Repeat
        ; Prompt the user and read number from keyboard
        PrintN("Please enter the height of the rectangle (1 to 24): ")
        height = Val(Input())
        PrintN("")
        
        ; Check for invalid values and warn the user
        If height<=0 Or height>=25
            PrintN("Invalid height - it must be more than 0 and less than 25")
        EndIf
    Until height>0 And height<25
    
    ; Get the character that will be used to draw the rectangle.
    ; Notice that we do not alter the string that the user enters, but later
    ; chapters will show you commands that can be used to validate character
    ; strings as you would with numbers.
    Print("Enter a character that should be used to draw the rectangle: ")
    draw_character = Input()

    ; Clear all the prompt and user input from the console
    ClearConsole()
    
    ; Calculate where the rectangle should start, to centre it on the screen
    ; In both calculations, the space at either side of the rectangle must be equal to
    ; half of the remaining space, after taking the rectangle size away from the total
    ; size.
    top = (25 - height) / 2
    left = (80 - width) / 2

    ; This first For...Next loop counts over the total height of the rectangle
    ; Note that to get the sums correct inside the loop we start from zero
    ; and finish one sooner too.
    For row=0 To height-1
        ; Move to the start of the current row in the rectangle
        ConsoleLocate(left, top + row)
        
        ; Another loop, to go through each column in the rectangle
        For column=0 To width-1
            ; Print a space - because we changed the background color
            ; the entire character will be shown in this color, since
            ; a space contains no parts which are drawn in the foreground
            Print(draw_character)
        Next
    Next
    
    ; Move the cursor to the bottom corner (just so it does not
    ; mess up our nice rectangle :)
    ConsoleLocate(0, 24)
    
    ; Give the user a chance to see the output before we quit
    Print("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


; ExecutableFormat=Console
; EOF