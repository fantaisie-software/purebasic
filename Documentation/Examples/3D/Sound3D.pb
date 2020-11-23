;
; ------------------------------------------------------------
;
;   PureBasic - Sound3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ;- Mesh
    CreateCube(0, 100)
    CreateSphere(1, 50)
    
    ;- Material
    GetScriptMaterial(0, "Color/Blue")
    GetScriptMaterial(1, "Color/Red")
    
    ;- Entity
    CreateEntity(0, MeshID(0), MaterialID(0))
    CreateEntity(1, MeshID(1), MaterialID(1))
        
    ;- Sound3D
    If LoadSound3D(0, "Roar.ogg")
      SoundVolume3D(0, 50)
      SoundRange3D(0, 1, 500)
      PlaySound3D(0, #PB_Sound3D_Loop)
    EndIf  
    
    If LoadSound3D(1, "Siren.ogg")
      SoundVolume3D(1, 50)
      SoundRange3D(1, 1, 500)
      PlaySound3D(1, #PB_Sound3D_Loop)
    EndIf 
    
    ;- Node
    ; Create a node, so we can link the entity and the sound
    CreateNode(0, -400, 0, 0)
      AttachNodeObject(0, SoundID3D(0))
      AttachNodeObject(0, EntityID(0))
      
    ; Create a node, so we can link the entity and the sound
    CreateNode(1, 400, 0, 0)
      AttachNodeObject(1, SoundID3D(1))
      AttachNodeObject(1, EntityID(1))
      
    ;- Camera  
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, -550, 70, 10, #PB_Absolute)
    CameraLookAt(0, NodeX(1), NodeY(1), NodeZ(1)) 
    
    ;- Light
    AmbientColor(0)
    CreateLight(0, RGB(255, 255, 255), 0, 700, 0)
    
    ;- Sky
    SkyBox("desert07.jpg")
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
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
           
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      SoundListenerLocate(CameraX(0), CameraY(0), CameraZ(0)) ; The 'ear' follows the camera
      
      RenderWorld()

      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End