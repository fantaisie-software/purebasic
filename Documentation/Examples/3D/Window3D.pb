
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

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Window 3D - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100)  ; Front camera
MoveCamera(0,0,100,100, #PB_Absolute)


OpenWindow3D(#MainWindow, 100, 100, 500, 200, "Hello in 3D !")

ButtonGadget3D(#CloseButton, 150, 40, 200, 50, "Quit")

ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor

Repeat
  While WindowEvent():Wend
  
  If ExamineKeyboard() And ExamineMouse()
    Input$ = KeyboardInkey()
    
    InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left), Input$, 0)
  EndIf
  
  ; Handle the GUI 3D events, it's similar to regular GUI events
  ;
  Repeat
    Event = WindowEvent3D()
    
    Select Event
      Case #PB_Event3D_CloseWindow
        If EventWindow3D() = #MainWindow
          CloseWindow3D(#MainWindow)
        EndIf
        
      Case #PB_Event3D_Gadget
        If EventGadget3D() = #CloseButton
          Quit = 1
        EndIf
        
    EndSelect
  Until Event = 0
  
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
