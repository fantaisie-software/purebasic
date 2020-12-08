;
; ------------------------------------------------------------
;
;   PureBasic - SaveTexture
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    WorldShadows(#PB_Shadow_Modulative, -1, RGB(175, 175, 175))
    
    ;Ground
    ;
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
    CreateEntity(0,MeshID(0),MaterialID(0))
    EntityRenderMode(0, 0)
    
    ;Mesh
    ;
    LoadMesh(1, "robot.mesh")
    
    ; Entity
    ;
    CreateEntity(1, MeshID(1), #PB_Material_None)
    
    ; Animation
    ;
    
    StartEntityAnimation(1, "Walk")
    
    ; SkyBox
    ;
    SkyBox("desert07.jpg")
    
    ; Camera
    ;
    
    CreateCamera(1, 0, 0, 100, 100)
    MoveCamera(1, -100, 120, 190, #PB_Absolute)
    CameraLookAt(1, EntityX(1), EntityY(1), EntityZ(1))
    
    ;SaveScreen
    ;
    CreateRenderTexture(1, CameraID(1), CameraViewWidth(1), CameraViewHeight(1), #PB_Texture_CameraViewPort)
    CreateMaterial(1, TextureID(1))
    
    ; Light
    ;
    CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
    AmbientColor(RGB(80, 80, 80))
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX()/10 
        MouseY = -MouseDeltaY()/10
      EndIf
            
      If ExamineKeyboard()
        
        If KeyboardReleased(#PB_Key_F5)
          No + 1
          SaveRenderTexture(1, "test" + Str(No) + ".png")    
        EndIf
        
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -2
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = 2
        Else
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -2
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = 2
        Else
          KeyY = 0
        EndIf
                
      EndIf
           
      RotateEntity(1, 0, 1, 0, #PB_Relative)
      
      RotateCamera(1, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (1, KeyX, 0, KeyY)
    
      RenderWorld()
            
      FlipBuffers()
      
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End