
; ------------------------------------------------------------
;
;   PureBasic - EntityBoneX/Y/Z
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Use keys Q,S,D,Z (Robot shoot)

Structure Bullet
  Bullet.i
  timer.f
  Speed.f
  Life.l
EndStructure

Define.f KeyX, KeyY, MouseX, MouseY, Speed = 0.1
Define.i RobotMove,Time
Global NewList Bullets.Bullet()

#CameraSpeed = 2

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

;-Declare
Declare Normalize(*V.Vector3)
Declare AddShoot()
Declare Shootbullet()

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " EntityBoneX/Y/Z -  [D]   [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

KeyboardMode(#PB_Keyboard_International)

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
CreateSphere(2, 1)

; Entity
;
CreateEntity(1, MeshID(1), #PB_Material_None)

; SkyBox
;
SkyBox("desert07.jpg")

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 50, 100, 180, #PB_Absolute)
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
    
    
    If KeyboardPushed(#PB_Key_Q)
      RotateEntity(1, 0, 180, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_D)
      RotateEntity(1, 0, 0, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Z)
      RotateEntity(1, 0, 90, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_S)
      RotateEntity(1, 0, -90, 0)
      RobotMove = #True
    EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
  
    If KeyboardPushed(#PB_Key_PageUp) And Speed < 1.0
      Speed + 0.05
    ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1
      Speed - 0.05
    EndIf
    
  EndIf
  
  If RobotMove
    If EntityAnimationStatus(1, "Shoot") = #PB_EntityAnimation_Stopped ; Loop
      StartEntityAnimation(1, "Shoot", #PB_EntityAnimation_Manual)     ; Start the animation from the beginning
    EndIf
  Else
    StopEntityAnimation(1, "Shoot")
    SetEntityAnimationTime(1, "Shoot", 0)
  EndIf
  
  AddEntityAnimationTime(1, "Shoot", TimeSinceLastFrame)
  
  ;Add Shoot
  If GetEntityAnimationTime(1, "Shoot") > 280 And GetEntityAnimationTime(1, "Shoot") < 310 And ElapsedMilliseconds()-Time>500
    Time = ElapsedMilliseconds()
    AddShoot()
  EndIf
  
  Shootbullet()
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  TimeSinceLastFrame = RenderWorld() * Speed
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1


Procedure Normalize(*V.Vector3)
  Define.f magSq, oneOverMag
  
  magSq = *V\x * *V\x + *V\y * *V\y + *V\z * *V\z
  If magsq > 0
    oneOverMag = 1.0 / Sqr(magSq)
    *V\x * oneOverMag
    *V\y * oneOverMag
    *V\z * oneOverMag
  EndIf
  
EndProcedure


Procedure AddShoot()
  Protected.i Bullet
  Protected.Vector3 Bone1, Bone2, Direction
  Protected.f Angle
  
  GetBonePosition(Bone1, 1, "Joint17", 0, 0, 0)
  GetBonePosition(Bone2, 1, "Joint18", 0, 0, -5)
  SubVector3(Direction, Bone2, Bone1)
  Normalize(@Direction)
  
  For i=0 To 315 Step 45
    AddElement(Bullets())
    
    With Bullets()
      \Speed = 180
      \Life = ElapsedMilliseconds()
      ;\Bullet = CreateEntity(#PB_Any, MeshID(2), MaterialID(1), Bone2\x-2, Bone2\y+0.5, Bone2\z)
      If Int(EntityYaw(1))=90 Or Int(EntityYaw(1))=-90
        \Bullet = CreateEntity(#PB_Any, MeshID(2), MaterialID(1), 2.4*Cos(Radian(Angle))+Bone2\x+1.2, 2.4*Sin(Radian(Angle))+Bone2\y+0.7, Bone2\z)
      Else
        \Bullet = CreateEntity(#PB_Any, MeshID(2), MaterialID(1), Bone2\x, 2.4*Sin(Radian(Angle))+Bone2\y+0.7, 2.4*Cos(Radian(Angle))+Bone2\z+1.2)
      EndIf
      Angle + 45
      CreateEntityBody(\Bullet, #PB_Entity_SphereBody, 1)
      ApplyEntityImpulse(\Bullet, Direction\x * \Speed, Direction\y * \Speed, Direction\z * \Speed)
    EndWith
  Next
EndProcedure

Procedure Shootbullet()
  ForEach Bullets()
    With Bullets()
      
      If ElapsedMilliseconds()-Bullets()\Life>3000
        If IsEntity(\Bullet)
          FreeEntity(\Bullet)
        EndIf
        DeleteElement(Bullets(), 1)
      EndIf
    EndWith
  Next
EndProcedure