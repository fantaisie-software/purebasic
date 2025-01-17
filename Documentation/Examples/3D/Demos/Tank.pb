;
; ------------------------------------------------------------
;
;   PureBasic - Tank
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#PlayerSpeed = 0.4
#CameraSpeed = 1

Structure s_Key
  Up.i
  Down.i
  Left.i
  Right.i
EndStructure

Structure s_Entity
  elapsedTime.f
  Key.s_Key
  MainNode.i
  TourelleNode.i
  CanonNode.i
  ShootNode.i
  ForwardNode.i
  SightNode.i
  CameraNode.i
  SightNode1.i
  CameraNode1.i
EndStructure

Structure s_Camera
  Camera.i
  Tightness.f
  CameraNode.i
  TargetNode.i
EndStructure

Structure Bullet
  Bullet.i
  numRibbon.i
  timer.f
  Direction.Vector3
  Speed.f
  Life.l
EndStructure


Macro GetNodePosition(Position, Node)
  Position\x = NodeX(Node)
  Position\y = NodeY(Node)
  Position\z = NodeZ(Node)
EndMacro

Macro SubVector3(V, V1, V2)
  V\x = V1\x - V2\x
  V\y = V1\y - V2\y
  V\z = V1\z - V2\z
EndMacro

;-Declare
Declare HandleEntity(*Entity.s_Entity)
Declare CameraTrack(*Camera.s_Camera, *Entity.s_Entity)
Declare CreatePyramide(Nb.i)
Declare Shootbullet()

;-Variables
Define Tank.s_Entity
Define Camera.s_Camera
Global NewList Bullets.Bullet()

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Tank - [Arrows]  [Mouse+clic] [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, 500)

