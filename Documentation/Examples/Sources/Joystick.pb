;
; ------------------------------------------------------------
;
;   PureBasic - Joystick example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

NbJoysticks = InitJoystick()

If NbJoysticks = 0
  MessageRequester("Error", "No joysticks are availables.", 0)
  End
EndIf

If OpenWindow(0, 100, 100, 300, 260, "PureBasic - Joystick Demo")

  MessageRequester("Information", "This will test the joystick in a window.", 0)

  x = WindowWidth(0)/2
  y = WindowHeight(0)/2-20

  Repeat
  
    Repeat
      Event = WindowEvent()
      If Event = #PB_Event_CloseWindow : Quit = 1 : EndIf
    Until Event = 0

    Delay(20) ; a little delay (20 milli seconds -> 50 fps)
  
    If ExamineJoystick(0)
      x+JoystickAxisX(0)
      y+JoystickAxisY(0)
     
      If JoystickButton(0, 1)
        MessageRequester("Info", "Button 1 has been pressed", 0)
      EndIf
      
      If JoystickButton(0, 2)
        MessageRequester("Info", "Button 2 has been pressed", 0)
      EndIf
    
      If StartDrawing(WindowOutput(0)) ; Set the drawing output to our window
        FrontColor(RGB(255,0,0))      ; Use the RED colour
        Box(x, y, 10, 10)         ; Draw a little box
        StopDrawing()             ;
      EndIf
    EndIf

  Until Quit = 1

EndIf

End
