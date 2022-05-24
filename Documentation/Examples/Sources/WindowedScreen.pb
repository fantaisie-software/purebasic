;
; ------------------------------------------------------------
;
;   PureBasic - Windowed Screen example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitSprite() = 0 Or InitKeyboard() = 0 Or InitMouse() = 0
  MessageRequester("Error", "Can't open the sprite system", 0)
  End
EndIf

If OpenWindow(0, 0, 0, 340, 285, "Gadget and sprites!", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  ButtonGadget(1, 10,  10, 100, 25, "Grab input")
  ButtonGadget(2, 120,  10, 100, 25, "Button 2")
  ButtonGadget(3, 230,  10, 100, 25, "Button 3")
  TextGadget  (4, 10, 40, 300, 30, "Mouse and keyboard released")

  If OpenWindowedScreen(WindowID(0), DesktopScaledX(10), DesktopScaledX(70), DesktopScaledX(320), DesktopScaledX(200), 0, 0, 0)
    LoadSprite(0, #PB_Compiler_Home + "examples/sources/Data/PureBasicLogo.bmp")

    direction = 1
    playerX = 1
    playerY = 1
    
    ; Center the mouse driven sprite
    ;
    MouseX = (ScreenWidth() - SpriteWidth(0)) / 2
    MouseY = (ScreenHeight() - SpriteHeight(0)) / 2
    MouseLocate(MouseX, MouseY)
    
    ; Start with released input
    ReleaseMouse(#True)
    InputReleased = 1
    
    Repeat
      Repeat
        ; Always process all the events to flush the queue at every frame
        Event = WindowEvent()
        
        Select Event
          Case #PB_Event_CloseWindow
            Quit = 1
        
          Case #PB_Event_Gadget
            
            ; Do the normal application management here
            Gadget = EventGadget()
        
            Select Gadget
              Case 1
                InputReleased = 0
                ReleaseMouse(#False)
                SetGadgetText(4, "Press 'F1' to ungrab keyboard and mouse")
    
              Case 2, 3
                SetGadgetText(4, "Button "+Str(Gadget)+" pressed.")
            EndSelect
        
        EndSelect
        
      Until Event = 0 ; Quit the event loop only when no more events are available
      
      ExamineKeyboard()
      
      If InputReleased = 0
    
        If ExamineMouse()
          MouseX = MouseX()
          MouseY = MouseY()
        EndIf
    
        ; do the sprite & screen management at every frame
        If KeyboardPushed(#PB_Key_Up)    And playerY > 0   : playerY -3 : EndIf
        If KeyboardPushed(#PB_Key_Down)  And playerY < 280 : playerY +3 : EndIf
        If KeyboardPushed(#PB_Key_Left)  And playerX > 0   : playerX -3 : EndIf
        If KeyboardPushed(#PB_Key_Right) And playerX < 300 : playerX +3 : EndIf
    
        If KeyboardPushed(#PB_Key_F1)
          ReleaseMouse(#True)
          InputReleased = 1
          SetGadgetText(4, "Mouse and keyboard released");
        EndIf
      EndIf
      
      ; Clear the screen and draw our sprites
      ClearScreen(RGB(0,0,0))
      ClipSprite(0, 0, 0, x, x/8)
      DisplaySprite(0, x, 100)
      DisplaySprite(0, x, x)
      DisplaySprite(0, 300-x, x)
      DisplaySprite(0, playerX, playerY)
      
      ClipSprite(0, #PB_Default , #PB_Default , #PB_Default , #PB_Default)
      DisplaySprite(0, MouseX, MouseY)
    
      x + direction
      If x > 300 : direction = -1 : EndIf   ; moving back to the left with negative value
      If x < 0   : direction =  1 : EndIf   ; moving to the right with positive value
        
      FlipBuffers()       ; Inverse the buffers (the back become the front (visible)... and we can do the rendering on the back
    
    Until  Quit Or KeyboardPushed(#PB_Key_Escape)
  Else
    MessageRequester("Error", "Can't open windowed screen!", 0)
  EndIf
EndIf
