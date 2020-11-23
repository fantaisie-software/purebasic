;
; ------------------------------------------------------------
;
;   PureBasic - Math example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


If OpenWindow(0, 200, 200, 400, 400, "Test")

  ImageGadget(0, 0, 0, 400, 400, 0)

  CreateImage(0, 400, 400)

  X.f = 40+Random(40)
  Y.f = X
  
  AddWindowTimer(0, 0, 10)
  
  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Timer
      a.f+0.01
    
      If StartDrawing(ImageOutput(0))
        FrontColor(RGB(0, Random(255), Random(255)))
        
        x2.f = X*Cos(a) + Y*Sin(a)
        y2.f = X*Sin(a) - Y*Cos(a)
        
        Plot(200+x2, 200+y2)
        Plot(100+x2, 200+y2)
  
        StopDrawing()
      EndIf
  
      SetGadgetState(0, ImageID(0))
    EndIf
    
  Until Event = #PB_Event_CloseWindow
  
EndIf