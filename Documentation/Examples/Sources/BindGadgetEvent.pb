;
; ------------------------------------------------------------
;
;   PureBasic - BindEvent and  BindGadgetEvent example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Let's create a custom TrackBar gadget with a Canvas gadget.


Procedure RepaintCanvas(x)
  ; Paint a canvas which looks like a Trackbar
  If StartDrawing( CanvasOutput(0) )
    Box(0,0,OutputWidth(),OutputHeight(),RGB($FF,$FF,$FF))
    DrawingMode(#PB_2DDrawing_Gradient)
    BackColor(RGB($40,$40,$40))
    FrontColor(RGB($DD,$DD,$DD))
    LinearGradient(0, 0, OutputWidth(), OutputHeight())
    Box(0,0,OutputWidth(),OutputHeight())
    DrawingMode(#PB_2DDrawing_Default)
    Box(x,0,OutputWidth()-x,OutputHeight(),RGB($FF,$FF,$FF))
    Box(x-3,0,5,OutputHeight(),RGB($00,$00,$00))
    StopDrawing()
  EndIf
EndProcedure

Procedure OnLeftClick()
  ; Left click on the canvas
  RepaintCanvas( GetGadgetAttribute(0,#PB_Canvas_MouseX) )
EndProcedure

Procedure OnMouseMove()
  ; Left click + move on the mouse on the canvas
  If GetGadgetAttribute(0,#PB_Canvas_Buttons) & #PB_Canvas_LeftButton
    x = GetGadgetAttribute(0,#PB_Canvas_MouseX)
    If x < 0 : x = 0 : EndIf
    If x > DesktopScaledX(GadgetWidth(0)) : x = DesktopScaledX(GadgetWidth(0)) : EndIf
    RepaintCanvas( x )
  EndIf
EndProcedure

 ; Let's open a windows with a canvas
If OpenWindow(0, 0, 0, 220, 40, "BindGadgetEvent", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  CanvasGadget(0, 10, 10, 200, 20)
  
  RepaintCanvas(50) ; Paint the canvas and set the tracker at 50
  
  BindGadgetEvent(0, @OnLeftClick(),#PB_EventType_LeftClick) ; Bind canvas left click
  BindGadgetEvent(0, @OnMouseMove(),#PB_EventType_MouseMove) ; Bind mouse move on the canvas
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf

