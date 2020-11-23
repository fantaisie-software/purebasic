;
; ------------------------------------------------------------
;
;   PureBasic - CompoundBody
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY


If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/"              , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"  , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"    , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"    , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI"        , #PB_3DArchive_FileSystem)
    Parse3DScripts()
    
    WorldDebug(#PB_World_DebugBody)
    
    
    ;-------------------------------
    ; create  material
    CreateMaterial(1, LoadTexture(1, "wood.jpg"))
    SetMaterialColor(1, #PB_Material_AmbientColor, #PB_Material_AmbientColors)
    ; 
    CreateMaterial(2, LoadTexture(2, "dirt.jpg"))
    SetMaterialColor(2, #PB_Material_AmbientColor, #PB_Material_AmbientColors)
    
    CreateMaterial(3, LoadTexture(3, "clouds.jpg"))
    SetMaterialColor(3, #PB_Material_AmbientColor, #PB_Material_AmbientColors)
    
    CreateMaterial(4, LoadTexture(4, "r2skin.jpg"))
    
    ;-------------------------------
    CreateCube(1, 1.0)
    CreateSphere(2, 1)
    LoadMesh(3, "robot.mesh")
    
    CreateEntity(1, MeshID(1),MaterialID(1),  0, -1, 0)
    CreateEntity(2, MeshID(1),MaterialID(1),  0,  1, 0)
    CreateEntity(3, MeshID(1),MaterialID(1), -1,  0, 0)
    CreateEntity(4, MeshID(1),MaterialID(1),  1,  0, 0)
    CreateEntity(5, MeshID(2),MaterialID(3),  0,  0, 0)  
    
    Compound = CreateEntity(#PB_Any)
        
    AddSubEntity(Compound, 1, #PB_Entity_BoxBody) 
    AddSubEntity(Compound, 2, #PB_Entity_BoxBody) 
    AddSubEntity(Compound, 3, #PB_Entity_BoxBody) 
    AddSubEntity(Compound, 4, #PB_Entity_BoxBody) 
    AddSubEntity(Compound, 5, #PB_Entity_SphereBody) 
    CreateEntityBody(Compound, #PB_Entity_CompoundBody, 1, 0.4, 0.4)
    
    RotateEntity(Compound, 45, 0, 0)
        
    ; Compound 2
    ;
    Cube = CreateEntity(#PB_Any, MeshID(1),MaterialID(1),  0, 1, 0)
    
    Compound2 = CreateEntity(#PB_Any)
    AddSubEntity(Compound2, Cube, #PB_Entity_BoxBody, 0, -0.5, 0) 
    CreateEntityBody(Compound2, #PB_Entity_CompoundBody, 1, 0.4, 0.4)
    
    
    MoveEntity(Compound2, 5, 0, -5)
    
    ; Compound 3
    ;
    Robot = CreateEntity(#PB_Any, MeshID(3), MaterialID(4))
    ScaleEntity(Robot, 0.05,0.05,0.05)
    Compound3 = CreateEntity(#PB_Any)
    
    AddSubEntity(Compound3, Robot, #PB_Entity_CapsuleBody, 0, 2.1, 0) 
    CreateEntityBody(Compound3, #PB_Entity_CompoundBody, 1, 0.2, 0.2)
    
    

    
    ;Ground
    ;
    Ground = CreateEntity(#PB_Any, MeshID(1), MaterialID(2), 0, -7, 0)
    ScaleEntity(Ground, 40, 0.4, 40)
    CreateEntityBody(Ground, #PB_Entity_StaticBody)

    ; camera
    ;
    CreateCamera(0, 0, 0, 100, 100, #True)
    MoveCamera(0,0,2,30, #PB_Absolute)
    
    ; GUI
    OpenWindow3D(0, 0, 0, 50 , 10 , "")
    HideWindow3D(0,1)
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
        
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        InputEvent3D(MouseX(), MouseY(),0)
        BodyPick(CameraID(0), MouseButton(#PB_MouseButton_Left), MouseX(), MouseY(), 1)
      EndIf
    
      If ExamineKeyboard()
        
        If KeyboardReleased(#PB_Key_Space)
          ApplyEntityImpulse(Compound, 0, 10, 0)
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
      
      MoveCamera  (0, KeyX, 0, KeyY)
      RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)
      
      RenderWorld()
      
      FlipBuffers()
      
      
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
    
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End
