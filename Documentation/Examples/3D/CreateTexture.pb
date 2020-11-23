;
; ------------------------------------------------------------
;
;   PureBasic - CreateTexture
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

LoadFont(0, "Arial", 28, #PB_Font_Bold)

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    AmbientColor(RGB(255,255,255))
    
    ; Texture
    ;
    CreateTexture(0, 256, 256)
    StartDrawing(TextureOutput(0))
      Box(0, 0, 256, 256, RGB(90, 40, 0))
      Box(6, 6, 244, 244, RGB(190, 140, 0))
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(0))
      DrawText(10, 110, "PureBasic", RGB(90, 40, 90))
    StopDrawing()
    
    CreateMaterial(0, TextureID(0))
    
    ; Cube
    ;
    CreateCube(0, 30)
    CreateEntity(0, MeshID(0), MaterialID(0))
    
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 100, #PB_Absolute)
    
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
          
      RotateEntity(0, 0, 1, 0, #PB_Relative)
      
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