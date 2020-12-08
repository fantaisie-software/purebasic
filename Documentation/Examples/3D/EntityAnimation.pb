;
; ------------------------------------------------------------
;
;   PureBasic - EntityAnimation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;Speed animation = PageUp and PageDown 

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, Speed = 0.3

If InitEngine3D()
  
    
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    WorldShadows(#PB_Shadow_Modulative, -1, RGB(175, 175, 175))
    
    ;Ground
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
    CreateEntity(0,MeshID(0),MaterialID(0))
    EntityRenderMode(0, 0)
    
    ;Mesh
    ;
    LoadMesh(1, "robot.mesh")
    
    ; Entity
    ;
    CreateEntity(1, MeshID(1), #PB_Material_None)
    
    ; Animation
    ;
    StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual)
     
    ; SkyBox
    ;
    SkyBox("Desert07.jpg")
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 50, 100, 80, #PB_Absolute)
    CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
    
    CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
    AmbientColor(RGB(80, 80, 80))
    KeyboardMode(#PB_Keyboard_International)
        
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX()/10 
        MouseY = -MouseDeltaY()/10
      EndIf
      
          
      If ExamineKeyboard()
      
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -1
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = 1
        Else
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -1
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = 1
        Else
          KeyY = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0
          Speed + 0.05
        ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1 
          Speed - 0.05
        EndIf
                
      EndIf

      AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame * Speed)
                
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      TimeSinceLastFrame = RenderWorld()

      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf
  
End