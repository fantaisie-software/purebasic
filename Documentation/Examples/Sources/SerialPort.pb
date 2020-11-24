;
; ------------------------------------------------------------
;
;   PureBasic - SerialPort example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Port$ = "COM1"
CompilerElse
  Port$ = "/dev/ttyS0"
CompilerEndIf

If OpenSerialPort(0, Port$, 300, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 1024, 1024)
  
  MessageRequester("Information", "SerialPort opened with success")
  
Else
  MessageRequester("Error", "Can't open the serial port: "+Port$)
EndIf
