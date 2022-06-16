;
; ------------------------------------------------------------
;
;   PureBasic - BindEvent and  BindGadgetEvent example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Let's create a speedButton which produce event as long as it's pressed.

Global Gadget, Pressed.b, n
Global Min=-50, Max=50

; Change the speed here !
Global Delay=50 ; 50 ms


Procedure paint(canvas, state, text$)
  ; Paint canvas as fake button "+" and fake button "-"
  Protected w, h
  ;State: 0     = Pushed
  ;State: Not 0 = Released
  If StartDrawing(CanvasOutput(canvas))
    Width = OutputWidth()
    Height = OutputHeight()
    Box(0,0,Width,Height,$CFFFFC) ; Yellow background
    If state=0 ; UP
      LineXY(0,Height,Width,Height,$000000)
      LineXY(Width,0,Width,Height,$000000)
      LineXY(0,0,Width,0,$FFFFFF)
      LineXY(0,0,0,Height,$FFFFFF)
    Else       ;DOWN
      LineXY(0,Height,Width,Height,$FFFFFF)
      LineXY(Width,0,Width,Height,$FFFFFF)
      LineXY(0,0,Width,0,$000000)
      LineXY(0,0,0,Height,$000000)
    EndIf
    w=TextWidth(text$)
    h=TextHeight(text$)
    DrawText(Height/2-w/2, Height/2-h/2, Text$, $000000, $CFFFFC)
    
    StopDrawing()
  EndIf
  
EndProcedure

Procedure OnSpeedButtonEvent()
  ; Bind all button "-" events and all button "+" events
  Gadget = EventGadget()
  
  Select EventType() ; Which event ?
    Case #PB_EventType_MouseEnter
      If Gadget=0
        Debug "Enter button -"
      ElseIf Gadget=1
        Debug "Enter button +"
      EndIf
      
    Case #PB_EventType_MouseLeave
      If Gadget=0
        Debug "Leave button -"
      ElseIf Gadget=1
        Debug "Leave button +"
      EndIf
      
    ; Each time a button is left clicked
    Case #PB_EventType_LeftButtonDown
      Pressed = #True
      
      Select Gadget
        Case 0 ; Button "-"
          paint(0,1,"-") ; Paint the button "-" pushed
        Case 1 ; Button "+"
          paint(1,1,"+") ; Paint the button "+" pushed
      EndSelect
      
    Case #PB_EventType_LeftButtonUp
      Pressed = #False
      paint(0,0,"-")     ; Paint the button "-" released
      paint(1,0,"+")     ; Paint the button "+" released
      
  EndSelect
EndProcedure

Procedure OnTimer()
  If Pressed ; Each time a button is left clicked and as long as it's clicked
    Select Gadget
      Case 0 ; Button "-"
        If n>Min
         n-1
         SetGadgetState(2, GetGadgetState(2)-1) ; ProgressBar down
        EndIf
        
      Case 1 ; Button "+"
        If n<Max
         n+1
         SetGadgetState(2, GetGadgetState(2)+1) ; ProgressBar up
        EndIf
    EndSelect
    
    Debug n
  EndIf
EndProcedure

; Open a window with some gadgets
OpenWindow(0, 0, 0, 400, 100, "Please clic a looooong time please on +/-", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
CanvasGadget(0, 10, 30, 32, 32)        ; Fake button -
CanvasGadget(1, 400-32-10, 30, 32, 32) ; Fake button +
paint(0,0,"-")
paint(1,0,"+")
ProgressBarGadget(2,52,30,296,32,Min,Max,#PB_ProgressBar_Smooth)

AddWindowTimer(0, 100, Delay) ; Timer 100 ms

BindGadgetEvent(0, @OnSpeedButtonEvent()) ; Bind all button "-" events
BindGadgetEvent(1, @OnSpeedButtonEvent()) ; Bind all button "+" events
BindEvent(#PB_Event_Timer, @OnTimer())    ; Bind the timer event

Repeat : Until WaitWindowEvent(10) = #PB_Event_CloseWindow
