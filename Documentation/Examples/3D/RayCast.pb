;
; ------------------------------------------------------------
;
;   PureBasic - RayCast
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 0.4
#N = 2

Enumeration
  #MainWindow 
  #Editor
EndEnumeration

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY, SpeedRotate

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
    
    WorldDebug(#PB_World_DebugEntity)
    
    ;-Materials
    ;
    GetScriptMaterial(0, "Color/Blue")
    GetScriptMaterial(1, "Color/Green")
    GetScriptMaterial(2, "Color/Red")
    GetScriptMaterial(3, "Color/Yellow")
    CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))
    
    ;-Meshes
    ;
    CreateCube(0, 2)
    CreateSphere(1, 1)
    CreateCylinder(2, 1, 4)
    CreatePlane(3, 20, 20, 1, 1, 1, 1)
    LoadMesh(10, "robot.mesh")
    LoadMesh(11, "ninja.mesh")
    
    ;-Entities
    ;
    CreateEntity(0, MeshID(0), MaterialID(0), 14,  1,  0)
    CreateEntity(1, MeshID(1), MaterialID(1), -4,  1,  0)
    CreateEntity(2, MeshID(2), MaterialID(2),  0,  2, -4)
    CreateEntity(3, MeshID(0), MaterialID(3), 10,  1, 13)
    CreateEntity(5, MeshID(1), MaterialID(2), 0, 0, 0, 0)
    
    ScaleEntity(3, 8, 1, 1)
    RotateEntity(3, 0, 34, 0)
    ScaleEntity(5, 0.5, 0.5, 0.5)
    
    
    ;-Robot
    CreateEntity(10, MeshID(10), #PB_Material_None, -1, -1.5, 5)
    ScaleEntity(10, 0.05, 0.05, 0.05)
    StartEntityAnimation(10, "Walk")
    
    ;-Ninja
    CreateEntity(11, MeshID(11), #PB_Material_None, 6, -1.5, 12)
    ScaleEntity(11, 0.02, 0.02, 0.02)
    RotateEntity(11,0, 70, 0)
    StartEntityAnimation(11, "Walk")
    
    ;-Nodes
    ;
    CreateNode(0, 3, 0, 0)
    AttachNodeObject(0, EntityID(5))
    
    CreateNode(1, 0, 0, 1) 
    AttachNodeObject(0, NodeID(1))
    MoveNode(0, 0, 1, 0)
    
    ;-Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    CameraBackColor(0, RGB(40, 30, 60))
    MoveCamera(0, -1, 8, 15, #PB_Absolute)
    CameraLookAt(0, -1, 0, 0)
    
    ;-Light
    ;
    CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
    AmbientColor(RGB(50, 50, 50))
    
    ;-GUI
    ;
    RatioX = CameraViewWidth(0) / 1920
    RatioY = CameraViewHeight(0) / 1080
    OpenWindow3D(#MainWindow, 0, 0, 360 * RatioX, 110 * RatioY, "RayCast")
    StringGadget3D(#Editor, 10 * RatioX, 20 * RatioY, 300 * RatioX, 40 * RatioY, "", #PB_String3D_ReadOnly)
    
    
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
        
        If KeyboardPushed(#PB_Key_Space)
          Stop = 0
        Else
          Stop = 1
        EndIf          
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
      
      Entity = RayCast(NodeX(0), NodeY(0), NodeZ(0), NodeX(1)-NodeX(0), 0, NodeZ(1)-NodeZ(0), -1)
      CreateLine3D(10, NodeX(0), NodeY(0), NodeZ(0), RGB(255, 255, 255), NodeX(1), NodeY(1), NodeZ(1), RGB(255, 255, 255))
      
      If Entity>=0 
        CreateLine3D(10, NodeX(0), NodeY(0), NodeZ(0), RGB(0, 255, 255), PickX(), PickY(), PickZ(), RGB(0, 255, 255))
        CreateLine3D(11, PickX(), PickY(), PickZ(), RGB(255,0,0), PickX() + NormalX()*#N, PickY() + NormalY()*#N, PickZ() + NormalZ()*#N, RGB(255,0,0))
        SetGadgetText3D(#Editor, "Entity = " + Str(Entity))
        SpeedRotate = 0.1 
      Else   
        SetGadgetText3D(#Editor, "I'm looking...")
        SpeedRotate = 0.5
      EndIf  
      
      RotateNode(0, 0, SpeedRotate * Stop, 0, #PB_Relative)
      
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
