;
; ------------------------------------------------------------
;
;   PureBasic - Thread example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Procedure AlertThread(Parameter)

  Repeat
    Debug "Alert !"
    Delay(2000)
  ForEver

EndProcedure

CreateThread(@AlertThread(), 0)

MessageRequester("Info", "It will display an alert every 2 seconds."+#LF$+"Click To finish the program", 0)
