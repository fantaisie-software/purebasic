
; ------------------------------------------------------------
;
;   PureBasic - Entity
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Entity - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)

LoadMesh(0, "robot.mesh")

CreateMaterial(0, LoadTexture(0, "clouds.jpg"))
CopyMaterial(0, 1)
CreateMaterial(2, LoadTexture(2, "r2skin.jpg"))
MaterialShadingMode(0, #PB_Material_Wireframe)

CreateEntity(0, MeshID(0), MaterialID(0))
CreateEntity(1, MeshID(0), MaterialID(1), -60, 0, 0)
CreateEntity(2, MeshID(0), MaterialID(2),  60, 0, 0)

StartEntityAnimation(0, "Walk")

EntityRenderMode(0, #PB_Entity_DisplaySkeleton)

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
  
  RotateEntity(1, 0, 1, 0, #PB_Relative)
  RotateEntity(2, 0, 1, 0, #PB_Relative)
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

