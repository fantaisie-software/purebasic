;
; ------------------------------------------------------------
;
;   PureBasic - MaterialFog
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
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data"                , #PB_3DArchive_FileSystem)    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
    
    ; Material
    ;
    CreateMaterial(0, LoadTexture(0, "MRAMOR6X6.jpg"))
    MaterialFog(0, RGB(255, 175, 175), 1, 0, 700)
    
    CreatePlane(0, 300, 300, 10, 10, 1, 1)
    CreateEntity(0, MeshID(0), MaterialID(0), -16, 0, 0)
     
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100) 
    MoveCamera(0, 0, 150, 300, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    CameraBackColor(0, RGB(0, 0, 30))
    
    ;- Light
    ;
    AmbientColor(RGB(75, 75, 75))
    CreateLight(0, RGB(255, 255, 255), 0, 500, 0)
    
    ;Fog(RGB(55, 55, 175), 1, 0, 1000)
    
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

