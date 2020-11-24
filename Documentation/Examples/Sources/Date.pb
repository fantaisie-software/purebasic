;
; ------------------------------------------------------------
;
;   PureBasic - Date example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Date$ = FormatDate("%yyyy/%mm/%dd", Date())
Time$ = FormatDate("%hh:%ii:%ss", Date())

MessageRequester("PureBasic - Date Example", "Date: "+Date$+Chr(10)+"Time: "+Time$, 0)