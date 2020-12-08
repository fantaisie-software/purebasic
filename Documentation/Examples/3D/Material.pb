;
; ------------------------------------------------------------
;
;   PureBasic - Material
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()

  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    AmbientColor(RGB(255,255,255))
    
    LoadMesh   (0, "robot.mesh")
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))

    CreateMaterial(1, LoadTexture(1, "clouds.jpg"))
    MaterialBlendingMode(1, #PB_Material_AlphaBlend)  ; Alphablending for this texture
    
    CreateEntity  (0, MeshID(0), MaterialID(1))
    CreateEntity  (1, MeshID(0), MaterialID(0))
 
    MoveEntity(1, 60, 0, 0)
    
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
          
      RotateEntity(0, 0, -0.5, 0, #PB_Relative)
      RotateEntity(1, 0, 0.5, 0, #PB_Relative)
      
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