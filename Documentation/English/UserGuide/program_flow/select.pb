If OpenConsole()

    ; This is the same as one of the previous examples, although
    ; the comparisons are always for equality so we cannot do the
    ; same as the ElseIf name$<>"John" part of the previous example
    name$ = "John"
    Select name$
        Case "Andrew"
            PrintN("You have the same name as my brother.")
            
        Case "Robert"
            PrintN("Were you named after the famous Scottish king?")
            
        Case "John"
            PrintN("Where can we find Paul, George and Ringo?")
            
        Default
            PrintN("Sorry, I do not recognise you.")
    EndSelect
    
    
    ; A simple set of instructions for farmers, depending on the age of their chickens ;)
    ; (NB: no animals were harmed during the testing of this example!)
    chicken_age.w = -1
    Select chicken_age
        Case 0
            PrintN("Just a chick more than a chicken")

        Case 1
            PrintN("Useful for laying eggs")

        Case 2
            PrintN("Prime age for meat - choppity chop chop! >)")

        Case 3
            PrintN("Getting old now, better put it out of its misery - choppity chop chop! >)")

        Default
            PrintN("Counting them before they are hatched?")
    EndSelect
    
    PrintN("Press return to exit program.")
    Input()
    CloseConsole()
EndIf
End

