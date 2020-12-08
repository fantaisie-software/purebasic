;
; ------------------------------------------------------------
;
;   PureBasic - CameraTrack
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Code adapted from this tutorial 
; http://www.ogre3d.org/tikiwiki/3rd+person+camera+system+tutorial

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#PlayerSpeed = 2

Enumeration
  #MainWindow 
  #StMode
  #StFPS
  #Editor
EndEnumeration

Enumeration 
  #ThirdPersonChase  
  #ThirdPersonFixed
  #FirstPerson
EndEnumeration

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
EndStructure

Structure s_Entity
  Entity.i
  elapsedTime.f
  Key.s_Key
  SightNode.i
  CameraNode.i  
  DirectionNode.i
  Offset.Vector3 ; if needed for FirstPerson
EndStructure

Structure s_Camera
  Camera.i
  Mode.i
  Tightness.f
  CameraNode.i 
  TargetNode.i
EndStructure    

Macro GetNodePosition(Position, Node)
  Position\x = NodeX(Node)  
  Position\y = NodeY(Node)  
  Position\z = NodeZ(Node)  
EndMacro

Macro GetEntityPosition(Position, Node)
  Position\x = EntityX(Node)  
  Position\y = EntityY(Node)  
  Position\z = EntityZ(Node)  
EndMacro

Macro SetVector3(V, xx, yy, zz)
  V\x = xx
  V\y = yy
  V\z = zz
EndMacro

Macro AddVector3(V, V1, V2)
  V\x = V1\x + V2\x
  V\y = V1\y + V2\y
  V\z = V1\z + V2\z
EndMacro

Macro SubVector3(V, V1, V2)
  V\x = V1\x - V2\x
  V\y = V1\y - V2\y
  V\z = V1\z - V2\z
EndMacro

;-Declare
Declare HandleEntity(*Entity.s_Entity)
Declare CameraMode(*Camera.s_Camera, *Entity.s_Entity)
Declare CameraTrack(*Camera.s_Camera, *Entity.s_Entity)
Declare CameraInstantUpdate(*Camera.s_Camera, *CameraPosition.Vector3, *TargetPosition.Vector3)
Declare CameraUpdate(*Camera.s_Camera, *CameraPosition.Vector3, *TargetPosition.Vector3)

