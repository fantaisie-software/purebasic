
; ------------------------------------------------------------
;
;   PureBasic - LightLookAt
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " LightLookAt - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
        
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)

;- Ground
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1000, 1000, 50, 50, 1, 1)
CreateEntity (0, MeshID(0), MaterialID(0))


;- Light
CreateLight(0, RGB(255, 255, 255), 0, 900, 0, #PB_Light_Spot)
SpotLightRange(0, 1, 30, 3)
AmbientColor(0)

;- Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 900, 1200, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)
CameraBackColor(0, RGB(0, 0, 30))

ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor

Repeat
  While WindowEvent():Wend
     
  If ExamineMouse()
    
    InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
    
    If MousePick(0, MouseX(), MouseY()) >= 0
      LightLookAt(0, PickX(), PickY(), PickZ())
    EndIf
    
  EndIf
  
   If ExamineKeyboard()
    Input$ = KeyboardInkey()
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
