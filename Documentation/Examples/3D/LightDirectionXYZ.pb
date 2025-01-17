
; ------------------------------------------------------------
;
;   PureBasic - LightDirectionX/Y/Z
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Define.f x, y, z, Distance = 1500

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " LightDirectionX/Y/Z - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Parse3DScripts()

KeyboardMode(#PB_Keyboard_International)

; Ground
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1000, 1000, 50, 50, 1, 1)
CreateEntity (0, MeshID(0), MaterialID(0))

; Light
CreateLight(0, RGB(255, 255, 255), 0, 400, 0, #PB_Light_Spot)
SpotLightRange(0, 1, 30, 3)
AmbientColor(0)

; spot
CreateSphere(1, 20, 50, 50)
GetScriptMaterial(1, "Color/Yellow")
SetMaterialColor(1, #PB_Material_SelfIlluminationColor, RGB(185, 155, 65))
CreateEntity(1, MeshID(1), MaterialID(1), LightX(0), LightY(0), LightZ(0))


; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 900, 1000, #PB_Absolute)
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
  
  ExamineKeyboard()
  
  x = LightX(0) + LightDirectionX(0) * Distance
  y = LightY(0) + LightDirectionY(0) * Distance
  z = LightZ(0) + LightDirectionZ(0) * Distance
  CreateLine3D(10, LightX(0), LightY(0), LightZ(0),  RGB(0, 255, 0), x, y, z, RGB(0, 255, 0))
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
