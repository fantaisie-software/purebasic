If OpenConsole()
    age.w = 0
    While age <= 120
        PrintN("Happy birthday at "+Str(age)+" years old")
        age = age + 20
    Wend
    PrintN("Died at "+Str(age)+" years old")
    
    
    bottom = 0
    top = 10
    While bottom<>top And bottom<4
        PrintN("Bottom="+Str(bottom)+"  Top="+Str(top))
        
        bottom + 1
        top - 1
    Wend
    
    
    While 0
        PrintN("You will never see me")
    Wend
    
    
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


