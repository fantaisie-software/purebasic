If OpenConsole()

    For count=0 To 10
        If count=5
            count = 10
        Else
            PrintN("The value of count is "+Str(count))
        EndIf
    Next
    
    PrintN("Press return to exit program")
    Input()
    CloseConsole()
EndIf
End

