
; ------------------------------------------------------------
;
;   PureBasic - Window 3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#MainWindow = 0
#CloseButton = 0

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Window 3D - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

InitScreenGadgets() ; Must be called after OpenWindowedScreen()

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100)  ; Front camera
MoveCamera(0,0,100,100, #PB_Absolute)


OpenScreenWindow(#MainWindow, 100, 100, 500, 200, "Hello in 3D !")

ButtonScreenGadget(#CloseButton, 150, 40, 200, 50, "Quit")

Repeat
  While WindowEvent():Wend

  ExamineKeyboard()
  ExamineMouse()

  ; Handle the screen GUI events. There is at most one event per frame, so no inner event loop is needed
  ;
  If ScreenWindowEvent() = #PB_Event_Gadget
    If EventScreenGadget() = #CloseButton
      Quit = 1
    EndIf
  EndIf

  RenderWorld()
  RenderScreenGadgets() ; Draw the screen GUI over the 3D world

  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
