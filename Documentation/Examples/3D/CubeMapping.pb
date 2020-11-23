;
; ------------------------------------------------------------
;
;   PureBasic - CubeMapping
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
  
    Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    MoveCamera(Camera, 100, 100, 100, #PB_Absolute)
    CameraLookAt(Camera,0,50,0)
    
    CubeMapTexture = CreateCubeMapTexture(#PB_Any, 256, 256, "CubeMapTexture") ; Should be the same name than in 'CubeMap.material' file
    GetScriptMaterial(1,"CubeMapMaterial") ; Should be the same name than in 'CubeMap.material' file
    SetMaterialColor(1, #PB_Material_SelfIlluminationColor, $FFFFFF)
  
    Mesh = LoadMesh(#PB_Any,"robot.mesh")
    Entity = CreateEntity(#PB_Any, MeshID(Mesh), MaterialID(1))
    
    EntityCubeMapTexture(CubeMapTexture, Entity)
    
    SkyBox("Desert07.jpg")
    
    Repeat
      Screen3DEvents()
      
      
      RotateEntity(Entity, 0, 1 , 0, #PB_Relative)
      
      RenderWorld()
      FlipBuffers()
      
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
  
EndIf