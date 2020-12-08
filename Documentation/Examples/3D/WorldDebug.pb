;
; ------------------------------------------------------------
;
;   PureBasic - WorldDebug
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.4
#Speed = 60

Enumeration
  #MainWindow 
  #Editor
EndEnumeration

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY
Define DebugBody 

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
    Parse3DScripts()
    
    ;- Materials
    GetScriptMaterial(0, "Color/Blue")
    GetScriptMaterial(1, "Color/Green")
    GetScriptMaterial(2, "Color/Red")
    GetScriptMaterial(3, "Color/Yellow")
    CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))
    
    ;- Meshes
    CreateCube(0, 2)
    CreateSphere(1, 1)
    LoadMesh(2, "PureBasic.mesh")
    
    ;- Entities
    CreateEntity(0, MeshID(0), MaterialID(0),  4, 1.0, 0)
    CreateEntity(1, MeshID(1), MaterialID(1), -4, 0.5, 0)
    CreateEntity(2, MeshID(2), MaterialID(2),  0, -2.3, 0)
    CreateEntity(4, MeshID(0), MaterialID(4), 0, -4, 0)
    ScaleEntity(2, 0.1, 0.1, 0.1)
    ScaleEntity(4, 5, 0.5, 5)
    
    ;- Body
    CreateEntityBody(0, #PB_Entity_BoxBody, 1)
    CreateEntityBody(1, #PB_Entity_SphereBody, 1)
    CreateEntityBody(2, #PB_Entity_StaticBody)
    CreateEntityBody(4, #PB_Entity_StaticBody)
    
    ;- Camera
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    MoveCamera(Camera, -1, 8, 25, #PB_Absolute)
    CameraLookAt(Camera, -1, 0, 0)
    
    ;- Light
    CreateLight(#PB_Any, RGB(255, 255, 255), 1560, 900, 500)
    
    ;- GUI
    RatioX = CameraViewWidth(Camera) / 1920
    RatioY = CameraViewHeight(Camera) / 1080
    OpenWindow3D(#MainWindow, 10, 10, 380 * RatioX, 180 * RatioY, "WorldDebug")
    EditorGadget3D(#Editor, 10 * RatioX, 20 * RatioY, 340 * RatioX, 110 * RatioY, #PB_Editor3D_ReadOnly)
    SetGadgetText3D(#Editor, "F2 : Debug Entity" + Chr(10) + "F3 : Debug Body"  + Chr(10) + "F4 : Debug none")
    
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    Repeat
      Screen3DEvents()
      
      Repeat
        Event3D = WindowEvent3D()
      Until Event3D = 0
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
        
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_F2)
          WorldDebug(#PB_World_DebugEntity) 
        ElseIf KeyboardPushed(#PB_Key_F3)
          WorldDebug(#PB_World_DebugBody) 
        ElseIf KeyboardPushed(#PB_Key_F4)
          WorldDebug(#PB_World_DebugNone) 
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
      
      CameraLookAt(Camera, 0, 0, 0)
      MoveCamera  (Camera, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End