;
; ------------------------------------------------------------
;
;   PureBasic - Image example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


If OpenWindow(0, 100, 100, 500, 300, "PureBasic - Image")

  If CreateImage(0, 255, 255)

    StartDrawing(ImageOutput(0))
    
    For k=0 To 255
      FrontColor(RGB(k,0, k))  ; a rainbow, from black to pink
      Line(0, k, 255, 1)
    Next

    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(255,255,255)) ; print the text to white !
    DrawText(40, 50, "An image easily created !")

    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
  EndIf
  
  CopyImage(0, 1)
  ResizeImage(1, 100, 100)
  
  GrabImage(0, 2, 100, 60, 150, 40)

        
  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Repaint
      StartDrawing(WindowOutput(0))
        DrawImage(ImageID(0), 20, 10)
        DrawImage(ImageID(1), 320, 80)
        DrawImage(ImageID(2), 320, 200)
      StopDrawing()    
    EndIf
    
  Until Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
  
EndIf

End   ; All the opened windows are closed automatically by PureBasic
