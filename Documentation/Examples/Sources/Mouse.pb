;
; ------------------------------------------------------------
;
;   PureBasic - Fullscreen mouse example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitMouse() = 0 Or InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Can't initialize GFX", 0)
  End
EndIf

;
;-------- MessageReq and OpenScreen --------
;

MessageRequester("Information", "This will test the fast mouse access..."+ #LF$ +
                                "Press any mouse button to quit!", 0)

If OpenScreen(1920, 1080, 32, "Mouse") = 0
  MessageRequester("Error", "Impossible to open a 800*600 32-bit screen",0)
  End
EndIf

;
;-------- Init and Load Stuff --------
;

x = 100
y = 100

LoadSprite(0, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp")   ; Load nice small Logo

;
;-------- MainLoop --------
;

Repeat
  FlipBuffers()                        ; Flip for DoubleBuffering
  ClearScreen(RGB(0,0,0))              ; CleanScreen, black

  ExamineKeyboard()
  ExamineMouse()
          
  x = MouseX()                         ; Returns actual x pos of our mouse
  y = MouseY()                         ; Returns actual y pos of our mouse
  
  x+MouseWheel()*10
  
  If MouseButton(#PB_MouseButton_Middle)
    MouseLocate(ScreenWidth()/2, ScreenHeight()/2)
  EndIf

  DisplaySprite(0, x-SpriteWidth(0)/2, y-SpriteHeight(0)/2)
  
Until MouseButton(#PB_MouseButton_Left) Or MouseButton(#PB_MouseButton_Right)

End