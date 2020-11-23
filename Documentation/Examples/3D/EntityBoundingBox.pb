;
; ------------------------------------------------------------
;
;   PureBasic - EntityBoundingBox
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;Speed animation = PageUp and PageDown 

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, Speed = 0.3
Define.f x1, y1, z1, x2, y2, z2
Define Color = RGB(255, 0, 0)

If InitEngine3D()
  
    
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ; Entity
    ;
    CreateEntity(1, LoadMesh(1, "robot.mesh"), #PB_Material_None)

    ; Animation
    ;
    StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual)
    
    ; SkyBox
    ;
    SkyBox("Desert07.jpg")
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 50, 100, 80, #PB_Absolute)
    CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
    
    CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
    AmbientColor(RGB(80, 80, 80))
    KeyboardMode(#PB_Keyboard_International)
        
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
        
        If KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0
          Speed + 0.05
        ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1 
          Speed - 0.05
        EndIf
                
      EndIf

      AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame * Speed)
                
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      TimeSinceLastFrame = RenderWorld()
      RotateEntity(1, 0, 1, 0, #PB_Relative)
      
      ;BoudingBox
      x1 = EntityBoundingBox(1, #PB_Entity_MinBoundingBoxX)
      y1 = EntityBoundingBox(1, #PB_Entity_MinBoundingBoxY)
      z1 = EntityBoundingBox(1, #PB_Entity_MinBoundingBoxZ)
      x2 = EntityBoundingBox(1, #PB_Entity_MaxBoundingBoxX)
      y2 = EntityBoundingBox(1, #PB_Entity_MaxBoundingBoxY)
      z2 = EntityBoundingBox(1, #PB_Entity_MaxBoundingBoxZ)
      
      ;Bottom
      CreateLine3D(10, x1, y1, z1, Color, x2, y1, z1, Color)
      CreateLine3D(11, x2, y1, z1, Color, x2, y1, z2, Color)
      CreateLine3D(12, x2, y1, z2, Color, x1, y1, z2, Color)
      CreateLine3D(13, x1, y1, z2, Color, x1, y1, z1, Color)
      ;Top
      CreateLine3D(14, x1, y2, z1, Color, x2, y2, z1, Color)
      CreateLine3D(15, x2, y2, z1, Color, x2, y2, z2, Color)
      CreateLine3D(16, x2, y2, z2, Color, x1, y2, z2, Color)
      CreateLine3D(17, x1, y2, z2, Color, x1, y2, z1, Color)
      ;Edge
      CreateLine3D(18, x1, y1, z1, Color, x1, y2, z1, Color)
      CreateLine3D(19, x2, y1, z1, Color, x2, y2, z1, Color)    
      CreateLine3D(20, x2, y1, z2, Color, x2, y2, z2, Color)
      CreateLine3D(21, x1, y1, z2, Color, x1, y2, z2, Color)
 
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf
  
End
