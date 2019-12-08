;
; ------------------------------------------------------------
;
;   PureBasic - IDE Automation library - example
;
;    (c) 2010 - Fantaisie Software
;
; ------------------------------------------------------------
;

;
; This short example shows how to use the wrapper to the
; IDE's Automation library provided in Automation.pb to
; connect to the IDE and get it to open the Preferences dialog.
;
; The available commands in the dll and their parameters are
; described in the Automation.pb file.
;

XIncludeFile "Automation.pb"

If Automation_Initialize()
  Debug "Library initialized"
  
  If Automation_ConnectToProgram(#PB_Compiler_Home + "PureBasic.exe")
    Debug "Connected to the IDE"
    
    ; Open the preferences window
    ;
    If Automation_MenuCommand("Preferences")
      Debug "Preferences opened"
    Else
      Debug "Error: " + Automation_ErrorMessage()
    EndIf
    
    Automation_Disconnect()
  Else
    Debug "Error: " + Automation_ErrorMessage()
  EndIf
  
  Automation_Shutdown()
Else
  Debug "Could not load Automation library"
EndIf