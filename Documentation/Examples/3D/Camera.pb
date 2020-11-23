;
; ------------------------------------------------------------
;
;   PureBasic - Camera
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
    
    AmbientColor(RGB(0, 200, 0))  ; Green 'HUD' like color 
 
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
    CreateEntity(0, LoadMesh(0, "robot.mesh"), MaterialID(0))
    StartEntityAnimation(0, "Walk")
    
    CreateCamera(0, 0, 0, 100, 50)  ; Front camera
    MoveCamera(0, 0, 20, 250, #PB_Absolute)
    CameraBackColor(0, RGB(55, 0, 0))
    
    CreateCamera(1, 0, 50, 100, 50) ; Back camera
    MoveCamera(1, 0, 20, -250, #PB_Absolute)
    CameraBackColor(1, RGB(25, 25, 25))
    RotateCamera(1, 180, 0, 0)
    
    CameraRenderMode(1, #PB_Camera_Wireframe)  ; Wireframe for this camera
 
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
      
      
      RotateEntity(0, 0, 0.1, 0, #PB_Relative)
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RotateCamera(1, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (1, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf
  
End