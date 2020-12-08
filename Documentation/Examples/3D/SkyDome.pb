;
; ------------------------------------------------------------
;
;   PureBasic - SkyDome
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1

Enumeration
  #MainWindow 
  #Editor
EndEnumeration

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY

If InitEngine3D()

  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    AmbientColor(RGB(255, 255, 255))
    
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
    CreateEntity  (0, LoadMesh(0, "robot.mesh"), MaterialID(0), -1, -2, -3)
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 70, 400, #PB_Absolute)
    CameraBackColor(0, RGB(19, 34, 49))
    
    ;-GUI
    RatioX = CameraViewWidth(0) / 1920
    RatioY = CameraViewHeight(0) / 1080
    
    OpenWindow3D(#MainWindow, 10, 10, 570 * RatioX, 180 * RatioY, "SkyDome")
    EditorGadget3D(#Editor, 10 * RatioX, 20 * RatioY, 530 * RatioX, 90 * RatioY, #PB_Editor3D_ReadOnly)
    SetGadgetText3D(#Editor, "[F2]/[F3] = Change SkyDome " + Chr(10) + "[F4] = Disable SkyDome")
    
    ShowGUI(128, 1)
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardReleased(#PB_Key_F2)
          SkyDome("clouds.jpg", 30)
        ElseIf KeyboardReleased(#PB_Key_F3) 
          SkyDome("Wood.jpg", 30)
        ElseIf KeyboardReleased(#PB_Key_F4)
          SkyDome("", 0)
        EndIf
        
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