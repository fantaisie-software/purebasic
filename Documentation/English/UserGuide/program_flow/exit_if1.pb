exit_test_var.l = 5
If OpenConsole()
    If exit_test_var<>5
        PrintN("Some text")
    EndIf
    
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


