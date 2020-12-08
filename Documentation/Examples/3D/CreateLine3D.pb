;
; ------------------------------------------------------------
;
;   PureBasic - CreateLine3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY
  
If InitEngine3D()
   
  InitSprite()
  InitKeyboard()
  InitMouse()
    
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"  , #PB_3DArchive_FileSystem)
    
    LoadMesh(10, "axes.mesh")
    CreateMaterial(0, LoadTexture(0, "axes.png"))
    CreateEntity(0, MeshID(10), MaterialID(0))
    ScaleEntity(0, 0.1, 0.1 ,0.1)
    
    ; Line3D
    ;
    CreateLine3D(0, 0, 0, 0, RGB(255,   0,   0), 10,  0,  0, RGB(255,   0,   0))  ; Axis X
    CreateLine3D(1, 0, 0, 0, RGB(  0, 255,   0),  0, 10,  0, RGB(  0, 255,   0))  ; Axis Y
    CreateLine3D(2, 0, 0, 0, RGB(  0,   0, 255),  0,  0, 10, RGB(  0,   0, 255))  ; Axis Z
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 5, 5, 5, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    
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