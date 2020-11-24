; Open console and check that it is opened successfully. Only perform the main part of
; the program if it was successful.
If OpenConsole()

    ; Reset our running total to zero
    total.l = 0
    
    ; Loop to take in 10 numbers
    For which_number=1 To 10
    
        ; Give the user a prompt, telling them what to enter
        PrintN("")
        Print("Please enter a value for number "+Str(which_number)+" in the range 1 to 10: ")
        
        ; Read in a number from the keyboard
        number.l = Val(Input())
        
        ; Invalid number handling loop - instructions in the loop are repeated while
        ; the number the user enters is out of range
        While number<1 Or number>10
        
            ; Tell the user they went wrong and read in a new number
            PrintN("")
            Print("Error: you must enter a number between 1 and 10: ")
            number.l = Val(Input())
        Wend
        
        ; Add valid number onto running total
        total = total + number
    Next
    
    ; Display final total
    PrintN("")
    PrintN("The total of the numbers you entered is "+Str(total))
    
    ; Give the user the chance to see the result before exiting
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End

; ExecutableFormat=Windows
; EOF