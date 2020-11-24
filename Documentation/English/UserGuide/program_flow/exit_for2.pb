If OpenConsole()

    For count=0 To 10
        If count=5
            Goto loop_exit
        Else
            PrintN("The value of count is "+Str(count))
        EndIf
    Next
    loop_exit:
    
    PrintN("Press return to exit program")
    Input()
    CloseConsole()
EndIf
End

