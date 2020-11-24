; Open the console and only perform the main instructions
; if it was opened successfully
If OpenConsole()

    ; Since we are printing 16 values per row, that gives us
    ; 16 rows. This shows an alternative way to achieve the
    ; same as in ex 5.2
    For row = 32 To 127 Step 16
        For column = 0 To 15

            ; Calculate the value to print
            value = row + column

            ; And print it if the value is not 127
            If value <> 127
                Print(Str(value)+" ")
            EndIf
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

