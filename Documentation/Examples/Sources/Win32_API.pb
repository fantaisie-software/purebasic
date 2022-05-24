;
; ------------------------------------------------------------
;
;   PureBasic - Win32 API example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; NOTE: This file doesn't compile with the demo version ! (API Calls)
;

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "This example is Windows only"
CompilerEndIf

;
; Now, open a window, and do some stuff with it...
;

If OpenWindow(0, 100, 100, 195, 260, "PureBasic Window")

  ;
  ; This is the 'event loop'. All the user actions are processed here.
  ; It's very easy to understand: when an action occurs, the Event
  ; isn't 0 and we just have to see what have happened...
  ;

  Repeat
    Event = WaitWindowEvent()

    ;
    ; Here we use directly the Windows API to draw an ellipse.
    ; All the Windows® functions are supported !
    ;
  
    *DC = GetDC_(WindowID(0))          ; Get the output pointer
    Ellipse_(*DC, 10, 10, 100, 100)   ; Draw a filled ellipse
    ReleaseDC_(WindowID(0), *DC)       ; Release the drawing output

    If Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
      Quit = 1
    EndIf

  Until Quit = 1
  
EndIf

End   ; All the opened windows are closed automatically by PureBasic
