;
; ------------------------------------------------------------
;
;   PureBasic - LightAttenuation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY
Define DebugBody 

#CameraSpeed = 1

If InitEngine3D(#PB_Engine3D_DebugLog | #PB_Engine3D_DebugOutput)
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    KeyboardMode(#PB_Keyboard_International) 
    
    WorldShadows(#PB_Shadow_Modulative, -1, RGB(155, 0, 0))
        
    ;Materials
    ;
    CreateMaterial(1, LoadTexture(1, "Wood.jpg"))
    CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
    
    ; Ground
    ;
    CreatePlane(0, 100, 100, 10, 10, 15, 15)
    CreateEntity(0, MeshID(0), MaterialID(2))
    EntityRenderMode(0, 0) 
    
    ; Meshes
    ;
    CreateCube(1, 2)
    CreateSphere(2, 2, 50, 50)
    CreateCylinder(3, 1, 4)

    ; Entities
    ;
    CreateEntity(1, MeshID(1), MaterialID(1), -5, 1, -5)
    CreateEntity(2, MeshID(2), MaterialID(1),  0, 2,  0)
    CreateEntity(3, MeshID(3), MaterialID(1),  5, 2,  5)
        
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 10, 10, -50, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
   
    ; Light
    ;
    CreateLight(0, RGB(255, 127, 0), 3, 8, -10)
    SetLightColor(0, #PB_Light_SpecularColor, RGB(255, 255, 0))
    LightAttenuation(0, 100, 1.0)
    
    AmbientColor(RGB(0, 0, 0))
     
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
      
     
      MoveCamera  (0, KeyX, 0, KeyY)
      RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
      
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
    
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End