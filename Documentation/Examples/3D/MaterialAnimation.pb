;
; ------------------------------------------------------------
;
;   PureBasic - MaterialAnimation
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
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"                , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/zombie.zip"      , #PB_3DArchive_Zip)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/ogredance.zip" , #PB_3DArchive_Zip)
    Parse3DScripts()
    
    ;- Material
    ;
    CreateMaterial(4,LoadTexture(4,"White.jpg"))
    MaterialAnimation(4, "ogredance.png",8,2)
    MaterialBlendingMode(4, #PB_Material_AlphaBlend)
    MaterialFilteringMode(4, #PB_Material_None)
    DisableMaterialLighting(4, #True)
    
    ;- Entity
    ;
    CreatePlane(0, 1,1,1,1,1,1)
    Ground = CreateEntity(#PB_Any, MeshID(0), MaterialID(4))
    
    ;- Camera
    ;
    CreateCamera(0, 0, 0, 100, 100, #True)
    MoveCamera(0,0,3,-0.1, #PB_Absolute)
    CameraLookAt(0,0,0,0)
        
    Repeat
      Screen3DEvents()
      
      ExamineMouse()
      
      If ExamineKeyboard()
        
        ; Change animation
        If KeyboardPushed(#PB_Key_Left)
          MaterialAnimation(4, "l.png",3,0.5)
        ElseIf KeyboardPushed(#PB_Key_Right)
          MaterialAnimation(4, "r.png",3,0.5)
        ElseIf KeyboardPushed(#PB_Key_Up)
          MaterialAnimation(4, "d.png",3,0.5)
        ElseIf KeyboardPushed(#PB_Key_Down)
          MaterialAnimation(4, "u.png",3,0.5)
        EndIf
        
      EndIf
            
      RenderWorld()
      
      FlipBuffers()
            
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
    
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End