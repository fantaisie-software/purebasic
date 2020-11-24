If OpenConsole()

    game$ = "Football"
    team$ = "England"

    Select game$
        Case "Football"
            PrintN("Scotland will win the next football World cup.")
            ; (Well, dreams can come true ;)

            If team$="Scotland"
                Goto is_scotland
            EndIf

            ; These are the instructions we want to skip
            PrintN("The " + team$ + " football team have no chance of winning the next World Cup.")
            
            is_scotland:
        Default
            PrintN("I'm sorry, what kind of sport is that? ;p")
    EndSelect

    PrintN("Press return to exit program")
    Input()
    CloseConsole()
EndIf
End


