If OpenConsole()

    divided.l = 64
    Repeat
        PrintN("divided = "+Str(divided))
        divided = divided / 2
    Until divided = 1

    Repeat
        PrintN("You will see this once")
    Until 1

    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


