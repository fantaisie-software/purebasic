If OpenConsole()
    
    ; Problem 1 - read a number from the user in the range 1 to 10
    Repeat
        Print("Please enter a number in the range 1 to 10: ")
        
        number.l = Val(Input())
        PrintN("")  ; Move onto the line after the user's number has been entered
        
        ; Check the data the user entered and let them know if it was incorrect
        If number<1 Or number>10
            PrintN("Error. You must enter a number between 1 and 10.")
        EndIf
    
        ; Keep going round the loop until the number the user enters is valid
    Until number>=1 And number<=10
    
    PrintN("You successfully entered the number "+Str(number))


    ; Problem 2 - read a number from the user in the range 1 to 100
    Print("Please enter a number in the range 1 to 100: ")
    number = Val(Input())
    
    While number<1 Or number>100
        PrintN("")
        Print("Error. You must enter a number between 1 and 100: ")
        number.l = Val(Input())
    Wend
    
    PrintN("")
    PrintN("You successfully entered the number "+Str(number))
    
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End

; ExecutableFormat=Windows
; EOF