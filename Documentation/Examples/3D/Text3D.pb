
; ------------------------------------------------------------
;
;   PureBasic - Text3D
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Text3D - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/fonts", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateCube(0, 2)

CreateMaterial(0, LoadTexture(0, "Caisse.png"))

CreateEntity(0, MeshID(0), MaterialID(0))

CreateText3D(0, "Hello world")
Text3DColor(0, RGBA(255, 0, 0, 255))
Text3DAlignment(0, #PB_Text3D_HorizontallyCentered)
AttachEntityObject(0, "", Text3DID(0))
MoveText3D(0, 0, 2, 2)

RotateEntity(0, 0, -70, 0)

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 0, 10, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  RotateEntity(0, 1, 1, 1, #PB_Relative)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

