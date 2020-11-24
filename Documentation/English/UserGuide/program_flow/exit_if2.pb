If OpenConsole()
    ; This is how many apples the user wants
    desired_quantity = 10

    If 1
        ; The default number of apples in a delivery
        apples = 8
        
        If apples >= desired_quantity
            Goto exit_position
        EndIf
        
        PrintN("Not enough apples")
        ; Perform instructions for adding more apples to the delivery
        
        exit_position:
    EndIf
    
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


