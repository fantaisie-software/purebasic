;
; ------------------------------------------------------------
;
;   PureBasic - Third Person
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#PlayerSpeed = 60*2
#CameraSpeed = 10


Structure s_Key
  Up.i
  Down.i
  Left.i
  Right.i
  StrafeLeft.i
  StrafeRight.i
  Jump.i
EndStructure

Structure s_Entity
  Entity.i
  EntityBody.i
  BodyOffsetY.f
  elapsedTime.f
  Key.s_Key
  MainNode.i
  SightNode.i
  CameraNode.i
  ForwardNode.i
  StrafeNode.i
EndStructure

Structure s_Camera
  Camera.i
  Tightness.f
  CameraNode.i
  TargetNode.i
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
Declare OnGround(*Entity.s_Entity)
Declare MakeColimacon(PX.f, PY.f, PZ.f, Length.i, Height.i, Width.i, Stair.i)
Declare MakeStair(PX.f, PY.f, PZ.f, Length.i, Height.i, Width.i, Stair.i)
Declare AddObjects()

Global Robot.s_Entity
Global Camera.s_Camera
Global.f TimeSinceLastFrame = 0

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "test - [PageUp][PageDown] Sun height  [F12] Wireframe  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI"             , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

;WorldShadows(#PB_Shadow_Modulative, 3000, RGB(150, 150, 150))

;Texture
CreateTexture(1, 256, 256)
StartDrawing(TextureOutput(1))
Box(0, 0, 256, 256, RGB(0, 34, 85))
DrawingMode(#PB_2DDrawing_Outlined)
Box(0, 0, 256, 256, RGB(255, 255, 255))
Box(10, 10, 236, 236, RGB(0, 255, 255))
StopDrawing()

;Material
CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
CreateMaterial(1, TextureID(1))
MaterialFilteringMode(1, 2)

CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
CreateMaterial(3, LoadTexture(3, "Wood.jpg"))
GetScriptMaterial(4, "Scene/GroundBlend")

MaterialFilteringMode(1, #PB_Material_Anisotropic, 8)

;Robot
LoadMesh   (0, "robot.mesh")
CreateEntity (0, MeshID(0), #PB_Material_None);
StartEntityAnimation(0, "Walk")

;Robot Body
CreateEntity(1, MeshID(0), #PB_Material_None, 0, 26, 0)
HideEntity(1, 1)

;Ground
CreatePlane(2, 5000, 5000, 100, 100, 100, 100)
CreateEntity(2, MeshID(2), MaterialID(1), 0, 0, 0)

;Body
CreateEntityBody(1, #PB_Entity_CapsuleBody, 1, 0, 0)
CreateEntityBody(2, #PB_Entity_StaticBody)

;Add some statics and dynamics objects
CreateCube(3, 1)
AddObjects()

;Add some stairs
MakeColimacon(120, 0, 120, 130, 7, 48, 15)
MakeStair(360, 0, 220, 130, 11, 48, 15)

;-Light
CreateLight(0,RGB(155,155,155),700,500,0)
AmbientColor(RGB(85,85,85))

;- Fog
Fog(RGB(210, 210, 210), 1, 0, 10000)

; Skybox
SkyBox("desert07.jpg")

;
With Robot
  \Entity = 0
  \EntityBody = 1
  \BodyOffsetY = 43
  
  \Key\Down        = #PB_Key_Down
  \Key\Left        = #PB_Key_Left
  \Key\Right       = #PB_Key_Right
  \Key\Up          = #PB_Key_Up
  \Key\StrafeLeft  = #PB_Key_X
  \Key\StrafeRight = #PB_Key_C
  \Key\Jump        = #PB_Key_Space
  
  \MainNode    = CreateNode(#PB_Any) ; Entity position
  \SightNode   = CreateNode(#PB_Any,  120,  20,  0) ; For cameraLookAt
  \CameraNode  = CreateNode(#PB_Any, -140, 100,  0) ; Camera position
  \ForwardNode = CreateNode(#PB_Any,    1,   0,  0) ; Direction normalized
  \StrafeNode  = CreateNode(#PB_Any,    0,   0, -1) ; Direction normalized
  
  AttachNodeObject(\MainNode, NodeID(\SightNode))
  AttachNodeObject(\MainNode, NodeID(\CameraNode))
  AttachNodeObject(\MainNode, NodeID(\ForwardNode))
  AttachNodeObject(\MainNode, NodeID(\StrafeNode))
  AttachNodeObject(\MainNode, EntityID(\Entity))
EndWith

;-Camera
CreateCamera(0, 0, 0, 100, 100)
With Camera
  \Camera = 0
  \Tightness = 0.035
  ; Camera use 2 nodes
  \CameraNode = CreateNode(#PB_Any, -3000, 700, 0) ; Camera position
  \TargetNode = CreateNode(#PB_Any)                ; For cameraLookAt
  AttachNodeObject(\CameraNode, CameraID(\Camera))
EndWith

;-Main loop
;
Repeat
  While WindowEvent():Wend
  
  Robot\elapsedTime = TimeSinceLastFrame * 40
  
  HandleEntity(@Robot)
  
  CameraTrack(@Camera, @Robot)
  
  TimeSinceLastFrame = RenderWorld() / 1000
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1


Procedure OnGround(*Entity.s_Entity)
  With *Entity
    ProcedureReturn RayCollide(NodeX(\MainNode),  NodeY(\MainNode)+3, NodeZ(\MainNode), NodeX(\MainNode), NodeY(\MainNode),  NodeZ(\MainNode))
  EndWith
EndProcedure

Procedure IsStair(*Entity.s_Entity)
  Protected.f x, y, z
  With *Entity
    x = (NodeX(\ForwardNode) - NodeX(\MainNode))*30
    y = (NodeY(\ForwardNode) - NodeY(\MainNode))*30
    z = (NodeZ(\ForwardNode) - NodeZ(\MainNode))*30
    ;CreateLine3D(20, NodeX(\MainNode), NodeY(\MainNode)+20, NodeZ(\MainNode), $FFFF, NodeX(\MainNode)+x, NodeY(\MainNode)+y+20,  NodeZ(\MainNode)+z, $FFFF)
    Ray1 = RayCollide(NodeX(\MainNode), NodeY(\MainNode)+10, NodeZ(\MainNode),  NodeX(\MainNode)+x, NodeY(\MainNode)+y+10,  NodeZ(\MainNode)+z)
    Ray2 = RayCollide(NodeX(\MainNode), NodeY(\MainNode)+20, NodeZ(\MainNode),  NodeX(\MainNode)+x, NodeY(\MainNode)+y+20,  NodeZ(\MainNode)+z)
    If Ray1>-1 And Ray2=-1
      ProcedureReturn 1
    EndIf
    ProcedureReturn 0
  EndWith
EndProcedure

Procedure HandleEntity(*Entity.s_Entity)
  Protected.Vector3 Forward, Strafe, PosMain, PosDir, PosStrafe
  Protected.f Speed, Speed2, x, y, MouseX, MouseY
  Static Jump.f, MemJump.i, Rot.Vector3, Trans.Vector3, Clic
  
  With *Entity
    GetNodePosition(PosMain, \MainNode)
    GetNodePosition(PosDir, \ForwardNode)
    GetNodePosition(PosStrafe, \StrafeNode)
    SubVector3(Forward, PosDir, PosMain)
    SubVector3(Strafe, PosStrafe, PosMain)
    
    Speed = #PlayerSpeed * \elapsedTime
    Speed2 = Speed / 2
    
    If ExamineKeyboard()
      
      If KeyboardReleased(#PB_Key_F5)
        WorldDebug(#PB_World_DebugBody)
      ElseIf KeyboardReleased(#PB_Key_F6)
        WorldDebug(#PB_World_DebugEntity)
      ElseIf KeyboardReleased(#PB_Key_F7)
        WorldDebug(#PB_World_DebugNone)
      EndIf
      
      If KeyboardPushed(\Key\Jump) And OnGround(*Entity)>-1
        Jump = 4
        MemJump = 1
      EndIf
      
      Rot\x * 0.30
      Rot\y * 0.30
      Rot\z * 0.30
      Trans\x * 0.20
      Trans\y = Jump
      Trans\z * 0.20
      
      If KeyboardPushed(\Key\Up)
        Trans\x + Forward\x * Speed
        Trans\z + Forward\z * Speed
      ElseIf KeyboardPushed(\Key\Down)
        Trans\x + Forward\x * -Speed2
        Trans\z + Forward\z * -Speed2
      EndIf

      If KeyboardPushed(\Key\Left)
        Rot\y + 2 * \elapsedTime
      ElseIf KeyboardPushed(\Key\Right)
        Rot\y - 2 * \elapsedTime
      EndIf
      
      If KeyboardPushed(\Key\StrafeLeft)
        Trans\x + Strafe\x * Speed2
        Trans\z + Strafe\z * Speed2
      ElseIf KeyboardPushed(\Key\StrafeRight)
        Trans\x + Strafe\x * -Speed2
        Trans\z + Strafe\z * -Speed2
      EndIf
      
      If OnGround(*Entity) > -1
        Jump = 0
      ElseIf MemJump
        Jump + 20
        If Jump > 80
          MemJump = 0
        EndIf
      Else
        Jump - 9
      EndIf
      
      If IsStair(*Entity) And Jump = 0 And ( Abs(Trans\x)>=Speed / 2 Or Abs(Trans\z)>=Speed / 2)
        Jump = 22 ; Or more
      EndIf
      
    EndIf
    
    MoveEntity  (\EntityBody, Trans\x, Trans\y, Trans\z,#PB_Relative|#PB_World)
    RotateEntity(\EntityBody, 0, Rot\y, 0, #PB_Relative)
    
    MoveNode(\MainNode, EntityX(\EntityBody), EntityY(\EntityBody)-\BodyOffsetY, EntityZ(\EntityBody), #PB_Absolute|#PB_World)
    RotateNode(\MainNode, 0, EntityYaw(\EntityBody), #PB_Absolute)
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


Procedure MakeColimacon(PX.f, PY.f, PZ.f, Length.i, Height.i, Width.i, Stair.i)
  Protected.f Angle
  Protected.i a, Ent
  
  For a = 1 To Stair
    Ent = CreateEntity(#PB_Any, MeshID(3), MaterialID(2))
    ScaleEntity(Ent, Length, Height, Width)
    MoveEntity(Ent, PX + Cos(Radian(Angle)) * Width * 5, PY + (a-1) * Height * 4, PZ -Sin(Radian(Angle)) * Width * 5, #PB_Absolute)
    RotateEntity(Ent, 0, Angle, 0)
    CreateEntityBody(Ent, #PB_Entity_StaticBody)
    Angle = Mod(Angle + 30, 360)
  Next
EndProcedure

Procedure MakeStair(PX.f, PY.f, PZ.f, Length.i, Height.i, Width.i, Stair.i)
  Protected.i a, Ent, Nb
  Protected.f Size, SizeD, Delta, H
  
  For a = 1 To Stair
    Ent = CreateEntity(#PB_Any, MeshID(3), MaterialID(2))
    ScaleEntity(Ent, Length, Height, Width)
    MoveEntity(Ent, PX, PY + (a-1) * Height, PZ + (a-1) * Width * 0.8, #PB_Absolute)
    CreateEntityBody(Ent, #PB_Entity_StaticBody)
  Next a
  
  ;Add a plateform
  Ent = CreateEntity(#PB_Any, MeshID(3), MaterialID(2))
  ScaleEntity(Ent, Length*5, Height, Width*5)
  MoveEntity(Ent, PX, PY + (a-1) * Height, PZ + (a-1) * Width, #PB_Absolute)
  CreateEntityBody(Ent, #PB_Entity_StaticBody)
  
  ;Add Pyramid
  Nb = 7
  Delta = 0.01
  Size = 20
  SizeD = Size + 0.5
  H = EntityY(Ent) + Height/2 + Delta
  For j = 0 To Nb
    For i= 0 To Nb-j
      Ent = CreateEntity(#PB_Any, MeshID(3), MaterialID(4))
      ScaleEntity(Ent, Size, Size, Size)
      CreateEntityBody(Ent, #PB_Entity_BoxBody, 0.5)
      MoveEntity(Ent, 340 +  j * (SizeD / 2) + i * SizeD, H + (SizeD / 2) + (j * SizeD), 890, #PB_Absolute)
    Next
  Next
EndProcedure

Procedure AddObjects()
  Protected Size.Vector3
  Protected.f x, z
  Protected.i Ent, i
  
  For i = 0 To 100
    If Random(1)
      Size\x = Random(60) + 30
      Size\y = Random(60) + 30
      Size\z = Random(60) + 30
      Volume.f = Size\x * Size\y * Size\z
      Ent=CreateEntity(#PB_Any, MeshID(3), MaterialID(3), Random(5000)-2600, 100, Random(5000)-2500)
      RotateEntity(Ent, 0, Random(360), 0)
      ScaleEntity(ent, Size\x, Size\y, Size\z)
      CreateEntityBody(Ent, #PB_Entity_BoxBody, (Volume / 7000), 0, 2)
    Else
      Size\x = Random( 60) + 30
      Size\y = Random(160) + 30
      Size\z = Random( 60) + 30
      
      Repeat
        x = Random(5000)-2500
      Until x < -400 Or x > 400
      
      Repeat
        z = Random(5000)-2500
      Until z < -400 Or z > 400
      
      Ent=CreateEntity(#PB_Any, MeshID(3), MaterialID(2), x, Size\y / 2 + Random(90) , z)
      RotateEntity(Ent, 0, Random(360), 0)
      ScaleEntity(Ent, Size\x, Size\y, Size\z)
      CreateEntityBody(Ent, #PB_Entity_StaticBody)
    EndIf
    
  Next
EndProcedure
