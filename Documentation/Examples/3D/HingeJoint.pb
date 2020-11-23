;
; ------------------------------------------------------------
;
;   PureBasic - HingeJoint
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()

    ; First create materials
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreateMaterial(1, LoadTexture(1, "Wood.jpg"))

    ; Meshes
    ;
    CreateCube(0, 1.0)
    CreateSphere(1, 0.66)
    
    ; Entities
    ;
    CreateEntity(0, MeshID(0), MaterialID(0), 0, 0, 0)
    ScaleEntity(0, 2, 4, 0.5)
    CreateEntity(1, MeshID(0), MaterialID(1), 3, 0, 0)
    ScaleEntity(1, 2, 4, 0.5)
     
    ; Bodies
    ;
    
    CreateEntityBody(0, #PB_Entity_StaticBody)
    CreateEntityBody(1, #PB_Entity_BoxBody, 1.0)

    ; HingeJoint
    ;
    HingeJoint(0, EntityID(0), 1.0, 0.5, 0.25, 0, 1, 0, EntityID(1), -1.0, 0.5, 0.25, 0, 1, 0)
    SetJointAttribute(0, #PB_HingeJoint_LowerLimit, 0)
    ;SetJointAttribute(0, #PB_HingeJoint_UpperLimit, Degree(#PI/4))

    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 12, 15, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)

   Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Space)
           ApplyEntityImpulse(1, 0, 0, -1) 
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
