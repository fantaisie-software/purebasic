
; ------------------------------------------------------------
;
;   PureBasic - CopyMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CopyMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

CreateMaterial(0, LoadTexture(0, "clouds.jpg"))

CreateSphere(0, 40, 50, 50)
CreateEntity(0,MeshID(0), MaterialID(0), -60,   0,  0)

; Copy the Material
CopyMaterial(0, 1)

; Create a cube with the new material
CreateCube(1, 40)
CreateEntity(1, MeshID(1), MaterialID(1), 60, 0, 0)

; Camera
CreateCamera(0, 0, 0, 100, 100)
CameraBackColor(0, $333333)
MoveCamera(0,0,100,300, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

; Light
CreateLight(0, $FFFFFF, 1560, 900, 500)
AmbientColor($330000)

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

