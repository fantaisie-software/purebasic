;
; ------------------------------------------------------------
;
;   PureBasic - SkyBox
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Thanks to Steve 'Sinbad' Streeting for the nice SkyBox !
;

; Use [F2]/[F3] to change SkyBox's texture 
; Use [F4] to disable SkyBox

#CameraSpeed = 1

Enumeration
  #MainWindow 
  #Editor
EndEnumeration

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    ;-Material
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
    
    ;-Entity
    CreateEntity(0, LoadMesh(0, "robot.mesh"), MaterialID(0))
    
    ;-Camera 
    CreateCamera(0,0,0,100,100)
    MoveCamera(0,0,0,100, #PB_Absolute)
    CameraBackColor(0, RGB(19, 34, 49))
    
    ;-GUI
    RatioX = CameraViewWidth(0) / 1920
    RatioY = CameraViewHeight(0) / 1080
    
    OpenWindow3D(#MainWindow, 10, 10, 570 * RatioX, 180 * RatioY, "SkyBox")
    EditorGadget3D(#Editor, 10 * RatioX, 20 * RatioY, 530 * RatioX, 90 * RatioY, #PB_Editor3D_ReadOnly)
    SetGadgetText3D(#Editor, "[F2]/[F3] = Change SkyBox " + Chr(10) + "[F4] = Disable SkyBox")
    
    ShowGUI(155, 0)
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardReleased(#PB_Key_F2)
          SkyBox("stevecube.jpg")
        ElseIf KeyboardReleased(#PB_Key_F3) 
          SkyBox("desert07.jpg")
        ElseIf KeyboardReleased(#PB_Key_F4)
          SkyBox("")
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

      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf
  
End