;
; ------------------------------------------------------------
;
;   PureBasic - CameraView
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, SpriteX, SpriteY 

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    
    ;- Ground
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
    CreateEntity(0,MeshID(0),MaterialID(0))
    EntityRenderMode(0, 0)
    
    CreateCube(1, 50)
    CreateEntity(1, MeshID(1), GetScriptMaterial(1, "Color/Blue"), 0, 50, 0)
     
    ;- Camera
    ;
    CreateCamera(1, 50, 50, 1, 1) ; J'ai ajouté et caché cette caméra pour que la caméra 0 ne soit pas zoomée ! Bug ogre ?
    
    CreateCamera(0, 25, 25, 50, 50)
    MoveCamera(0, 0, 120, 500, #PB_Absolute)
    CameraBackColor(0, $FF)
 
    ;- Light
    ;
    CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
    AmbientColor(RGB(80, 80, 80))
    
    ;- Sprite
    ;
    UsePNGImageDecoder()
    LoadImage(0, "Data/Textures/viseur-jeux.png")
    ResizeImage(0, 30 * CameraViewWidth(0) / ImageWidth(0), 30 * CameraViewWidth(0) / ImageWidth(0)); Keep Size Ratio for all resolution
    
    CreateSprite(0, ImageWidth(0), ImageHeight(0))
    If StartDrawing(SpriteOutput(0))
      DrawImage(ImageID(0), 0, 0)
      StopDrawing()
    EndIf
    
    TransparentSpriteColor(0, RGB(255, 255, 255))

    SpriteX = CameraViewX(0) + (CameraViewWidth(0)  - SpriteWidth(0))  / 2
    SpriteY = CameraViewY(0) + (CameraViewHeight(0) - SpriteHeight(0)) / 2
    
    Repeat
 
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX()/10 
        MouseY = -MouseDeltaY()/10
      EndIf
      
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -1
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = 1
        Else
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -1
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = 1
        Else
          KeyY = 0
        EndIf
        
      EndIf
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld() 
      
      DisplayTransparentSprite(0, SpriteX, SpriteY)
   
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End