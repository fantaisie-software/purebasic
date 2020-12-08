;
; ------------------------------------------------------------
;
;   PureBasic - SetOrientation 
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, RollZ


If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    LoadMesh(0, "robot.mesh")
    
    CreateMaterial(1, LoadTexture(1, "clouds.jpg"))
    CreateMaterial(2, LoadTexture(2, "r2skin.jpg"))
    
    CreateEntity(1, MeshID(0), MaterialID(1), -30, 0, 0)
    CreateEntity(2, MeshID(0), MaterialID(2),  30, 0, 0)
       
    SkyBox("stevecube.jpg")
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 40, 150, #PB_Absolute)
    
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
      
      RotateEntity(1, 0.7, 1, 0.5, #PB_Relative)
      
      FetchOrientation(EntityID(1))
      SetOrientation(EntityID(2), GetX(), GetY(), GetZ(), GetW())
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End