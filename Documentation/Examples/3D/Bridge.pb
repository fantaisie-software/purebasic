;
; ------------------------------------------------------------
;
;   PureBasic - PointJoint (Bridge)
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1
#NbPlanks = 30
Define.f KeyX, KeyY, MouseX, MouseY
Dim Plank(#NbPlanks)

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    WorldShadows(#PB_Shadow_Modulative, -1, RGB(127, 127, 127))
    
    ;Materials
    ;
    CreateMaterial(0, LoadTexture(0, "Wood.jpg"))
    GetScriptMaterial(1, "SphereMap/SphereMappedRustySteel")
    CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
    GetScriptMaterial(3, "Scene/GroundBlend")
    
    ; Ground
    ;
    CreatePlane(3, 500, 500, 5, 5, 5, 5)
    CreateEntity(3,MeshID(3),MaterialID(3), 0, -50, 0)
    EntityRenderMode(3, 0) 
    CreateEntityBody(3, #PB_Entity_BoxBody, 0, 1, 1)
    
    ; Bridge
    CreateCube(1, 1.0)
    For i = 1 To #NbPlanks
      Plank(i)=CreateEntity(#PB_Any, MeshID(1), MaterialID(0))
      ScaleEntity(Plank(i), 2.8, 0.8, 20)
      MoveEntity(Plank(i), i * 3, 0, 0, #PB_Absolute)
      CreateEntityBody(Plank(i), #PB_Entity_BoxBody, 1.0)
    Next i
    
    Pas.f = 1.5
    PointJoint(#PB_Any, EntityID(Plank(1)), -Pas, 0, -5)
    For i= 1 To #NbPlanks-2
      Joint=PointJoint(#PB_Any, EntityID(Plank(i+1)), -Pas, 0, -5, EntityID(Plank(i)), Pas, 0, -5)
    Next i
    PointJoint(#PB_Any, EntityID(Plank(#NbPlanks)),  Pas, 0, -5)
    PointJoint(#PB_Any, EntityID(Plank(#NbPlanks-1)),  Pas, 0, -5, EntityID(Plank(#NbPlanks)), -Pas, 0, -5)
    
    PointJoint(#PB_Any, EntityID(Plank(1)), -Pas, 0, 5)
    For i= 1 To #NbPlanks-2
      Joint=PointJoint(#PB_Any, EntityID(Plank(i+1)),  -Pas, 0, 5, EntityID(Plank(i)), Pas, 0, 5)
    Next i
    PointJoint(#PB_Any, EntityID(Plank(#NbPlanks)),  Pas, 0, 5)
    toto=PointJoint(#PB_Any, EntityID(Plank(#NbPlanks-1)),  Pas, 0, 5, EntityID(Plank(#NbPlanks)), -Pas, 0, 5)
    
    ; Objects
    ;
    CreateSphere(2, 2, 30, 30)
    
    C = Plank(1)
    For i = 1 To #NbPlanks/2
      Perso = CreateEntity(#PB_Any, MeshID(2), MaterialID(1), EntityX(C) +i * 5, EntityY(C)+ i * 2, EntityZ(C))
      CreateEntityBody(Perso, #PB_Entity_SphereBody, 1.0, 0.3, 0.5)
    Next i
    
    For i = 1 To #NbPlanks/2
      Perso = CreateEntity(#PB_Any, MeshID(1), MaterialID(2), EntityX(C) +i * 5, EntityY(C)+ i * 4, EntityZ(C))
      ScaleEntity(Perso, 3, 3, 3)
      CreateEntityBody(Perso, #PB_Entity_BoxBody, 1.0)
    Next i
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, -20, 30, -40, #PB_Absolute)
    CameraLookAt(0, EntityX(C) + 25, EntityY(C) + 10,  EntityZ(C))
    
    ; Skybox
    ;
    SkyBox("desert07.jpg")
    
    ; Light
    ;
    CreateLight(0, RGB(255, 255, 255), 100, 800, -500)
    AmbientColor(RGB(20, 20, 20))
    
    Plank = 1
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        If KeyboardPushed(#PB_Key_Space)
          ApplyEntityImpulse(Plank(#NbPlanks/2), 0, 9, 0)
        EndIf
        If KeyboardReleased(#PB_Key_Return)
          
          If Plank <= #NbPlanks
            DisableEntityBody(Plank(Plank), 0)
            FreeEntityJoints(Plank(Plank))
            Plank + 1  
          EndIf  
          
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