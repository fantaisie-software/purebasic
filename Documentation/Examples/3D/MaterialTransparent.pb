;
; ------------------------------------------------------------
;
;   PureBasic - Material Transparent
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, RollZ, Blend, Pas = 0.2 

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
    CreateSphere(1, 5)
    
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    MaterialBlendingMode(0, #PB_Material_AlphaBlend)
    
    CreateEntity(0, MeshID(0), MaterialID(0))  

    SkyBox("stevecube.jpg")
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 90, 80, 150, #PB_Absolute)

    Repeat
      Screen3DEvents()
      
      ExamineKeyboard()
      
      Blend + pas
      If blend >= 255 Or Blend <= 0
        pas = -pas
      EndIf  
      
      SetMaterialColor(0, #PB_Material_DiffuseColor, RGBA(255, 255, 255, Blend))
      
      RotateEntity(0, 0, 0.4, 0, #PB_Relative)
      MoveEntity(0, 0, 0, -1, #PB_Local)
            
      CameraLookAt(0, EntityX(0), EntityY(0), EntityZ(0))
      RenderWorld()

      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End 
