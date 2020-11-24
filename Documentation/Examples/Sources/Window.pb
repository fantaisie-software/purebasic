;
; ------------------------------------------------------------
;
;   PureBasic - Window example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;
; Open a window, and do some stuff with it...
;

If OpenWindow(0, 100, 200, 195, 260, "PureBasic Window", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)

  MessageRequester("Information", "Click to move the Window", 0)
  ResizeWindow(0, 200, 200, #PB_Ignore, #PB_Ignore)   ; Move the window to the coordinate 200,200
  
  MessageRequester("Information", "Click to resize the Window", 0)
  ResizeWindow(0, #PB_Ignore, #PB_Ignore, 320, 200) ; Resize the window to 320,200
  
  ;
  ; This is the 'event loop'. All the user actions are processed here.
  ; It's very easy to understand: when an action occurs, the Event
  ; isn't 0 and we just have to see what have happened...
  ;

  Repeat
    Event = WaitWindowEvent()

    If Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
      Quit = 1
    EndIf

  Until Quit = 1
  
EndIf

End   ; All the opened windows are closed automatically by PureBasic
