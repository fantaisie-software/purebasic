
; ------------------------------------------------------------
;
;   PureBasic - MaterialFog
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " MaterialFog - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data"                , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)

CreateCube(0,100)
CreateMaterial(0, LoadTexture(0, "MRAMOR6X6.jpg"))
MaterialCullingMode(0,#PB_Material_AntiClockWiseCull)
CreateEntity(0, MeshID(0), MaterialID(0))

CreateCube(1,10)
CreateMaterial(1, LoadTexture(0, "Caisse.png"))
MaterialFog(1, RGBA(255, 255,0,0), 1, 0, 100)
For i=1 To 16
  CreateEntity(i, MeshID(1), MaterialID(1))
Next

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 20, -50, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

;- Light
;
AmbientColor(RGB(75, 75, 75))
CreateLight(0, RGB(255, 255, 255), 0, 500, 0)

Repeat
  While WindowEvent():Wend
  
  a.f+0.5
  For i=1 To 16
    ai.f=Radian(a+360*i/16)
    MoveEntity(i,Cos(ai)*30,0,Sin(ai)*30,#PB_Absolute)
  Next
  
  ExamineKeyboard()
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)

