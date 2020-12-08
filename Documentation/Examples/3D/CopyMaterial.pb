;
; ------------------------------------------------------------
;
;   PureBasic - CopyMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    CreateMaterial(0, LoadTexture(0, "clouds.jpg"))
  
    CreateSphere(0, 40, 50, 50)
    CreateEntity(0,MeshID(0), MaterialID(0), -60,   0,  0)
    
    ; Copy the Material 
    CopyMaterial(0, 1)
    
    ; Create a cube with the new material 
    CreateCube(1, 40)
    CreateEntity(1, MeshID(1), MaterialID(1), 60, 0, 0)
        
    ; Camera 
    CreateCamera(0, 0, 0, 100, 100)
    CameraBackColor(0, $333333)
    MoveCamera(0,0,100,300, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    
    ; Light
    CreateLight(0, $FFFFFF, 1560, 900, 500)
    AmbientColor($330000)
  
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