Define.f RatioX, RatioY
Define Robot.s_Entity
Define Camera.s_Camera

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI"             , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
    
    WorldShadows(#PB_Shadow_Modulative)
    
    ;Change the texture filtering mode for all materials
    MaterialFilteringMode(#PB_Default, #PB_Material_Anisotropic, 8)
    
    CreateTexture(1, 256, 256)
    StartDrawing(TextureOutput(1))
    Box(0, 0, 256, 256, RGB(0, 34, 85))
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0, 0, 256, 256, RGB(255, 255, 255))
    Box(10, 10, 236, 236, RGB(0, 255, 255))
    StopDrawing()
    
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
    CreateMaterial(1, TextureID(1))
    
    ;robot
    LoadMesh   (0, "robot.mesh")
    CreateEntity (0, MeshID(0), MaterialID(0));
    StartEntityAnimation(0, "Walk")
    
    ;Sol
    CreatePlane(1, 5000, 5000, 100, 100, 100,100)
    CreateEntity(1, MeshID(1), MaterialID(1))
    
    
    With Robot
      \Entity = 0
      \Key\Down  = #PB_Key_Down
      \Key\Left  = #PB_Key_Left
      \Key\Right = #PB_Key_Right
      \Key\Up    = #PB_Key_Up
      \Offset\x = 0
      \Offset\y = 50 ; Offset could be needed for FirstPerson
      \Offset\z = 0  
      ; Entity use 3 nodes    
      \SightNode=CreateNode(#PB_Any, 120, 20, 0) ; For cameraLookAt 
      \CameraNode=CreateNode(#PB_Any, -140, 100, 0) ; Camera position
      \DirectionNode=CreateNode(#PB_Any, 1, 0, 0) ; Direction normalized 
      
      AttachEntityObject(\Entity, "", NodeID(\SightNode))
      AttachEntityObject(\Entity, "", NodeID(\CameraNode))   
      AttachEntityObject(\Entity, "", NodeID(\DirectionNode))     
    EndWith
    
    ;-Camera
    CreateCamera(0, 0, 0, 100, 100)
    With Camera  
      \Camera = 0
      \Mode = #ThirdPersonChase
      \Tightness = 0.01
      ; Camera use 2 nodes
      \CameraNode = CreateNode(#PB_Any, -3000, 700, 0) ; Camera position
      \TargetNode = CreateNode(#PB_Any) ; For cameraLookAt 
      AttachNodeObject(\CameraNode, CameraID(\Camera))
    EndWith  
    
    ;-Light
    CreateLight(0,RGB(125,125,125),700,500,0)
    AmbientColor(RGB(85,85,85))
    
    SkyBox("desert07.jpg")
    
    ;-GUI
    RatioX = CameraViewWidth(0) / 800
    RatioY = CameraViewHeight(0) / 600
    OpenWindow3D(#MainWindow, 0, 0, 280 * RatioX, 170 * RatioY, "Camera Track")
    StringGadget3D(#StFPS , 10 * RatioX, 10 * RatioY, 240 * RatioX, 30 * RatioY, "FPS")
    StringGadget3D(#StMode, 10 * RatioX, 45 * RatioY, 240 * RatioX, 30 * RatioY, "ThirdPersonChase")
    EditorGadget3D(#Editor, 10 * RatioX, 85 * RatioY, 240 * RatioX, 30 * RatioY, #PB_Editor3D_ReadOnly)
    SetGadgetText3D(#Editor, "Use F2, F3 or F4 to change Mode")

    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    Repeat
      Screen3DEvents()
      
      If Engine3DStatus(#PB_Engine3D_CurrentFPS)
        Robot\elapsedTime = 40/Engine3DStatus(#PB_Engine3D_CurrentFPS)
      EndIf  
      
      If ExamineMouse()
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left), "", 0)
      EndIf
      
      If ExamineKeyboard()
        CameraMode(@Camera, @robot)     
        HandleEntity(@Robot)
      EndIf
      
      
      Repeat
        Event3D = WindowEvent3D()
      Until Event3D = 0
      
      CameraTrack(@Camera, @Robot)
      
      SetGadgetText3D(#StFPS, "FPS = " + Str(Engine3DStatus(#PB_Engine3D_CurrentFPS)))
      
      RenderWorld()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End

Procedure HandleEntity(*Entity.s_Entity)
  Protected Direction.Vector3, PosMain.Vector3, PosDir.Vector3
  Protected Speed.f, Speed2.f
  With *Entity
    GetEntityPosition(PosMain, \Entity)
    GetNodePosition(PosDir, \DirectionNode)
    SubVector3(Direction, PosDir, PosMain)
    Speed = #PlayerSpeed * \elapsedTime
    Speed2 = -Speed / 2
    If KeyboardPushed(\Key\Up)
      MoveEntity(\Entity, Direction\x * Speed, Direction\y * Speed, Direction\z * Speed)
    ElseIf KeyboardPushed(\Key\Down)
      MoveEntity(\Entity, Direction\x * Speed2, Direction\y * Speed2, Direction\z * Speed2)
    EndIf
    
    If KeyboardPushed(\Key\Left)
      RotateEntity(\Entity, 0,#PlayerSpeed/2 * \elapsedTime, 0, #PB_Relative)
    ElseIf KeyboardPushed(\Key\Right)
      RotateEntity(\Entity, 0, -#PlayerSpeed/2 * \elapsedTime, 0, #PB_Relative)
    EndIf 
  EndWith   
EndProcedure

Procedure CameraMode(*Camera.s_Camera, *Entity.s_Entity)
  Protected CameraPosition.Vector3, TargetPosition.Vector3, Temp.Vector3
  
  If KeyboardReleased(#PB_Key_F2)
    *Camera\Mode = #ThirdPersonChase
    HideEntity(*Entity\Entity, #False)
    GetNodePosition(CameraPosition, *Entity\CameraNode)
    GetNodePosition(TargetPosition, *Entity\SightNode)
    CameraInstantUpdate(*Camera, @CameraPosition, @TargetPosition)
    *Camera\Tightness = 0.01
    SetGadgetText3D(#StMode, "ThirdPersonChase")
    
  ElseIf KeyboardReleased(#PB_Key_F3)
    *Camera\Mode = #ThirdPersonFixed
    HideEntity(*Entity\Entity, #False)
    SetVector3(CameraPosition, 0, 200, 0)
    GetNodePosition(TargetPosition, *Entity\SightNode)
    CameraInstantUpdate(*Camera, @CameraPosition, @TargetPosition)
    *Camera\Tightness = 0.01
    SetGadgetText3D(#StMode, "ThirdPersonFixed")
    
  ElseIf KeyboardReleased(#PB_Key_F4)  
    *Camera\Mode = #FirstPerson
    HideEntity(*Entity\Entity, #True)
    GetEntityPosition(Temp, *Entity\Entity)
    AddVector3(CameraPosition, Temp, *Entity\Offset)
    GetNodePosition(TargetPosition, *Entity\SightNode)
    CameraInstantUpdate(*Camera, @CameraPosition, @TargetPosition)
    *Camera\Tightness = 1   
    SetGadgetText3D(#StMode, "FirstPerson")
    
  EndIf 
EndProcedure

Procedure CameraTrack(*Camera.s_Camera, *Entity.s_Entity)
  Protected CameraPosition.Vector3, TargetPosition.Vector3, Temp.Vector3
  
  Select *Camera\Mode
    Case #ThirdPersonChase
      GetNodePosition(CameraPosition, *Entity\CameraNode)
      GetNodePosition(TargetPosition, *Entity\SightNode)
      CameraUpDate(*Camera, @CameraPosition, @TargetPosition)
      
    Case #ThirdPersonFixed
      SetVector3(CameraPosition, 0, 200, 0)
      GetNodePosition(TargetPosition, *Entity\SightNode)
      CameraUpDate(*Camera, @CameraPosition, @TargetPosition)
      
    Case #FirstPerson
      GetEntityPosition(Temp, *Entity\Entity)
      AddVector3(CameraPosition, Temp, *Entity\Offset)
      GetNodePosition(TargetPosition, *Entity\SightNode)
      CameraUpDate(*Camera, @CameraPosition, @TargetPosition)
      
  EndSelect
EndProcedure

Procedure CameraInstantUpdate(*Camera.s_Camera, *CameraPosition.Vector3, *TargetPosition.Vector3)
  Protected V1.Vector3, V2.Vector3
  
  MoveNode(*Camera\CameraNode, *CameraPosition\x, *CameraPosition\y, *CameraPosition\z, #PB_Absolute)
  
  MoveNode(*Camera\TargetNode, *TargetPosition\x, *TargetPosition\y, *TargetPosition\z, #PB_Absolute)
  
  CameraLookAt(*Camera\Camera, NodeX(*Camera\TargetNode), NodeY(*Camera\TargetNode), NodeZ(*Camera\TargetNode)) 
EndProcedure

Procedure CameraUpdate(*Camera.s_Camera, *CameraPosition.Vector3, *TargetPosition.Vector3)
  Protected V1.Vector3, V2.Vector3
  
  V1\x = (*CameraPosition\x - NodeX(*Camera\CameraNode)) *  *Camera\Tightness
  V1\y = (*CameraPosition\y - NodeY(*Camera\CameraNode)) *  *Camera\Tightness
  v1\z = (*CameraPosition\z - NodeZ(*Camera\CameraNode)) *  *Camera\Tightness
  MoveNode(*Camera\CameraNode, V1\x, V1\y, V1\z)
  
  V2\x = (*TargetPosition\x - NodeX(*Camera\TargetNode)) *  *Camera\Tightness
  V2\y = (*TargetPosition\y - NodeY(*Camera\TargetNode)) *  *Camera\Tightness
  V2\z = (*TargetPosition\z - NodeZ(*Camera\TargetNode)) *  *Camera\Tightness
  MoveNode(*Camera\TargetNode, V2\x, V2\y, V2\z)
  
  CameraLookAt(*Camera\Camera, NodeX(*Camera\TargetNode), NodeY(*Camera\TargetNode), NodeZ(*Camera\TargetNode)) 
EndProcedure