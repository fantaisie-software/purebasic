;
; ------------------------------------------------------------
;
;   PureBasic - CheckObjectVisibility
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 0.4

Enumeration
  #MainWindow 
  #Editor1
  #Editor2
  #Editor3
EndEnumeration

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY, SpeedRotate

Declare IsOnScreen(Editor, object.s , objectID)

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
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    GetScriptMaterial(1, "Color/Blue")
    GetScriptMaterial(2, "Color/Green")
    GetScriptMaterial(3, "Color/Red")
    
    ; Meshes
    ;
    CreatePlane(0, 500, 500, 10, 10, 10, 10)
    CreateCube(1, 2)
    CreateSphere(2, 2)
    CreateCylinder(3, 1, 4)
    
    ; Entities
    ;
    CreateEntity(0, MeshID(0), MaterialID(0))
    CreateEntity(1, MeshID(1), MaterialID(1),   0, 1,  150)
    CreateEntity(2, MeshID(2), MaterialID(2), 150, 1,    0)
    CreateEntity(3, MeshID(3), MaterialID(3),   0, 2, -150)
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    CameraBackColor(0, RGB(30, 50, 70))
    MoveCamera(0, -1, 10, 15, #PB_Absolute)
    CameraLookAt(0, 100, 0, 0)
    
    ; Light
    ;
    CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
    AmbientColor(RGB(30, 30, 30))
    
    ;GUI
    ;
    RatioX = CameraViewWidth(0) / 1920
    RatioY = CameraViewHeight(0) / 1080
    OpenWindow3D(#MainWindow, 0, 0, 490 * RatioX, 190 * RatioY, "Who Is on Screen ?")
    StringGadget3D(#Editor1, 10 * RatioX,  20 * RatioY, 430 * RatioX, 40 * RatioY, "", #PB_String3D_ReadOnly)
    StringGadget3D(#Editor2, 10 * RatioX,  60 * RatioY, 430 * RatioX, 40 * RatioY, "", #PB_String3D_ReadOnly)
    StringGadget3D(#Editor3, 10 * RatioX, 100 * RatioY, 430 * RatioX, 40 * RatioY, "", #PB_String3D_ReadOnly)
    
    ShowGUI(128, 1)
    
    Repeat
      Screen3DEvents()
      
      Repeat
        Event3D = WindowEvent3D()
      Until Event3D = 0
      
      If ExamineMouse()
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.5
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.5
      EndIf  
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Space)
          Stop = 0
        Else
          Stop = 1
        EndIf          
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
      IsOnScreen(#Editor1, "Cube", EntityID(1))
      IsOnScreen(#Editor2, "Sphere", EntityID(2))
      IsOnScreen(#Editor3, "Cylinder", EntityID(3))
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
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
Procedure IsOnScreen(Editor, object.s , objectID)
  If CheckObjectVisibility(0, objectID)
    SetGadgetText3D(Editor, object + " is on screen")
  Else
    SetGadgetText3D(Editor, object + " is not on screen")
  EndIf
EndProcedure