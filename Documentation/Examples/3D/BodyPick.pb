;
; ------------------------------------------------------------
;
;   PureBasic - BodyPick
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
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Desert.zip", #PB_3DArchive_Zip)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
    Parse3DScripts()
    
    WorldShadows(#PB_Shadow_Modulative, -1, RGB(105, 105, 105))
    ;WorldDebug(#PB_World_DebugBody)    
    
    ;- Materials
    ;
    GetScriptMaterial(1, "Color/Red")
    GetScriptMaterial(2, "Color/Green")
    GetScriptMaterial(3, "Color/Blue")
    GetScriptMaterial(4, "Color/Yellow")
    DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"Dirt.jpg")))
    
    ;- Mesh
    ;
    CapsuleMesh = CreateCapsule(#PB_Any, 1,2)
    ConeMesh = CreateCone(#PB_Any, 1,2)
    CubeMesh = CreateCube(#PB_Any, 2)
    CylinderMesh = CreateCylinder(#PB_Any, 1,2)
    IcoSphereMesh = CreateIcoSphere(#PB_Any, 2)
    PlaneMesh = CreatePlane(#PB_Any, 200, 200, 40, 40, 4, 4)
    SphereMesh = CreateSphere(#PB_Any, 2)
    TorusMesh = CreateTorus(#PB_Any, 2, 1)
    TubeMesh = CreateTube(#PB_Any, 2, 1, 2)
    
    ;-Entity
    ;
    Capsule = CreateEntity(#PB_Any, MeshID(CapsuleMesh), MaterialID(1),0,5, 5)
    Cone = CreateEntity(#PB_Any, MeshID(ConeMesh), MaterialID(2),0,5,10)
    Cube = CreateEntity(#PB_Any, MeshID(CubeMesh), MaterialID(3),0,5,15)
    Cylinder = CreateEntity(#PB_Any, MeshID(CylinderMesh), MaterialID(4),0,5,20)
    IcoSphere = CreateEntity(#PB_Any, MeshID(IcoSphereMesh), MaterialID(1),0,5,25)
    Plane = CreateEntity(#PB_Any, MeshID(PlaneMesh), MaterialID(DirtMaterial))
    Sphere = CreateEntity(#PB_Any, MeshID(SphereMesh), MaterialID(2),0,5,30)
    Torus = CreateEntity(#PB_Any, MeshID(TorusMesh), MaterialID(3),0,5,35)
    Tube = CreateEntity(#PB_Any, MeshID(TubeMesh), MaterialID(4),0,5,40)
    
     EntityRenderMode(Plane, 0) 
    ;-Body
    ;
    CreateEntityBody(Capsule, #PB_Entity_CapsuleBody, 1)
    CreateEntityBody(Cone, #PB_Entity_ConeBody, 1)
    CreateEntityBody(Cube, #PB_Entity_BoxBody, 1)
    CreateEntityBody(Cylinder, #PB_Entity_CylinderBody, 1) 
    CreateEntityBody(IcoSphere, #PB_Entity_SphereBody, 1)
    CreateEntityBody(Plane, #PB_Entity_PlaneBody, 0,0,1)
    CreateEntityBody(Sphere, #PB_Entity_SphereBody, 1)
    CreateEntityBody(Torus, #PB_Entity_CylinderBody, 1) 
    CreateEntityBody(Tube, #PB_Entity_CylinderBody, 1) 
    
    ;- Light
    ;
    CreateLight(0, RGB(255,255,255), 200, 50, 100)
    
    ;- SkyBox
    ;
    SkyBox("Desert07.jpg")
        
    ;- Camera
    ;
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    MoveCamera(Camera, 100, 30, 20)
    CameraLookAt(Camera, 0,0,0)
    
    ;- GUI
    ;
    OpenWindow3D(0, 0, 0, 50 , 10 , "")
    HideWindow3D(0,1)
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.03
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        InputEvent3D(MouseX(), MouseY(),0)
        BodyPick(CameraID(Camera), MouseButton(#PB_MouseButton_Left), MouseX(), MouseY(), 1)
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

      MoveCamera  (Camera, KeyX, 0, KeyY)
      RotateCamera(Camera,  MouseY, MouseX, 0, #PB_Relative)
          
      EndIf
           
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End