;
; ------------------------------------------------------------
;
;   PureBasic - Mesh (Skeleton Animation)
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


#PB_Material_SpecularColor = 1
#PB_Material_AmbientColor  = 2

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

#CameraSpeed  = 1
#RobotMesh    = 0
#RobotTexture = 0
#Robot        = 0
  
If InitEngine3D()

  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
   
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    LoadMesh   (#RobotMesh   , "robot.mesh")
    LoadTexture(#RobotTexture, "clouds.jpg")
    
    CreateMaterial(0, TextureID(#RobotTexture))
    
    CreateEntity(#Robot, MeshID(#RobotMesh), MaterialID(0))
    SetEntityMaterial(#Robot, MaterialID(0))
    
    StartEntityAnimation(#Robot, "Walk")
    
    DisableMaterialLighting(0, 1)
    
    SetMaterialColor(0, #PB_Material_AmbientColor, RGB(100, 100, 100))
    SetMaterialColor(0, #PB_Material_SpecularColor, RGB(255, 255, 255))
    ScrollMaterial(0, 0.15, 0, 1)
        
    CreateLight(0, RGB(0,0,255), 100.0, 0, 0)
    SetLightColor(0, #PB_Light_SpecularColor, RGB(255, 0, 0))
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 40, 150)
    CameraBackColor(0, RGB(0, 0, 128))
      
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
         
      RotateEntity(#Robot, 0, 1, 0, #PB_Relative)
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf
  
End