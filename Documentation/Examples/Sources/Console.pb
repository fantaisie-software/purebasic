;
; ------------------------------------------------------------
;
;   PureBasic - Console example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
    text$  = "Feel the Power of PureBasic!"        ; just a small text$ string
    dlay   = 4000                                  ; delay will set to 4000

;
;-------- Open our Console --------
;

    OpenConsole()                                  ; First we must open a console
    ConsoleTitle ("PureBasic - Console Example:")  ; Now we can give the opened console a Titlename ;)
    EnableGraphicalConsole(1)

;
;-------- Ask and display the UserName --------
;
    
    ConsoleLocate (18,12)                          ; x y position
    Print ("Please enter your name:   ")           ; Ask for name
    name$=Input()                                  ; Wait for user input

    ClearConsole()                                 ; This will clean the ConsoleScreen
    
    ConsoleLocate (24,10)                          ; x y position
    PrintN ("Welcome "+name$)                      ; Print our text and the UserName
    ConsoleLocate (24,12)                          ; x y position
    PrintN (text$)                                 ; Print our text

    Delay (dlay)                                   ; Waits for moment

;
;-------- Cls and Cycle the Text-BG-Color 0 to 15 --------
;

    ClearConsole()                                 ; This will clean the ConsoleScreen
                                                   ; Info: Standard colors are (8 for text, 0 for backround)
    For i = 0 To 15
        ConsoleColor (0,i)                         ; Change BackGround text color (max 15) in every loop
        ConsoleLocate (24,4+i)                     ; x y position
        Print (text$)                              ; Print our text
    Next i

    Delay (dlay)                                   ; Waits for moment

;
;-------- Cls and Cycle the Text-FG-Color 0 to 15 --------
;

    ConsoleColor(0,0)                              ; Set back to black (0,0) for complete background...
    ClearConsole()                                 ; This will clean the ConsoleScreen
                                                   ; Info: Standard colors are (8 for text, 0 for backround)
    For i = 0 To 15
        ConsoleColor (i,0)                         ; Change ForGround text color (max 15) in every loop
        ConsoleLocate (24,4+i)                     ; x y position
        Print (text$)                              ; Print our text
    Next i

    Delay (dlay)                                   ; Waits for moment

;
;-------- Cls and Cycle the Background-Color 0 to 15 --------
;

    For a = 1 To 15
        ConsoleColor(a,a)                          ; Cycle background color...
        ClearConsole()                             ; This will clean the ConsoleScreen
        ;                                          ; Info: Standard colors are (8 for text, 0 for backround)
        For i = 0 To 15
            ConsoleColor (i,a)                     ; Change ForGround text color (max 15) in every loop
            ConsoleLocate (24,4+i)                 ; x y position
            Print (text$)                          ; Print our text
        Next i
        ;
        Delay(dlay/10)                             ; Waits for moment
    Next a

    ;-------- Exit --------

    CloseConsole()
End