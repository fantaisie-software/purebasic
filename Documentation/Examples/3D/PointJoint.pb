;
; ------------------------------------------------------------
;
;   PureBasic - PointJoint
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
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ; First create materials
    ;
    CreateMaterial(0, LoadTexture(0, "Wood.jpg"))
    CreateMaterial(1, LoadTexture(1, "Dirt.jpg"))
    
    ; Meshes
    ;
    CreateCube(0, 1.0)
    CreateSphere(1, 0.66)
    
    ; Entities
    ;
    CreateEntity(0, MeshID(0), MaterialID(0), 2,  0, 0)
    CreateEntity(1, MeshID(0), MaterialID(0), 2, -3, 0)
    CreateEntity(2, MeshID(1), MaterialID(0), 2, -6, 0)
    ;
    CreateEntity(3, MeshID(0), MaterialID(1), 5,  4, 0)
    ScaleEntity (3, 10, 1, 10)
    
    ; Bodies
    ;
    CreateEntityBody(0, #PB_Entity_BoxBody   , 1.0)
    CreateEntityBody(1, #PB_Entity_BoxBody   , 1.0)
    CreateEntityBody(2, #PB_Entity_SphereBody, 1.0)
    CreateEntityBody(3, #PB_Entity_StaticBody)
    
    ; PointJoint
    ;
    PointJoint(0, EntityID(3), -5, -1, 0, EntityID(0), 0, 1, 0) 
    PointJoint(1, EntityID(0),  0, -1, 0, EntityID(1), 0, 1, 0)
    PointJoint(2, EntityID(1),  0, -1, 0, EntityID(2), 0, 1, 0) 
    
    For i=0 To 2
      SetJointAttribute(i, #PB_PointJoint_Tau, 10)
    Next
  
    ApplyEntityImpulse(0,  10, 0, 0)
    
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 2, 25, #PB_Absolute)
    
    Repeat
      Screen3DEvents()
             
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Space)
          FreeJoint(1)
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
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End