;
; ------------------------------------------------------------
;
;   PureBasic - Text3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"


If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/fonts", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    CreateCube(0, 2)
    
    CreateMaterial(0, LoadTexture(0, "Caisse.png"))
    
    CreateEntity(0, MeshID(0), MaterialID(0))
    
    CreateText3D(0, "Hello world")
    Text3DColor(0, RGBA(255, 0, 0, 255))
    Text3DAlignment(0, #PB_Text3D_HorizontallyCentered)
    AttachEntityObject(0, "", Text3DID(0))
    MoveText3D(0, 0, 2, 2)

    RotateEntity(0, 0, -70, 0)
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 10, #PB_Absolute)
    
    Repeat
      Screen3DEvents()
      
      ExamineKeyboard()
      
      RotateEntity(0, 1, 1, 1, #PB_Relative)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End
