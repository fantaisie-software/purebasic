;
; ------------------------------------------------------------
;
;   PureBasic - AddMaterialLayer
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY 

Font = LoadFont(#PB_Any, "Arial", 12, #PB_Font_Bold)

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  
    ;- Mesh
    Mesh = LoadMesh(#PB_Any, "robot.mesh")
    
    
    Texture = CreateTexture(#PB_Any, 512, 512)
    If StartDrawing(TextureOutput(Texture))
      Box(0, 0, 512, 512, RGB(0, 0, 0))
      DrawingFont(FontID(Font))
      DrawText(70, 210, "PureBasic", RGB(255, 255, 105))
      StopDrawing()
    EndIf
    
    ;- Material
    Material = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any, "r2skin.jpg")))
    AddMaterialLayer(Material, TextureID(Texture), #PB_Material_Add)
    
    ;- Entity
    Entity = CreateEntity(#PB_Any, MeshID(Mesh), MaterialID(Material))
    StartEntityAnimation(Entity, "Walk")
    RotateEntity(Entity, 0, -90, 0)
    
    ;- Camera
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    MoveCamera(Camera, 0, 70, 90, #PB_Absolute)
    
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