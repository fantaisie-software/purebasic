;
; ------------------------------------------------------------
;
;   PureBasic - ScaleMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/"                , #PB_3DArchive_FileSystem)    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
    
    ; Material
    ;
    CreateMaterial(0, LoadTexture(0, "MRAMOR6X6.jpg"))
    
    ; Scaled Material
    ;
    CopyMaterial(0, 1)
    ScaleMaterial(1, 1, 3)
    
    ;- Mesh
    CreatePlane(0, 30, 10, 1, 1, 1, 1)
    
    ;- Entity without material scaled
    CreateEntity(0, MeshID(0), MaterialID(0), -16, 0, 0)
    
    ;-Entity with Material scaled
    CreateEntity(1, MeshID(0), MaterialID(1),  16, 0, 0)  
     
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100) 
    MoveCamera(0, 0, 50, 2, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    CameraBackColor(0, RGB(0, 0, 30))
    
    ;- Light
    ;
    AmbientColor(RGB(75, 75, 75))
    CreateLight(0, RGB(255, 255, 255), 0, 500, 0)
    
    Repeat
      Screen3DEvents()
      
      ExamineKeyboard()
      RenderWorld()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape)   
    
    End 
    
  EndIf 
Else
  MessageRequester("Error","Can't initialize engine3D")
EndIf 

