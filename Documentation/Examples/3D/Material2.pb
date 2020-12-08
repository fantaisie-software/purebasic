;
; ------------------------------------------------------------
;
;   PureBasic - Material
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY 

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
        
    LoadTexture(0, "grass2.png")
    LoadTexture(1, "wood.jpg")
    LoadTexture(2, "dirt.jpg")
    LoadTexture(3, "spheremap.png")
    
    CreateMaterial(0, TextureID(0)):ScaleMaterial(0,0.25,0.25) : MaterialCullingMode(0,#PB_Material_NoCulling)
    CreateMaterial(1, TextureID(0)):ScaleMaterial(1,0.5,0.5) : MaterialCullingMode(1,#PB_Material_NoCulling)
    CreateMaterial(2, TextureID(1)):AddMaterialLayer(2,TextureID(3),#PB_Material_Add)
    CreateMaterial(3, TextureID(2)):ScaleMaterial(3,0.1,0.1):AddMaterialLayer(3,TextureID(3),#PB_Material_Add)
    
    SetMaterialAttribute(0,#PB_Material_AlphaReject,-160,0)
    SetMaterialAttribute(1,#PB_Material_AlphaReject,128,0)
    SetMaterialAttribute(2,#PB_Material_EnvironmentMap,#PB_Material_PlanarMap,1)
    SetMaterialAttribute(3,#PB_Material_EnvironmentMap,#PB_Material_CurvedMap,1)
    
    CreateSphere(0, 0.75,32,32)
    CreateCube(1, 1)
    CreateTorus(3,0.5,0.2,32,32)
    
    CreateEntity(0, MeshID(0), MaterialID(0),-1.5,0,0)
    CreateEntity(1, MeshID(1), MaterialID(1),1.5,0,0)
    CreateEntity(2, MeshID(1), MaterialID(2),0,0,-1.5)
    CreateEntity(3, MeshID(3), MaterialID(3),0,0,1.5)
    
    CreateLight(0, RGB(255,255,255), 50, 50, 50)
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 5, 10, 5)
    CameraLookAt(0, 0, 0, 0)
    CameraBackColor(0, RGB(20,20,20))
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.5
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.5
      EndIf  
      
      If ExamineKeyboard()
        
        
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
            
      RotateEntity(0,0.1,0.3,0.2,#PB_Relative)
      RotateEntity(1,0.1,0.3,0.2,#PB_Relative)
      RotateEntity(2,0.1,0.3,0.2,#PB_Relative)
      RotateEntity(3,0.1,0.3,0.2,#PB_Relative)
      
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



