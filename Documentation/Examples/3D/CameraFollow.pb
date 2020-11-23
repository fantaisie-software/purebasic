;
; ------------------------------------------------------------
;
;   PureBasic - CameraFollow
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 2

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Desert.zip", #PB_3DArchive_Zip)
    Parse3DScripts()
    
    ; First create materials
    ;
    
    GrassMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"grass1.png")))
    MaterialBlendingMode(GrassMaterial, #PB_Material_AlphaBlend)
    DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"Dirt.jpg")))
    NinjaRed = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"nskinrd.jpg")))
    
    ; Then create the billboard group and use the previous material
    ;
    ;-Billboard
    
    Billboard = CreateBillboardGroup(#PB_Any, MaterialID(GrassMaterial), 60, 60)
    For i = 0 To 1000
      AddBillboard(Billboard, Random(2000)-1000, 30, Random(2000) - 1000)
    Next i
    
    ; create ground
    MeshPlane = CreatePlane(#PB_Any, 2000, 2000, 40, 40, 4, 4)
    CreateEntity(#PB_Any, MeshID(MeshPlane), MaterialID(DirtMaterial))
    
    ; Add house
    MeshHouse = LoadMesh(#PB_Any, "tudorhouse.mesh")
    House = CreateEntity(#PB_Any, MeshID(MeshHouse), #PB_Material_None, 0, 280, 0)
    ScaleEntity(House, 0.5, 0.5, 0.5)
    
    ;- Ninja
    NinjaMesh = LoadMesh(#PB_Any, "ninja.mesh")
    Ninja = CreateEntity(#PB_Any, MeshID(NinjaMesh), MaterialID(NinjaRed), 500, 0, 400)
    ScaleEntity(Ninja, 0.5, 0.5, 0.5)  
    StartEntityAnimation(Ninja, "Walk")
    
    ; SkyBox
    SkyBox("Desert07.jpg")
    
    ; create camera
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.03
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -#CameraSpeed
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = #CameraSpeed
        Else
          KeyX * 0.85
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -#CameraSpeed
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = #CameraSpeed
        Else
          KeyY * 0.9
        EndIf
        
      EndIf
      
      MoveEntity(Ninja, KeyX, 0, KeyY, #PB_Local)
      Yaw(EntityID(Ninja), MouseX, #PB_World)         
      CameraFollow(Camera, EntityID(Ninja), 0, EntityY(Ninja) + 80, 160, 0.1, 0.1, #False)
      CameraLookAt(Camera, EntityX(Ninja), 40, EntityZ(Ninja))      
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End