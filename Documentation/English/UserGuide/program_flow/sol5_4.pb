If OpenConsole()

    count = 1
    While count<100

        Print(Str(count) + " in words is: ")

        If count>=10 And count<20
            Select count
                Case 10 : Print("Ten")
                Case 11 : Print("Eleven")
                Case 12 : Print("Twelve")
                Case 13 : Print("Thirteen")
                Case 14 : Print("Fourteen")
                Case 15 : Print("Fifteen")
                Case 16 : Print("Sixteen")
                Case 17 : Print("Seventeen")
                Case 18 : Print("Eighteen")
                Case 19 : Print("Nineteen")
            EndSelect

            tens.w = count / 10
            units.w = count - (tens * 10)
        Else

            tens.w = count / 10
            Select tens
                Case 2 : Print("Twenty ")
                Case 3 : Print("Thirty ")
                Case 4 : Print("Forty ")
                Case 5 : Print("Fifty ")
                Case 6 : Print("Sixty ")
                Case 7 : Print("Seventy ")
                Case 8 : Print("Eighty ")
                Case 9 : Print("Ninety ")
            EndSelect

            units.w = count - (tens * 10)
            Select units
                Case 1 : Print("One")
                Case 2 : Print("Two")
                Case 3 : Print("Three")
                Case 4 : Print("Four")
                Case 5 : Print("Five")
                Case 6 : Print("Six")
                Case 7 : Print("Seven")
                Case 8 : Print("Eight")
                Case 9 : Print("Nine")
            EndSelect
        
        EndIf

        ; Move onto next value
        PrintN("")
        count + 1

        ; A pause to let the user see the result of the program
        If units=9
            PrintN("Press return to continue")
            PrintN("")
            Input()
        EndIf
    Wend

EndIf
End

