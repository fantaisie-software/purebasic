
; ------------------------------------------------------------
;
;   PureBasic - GetScriptMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1


Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " GetScriptMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

Red = GetScriptMaterial(#PB_Any, "Color/Red")
Blue = GetScriptMaterial(#PB_Any, "Color/Blue")
Yellow = GetScriptMaterial(#PB_Any, "Color/Yellow")
Green = GetScriptMaterial(#PB_Any, "Color/Green")

CreateSphere(0, 40, 50, 50)
CreateEntity(0,MeshID(0), MaterialID(Red)   , -60,   0,  0)
CreateEntity(1,MeshID(0), MaterialID(Blue)  ,  60,   0,  0)
CreateEntity(2,MeshID(0), MaterialID(Yellow),   0,  60,  0)
CreateEntity(3,MeshID(0), MaterialID(Green) ,   0, -60,  0)

; Camera
CreateCamera(0, 0, 0, 100, 100)
CameraBackColor(0, RGB(50, 50, 50))
MoveCamera(0,0, 100, 300, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

; Light
CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
AmbientColor(RGB(50,50,50))

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

