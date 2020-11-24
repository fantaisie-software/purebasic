If OpenConsole()

    Print("  x")
    For column = 2 To 12
        Print("  ")
        If column < 10
            Print(" ")
        EndIf
        Print(Str(column))
    Next
    PrintN("")

    row = 2
    Repeat
        If row < 10
            Print(" ")
        EndIf
        Print(Str(row)+" ")

        For column = 2 To 12
            Print(" ")
            
            value = column * row
            
            If value < 10
                Print("  ")
            ElseIf value<100
                Print(" ")
            EndIf
            Print(Str(value))
        Next
        
        PrintN("")
        row = row + 1
    Until row=13

    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End

