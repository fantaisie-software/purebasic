
; ------------------------------------------------------------
;
;   PureBasic - CreateRenderTexture
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CreateRenderTexture -  [F5] Save RTT [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Compositors", #PB_3DArchive_FileSystem)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, 3000, RGB(175, 175, 175))

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
StartEntityAnimation(1, "Walk")

; Camera
;
CreateCamera(1, 0, 0, 100, 100)
MoveCamera(1, -100, 120, 190, #PB_Absolute)

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 90, 60, 0, #PB_Absolute)
CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
CameraFOV(0, 80)

;Miroir
CreateRenderTexture(1, CameraID(0), 800, 600)
CreateCompositorEffect(0,0,"Embossed")
CreateMaterial(1, TextureID(1))
CreateMesh(5)
MeshVertex(-80, 0,  60,1,0,$ffffff,0,-1,0)
MeshVertex( 80, 0,  60,0,0,$ffffff,0,-1,0)
MeshVertex( 80, 0, -60,0,1,$ffffff,0,-1,0)
MeshVertex(-80, 0, -60,1,1,$ffffff,0,-1,0)
MeshFace(0, 1, 2, 3)
MeshFace(3, 2, 1, 0)
FinishMesh(1)
CreateEntity(5, MeshID(5), MaterialID(1), 100, 40, 0)
RotateEntity(5, -90, -90, 0)


CameraLookAt(1, EntityX(5), EntityY(5), EntityZ(5))

CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
AmbientColor(RGB(80, 80, 80))

; Skybox
;
SkyBox("desert07.jpg")


Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX()/10
    MouseY = -MouseDeltaY()/10
  EndIf
  
  
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_F5)
      No + 1
      SaveRenderTexture(1, "test" + Str(No) + ".png")
    EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*2
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*2    
    
  EndIf
  
  RotateEntity(1, 0, 1, 0, #PB_Relative)
  
  RotateCamera(1, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (1, KeyX, 0, KeyY)
  
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

