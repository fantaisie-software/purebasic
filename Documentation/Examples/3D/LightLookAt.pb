;
; ------------------------------------------------------------
;
;   PureBasic - LightLookAt
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
        
    ;- Ground
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreatePlane(0, 1000, 1000, 50, 50, 1, 1)
    CreateEntity (0, MeshID(0), MaterialID(0))
    
    
    ;- Light
    CreateLight(0, RGB(255, 255, 255), 0, 900, 0, #PB_Light_Spot)
    SpotLightRange(0, 1, 30, 3)
    AmbientColor(0)
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100) 
    MoveCamera(0, 0, 900, 1200, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    CameraBackColor(0, RGB(0, 0, 30))
    
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    Repeat
      Screen3DEvents()
         
      If ExamineMouse()
        
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
        
        If MousePick(0, MouseX(), MouseY()) >= 0
          LightLookAt(0, PickX(), PickY(), PickZ())
        EndIf
        
      EndIf
      
       If ExamineKeyboard()
        Input$ = KeyboardInkey()
      EndIf
      
      RenderWorld()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf