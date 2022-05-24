;
; ------------------------------------------------------------
;
;   PureBasic - Font example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; NOTE: This file doesn't compile with the demo version !
;

LoadFont (0, "Courier", 15)            ; Load Courier Font, Size 15
LoadFont (1, "Arial", 24)              ; Load Arial Font, Size 24

If OpenWindow(0, 100, 200, 460, 148, "Font Test") = 0
  MessageRequester("Error", "Can't open Window", 0)
  End
EndIf

If CreateImage(0, DesktopScaledX(450), DesktopScaledY(130))

  If StartDrawing(ImageOutput(0))
    Box(0, 0, ImageWidth(0), ImageHeight(0), RGB(255, 255, 255)) ; White background
  
    DrawingMode(1)                          ; Transparent TextBackground
  
    DrawingFont(FontID(0))                  ; Use the 'Courier' font
    DrawText(10,10, "Font: Courier - Size: 15 - Red", RGB(255, 0, 0))    ; Print our text
                
    DrawingFont(FontID(1))                  ; Use the Arial font
    DrawText(10,40, "Font: Arial - Size: 24", RGB(0, 0, 0))     ; Print our text

    StopDrawing()                           ; This is absolutely needed when the drawing operations are
  EndIf                                     ; finished !!! Never forget it !

EndIf

; Display the image on the window
;
ImageGadget(0, 5, 10, ImageWidth(0), ImageHeight(0), ImageID(0))

;
; This is the 'event loop'. All the user actions are processed here.
; It's very easy to understand: when an action occurs, the Event
; isn't 0 and we just have to see what have happened...
;
Repeat
  Event = WaitWindowEvent()
Until Event = #PB_Event_CloseWindow    ; If the user has pressed on the close button

End                                    ; All the opened windows are closed automatically by PureBasic
  