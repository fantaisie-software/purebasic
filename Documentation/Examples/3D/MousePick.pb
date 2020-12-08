;
; ------------------------------------------------------------
;
;   PureBasic - MousePick
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.4

Enumeration
  #MainWindow 
  #Editor
EndEnumeration

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ; First create materials
    ;
    GetScriptMaterial(0, "Color/Blue")
    GetScriptMaterial(1, "Color/Green")
    GetScriptMaterial(2, "Color/Red")
    GetScriptMaterial(3, "Color/Yellow")
    CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))
    
    ; Meshes
    ;
    CreateCube(0, 2)
    CreateSphere(1, 1)
    CreateCylinder(2, 1, 4)
    CreatePlane(3, 20, 20, 1, 1, 1, 1)

    ; Entities
    ;
    CreateEntity(0, MeshID(0), MaterialID(0),  4, 1, 0)
    CreateEntity(1, MeshID(1), MaterialID(1), -4, 1, 0)
    CreateEntity(2, MeshID(2), MaterialID(2),  0, 2, 0)
    CreateEntity(4, MeshID(3), MaterialID(4))
    
    CreateEntity(3, MeshID(1), MaterialID(3))  
    ScaleEntity(3, 0.1, 0.1, 0.1)
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, -1, 8, 15, #PB_Absolute)
    CameraLookAt(0, -1, 0, 0)
    
    ; Light
    ;
    CreateLight(0, $FFFFFF, 1560, 900, 500)
    AmbientColor($330000)
    
    ;GUI
    ;
    OpenWindow3D(#MainWindow, 10, 10, 340, 75, "MousePick")
    StringGadget3D(#Editor, 20, 10, 300, 30, "Clic somewhere", #PB_String3D_ReadOnly)
        
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor

    Repeat
      Screen3DEvents()
      
      Repeat
        Event3D = WindowEvent3D()
      Until Event3D = 0
      
       If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
   
        If MouseButton(#PB_MouseButton_Left) 
          Entity = MousePick(0, MouseX(), MouseY())
          If Entity>=0 And Entity<>3
            MoveEntity(3, PickX(), PickY(), PickZ(), #PB_Absolute)
            SetGadgetText3D(#Editor, "Entity = " + Str(Entity))
          EndIf
        EndIf
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
               
      CameraLookAt(0, 0, 0, 0)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End