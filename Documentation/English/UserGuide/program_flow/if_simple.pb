If OpenConsole()
    PrintN("Console was opened successfully")

    a.l = 3
    b.l = 4
    If a=b
        PrintN("The values of the variables are the same.")
    EndIf

    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


