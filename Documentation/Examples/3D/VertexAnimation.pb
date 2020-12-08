;
; ------------------------------------------------------------
;
;   PureBasic - VertexAnimation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; shapekey.mesh + shapekey.material done by blendman, thanks :)

;Use [PageUp] and [PageDown]

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f MouseX, MouseY, Pose 

#Mesh = 1

Macro Clamp(num, min, max)
  If num<min
    num=min
  ElseIf num>max
    num=max
  EndIf  
EndMacro

If InitEngine3D(3)
    
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    WorldShadows(#PB_Shadow_Modulative)
    
    ;Ground
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
    CreateEntity(0,MeshID(0),MaterialID(0))
    
    ;- Mesh
    
    LoadMesh(#Mesh, "Shapekey.mesh")
    
    ; Create a animation state For each vertex pose, using the pose name 
    Track     = 0 
    KeyFrame  = 0 
    PoseIndex = 0
    Animation$ = MeshPoseName(#Mesh, PoseIndex)
    
    CreateVertexAnimation(#Mesh, Animation$, 0)                 ; Create animation just for this pose
    CreateVertexTrack(#Mesh, Animation$, Track)                 ; Create track for this pose
    CreateVertexPoseKeyFrame(#Mesh, Animation$, Track, KeyFrame); Create a keyframe for this pose.
        
    ;- Entity
    CreateEntity(1, MeshID(#Mesh), #PB_Material_None, 0, 50, 0)
    ScaleEntity(1, 3, 3, 3)
    StartEntityAnimation(1, Animation$)  
   
    ;- SkyBox
    SkyBox("Desert07.jpg")
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 10, EntityY(1) + 4, -10, #PB_Absolute)
    CameraLookAt(0, EntityX(1), EntityY(1), EntityZ(1))
    
    ;- Light
    CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
    AmbientColor(RGB(80, 80, 80))
     
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX()/10 
        MouseY = -MouseDeltaY()/10
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_PageDown) And Pose < 1
          Pose + 0.01
          Clamp(Pose, 0, 1)
        ElseIf KeyboardPushed(#PB_Key_PageUp) And Pose > 0
          Pose - 0.01
          Clamp(Pose, 0, 1) 
        EndIf
        
      EndIf
      
      ; update the pose reference
      UpdateVertexPoseReference(#Mesh, Animation$, Track, KeyFrame, PoseIndex, Pose)
      
      ; update animation state since we're fudging this manually
      UpdateEntityAnimation(1, Animation$)
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      
      RenderWorld() 
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End