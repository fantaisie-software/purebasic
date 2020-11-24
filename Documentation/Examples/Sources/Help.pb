;
; ------------------------------------------------------------
;
;   PureBasic - Help example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

OpenHelp(#PB_Compiler_Home + "PureBasic.chm", "MainGuide\history.html")

MessageRequester("Information", "Click to close the PureBasic help and open another old .hlp file", 0)
CloseHelp()

Filename$ = OpenFileRequester("Choose an .hlp file", "", "WinHelp files (*.hlp)|*.hlp", 0)
If Filename$
  OpenHelp(Filename$, "")
EndIf
