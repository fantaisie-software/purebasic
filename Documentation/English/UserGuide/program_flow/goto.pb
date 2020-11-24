If OpenConsole()
    Goto demo_label

    PrintN("This command will not be executed")

    demo_label:
    PrintN("Press any key to exit")
    Input()
    CloseConsole()
EndIf
End


