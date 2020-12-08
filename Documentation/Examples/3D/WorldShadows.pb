;
; ------------------------------------------------------------
;
;   PureBasic - ShadowColor
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

#CameraSpeed = 1

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)   
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
    Parse3DScripts()
    
    KeyboardMode(#PB_Keyboard_International) 
    
    WorldShadows(#PB_Shadow_Modulative, -1, RGB(255, 0, 0))
    
    ;Materials
    ;
    WoodMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any, "Wood.jpg")))
    DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any, "Dirt.jpg")))
    
    ; Ground
    ;
    MeshPlane = CreatePlane(#PB_Any, 100, 100, 10, 10, 15, 15)
    Ground = CreateEntity(#PB_Any, MeshID(MeshPlane), MaterialID(DirtMaterial))
    EntityRenderMode(Ground, 0) 
    
    ; Meshes
    ;
    MeshCube = CreateCube(#PB_Any, 2)
    MeshSphere = CreateSphere(#PB_Any, 2)
    MeshLogo = LoadMesh(#PB_Any, "PureBasic.mesh")
    
    ; Entities
    ;
    CreateEntity(#PB_Any, MeshID(MeshCube), MaterialID(WoodMaterial), -5, 1, -5)
    CreateEntity(#PB_Any, MeshID(MeshSphere), MaterialID(WoodMaterial),  0, 2,  0)
    Logo = CreateEntity(#PB_Any, MeshID(MeshLogo), MaterialID(WoodMaterial),  5, 3,  5)
    ScaleEntity(Logo, 0.2, 0.2, 0.2) 
    
    ; Camera
    ;
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    MoveCamera(Camera, 0, 10, 20, #PB_Absolute)
    
    ;SkyBox
    ;
    SkyBox("desert07.jpg")
    
    ; Light
    ;
    CreateLight(#PB_Any, RGB(255, 255, 255), 300, 90, -300)
    
    
    AmbientColor(RGB(20, 20, 20))
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
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
      
      RotateEntity(Logo, 0, 1, 0, #PB_Relative)
      MoveCamera  (Camera, KeyX, 0, KeyY)
      RotateCamera(Camera, MouseY, MouseX, 0, #PB_Relative)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
      
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
    
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End