If OpenConsole()
    name$ = "John"
    
    If name$="Frank"
        PrintN("Hi Frank, good to see you again.")
    ElseIf name$="Bob"
        PrintN("Bob! How are you?")
    ElseIf name$<>"John"
        PrintN("You are not John")
    Else
        PrintN("Sorry, I do not know who you are")
    EndIf

    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


