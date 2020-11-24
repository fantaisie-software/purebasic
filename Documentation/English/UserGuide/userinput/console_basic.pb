If OpenConsole()
    PrintN("Console was opened successfully")

    PrintN("Press return to exit")
    Input()
    CloseConsole()
Else
    ; Failed to open console - make sure you do not use the Print command
    ; to tell the user about it though :)
EndIf
End

; ExecutableFormat=Windows
; EOF