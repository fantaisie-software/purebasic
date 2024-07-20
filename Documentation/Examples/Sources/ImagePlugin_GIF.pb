;
; ------------------------------------------------------------
;
;   PureBasic - ImagePlugin GIF Viewer example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Enable the GIF decoder
UseGIFImageDecoder()

; Loading a GIF file
If LoadImage(0, #PB_Compiler_Home+"Examples/Sources/Data/PureBasicLogo.gif")

  OpenWindow(0, 100, 100, DesktopUnscaledX(ImageWidth(0)), DesktopUnscaledY(ImageHeight(0)), "GIF viewer")
 
  CanvasGadget(0, 0, 0, ImageWidth(0), ImageHeight(0))
  
  ; Add a timer to animate the GIF, starts immediately to display the first frame witout delay
  AddWindowTimer(0, 0, 1)
 
  Repeat
    Event = WaitWindowEvent()
   
    If Event = #PB_Event_Timer
      SetImageFrame(0, Frame)
     
      ; Each GIF frame can have its own delay, so change the timer accordingly
      ;
      RemoveWindowTimer(0, 0)
      AddWindowTimer(0, 0, GetImageFrameDelay(0))
     
      If StartDrawing(CanvasOutput(0))
        DrawImage(ImageID(0), 0, 0)
        StopDrawing()
      EndIf
      
      ; Go to next frame
      Frame+1
      If Frame >= ImageFrameCount(0) ; Cycle back to first frame, to play in loop
        Frame = 0
      EndIf
    EndIf
   
  Until Event = #PB_Event_CloseWindow
Else
  Debug "Impossible to load the file: " + Filename$
EndIf
