;
; ------------------------------------------------------------
;
;   PureBasic - 2D Drawing example file
;
;    (c) 2005 - Fantaisie Software
;
; ------------------------------------------------------------
;

If OpenWindow(0, 100, 200, 300, 200, "2D Drawing Test")

  ; Create an offscreen image, with a green circle in it.
  ; It will be displayed later
  ;
  If CreateImage(0, DesktopScaledX(300), DesktopScaledY(200))
    If StartDrawing(ImageOutput(0))
      Circle(100,100,50,RGB(0,0,255))  ; a nice blue circle...

      Box(150,20,20,20, RGB(0,255,0))  ; and a green box
      
      FrontColor(RGB(255,0,0)) ; Finally, red lines..
      For k=0 To 20
        LineXY(10,10+k*8,200, 0)
      Next
      
      DrawingMode(#PB_2DDrawing_Transparent)
      BackColor(RGB(0,155,155)) ; Change the text back and front colour
      FrontColor(RGB(255,255,255))
      DrawText(10,50,"Hello, this is a test")

      StopDrawing()
    EndIf
  EndIf

  ; Create a gadget to display our nice image
  ;
  ImageGadget(0, 0, 0, 0, 0, ImageID(0))
  
  ;
  ; This is the 'event loop'. All the user actions are processed here.
  ; It's very easy to understand: when an action occurs, the Event
  ; isn't 0 and we just have to see what have happened...
  ;
  Repeat
    Event = WaitWindowEvent()
  Until Event = #PB_Event_CloseWindow  ; If the user has pressed on the window close button
  
EndIf

End   ; All the opened windows are closed automatically by PureBasic