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

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    KeyboardMode(#PB_Keyboard_International)  
    
    AmbientColor(RGB(255,255,255))
    
    ; Mesh
    ;
    CreateCube(0, 30)

    ; Texture
    ;
    For i = 0 To 2
      Read.i R : Read.i G : Read.i B: Read.i A
      Read.f x : Read.f y : Read.f z
      CreateTexture(i, 256, 256)
      StartDrawing(TextureOutput(i))
      DrawingMode(#PB_2DDrawing_AllChannels | #PB_2DDrawing_AlphaBlend)
      Box(0, 0, 256, 256, RGBA(0, 0, 0, 255))
      Box(4, 4, 248, 248, RGBA(R, G, B, A)) 
      Circle(127, 127, 50, RGBA(0, 0, 0, 0))
      StopDrawing()
      CreateMaterial(i, TextureID(i))
      MaterialBlendingMode(i, #PB_Material_AlphaBlend)
      CreateEntity(i, MeshID(0), MaterialID(i), x, y, z)
    Next
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 10, 150, #PB_Absolute)
    CameraLookAt(0, 0, 0, 1)
    
    ; SkyBox
    ;
    SkyBox("desert07.jpg")
    
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
      
      For i = 0 To 2
        RotateEntity(i, 1, 1, 2-i, #PB_Relative)
      Next
      
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

DataSection
  Data.i 255, 0, 0, 127
  Data.f -20, 0, 5
  Data.i 0, 0, 255, 127
  Data.f 20, 0, 5 
  Data.i 0, 255, 0, 127
  Data.f 0, 40, -5
EndDataSection  