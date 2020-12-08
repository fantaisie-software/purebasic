;
; ------------------------------------------------------------
;
;   PureBasic - Billboard
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
    
    ; First create our material, with a little rotate effect
    ;
    Material = CreateMaterial(#PB_Any, LoadTexture(0, "clouds.jpg"))
    RotateMaterial(Material, 0.05, 1)
    
    ; Then create the billboard group and use the previous material
    ;
    Billboard = CreateBillboardGroup(#PB_Any, MaterialID(Material), 10, 10)
    
    AddBillboard(Billboard,   0, 0, -40)
    AddBillboard(Billboard, -20, 0, -40)
    AddBillboard(Billboard,  20, 0, -40)
    
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    
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
      
      RotateCamera(Camera, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (Camera, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End