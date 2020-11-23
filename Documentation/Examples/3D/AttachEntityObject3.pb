;
; ------------------------------------------------------------
;
;   PureBasic - AttachEntityObject
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, Speed = 1.0
Define.i RobotMove

#CameraSpeed = 2

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()

  If Screen3DRequester()
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/"                , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Particles"       , #PB_3DArchive_FileSystem)  
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
    Parse3DScripts()
    
    WorldShadows(#PB_Shadow_Modulative, 3000, RGB(175, 175, 175))
     
    ;- Material
    ;
    GetScriptMaterial(1, "Color/Red")
    GetScriptMaterial(2, "Color/Green")
    GetScriptMaterial(3, "Color/Blue")
    GetScriptMaterial(4, "Color/Yellow")
    CreateMaterial(5, LoadTexture(5, "r2skin.jpg"))
    SetMaterialColor(5, #PB_Material_SelfIlluminationColor, RGB(75, 75, 75))

    ;- Ground
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreatePlane(0, 700, 700, 70, 70, 15, 15)
    CreateEntity(0,MeshID(0),MaterialID(0))
    EntityRenderMode(0, 0)
    
    ;- Mesh
    ;
    LoadMesh(1, "robot.mesh")
    CreateSphere(2, 10)
    
    ;- Entity
    ;
    CreateEntity(1, MeshID(1), MaterialID(5))
    CreateEntity(2, MeshID(2), MaterialID(1), -200, 10,  100)
    CreateEntity(3, MeshID(2), MaterialID(2),  200, 10, 0)
    CreateEntity(4, MeshID(2), MaterialID(3),  200, 10,  100)
    CreateEntity(5, MeshID(2), MaterialID(4), -200, 10, -100)
    
    ScaleEntity(3, 2, 2, 2)

    ;- Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 120, 400, #PB_Absolute)
    CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
    
    CreateCamera(1, 0, 0, 100, 100, 0)
    CameraLookAt(1,  EntityX(3), EntityY(3), EntityZ(3))
    
    ;- TextureRTT
    ;
    CreateRenderTexture(10, CameraID(1), 800, 600, 1)
    CreateMaterial(10, TextureID(10))
    SetMaterialColor(10, #PB_Material_SelfIlluminationColor, RGB(255, 255, 255))
    
    ;- Billboard group 
    ;
    CreateBillboardGroup(0, MaterialID(10), 80, 60)
    AddBillboard(0, 0, 0, 0)
    
    ;- Attach objects
    ;
    AttachEntityObject(1, "Joint1" , BillboardGroupID(0), 0, 60, 0, 0, 0, 0)  
    AttachEntityObject(1, "Joint1", CameraID(1), 0, 0, 0, 0, 0, 10)
    
    ;-Light
    ;
    CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
    AmbientColor(RGB(80, 80, 80))
    
    ;- Skybox
    ;
    SkyBox("desert07.jpg")
    
    Repeat
      Screen3DEvents()
            
      RobotMove = #False    
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Left)
          MoveEntity(1, -1 * Speed, 0, 0)
          RotateEntity(1, 0, 180, 0)
          RobotMove = #True
        EndIf  
        
        If KeyboardPushed(#PB_Key_Right)
          MoveEntity(1, 1 * Speed, 0, 0)
          RotateEntity(1, 0, 0, 0)
          RobotMove = #True
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          MoveEntity(1, 0, 0, -1 * Speed)
          RotateEntity(1, 0, 90, 0)
          RobotMove = #True
        EndIf  
        
        If KeyboardPushed(#PB_Key_Down)
          MoveEntity(1, 0, 0, 1 * Speed)
          RotateEntity(1, 0, -90, 0)
          RobotMove = #True
        EndIf
        
        If KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0
          Speed + 0.05
        ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1 
          Speed - 0.05
        EndIf
        
      EndIf
      
      If RobotMove
        If EntityAnimationStatus(1, "Walk") = #PB_EntityAnimation_Stopped ; Loop
          StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual) ; Start the animation from the beginning
        EndIf
      Else
        StopEntityAnimation(1, "Walk")
      EndIf
      
      AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame)
      
      CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
      
      TimeSinceLastFrame = RenderWorld() * Speed
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End