
; ------------------------------------------------------------
;
;   PureBasic - Terrain : Physic
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#TerrainMiniX = 0
#TerrainMiniY = 0
#TerrainMaxiX = 0
#TerrainMaxiY = 0
#PlayerSpeed = 60
#CameraSpeed = 10

Define.f KeyX, KeyY, MouseX, MouseY, TimeSinceLastFrame
Declare InitBlendMaps()

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


Define Robot.s_Entity
Define Camera.s_Camera

InitEngine3D()
  
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Terrain : Physic -  [X]   [Space]   [F5]   [F6]   [F7]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/"       , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia" , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main",#PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Terrain",#PB_3DArchive_FileSystem)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, #PB_Default, RGB(120, 120, 120))

MaterialFilteringMode(#PB_Default, #PB_Material_Anisotropic, 8)

;- Light
;
light = CreateLight(#PB_Any ,RGB(185, 185, 185), 4000, 1200, 1000, #PB_Light_Directional)
SetLightColor(light, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4))
LightDirection(light ,0.55, -0.3, -0.75)
AmbientColor(RGB(5, 5,5))

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
CameraBackColor(0, RGB(5, 5, 10))

;----------------------------------
;-terrain definition
SetupTerrains(LightID(Light), 3000, #PB_Terrain_NormalMapping)
;-initialize terrain
CreateTerrain(0, 513, 12000, 600, 3, "TerrainPhysic", "dat")
;-set all texture will be use when terrrain will be constructed
AddTerrainTexture(0,  0, 100, "dirt_grayrocky_diffusespecular.jpg",  "dirt_grayrocky_normalheight.jpg")
AddTerrainTexture(0,  1,  30, "grass_green-01_diffusespecular.jpg", "grass_green-01_normalheight.jpg")
AddTerrainTexture(0,  2, 200, "growth_weirdfungus-03_diffusespecular.jpg", "growth_weirdfungus-03_normalheight.jpg")

;-Construct terrains
For ty = #TerrainMiniY To #TerrainMaxiY
  For tx = #TerrainMiniX To #TerrainMaxiX
    Imported = DefineTerrainTile(0, tx, ty, "terrain513.png", ty % 2, tx % 2)
  Next
Next
BuildTerrain(0)

If Imported = #True
  InitBlendMaps()
  UpdateTerrain(0)
  
  ; If enabled, it will save the terrain as a (big) cache for a faster load next time the program is executed
  ; SaveTerrain(0, #False)
EndIf

; enable shadow terrain
TerrainRenderMode(0, 0)

;Add Physic Body
CreateTerrainBody(0, 0.1, 1)

;Texture
CreateTexture(1, 256, 256)
StartDrawing(TextureOutput(1))
Box(0, 0, 256, 256, $002255)
DrawingMode(#PB_2DDrawing_Outlined)
Box(0, 0, 256, 256, $FFFFFF)
Box(10, 10, 236, 236, $FFFF)
StopDrawing()

;Material
CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
CreateMaterial(1, TextureID(1))
CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
CreateMaterial(3, LoadTexture(3, "Wood.jpg"))
GetScriptMaterial(4, "Scene/GroundBlend")

;Robot
LoadMesh   (0, "robot.mesh")
CreateEntity (0, MeshID(0), #PB_Material_None);
StartEntityAnimation(0, "Walk")

;Robot Body
CreateEntity(1, MeshID(0), #PB_Material_None, 0, 426, 0)
HideEntity(1, 1)

;Body
CreateEntityBody(1, #PB_Entity_CapsuleBody, 1, 0, 0)

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
With Camera
  \Camera = 0
  \Tightness = 0.035
  ; Camera use 2 nodes
  \CameraNode = CreateNode(#PB_Any, -3000, 700, 0) ; Camera position
  \TargetNode = CreateNode(#PB_Any) ; For cameraLookAt
  AttachNodeObject(\CameraNode, CameraID(\Camera))
EndWith

;==================================
; create material
Red = GetScriptMaterial(#PB_Any, "Color/Red")
Blue = GetScriptMaterial(#PB_Any, "Color/Blue")
Yellow = GetScriptMaterial(#PB_Any, "Color/Yellow")
Green = GetScriptMaterial(#PB_Any, "Color/Green")

;==================================
; create Sphere
MeshSphere = CreateSphere(#PB_Any, 10.0)
For i = 0 To 5
  Entity=CreateEntity(#PB_Any, MeshID(MeshSphere), MaterialID(Green))
  MoveEntity(Entity, Random(2000)-1000, 800, Random(4000)-2000, #PB_Absolute)
  ; create bodies
  CreateEntityBody(Entity, #PB_Entity_SphereBody, 5.0)
Next

;==================================
; create Cylinder
MeshCylinder = CreateCylinder(#PB_Any, 10.0, 60)
For i = 0 To 5
  Entity=CreateEntity(#PB_Any, MeshID(MeshCylinder), MaterialID(Red))
  MoveEntity(Entity, Random(2000)-1000, 800, Random(4000)-2000, #PB_Absolute)
  ; create bodies
  CreateEntityBody(Entity, #PB_Entity_CylinderBody, 10.0, 0, 1)
Next

;==================================
; create Cube
MeshCube = CreateCube(#PB_Any, 25.0)
For i = 0 To 5
  Entity=CreateEntity(#PB_Any, MeshID(MeshCube), MaterialID(Yellow))
  MoveEntity(Entity, Random(2000)-1000, 800, Random(4000)-2000, #PB_Absolute)
  ; create bodies
  CreateEntityBody(Entity, #PB_Entity_BoxBody, 5.0)
Next

Repeat
  
  While WindowEvent():Wend
  
  Robot\elapsedTime = TimeSinceLastFrame
  
  HandleEntity(@Robot)
  
  CameraTrack(@Camera, @Robot)
  
  TimeSinceLastFrame = RenderWorld(60) * 40 / 1000
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)

End

Procedure Clamp(*var.float, min.f, max.f)
  If *var\f < min
    *var\f = min
  ElseIf *var\f > max
    *var\f = max
  EndIf
EndProcedure

Procedure InitBlendMaps()
  minHeight1.f = 70
  fadeDist1.f = 40
  minHeight2.f = 70
  fadeDist2.f = 15
  For ty = #TerrainMiniY To #TerrainMaxiY
    For tx = #TerrainMiniX To #TerrainMaxiX
      Size = TerrainTileLayerMapSize(0, tx, ty)
      For y = 0 To Size-1
        For x = 0 To Size-1
          Height.f = TerrainTileHeightAtPosition(0, tx, ty, 1, x, y)
          
          val.f = (Height - minHeight1) / fadeDist1
          Clamp(@val, 0, 1)
          SetTerrainTileLayerBlend(0, tx, ty, 1, x, y, val)
          
          val.f = (Height - minHeight2) / fadeDist2
          Clamp(@val, 0, 1)
          SetTerrainTileLayerBlend(0, tx, ty, 2, x, y, val)
        Next
      Next
      UpdateTerrainTileLayerBlend(0, tx, ty, 1)
      UpdateTerrainTileLayerBlend(0, tx, ty, 2)
    Next
  Next
EndProcedure

Procedure OnGround(*Entity.s_Entity)
  With *Entity
    Result = RayCollide(EntityX(\EntityBody), EntityY(\EntityBody), EntityZ(\EntityBody), EntityX(\EntityBody), EntityY(\EntityBody)-70,  EntityZ(\EntityBody))
    ;CreateLine3D(20,EntityX(\EntityBody), EntityY(\EntityBody), EntityZ(\EntityBody), $FFFF, EntityX(\EntityBody), EntityY(\EntityBody)-70,  EntityZ(\EntityBody), $FFFF)
    Delta.f = EntityY(\EntityBody) - PickY() - \BodyOffsetY

    If Result=-1 Or (Result>-1 And (delta >= 1))
      ProcedureReturn 0
    Else
      ProcedureReturn 1
    EndIf
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
      
      If KeyboardPushed(\Key\Jump) And OnGround(*Entity)
        Jump = 18
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
      
      If OnGround(*Entity)
        Jump = 0
      ElseIf MemJump
        Jump + 20 * \elapsedTime
        If Jump > 100
          MemJump = 0
        EndIf
      Else
        Jump - 9
      EndIf
      
    EndIf
    
    MoveEntity  (\EntityBody, Trans\x, Trans\y, Trans\z, #PB_Relative)
    RotateEntity(\EntityBody, 0, Rot\y, 0, #PB_Relative)
    
    MoveNode(\MainNode, EntityX(\EntityBody), EntityY(\EntityBody)-\BodyOffsetY, EntityZ(\EntityBody), #PB_Absolute)
    RotateNode(\MainNode, 0, EntityYaw(\EntityBody), 0)
    
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
  MoveNode(*Camera\CameraNode, x, y, z)
  
  x = NodeX(*Camera\TargetNode)
  y = NodeY(*Camera\TargetNode)
  z = NodeZ(*Camera\TargetNode)
  x = (TargetPosition\x - x) *  *Camera\Tightness
  y = (TargetPosition\y - y) *  *Camera\Tightness
  z = (TargetPosition\z - z) *  *Camera\Tightness
  MoveNode(*Camera\TargetNode, x, y, z)
  
  CameraLookAt(*Camera\Camera, NodeX(*Camera\TargetNode), NodeY(*Camera\TargetNode), NodeZ(*Camera\TargetNode))
  
EndProcedure
