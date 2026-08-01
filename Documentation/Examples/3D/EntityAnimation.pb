
; ------------------------------------------------------------
;
;   PureBasic - EntityAnimation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;Speed animation = PageUp and PageDown



Define.f KeyX, KeyY, MouseX, MouseY, Speed = 0.3

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " EntityAnimation -  [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, -1, RGB(175, 175, 175))

;Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)

;Mesh
;
LoadMesh(1, "robot.mesh")

; Entity
;
CreateEntity(1, MeshID(1), #PB_Material_None)

; Animation
;
StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual)

; SkyBox
;
SkyBox("desert07.jpg")

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 50, 100, 80, #PB_Absolute)
CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))

CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
AmbientColor(RGB(80, 80, 80))
KeyboardMode(#PB_Keyboard_International)

Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  MouseX = -MouseDeltaX()/10
  MouseY = -MouseDeltaY()/10
  
  ExamineKeyboard()    
  KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*1
  Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*1    
  
  Speed+ (Bool(KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0)-Bool(KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1))*0.01
  
  AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame * Speed)
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  TimeSinceLastFrame = RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
