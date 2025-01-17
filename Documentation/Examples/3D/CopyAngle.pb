
; ------------------------------------------------------------
;
;   PureBasic - CopyAngle
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY, RollZ

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CopyAngle - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)

LoadMesh(0, "robot.mesh")

CreateMaterial(1, LoadTexture(1, "clouds.jpg"))
CreateMaterial(2, LoadTexture(2, "r2skin.jpg"))

CreateEntity(1, MeshID(0), MaterialID(1), -30, 0, 0)
CreateEntity(2, MeshID(0), MaterialID(2),  30, 0, 0)

SkyBox("stevecube.jpg")

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 40, 150, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
  EndIf
  
  RotateEntity(1, 0.7, 1, 0.5, #PB_Relative)
  RotateEntity(2, EntityPitch(1,#PB_Engine3D_Adjusted), EntityYaw(1,#PB_Engine3D_Adjusted), EntityRoll(1,#PB_Engine3D_Adjusted))
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
