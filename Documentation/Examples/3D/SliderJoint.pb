;
; ------------------------------------------------------------
;
;   PureBasic - sliderJoint
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY
#CameraSpeed = 1

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ; First create materials
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreateMaterial(1, LoadTexture(1, "Wood.jpg"))
    GetScriptMaterial(2, "Color/Green")
    GetScriptMaterial(3, "Color/Red")
    
    ; Meshes
    ;
    CreateCube(0, 1.0)
    CreateSphere(1, 0.5)
    
    ; Entities
    ;
    CreateEntity(0, MeshID(0), MaterialID(0),  1, 0, 0)
    ScaleEntity(0, 2, 4, 0.5)
    CreateEntity(1, MeshID(0), MaterialID(1), -3, 0, 0)
    ScaleEntity(1, 2, 4, 0.5)
    
    CreateEntity(2, MeshID(0), MaterialID(2), -1, -2.1, 0)
    ScaleEntity(2, 10, 0.1, 4)
    
    CreateEntity(3, MeshID(1), MaterialID(3), -1, 1, 0.23)
        
    ; Bodies
    ;
    CreateEntityBody(0, #PB_Entity_StaticBody)
    CreateEntityBody(1, #PB_Entity_BoxBody, 1.0)
    CreateEntityBody(2, #PB_Entity_StaticBody)
    CreateEntityBody(3, #PB_Entity_SphereBody, 0.5)
    
    ; SliderJoint
    ;
    SliderJoint(0, EntityID(0), -1, 0, 0, EntityID(1), 1, 0, 0)
    SetJointAttribute(0, #PB_SliderJoint_LowerLimit, -3)
    SetJointAttribute(0, #PB_SliderJoint_UpperLimit,  0)
        
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, -1, 8, 5, #PB_Absolute)
    CameraLookAt(0, -1, 0, 0)
    
    ; Light
    CreateLight(0, $FFFFFF, 1560, 900, 500)
    AmbientColor($330000)
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_PageUp)
          ApplyEntityImpulse(1, 0.1, 0, 0)
        ElseIf KeyboardPushed(#PB_Key_PageDown)
          ApplyEntityImpulse(1, -0.1, 0, 0)
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