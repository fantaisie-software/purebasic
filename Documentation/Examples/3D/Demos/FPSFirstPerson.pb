;
; ------------------------------------------------------------
;
;   PureBasic - FPS First Person
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
; WaterWorld files come from the software Deled 
; http://www.delgine.com, Thanks For this great editor 3D.


Global ScreenWidth, ScreenHeight

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#PlayerSpeed = 80
#CameraSpeed = 10

Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Structure s_Key
  Up.i
  Down.i
  Left.i
  Right.i
  Jump.i
EndStructure

Structure s_Entity
  EntityBody.i
  BodyOffsetY.f 
  elapsedTime.f
  Fov.f
  Key.s_Key
  MainNode.i  
  CameraNode.i  
  HandNode.i
  ForwardNode.i
  StrafeNode.i
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
Declare OnGround(*Entity.s_Entity)

Define Robot.s_Entity
Dim Barrel.Vector3(2)
Barrel(0)\x =  0 : Barrel(0)\y =  0 : Barrel(0)\z = 0  
Barrel(1)\x = 60 : Barrel(1)\y =  0 : Barrel(1)\z = 0 
Barrel(2)\x = 30 : Barrel(2)\y = 70 : Barrel(2)\z = 0 

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()

    ;- AddArchive
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"            , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"              , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"             , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Water"               , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/waterworld.zip", #PB_3DArchive_Zip)
    Parse3DScripts()
    
    ;- Material
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
    CreateMaterial(1, LoadTexture(1,"viseur-jeux.png"))
    MaterialBlendingMode(1, #PB_Material_AlphaBlend)
    GetScriptMaterial(3, "Color/Red")
    CreateMaterial(4, LoadTexture(4, "RustyBarrel.png"))
    
    ;- Bullet
    CreateSphere(3,10)
    
    ;- Robot Body
    LoadMesh   (0, "robot.mesh")
    CreateEntity(0, MeshID(0), #PB_Material_None, -400, 300, -100)
    HideEntity(0, 1)
    
    ;- Gun
    LoadMesh(1, "AKM.mesh")
    CreateEntity(1, MeshID(1), MaterialID(0))
    ScaleEntity(1, 0.001, 0.001, 0.001)
    RotateEntity(1, 90, -85, 0)
   
    ;- Ground
    LoadMesh(2, "waterworld.mesh")
    CreateEntity(2, MeshID(2), #PB_Material_None)
    
        
    ;- Barrel 
    LoadMesh(4, "Barrel.mesh")
    Restore Barrel
    For i = 1 To 3
      Read.f x.f
      Read.f y.f
      Read.f z.f
      For j=0 To 2
        Barrel = CreateEntity(#PB_Any, MeshID(4), MaterialID(4), x+Barrel(j)\x, y+Barrel(j)\y, z+Barrel(j)\z)
        ScaleEntity(Barrel, 8, 10, 8)
        CreateEntityBody(Barrel, #PB_Entity_CylinderBody, 50, 0, 0.5) 
      Next
     Next 
       
     ;Body
    CreateEntityBody(0, #PB_Entity_CapsuleBody, 0.45, 0, 0) 
    CreateEntityBody(2, #PB_Entity_StaticBody)
    
    ;-Billboard
    CreateBillboardGroup(0, MaterialID(1), 1, 1)
    AddBillboard(0, 0, 0, 0)
    
    With Robot
      \Fov = 50
      \EntityBody = 0
      \BodyOffsetY = 43 
      \Key\Down  = #PB_Key_Down ;Down
      \Key\Left  = #PB_Key_Left ;Left
      \Key\Right = #PB_Key_Right;Right
      \Key\Up    = #PB_Key_Up   ;Up
      \Key\Jump  = #PB_Key_Space
    
      \MainNode   = CreateNode(#PB_Any) ; Entity position
      \CameraNode = CreateNode(#PB_Any,  0, 80,  0) ; Camera position
      \HandNode   = CreateNode(#PB_Any,  0, 80,  0) ; Hand position
      \ForwardNode= CreateNode(#PB_Any,  0,  0, -1) ; Direction normalized 
      \StrafeNode = CreateNode(#PB_Any, -1,  0,  0) ; Direction normalized
      
      AttachNodeObject(\MainNode  , NodeID(\CameraNode))   
      AttachNodeObject(\MainNode  , NodeID(\HandNode))   
      AttachNodeObject(\MainNode  , NodeID(\ForwardNode))
      AttachNodeObject(\MainNode  , NodeID(\StrafeNode))
      AttachNodeObject(\HandNode  , EntityID(1))
      AttachNodeObject(\CameraNode, BillboardGroupID(0))
      
      RotateNode(\HandNode, 5, 0, 0, #PB_Relative)
      MoveBillboardGroup(0, 0, 0, -15)
      MoveEntity(1, 0.1, -0.1, 0.01)
    EndWith
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100)
    CameraRange(0, 0.08, 5000) 
    AttachNodeObject(Robot\CameraNode, CameraID(0))
    CameraLookAt(0, NodeX(Robot\ForwardNode) * 100, NodeY(Robot\CameraNode), NodeZ(Robot\ForwardNode) * 100) 
    
    ;- Skybox
    SkyBox("desert07.jpg")
    
    ;- Light
    CreateLight(0, RGB(255, 255, 255), 200, 100, 200, #PB_Light_Point)
    
    ;- Fog
    Fog(RGB(127, 127, 127), 128, 10, 2000)
    
    ;- Water
    CreateWater(0, 0, -230, 0, 0, #PB_World_WaterLowQuality | #PB_World_WaterCaustics | #PB_World_WaterSmooth)
 
    ;- *** Main loop ***
    Repeat
      Screen3DEvents()
      
      If Engine3DStatus(#PB_Engine3D_CurrentFPS)
        Robot\elapsedTime = 40/Engine3DStatus(#PB_Engine3D_CurrentFPS)
      EndIf  
      
      HandleEntity(@Robot)
      
      RenderWorld(60)
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End

Procedure OnGround(*Entity.s_Entity)
  ProcedureReturn RayCollide(NodeX(*Entity\MainNode),  NodeY(*Entity\MainNode)+1, NodeZ(*Entity\MainNode), NodeX(*Entity\MainNode), NodeY(*Entity\MainNode)-3,  NodeZ(*Entity\MainNode)) 
EndProcedure

Procedure HandleEntity(*Entity.s_Entity)
  Protected.Vector3 Forward, Strafe, PosMain, PosDir, PosStrafe 
  Protected.f Speed, Speed2, SpeedShoot, x, y
  Protected.f MouseX, MouseY
  Static Jump.f, MemJump.i, Rot.Vector3, Trans.Vector3, Clic
  
  
  With *Entity
    GetNodePosition(PosMain, \MainNode)
    GetNodePosition(PosDir, \ForwardNode)
    GetNodePosition(PosStrafe, \StrafeNode)
    SubVector3(Forward, PosDir, PosMain)
    SubVector3(Strafe, PosStrafe, PosMain)
    
    Speed = #PlayerSpeed * \elapsedTime
    Speed2 = Speed * 0.5
    SpeedShoot = Speed * 10
    
     
    If  ExamineMouse()
      
      MouseX = -(MouseDeltaX()/200) * \Fov * \elapsedTime
      MouseY = -(MouseDeltaY()/200) * \Fov * \elapsedTime
      Rot\z = 0
      Rot\y + MouseX
      If NodePitch(\CameraNode) < 80 And MouseY > 0
        Rot\x + MouseY
      ElseIf NodePitch(\CameraNode) > -80 And MouseY < 0 
        Rot\x + MouseY
      EndIf  
     
      If MouseButton(#PB_MouseButton_Left) 
        If Clic = 0
          x = ScreenWidth / 2
          y = ScreenHeight / 2 
          If PointPick(0, x, y)
            Clic = 1
            Shoot = CreateEntity(#PB_Any, MeshID(3), MaterialID(3), BillboardGroupX(0), BillboardGroupY(0), BillboardGroupZ(0))
            CreateEntityBody(Shoot, #PB_Entity_SphereBody, 1)
            ApplyEntityImpulse(Shoot, PickX() * SpeedShoot, PickY() * SpeedShoot, PickZ() * SpeedShoot)
          EndIf
        EndIf
      Else
        Clic = 0
      EndIf
         
      If MouseButton(#PB_MouseButton_Right)
        If \Fov > 20
          \Fov - 2 * \elapsedTime
        EndIf  
      Else
        If \Fov < 50
          \Fov + 2 * \elapsedTime
        EndIf  
      EndIf
      
    EndIf
    If ExamineKeyboard()
      
      If KeyboardPushed(\Key\Jump) And OnGround(*Entity)>-1
        Jump = 30
        MemJump = 1
      EndIf 
      
      Rot\x * 0.30
      Rot\y * 0.30
      Rot\z * 0.30
      Trans\x * 0.80
      Trans\y = Jump
      Trans\z * 0.80
      
      If KeyboardPushed(\Key\Up)
        Trans\x = Forward\x * Speed
        Trans\z = Forward\z * Speed
      ElseIf KeyboardPushed(\Key\Down)
        Trans\x = Forward\x * -Speed2
        Trans\z = Forward\z * -Speed2
      EndIf
      
      If KeyboardPushed(\Key\Left)
        Trans\x = Strafe\x * Speed
        Trans\z = Strafe\z * Speed
      ElseIf KeyboardPushed(\Key\Right)
        Trans\x = Strafe\x * -Speed
        Trans\z = Strafe\z * -Speed
      EndIf 
      
      MoveEntity(\EntityBody, Trans\x, Trans\y, Trans\z)
      
      If OnGround(*Entity)>-1
        Jump = 0
      ElseIf MemJump  
        Jump + 30
        If Jump > 60 
          MemJump = 0
        EndIf  
      Else  
        Jump - 4 * \elapsedTime
      EndIf  
    EndIf
          
    
    CameraFOV(0, \Fov)  
       
    RotateEntity(\EntityBody,     0, Rot\y, 0, #PB_Relative)
    RotateNode(\CameraNode  , Rot\x,     0, 0, #PB_Relative)
    RotateNode(\HandNode    , Rot\x,     0, 0, #PB_Relative)
    
    MoveNode(\MainNode, EntityX(\EntityBody), EntityY(\EntityBody) - \BodyOffsetY, EntityZ(\EntityBody), #PB_Absolute) 
    RotateNode(\MainNode, 0, EntityYaw(\EntityBody), 0) 
    
  EndWith   
EndProcedure

DataSection
  Barrel:
  Data.f -885, 300, 158
  Data.f -800, 60, -1580
  Data.f -710, 60, -1270
EndDataSection  