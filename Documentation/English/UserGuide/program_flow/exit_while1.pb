If OpenConsole()
    
    count = 0
    While count <= 10
        If count = 5
            count = 10
        Else
            PrintN("The value of count is "+Str(count))
        EndIf
    
        count = count + 1
    Wend
    
    count = 0
    loop_exit = 0
    Repeat
        If count = 5
            loop_exit = 1
        Else
            PrintN("The value of count is "+Str(count))
        EndIf
    
        count = count + 1
    Until count > 10 Or loop_exit=1

    PrintN("Press return to exit program")
    Input()
    CloseConsole()
EndIf
End


; ExecutableFormat=Windows
; EOF