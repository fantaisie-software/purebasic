;
; ------------------------------------------------------------
;
;   PureBasic - RayPick
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 0.4

Enumeration
  #MainWindow 
  #Editor
EndEnumeration

Define.f KeyX, KeyY, MouseX, MouseY, SpeedRotate
Define MaskSphere = 0 ; RayPick() ignore this entity

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    KeyboardMode(#PB_Keyboard_International)  
    
    ;WorldDebug(#PB_World_DebugEntity)
    
    ; First create materials
    ;
    GetScriptMaterial(0, "Color/Blue")
    GetScriptMaterial(1, "Color/Green")
    GetScriptMaterial(2, "Color/Red")
    GetScriptMaterial(3, "Color/Yellow")
    CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))
    CreateMaterial(10, LoadTexture(10, "r2skin.jpg"))
    
    ;- Meshes
    CreateCube(0, 2)
    CreateSphere(1, 1)
    CreateCylinder(2, 1, 4)
    CreatePlane(3, 20, 20, 1, 1, 1, 1)
    LoadMesh(10, "robot.mesh")
    
    ;- Entities
    CreateEntity(0, MeshID(0), MaterialID(0),  4, 1,  0)
    CreateEntity(1, MeshID(1), MaterialID(1), -4, 1,  0)
    CreateEntity(2, MeshID(2), MaterialID(2),  0, 2, -4)
    CreateEntity(3, MeshID(0), MaterialID(3),  0, 1, -7)
    CreateEntity(4, MeshID(3), MaterialID(4))
    CreateEntity(5, MeshID(1), MaterialID(2), 0, 0, 0, MaskSphere)

    ScaleEntity(3, 8, 1, 1)
    ScaleEntity(5, 0.5, 0.5, 0.5)
        
    ;- Robot
    CreateEntity(10, MeshID(10), MaterialID(10), -1, 0, 5)
    ScaleEntity(10, 0.05, 0.05, 0.05)
    StartEntityAnimation(10, "Walk")
    
    ;- Nodes
    CreateNode(0)
    AttachNodeObject(0, EntityID(5))
    
    CreateNode(1, 0, 0, 1) 
    AttachNodeObject(0, NodeID(1))
    MoveNode(0, 0, 1, 0)
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, -1, 8, 15, #PB_Absolute)
    CameraLookAt(0, -1, 0, 0)
    
    ;- Light
    CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
    AmbientColor(0)
    
    ;- GUI
    RatioX.f = CameraViewWidth(0) / 1920
    RatioY.f = CameraViewHeight(0) / 1080
    OpenWindow3D(#MainWindow, 10, 10, 380 * RatioX, 120 * RatioY, "RayPick")
    StringGadget3D(#Editor, 20 * RatioX, 20 * RatioY, 300 * RatioX, 50 * RatioY, "", #PB_String3D_ReadOnly)
        
    ShowGUI(155, 0)
    
    Repeat
      Screen3DEvents()
      
      Repeat
        Event3D = WindowEvent3D()
      Until Event3D = 0
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.5
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.5
      EndIf  
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -#CameraSpeed 
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = #CameraSpeed 
        Else
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -#CameraSpeed 
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = #CameraSpeed 
        Else
          KeyY = 0
        EndIf
        
      EndIf
      
      Entity = RayPick(NodeX(0), NodeY(0), NodeZ(0), NodeX(1)-NodeX(0), 0, NodeZ(1)-NodeZ(0))
      CreateLine3D(10, NodeX(0), NodeY(0), NodeZ(0), RGB(255, 255, 255), NodeX(1), NodeY(1), NodeZ(1), RGB(255, 255, 255))
      
      If Entity>=0
        CreateLine3D(10, NodeX(0), NodeY(0), NodeZ(0), RGB(255, 0, 0), PickX(), PickY(), PickZ(), RGB(255, 0, 0))
        SetGadgetText3D(#Editor, "Entity = " + Str(Entity))
      Else   
        SetGadgetText3D(#Editor, "I'm looking...")
      EndIf  
      
      If entity = 10 
        SpeedRotate = 0.1
      Else
        SpeedRotate = 1
      EndIf  
      RotateNode(0, 0, SpeedRotate, 0, #PB_Relative)
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End