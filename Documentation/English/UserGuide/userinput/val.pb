If OpenConsole()

    Print("Please enter your name: ")
    name$ = Input()
    PrintN("")

    Print("How old are you? ")
    age.w = Val(Input())
    PrintN("")

    Print("Please enter a number (with decimal places if you like): ")
    num1.f = ValF(Input())
    PrintN("")

    Print("and another (with decimal places if you like): ")
    num2.f = ValF(Input())
    PrintN("")

    ; Display the results to the user
    PrintN("")
    PrintN("Hello, "+name$+". I see that you are "+Str(age)+" years old.")
    PrintN("You have an affinity with the number "+StrF(num1 * num2)+"!")

    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End
; ExecutableFormat=
; EOF