;
; ------------------------------------------------------------
;
;   PureBasic - Pendulum waves experiment
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
; Thanks to kelebrindae for this nice code.

#PB_Material_AmbientColor  = 2 

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 0.4

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()

  
  If Screen3DRequester()
     
    ; Texture
    ;
    CreateTexture(0, 128, 128)
    StartDrawing(TextureOutput(0))
      Box(0, 0, 128, 128, $FFFFFF)
      StopDrawing()
      
    CreateTexture(1, 128, 128)    
    StartDrawing(TextureOutput(1))
      Box(0, 0, 128, 128, $000000)
      Box(0, 0, 64, 64, $BBBBBB)
      Box(64, 64, 64, 64, $BBBBBB)
    StopDrawing()
    
    ; Materials
    ;
    CreateMaterial(1, TextureID(1))
    SetMaterialColor(1, #PB_Material_AmbientColor, #PB_Material_AmbientColors)
    CreateMaterial(2, TextureID(0))
    SetMaterialColor(2, #PB_Material_AmbientColor, $D0B86B)
    CreateMaterial(3, TextureID(0))
    SetMaterialColor(3, #PB_Material_AmbientColor, $0077FF)
    
    ; Entities
    ;
    CreatePlane(1, 40, 40, 20, 20, 15, 15)
    sol = CreateEntity(#PB_Any, MeshID(1), MaterialID(1))
    CreateEntityBody(sol, #PB_Entity_StaticBody)   
    
    CreateCube(2, 1)
    support = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
    ScaleEntity(support, 20, 0.3, 0.3)
    MoveEntity(support, 0, 10, 0, #PB_Absolute)
    CreateEntityBody(support, #PB_Entity_StaticBody)   
    
    support2 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
    ScaleEntity(support2, 0.4, 12, 0.4)
    RotateEntity(support2, 30, 0, 0)
    MoveEntity(support2, 10, 5, -3, #PB_Absolute)
    CreateEntityBody(support2, #PB_Entity_StaticBody)   
    
    support3 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
    ScaleEntity(support3, 0.4, 12, 0.4)
    RotateEntity(support3, -30, 0, 0)
    MoveEntity(support3, 10, 5, 3, #PB_Absolute)
    CreateEntityBody(support3, #PB_Entity_StaticBody)   
    
    support4 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
    ScaleEntity(support4, 0.4, 12, 0.4)
    RotateEntity(support4, 30, 0, 0)
    MoveEntity(support4,-10,5,-3, #PB_Absolute)
    CreateEntityBody(support2, #PB_Entity_StaticBody)   
    
    support5 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
    ScaleEntity(support5, 0.4, 12, 0.4)
    RotateEntity(support5, -30, 0, 0)
    MoveEntity(support5, -10, 5, 3, #PB_Absolute)
    CreateEntityBody(support5, #PB_Entity_StaticBody)   
    
    ; Pendulums
    #NBPENDULUM = 16
    Global Dim sph.i(#NBPENDULUM + 1)
    Global position.f, stringLength.f
    CreateSphere(3, 0.5)
    For i=1 To #NBPENDULUM
      
      stringLength = 980.6 * Pow(15 / ( 2 * #PI * (24 + i) ), 2)
      position = -9.3 + i * 1.10
      
      ; Create a sphere
      sph(i) = CreateEntity(#PB_Any, MeshID(3), MaterialID(2))
      MoveEntity(sph(i), EntityX(support) + position, EntityY(support) - stringLength,EntityZ(support), #PB_Absolute)
      CreateEntityBody(sph(i), #PB_Entity_SphereBody)   
      
      ; Attach the support and the sphere
      PointJoint(#PB_Any, EntityID(support), position, 0, 0, EntityID(sph(i)), 0, stringLength, 0)
      CreateLine3D(100 + i, EntityX(support) + position, EntityY(support), EntityZ(support), $77FF00, EntityX(sph(i)), EntityY(sph(i)), EntityZ(sph(i)), $77FF00)
      
      ; Gently push the sphere
      ApplyEntityImpulse(sph(i),0,0,4)
    Next 
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 12, 20, #PB_Absolute)
    CameraLookAt(0, 0, 5, 0)
    
    ; Light
    ;
    AmbientColor(RGB(105, 105, 105))
    CreateLight(0,RGB(160, 160, 255), 0, 300, 0)
    WorldShadows(#PB_Shadow_Additive)
    
    
    ;- Main loop
    angle.f = 0
    angle2.f = 0
        
    Repeat
      Screen3DEvents()
      
      ;- F1, F2 : Change view
      If ExamineKeyboard()
        If KeyboardReleased(#PB_Key_F2)
          MoveCamera(0, -15, 2.5, 0, #PB_Absolute)
          CameraLookAt(0, 0, 3, 0)
        EndIf
        If KeyboardReleased(#PB_Key_F3)
          MoveCamera(0, 0, 12, 20, #PB_Absolute)
          CameraLookAt(0, 0, 5, 0)
        EndIf
        
        ;- Return : Display FPS
        If KeyboardReleased(#PB_Key_Return)
          MessageRequester("Infos", "FPS = " + Str(Engine3DStatus(#PB_Engine3D_AverageFPS)))
        EndIf
        
      EndIf
      
      ; Redraw the line3D to  figure the prendulums' strings
      For i=1 To #NBPENDULUM
        position = -9.3 + i * 1.10
        CreateLine3D(100 + i, EntityX(support) + position, EntityY(support), EntityZ(support), $77FF00, EntityX(sph(i)), EntityY(sph(i)), EntityZ(sph(i)), $77FF00)
      Next i
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf