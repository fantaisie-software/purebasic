
; ------------------------------------------------------------
;
;   PureBasic - EntityBoneX/Y/Z
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Define.f KeyX, KeyY, MouseX, MouseY, Speed = 1.0
Define.i RobotMove
Define.Vector3 Bone1, Bone2

Macro GetBonePosition(Position, Entity, Bone, x1, y1, z1)
  Position\x = EntityBoneX(Entity, Bone, x1, y1, z1)
  Position\y = EntityBoneY(Entity, Bone, x1, y1, z1)
  Position\z = EntityBoneZ(Entity, Bone, x1, y1, z1)
EndMacro

Macro SubVector3(V, V1, V2)
  V\x = V1\x - V2\x
  V\y = V1\y - V2\y
  V\z = V1\z - V2\z
EndMacro

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()
  
ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " EntityBoneX/Y/Z - Robot speed: [PageUp]/[PageDown] - Quit: [Esc]",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()
  
WorldShadows(#PB_Shadow_Modulative, 3000, RGB(175, 175, 175))

GetScriptMaterial(1, "Color/Red")
GetScriptMaterial(2, "Color/Green")

;Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)

;Mesh
;
LoadMesh(1, "robot.mesh")
CreateSphere(2, 10)

; Entity
;
CreateEntity(1, MeshID(1), #PB_Material_None)
CreateEntity(2, MeshID(2), MaterialID(1))
CreateEntity(3, MeshID(2), MaterialID(2))
  
; SkyBox
;
SkyBox("desert07.jpg")

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 120, 500, #PB_Absolute)
CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
    
CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
AmbientColor(RGB(80, 80, 80))

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX()/10
    MouseY = -MouseDeltaY()/10
  EndIf
  
  RobotMove = #False
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Left)
      MoveEntity(1, -1 * Speed, 0, 0)
      RotateEntity(1, 0, 180, 0)
      RobotMove = #True
    ElseIf KeyboardPushed(#PB_Key_Right)
      MoveEntity(1, 1 * Speed, 0, 0)
      RotateEntity(1, 0, 0, 0)
      RobotMove = #True
    ElseIf KeyboardPushed(#PB_Key_Up)
      MoveEntity(1, 0, 0, -1 * Speed)
      RotateEntity(1, 0, 90, 0)
      RobotMove = #True
    ElseIf KeyboardPushed(#PB_Key_Down)
      MoveEntity(1, 0, 0, 1 * Speed)
      RotateEntity(1, 0, -90, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0
      Speed + 0.05
    ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1
      Speed - 0.05
    EndIf
    
  EndIf
  
  If RobotMove
    If EntityAnimationStatus(1, "Walk") = #PB_EntityAnimation_Stopped ; Loop
      StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual) ; Start the animation from the beginning
    EndIf
  Else
    StopEntityAnimation(1, "Walk")
  EndIf
  
  AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame)
  
  GetBonePosition(Bone1, 1, "Joint18", 10, -8, -5)
  GetBonePosition(Bone2, 1, "Joint15", 10, -8, 0)
  MoveEntity(2, Bone1\x, Bone1\y, Bone1\z, #PB_Absolute)
  MoveEntity(3, Bone2\x, Bone2\y, Bone2\z, #PB_Absolute)
  
  RotateCamera(0, MouseY, MouseX, RollZ, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  TimeSinceLastFrame = RenderWorld() * Speed
 
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

