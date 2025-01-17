
; ------------------------------------------------------------
;
;   PureBasic - Billboard
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1



Define.f angle

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Billboard - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

AmbientColor($ffffff)

;- Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 700, 700, 70, 70, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)

; First create our material, with a little rotate effect
;
Material = CreateMaterial(#PB_Any, LoadTexture(0, "clouds.jpg"))
RotateMaterial(Material, 0.05, 1)

; Then create the billboard group and use the previous material
;
Billboard = CreateBillboardGroup(#PB_Any, MaterialID(Material), 10, 10)

AddBillboard(Billboard, -20, 20, 0)
AddBillboard(Billboard,   0, 20, 0)
AddBillboard(Billboard,  20, 20, 0)

Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)

Repeat
  While WindowEvent():Wend      
  ExamineKeyboard()
  
  angle+0.02
  MoveCamera  (Camera, Cos(angle)*50, 40, Sin(angle)*50,#PB_Absolute)
  CameraLookAt(camera,0,20,0)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

