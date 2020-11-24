If OpenConsole()

    PrintN("Start of first loop")
    
    the_other = 1
    For something=10 To the_other Step -1
        PrintN("Current loop number is "+Str(something))
    Next
    
    PrintN("")
    PrintN("Start of second loop")

    For something=1 To 10 Step 2
        PrintN("Current loop number is "+Str(something))
    Next
        
    PrintN("Press return to exit program.")
    Input()
    CloseConsole()
EndIf
End


