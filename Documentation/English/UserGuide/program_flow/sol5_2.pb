; Open the console and only perform the main instructions
; if it was opened successfully
If OpenConsole()

    ; Since we are printing 16 values per row, that gives us
    ; 16 rows (remember that the two values in the For...Next
    ; statement are included so 0 to 15 gives us 16 items)
    For row = 0 To 15
        For column = 0 To 15

            ; Calculate the value to print
            value = row * 16 + column

            ; And print it
            Print(Str(value)+" ")
        Next

        ; Print nothing, with a new line so we move onto the next line
        PrintN("")
    Next

    ; Tell the user how to exit the program
    ; and give them some time to see the display
    PrintN("Press return to exit")
    Input()
    CloseConsole()

EndIf
End

