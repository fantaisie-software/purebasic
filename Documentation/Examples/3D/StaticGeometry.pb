;
; ------------------------------------------------------------
;
;   PureBasic - Static Geometry
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY
Define nx.f, nz.f, Boost.f = 10, Yaw.f, Pitch.f

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    WorldShadows(#PB_Shadow_Additive)
    
    AmbientColor(0)
        
    ; node for Light and Billboard (Sun)
    CreateNode(0, 0, 3000, 0)
    
    ;Create light
    CreateLight(0, RGB(90, 105, 132), 0, 3000, 0)
    AttachNodeObject(0, LightID(0))
    
    ; Create flare
    GetScriptMaterial(0, "Scene/burst")
    CreateBillboardGroup(0, MaterialID(0), 2048, 2048)
    AddBillboard(0, 0, 3000, 0)
    AttachNodeObject(0, BillboardGroupID(0))
    
    
    ; Static geometry
    ;
    
    ; Create Entity
    CreateCube(0, 1)
    CreateEntity(0, MeshID(0), #PB_Material_None)
        
    ; Create Static geometry
    CreateStaticGeometry(0, 1000, 1000, 1000, #True)

    For z = -10 To 10
      For x = -10 To 10
        AddStaticGeometryEntity(0, EntityID(0), x * 1000, 0, z * 1000, 1000,  10, 1000, 0, 0, 0)        
        Height.f = 200 + Random(800)
        AddStaticGeometryEntity(0, EntityID(0), x * 1000, Height/2, z * 1000,  200, Height, 200, 0, Random(360), 0)
      Next
    Next
    
    ; Build the static geometry
    BuildStaticGeometry(0)
   
    FreeEntity(0)

    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 2000, 2000, 2000, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    CameraRange (0, 2, 5000)
    CameraFOV   (0, 90)
    CameraBackColor(0, RGB(90, 105, 132))
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        Yaw   = -MouseDeltaX() * 0.05
        Pitch = -MouseDeltaY() * 0.05
      EndIf
      
      If ExamineKeyboard()
              
        If KeyboardPushed(#PB_Key_Up)    
          MoveCamera(0,  0, 0, -2 * Boost)
        ElseIf KeyboardPushed(#PB_Key_Down)
          MoveCamera(0,  0, 0,  2 * Boost)
        EndIf 
  
        If KeyboardPushed(#PB_Key_Left)  
          MoveCamera(0, -2 * Boost, 0, 0) 
        ElseIf KeyboardPushed(#PB_Key_Right)
          MoveCamera(0,  2 * Boost, 0, 0)
        EndIf 
  
      EndIf
           
      ; Sun
      nx = 10000 * Cos(ElapsedMilliseconds() / 2500)
      nz = 10000 * Sin(ElapsedMilliseconds() / 2500)   
      MoveNode(0, nx, 3000, nz, #PB_Absolute)
      
      RotateCamera(0, Pitch, Yaw, 0, #PB_Relative)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End