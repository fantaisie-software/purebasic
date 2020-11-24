If OpenConsole()

    ConsoleTitle("PureBasic User Guide console appearance example")

    PrintN("You will never see me!")
    ClearConsole()

    ConsoleColor(14, 1)
    Print("Enter your name: ")
    ConsoleColor(7, 0)
    name$ = Input()
    ConsoleColor(14, 1)
    ConsoleLocate(17, 0)
    Print("Thank you, "+name$)
    ConsoleColor(7, 0)

    ConsoleLocate(0, 24)
    Print("Press return to exit")
    Input()
    CloseConsole()
EndIf
End
; ExecutableFormat=
; EOF