;Texture
CreateTexture(0,128, 128)
StartDrawing(TextureOutput(0))
Box(0, 0, 128, 128, RGB(255, 255, 255))
StopDrawing()
; Ribbon texture
CreateTexture(1,128, 1)
StartDrawing(TextureOutput(1))
DrawingMode(#PB_2DDrawing_Gradient)
BackColor(0)
GradientColor(0.5, RGB(255, 255, 255))
FrontColor(0)
LinearGradient(0, 0, 128, 0)
Box(0, 0, 128, 1)
StopDrawing()

;-Material
;Tank
CreateMaterial(0, LoadTexture(3, "RustySteel.jpg"))

;Bullet
CreateMaterial(1, TextureID(0))
SetMaterialColor(1, #PB_Material_AmbientColor, RGB(255, 0, 0))
;Sol
GetScriptMaterial(5, "Scene/GroundBlend")
;Pyramide
CreateMaterial(6, LoadTexture(6, "Caisse.png"))

;Ribbon
GetScriptMaterial(7, "Examples/LightRibbonTrail")

;Ground
CreatePlane(0, 100, 100, 10, 10, 10, 10)
CreateEntity(0, MeshID(0), MaterialID(5), 0, 0, 0)
EntityRenderMode(0, 0) ; Disable shadow casting for this entity as it's our plan
CreateEntityBody(0, #PB_Entity_StaticBody)

; Mesh
CreateCube(1, 1)
CreateSphere(2, 1.5)
CreateCylinder(3, 0.5, 8)

;-Corps
CreateEntity(1, MeshID(1), MaterialID(0))
ScaleEntity(1, 4, 2, 8)
MoveEntity(1, 0, 1, 0)

;-Tourelle
CreateEntity(2, MeshID(2), MaterialID(0))
EntityRenderMode(2, 0)

;-Canon
CreateEntity(3, MeshID(3), MaterialID(0))
RotateEntity(3, 90, 0, 0)
MoveEntity(3, 0, 0.0, -4)

;-Create Pyramide
CreatePyramide(8)

;-Light
CreateLight(0,RGB(125, 125, 125), 100, 500, 250)
AmbientColor(RGB(95, 95, 95))

;-Fog
Fog(RGB(128, 128, 128), 1, 0, 10000)

;-Skybox
SkyBox("desert07.jpg")

;-Camera
CreateCamera(0, 0, 0, 100, 100)
CameraFOV(0, 40)
With Camera
  \Camera = 0
  \Tightness = 0.035
  ; Camera use 2 nodes
  \CameraNode = CreateNode(#PB_Any, 0, 700, 300) ; Camera position
  \TargetNode = CreateNode(#PB_Any)              ; For cameraLookAt
  AttachNodeObject(\CameraNode, CameraID(\Camera))
EndWith

CreateCamera(1, 0.1, 67, 33, 33)
CameraFOV(1, 25)

With Tank
  \Key\Down  = #PB_Key_Down
  \Key\Left  = #PB_Key_Left
  \Key\Right = #PB_Key_Right
  \Key\Up    = #PB_Key_Up
  
  \MainNode    = CreateNode(#PB_Any) ; Entity position
  \TourelleNode= CreateNode(#PB_Any,  0, 2.0,   0)
  \CanonNode   = CreateNode(#PB_Any,  0, 0.8,   0)
  \ShootNode   = CreateNode(#PB_Any,  0, 0.0,  -8)
  \SightNode   = CreateNode(#PB_Any,  0, 2.0, -12) ; For cameraLookAt
  \CameraNode  = CreateNode(#PB_Any,  0, 6.0,  15) ; Camera position
  \ForwardNode = CreateNode(#PB_Any,  0, 0.0,  -1) ; Direction normalized
  
  \SightNode1  = CreateNode(#PB_Any,  0, 1.0,   0) ; For cameraLookAt
  \CameraNode1 = CreateNode(#PB_Any,  0, 1.0,   0) ; Camera1 position
  
  AttachNodeObject(\MainNode, NodeID(\SightNode))
  AttachNodeObject(\MainNode, NodeID(\TourelleNode))
  AttachNodeObject(\MainNode, NodeID(\CameraNode))
  AttachNodeObject(\MainNode, NodeID(\ForwardNode))
  
  AttachNodeObject(\TourelleNode, NodeID(\CanonNode))
  AttachNodeObject(\CanonNode   , NodeID(\ShootNode))
  
  AttachNodeObject(\CanonNode   , NodeID(\CameraNode1))
  AttachNodeObject(\ShootNode   , NodeID(\SightNode1))
  
  AttachNodeObject(\Mainnode    , EntityID(1))
  AttachNodeObject(\TourelleNode, EntityID(2))
  AttachNodeObject(\CanonNode   , EntityID(3))
  AttachNodeObject(\CameraNode1 , CameraID(1))
  
EndWith

;-Main loop
;
Repeat
  While WindowEvent():Wend      
  ;If Engine3DStatus(#PB_Engine3D_CurrentFPS)
    Tank\elapsedTime = 40/60;Engine3DStatus(#PB_Engine3D_CurrentFPS)
  ;EndIf
  
  HandleEntity(@Tank)
  
  ShootBullet()
  
  CameraTrack(@Camera, @Tank)
  CameraLookAt(1, NodeX(Tank\SightNode1), NodeY(Tank\SightNode1), NodeZ(Tank\SightNode1))
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1


Procedure CreatePyramide(Nb)
  Define Ent, i, j
  Define Size.f, SizeD.f
  
  Size=1.5
  SizeD = Size + 0.01
  
  For j = 0 To Nb
    For i= 0 To Nb-j
      Ent = CreateEntity(#PB_Any, MeshID(1), MaterialID(6))
      CreateEntityBody(Ent, #PB_Entity_BoxBody, 0.1)
      ScaleEntity(Ent, Size, Size, Size)
      MoveEntity(Ent, j*(SizeD/2) + i * SizeD, (SizeD/2)+(j*SizeD), -20, #PB_Absolute)
    Next i
  Next j
EndProcedure
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

Procedure AddShoot(*Entity.s_Entity)
  Define Bullet, Color = RGB(255, 0, 0)
  Define.Vector3 PosCanon, PosShoot
  
  Bullet = CreateEntity(#PB_Any, MeshID(2), MaterialID(1))
  ScaleEntity(Bullet, 0.1, 0.1, 0.1)
  CreateEntityBody(Bullet, #PB_Entity_SphereBody, 0.7, 0.1, 0.1)
  MoveEntity(Bullet, NodeX(*Entity\ShootNode), NodeY(*Entity\ShootNode), NodeZ(*Entity\ShootNode), #PB_Absolute)
  AddElement(Bullets())
  
  With Bullets()
    \Bullet = Bullet
    \numRibbon = CreateRibbonEffect(#PB_Any, MaterialID(7), 1, 80, 120);
    RibbonEffectColor(\numRibbon, 0, RGBA(255, 50, 0, 255), RGBA(1, 5, 255, 5))
    RibbonEffectWidth(\numRibbon, 0, 0.3, 1)
    AttachRibbonEffect(\numRibbon, EntityParentNode(\Bullet))
    
    GetNodePosition(PosCanon, *Entity\CanonNode)
    GetNodePosition(PosShoot, *Entity\ShootNode)
    SubVector3(\Direction, PosShoot, PosCanon)
    Normalize(\Direction)
    \Speed = 20
    \Life = ElapsedMilliseconds()
    ApplyEntityImpulse(\Bullet, \Direction\x * \Speed, \Direction\y * \Speed, \Direction\z * \Speed)
  EndWith
  
EndProcedure


Procedure Shootbullet()
  ForEach Bullets()
    With Bullets()
      If ElapsedMilliseconds()-Bullets()\Life>10000
        If IsEntity(\Bullet)
          FreeEntity(\Bullet)
          FreeEffect(\numRibbon)
        EndIf
        DeleteElement(Bullets(), 1)
      EndIf
    EndWith
  Next
EndProcedure


Procedure HandleEntity(*Entity.s_Entity)
  Protected.Vector3 Forward, PosMain, PosDir
  Protected Speed.f, Speed2.f, x.f, y.f
  Protected MouseX.f, MouseY.f
  Static Rot.Vector3, Trans.Vector3, Clic, AngleCanon.f, Time, FirstShort=1
  
  With *Entity
    GetNodePosition(PosMain, \MainNode)
    GetNodePosition(PosDir, \ForwardNode)
    SubVector3(Forward, PosDir, PosMain)
    
    Speed = #PlayerSpeed * \elapsedTime
    Speed2 = Speed / 2
    
    If ExamineMouse()
      MouseX = -(MouseDeltaX()/5) * \elapsedTime
      MouseY = -(MouseDeltaY()/5) * \elapsedTime
      
      AngleCanon + MouseY
      If AngleCanon>45
        AngleCanon = 45
      ElseIf AngleCanon<-3
        AngleCanon = -3
      EndIf
      
      If MouseButton(#PB_MouseButton_Left) And (ElapsedMilliseconds()-Time > 500 Or FirstShort = 1)
        FirstShort = 0
        Time = ElapsedMilliseconds()
        AddShoot(*Entity)
      EndIf
      
    EndIf
    
    If ExamineKeyboard()
      
      If KeyboardReleased(#PB_Key_F5)
        WorldDebug(#PB_World_DebugBody)
      ElseIf KeyboardReleased(#PB_Key_F6)
        WorldDebug(#PB_World_DebugEntity)
      ElseIf KeyboardReleased(#PB_Key_F7)
        WorldDebug(#PB_World_DebugNone)
      EndIf
      
      Rot\x * 0.30
      Rot\y * 0.30
      Rot\z * 0.30
      Trans\x * 0.30
      Trans\y = 0
      Trans\z * 0.30
      
      If KeyboardPushed(\Key\Up)
        Trans\x + Forward\x * Speed
        Trans\z + Forward\z * Speed
      ElseIf KeyboardPushed(\Key\Down)
        Trans\x + Forward\x * -Speed2
        Trans\z + Forward\z * -Speed2
      EndIf
      
      If KeyboardPushed(\Key\Left)
        Rot\y + 1.5 * \elapsedTime
      ElseIf KeyboardPushed(\Key\Right)
        Rot\y - 1.5 * \elapsedTime
      EndIf
      
    EndIf
    
    MoveNode(\MainNode, Trans\x, Trans\y, Trans\z,#PB_Relative|#PB_World)
    RotateNode(\MainNode, 0, Rot\y, 0, #PB_Relative)
    RotateNode(\TourelleNode, 0, MouseX, 0, #PB_Relative)
    RotateNode(\CanonNode, AngleCanon, 0, 0, #PB_Absolute)
    
  EndWith
EndProcedure

Procedure CameraTrack(*Camera.s_Camera, *Entity.s_Entity)
  Protected.Vector3 CameraPosition, TargetPosition
  Protected.f x, y, z
  
  GetNodePosition(CameraPosition, *Entity\CameraNode)
  GetNodePosition(TargetPosition, *Entity\SightNode)
  x = NodeX(*Camera\CameraNode)
  y = NodeY(*Camera\CameraNode)
  z = NodeZ(*Camera\CameraNode)
  x = (CameraPosition\x - x) *  *Camera\Tightness
  y = (CameraPosition\y - y) *  *Camera\Tightness
  z = (CameraPosition\z - z) *  *Camera\Tightness
  MoveNode(*Camera\CameraNode, x, y, z,#PB_Relative)
  
  x = NodeX(*Camera\TargetNode)
  y = NodeY(*Camera\TargetNode)
  z = NodeZ(*Camera\TargetNode)
  x = (TargetPosition\x - x) *  *Camera\Tightness
  y = (TargetPosition\y - y) *  *Camera\Tightness
  z = (TargetPosition\z - z) *  *Camera\Tightness
  MoveNode(*Camera\TargetNode, x, y, z,#PB_Relative)
  
  CameraLookAt(*Camera\Camera, NodeX(*Camera\TargetNode), NodeY(*Camera\TargetNode), NodeZ(*Camera\TargetNode))
  
EndProcedure
; IDE Options = PureBasic 6.12 LTS (Windows - x86)
; CursorPosition = 81
; FirstLine = 66
; Folding = ---
; EnableXP
; DPIAware