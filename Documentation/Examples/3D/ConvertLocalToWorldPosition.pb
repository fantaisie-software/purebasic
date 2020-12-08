;
; ------------------------------------------------------------
;
;   PureBasic - ConvertLocalToWorldPosition
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"
#CameraSpeed = 1

Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Define.f KeyX, KeyY, MouseX, MouseY, RollZ, sens = -1
Define.Vector3 Resultat, C1, C2 

C1\x = -25 : C1\y = -25 : C1\z = -25
C2\x =  25 : C2\y =  25 : C2\z =  25

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    CreateCube(0, 50)
    CreateSphere(1, 8)
    
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreateMaterial(1, LoadTexture(1, "Wood.jpg"))
    
    CreateEntity(0, MeshID(0), MaterialID(0))  
    CreateEntity(1, MeshID(1), MaterialID(1))  
    CreateEntity(2, MeshID(1), MaterialID(1))

    SkyBox("stevecube.jpg")
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 90, 80, 150, #PB_Absolute)
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
      EndIf
      
      RotateEntity(0, 0, 0.4, 0, #PB_Relative)
      MoveEntity(0, 0, 0, -1, #PB_Local)
      
      ConvertLocalToWorldPosition(EntityID(0), C1\x, C1\y, C1\z)
      MoveEntity(1, GetX(), GetY(), GetZ(), #PB_Absolute)
      
      ConvertLocalToWorldPosition(EntityID(0), C2\x, C2\y, C2\z)
      MoveEntity(2, GetX(), GetY(), GetZ(), #PB_Absolute)
      RotateEntity(2, EntityPitch(0,#PB_Engine3D_Adjusted), EntityYaw(0,#PB_Engine3D_Adjusted), EntityRoll(0,#PB_Engine3D_Adjusted))
      
      CameraLookAt(0, EntityX(0), EntityY(0), EntityZ(0))
      RenderWorld()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End 