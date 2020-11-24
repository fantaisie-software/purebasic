; Open console and continue with program only if it is successful
If OpenConsole()

    a.w = 5
    b.w = 10
    c.w = 2

    PrintN("a="+Str(a)+"  b="+Str(b)+"  c="+Str(c))

    If a>b
        PrintN("a is more than b")
    Else
        PrintN("a is less than or equal to b")
    EndIf

    If a>=b
        PrintN("a is more than or equal to b")
    Else
        PrintN("a is less than b")
    EndIf

    If a=b
        PrintN("a is the same value as b")
    Else
        PrintN("a has a different value from b")
    EndIf

    If c<>b
        PrintN("c has a different value from b")
    Else
        PrintN("c is the same value as b")
    EndIf

    If c<b
        PrintN("c is less than b")
    Else
        PrintN("c is more than or equal to b")
    EndIf

    If c<=b
        PrintN("c is less than or equal to b")
    Else
        PrintN("c is more than b")
    EndIf

    If a>b Or b>c
        PrintN("a is more than b or b is more than c")
    Else
        PrintN("a is less than or equal to b and b is less than or equal to c")
    EndIf

    If a<>b And a<>c
        PrintN("a is not equal to b and a is not equal to c")
    Else
        PrintN("a is equal to b or a is equal to c")
    EndIf

    ; Give user some time to see output of program and then exit
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End

