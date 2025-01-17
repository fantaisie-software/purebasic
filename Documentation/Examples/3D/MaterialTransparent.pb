
; ------------------------------------------------------------
;
;   PureBasic - Material Transparent
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1



Define.f KeyX, KeyY, MouseX, MouseY, RollZ, Blend, Pas = 1

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Material Transparent - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateCube(0, 50)
CreateSphere(1, 5)

CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
MaterialBlendingMode(0, #PB_Material_AlphaBlend)

CreateEntity(0, MeshID(0), MaterialID(0))

SkyBox("stevecube.jpg")

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 90, 80, 150, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  Blend + pas
  If blend >= 255 Or Blend <= 0
    pas = -pas
  EndIf
  
  SetMaterialColor(0, #PB_Material_DiffuseColor, RGBA(255, 255, 255, Blend))
  
  RotateEntity(0, 0, 0.4, 0, #PB_Relative)
  MoveEntity(0, 0, 0, -1, #PB_Local)
  
  CameraLookAt(0, EntityX(0), EntityY(0), EntityZ(0))
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
