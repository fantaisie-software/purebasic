
; ------------------------------------------------------------
;
;   PureBasic - ScreenGadget
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

#HelloWindow = 0
#QuitButton  = 0

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops()
dx = DesktopWidth(0) * 0.8
dy = DesktopHeight(0) * 0.8

OpenWindow(0, 0, 0, DesktopUnscaledX(dx), DesktopUnscaledY(dy), "[Escape] to quit", #PB_Window_BorderLess | #PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

; Create the Screen UI
InitScreenGadgets()

TextScreenGadget(#PB_Any, 50, 0, 500, 24, "The screen is a container, you can put gadgets without windows")

OpenScreenWindow(#HelloWindow, 100, 100, 300, 100, "Screen UI")
ScreenWindowAnimation(#HelloWindow, 0, 1000, 1, 0, - 1, 0, - 1)

TextScreenGadget(#PB_Any, 10, 25, 300, 24, "Hello World !")
ButtonScreenGadget(#QuitButton, 70, 60, 160, 32, "Quit")

Repeat
  ; Top Window
  While WindowEvent() : Wend
  
  ClearScreen(RGB(0, 0, 0))
  
  ExamineMouse()
  ExamineKeyboard()
  
  ; Handle the screen UI events
  If ScreenWindowEvent() = #PB_Event_Gadget
    Select EventScreenGadget()
      Case #QuitButton
        End
    EndSelect
  EndIf
  
  RenderScreenGadgets()
  
  FlipBuffers()
  
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(#PB_MouseButton_Middle)