;
; ------------------------------------------------------------
;
;   PureBasic - String example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

c$ = "Test"
a$ = Left(c$,1)
a$ = Mid(c$,3, 1)

a = Val("-121212")

MessageRequester("PureBasic", "Welcome: "+Mid(Str(a),2,3)+" "+a$, 0)
 