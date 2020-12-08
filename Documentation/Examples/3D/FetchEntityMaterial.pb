;
; ------------------------------------------------------------
;
;   PureBasic - FetchEntityMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"


#Camera    = 0
#Entity0   = 0
#Entity1   = 1
#Light     = 0
#Material0 = 0
#Material1 = 1
#Mesh0     = 0
#Mesh1     = 1
#Texture0  = 0


Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    CreateMaterial(#Material0, LoadTexture(#Texture0, "clouds.jpg"))
  
    CreateSphere(#Mesh0, 40, 50, 50)
    CreateEntity(#Entity0,MeshID(#Mesh0), MaterialID(#Material0), -60, 0, 0)
    
    ; Get the MaterialID 
    FetchEntityMaterial(#Entity0, #Material1)
    
    ; Create a cube with materialID
    CreateCube(#Mesh1, 40)
    CreateEntity(#Entity1, MeshID(#Mesh1), MaterialID(#Material1), 60, 0, 0)
        
    ; Camera 
    CreateCamera(#Camera, 0, 0, 100, 100)
    CameraBackColor(#Camera, RGB(30, 0, 0))
    MoveCamera(#Camera, 0, 100, 300, #PB_Absolute)
    CameraLookAt(#Camera, 0, 0, 0)
    
    ; Light
    CreateLight(#Light, RGB(255, 255, 255), 560, 900, 500)
    AmbientColor(0)
  
    Repeat
      Screen3DEvents()
      
      ExamineKeyboard()
            
      RenderWorld()
      Screen3DStats()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End