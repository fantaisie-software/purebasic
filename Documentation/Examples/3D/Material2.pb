
; ------------------------------------------------------------
;
;   PureBasic - Material
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Material - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Parse3DScripts()

LoadTexture(0, "grass2.png")
LoadTexture(1, "Wood.jpg")
LoadTexture(2, "Dirt.jpg")
LoadTexture(3, "spheremap.png")

CreateMaterial(0, TextureID(0)):ScaleMaterial(0,0.25,0.25) : MaterialCullingMode(0,#PB_Material_NoCulling)
CreateMaterial(1, TextureID(0)):ScaleMaterial(1,0.5,0.5) : MaterialCullingMode(1,#PB_Material_NoCulling)
CreateMaterial(2, TextureID(1)):AddMaterialLayer(2,TextureID(3),#PB_Material_Add)
CreateMaterial(3, TextureID(2)):ScaleMaterial(3,0.1,0.1):AddMaterialLayer(3,TextureID(3),#PB_Material_Add)

SetMaterialAttribute(0,#PB_Material_AlphaReject,-160,0)
SetMaterialAttribute(1,#PB_Material_AlphaReject,128,0)
SetMaterialAttribute(2,#PB_Material_EnvironmentMap,#PB_Material_ReflectionMap,1)
SetMaterialAttribute(3,#PB_Material_EnvironmentMap,#PB_Material_CurvedMap,1)

CreateSphere(0, 0.75,32,32)
CreateCube(1, 1)
CreateTorus(3,0.5,0.2,32,32)

CreateEntity(0, MeshID(0), MaterialID(0),-1.5,0,0)
CreateEntity(1, MeshID(1), MaterialID(1),1.5,0,0)
CreateEntity(2, MeshID(1), MaterialID(2),0,0,-1.5)
CreateEntity(3, MeshID(3), MaterialID(3),0,0,1.5)

CreateLight(0, RGB(255,255,255), 50, 50, 50)

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 4, 4)
CameraLookAt(0, 0, 0, 0)
CameraBackColor(0, RGB(20,20,20))

Repeat
  While WindowEvent():Wend
  ExamineKeyboard()
  
  RotateEntity(0,0.1,0.3,0.2,#PB_Relative)
  RotateEntity(1,0.1,0.3,0.2,#PB_Relative)
  RotateEntity(2,0.1,0.3,0.2,#PB_Relative)
  RotateEntity(3,0.1,0.3,0.2,#PB_Relative)
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
