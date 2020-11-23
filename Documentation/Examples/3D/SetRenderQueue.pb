;
; ------------------------------------------------------------
;
;   PureBasic - SetRenderQueue
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;Use [F5]/[F6]

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1

#Camera    = 0
#Entity0   = 0
#Entity1   = 1
#Material0 = 0
#Material1 = 1
#Mesh      = 0
#Texture0  = 0
#Texture1  = 1

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    CreateMaterial(#Material0, LoadTexture(#Texture0, "clouds.jpg"))
    CreateMaterial(#Material1, LoadTexture(#Texture1, "Dirt.jpg"))        
    
    CreateCube(#Mesh, 20)
    CreateEntity(#Entity0, MeshID(#Mesh), MaterialID(#Material0),  5, 0, 0)
    CreateEntity(#Entity1, MeshID(#Mesh), MaterialID(#Material1), -5, 0, 0)    
    
    
    SkyBox("stevecube.jpg")
    
    CreateCamera(#Camera, 0, 0, 100, 100)
    MoveCamera(#Camera, 0, 40, 150, #PB_Absolute)
    
    Repeat
      Screen3DEvents()
      
      If ExamineKeyboard()
        If KeyboardReleased(#PB_Key_F5)
          SetRenderQueue(EntityID(#Entity0), 1)
          SetRenderQueue(EntityID(#Entity1), 0)  
        ElseIf KeyboardReleased(#PB_Key_F6)
          SetRenderQueue(EntityID(#Entity0), 0)
          SetRenderQueue(EntityID(#Entity1), 1)  
        EndIf  
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
