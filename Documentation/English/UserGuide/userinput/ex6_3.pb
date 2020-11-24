; Open console and only continue with program if it was opened successfully
If OpenConsole()

    ; Loop to display each of the foreground colors
    For foreground=0 To 15
    
        ; Loop to display each of the background colors
        For background=0 To 15
        
            ; Set the current foreground and background colors
            ConsoleColor(foreground, background)
            
            ; And display something so that both the foreground
            ; and background colors can be seen
            Print("*")
        Next
        
        ; Move onto the next line for the next foreground color
        PrintN("")
    Next
    
    ; Reset the colors to their defaults and give the user a chance to
    ; see the display before the program exits
    ConsoleColor(7, 0)
    PrintN("Press return to exit")
    Input()
    CloseConsole()
EndIf
End


; ExecutableFormat=Console
; EOF