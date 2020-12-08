;
; ------------------------------------------------------------
;
;   PureBasic - GetScriptMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
    Parse3DScripts()
      
    Red = GetScriptMaterial(#PB_Any, "Color/Red")
    Blue = GetScriptMaterial(#PB_Any, "Color/Blue")
    Yellow = GetScriptMaterial(#PB_Any, "Color/Yellow")
    Green = GetScriptMaterial(#PB_Any, "Color/Green")
    
    CreateSphere(0, 40, 50, 50)
    CreateEntity(0,MeshID(0), MaterialID(Red)   , -60,   0,  0)
    CreateEntity(1,MeshID(0), MaterialID(Blue)  ,  60,   0,  0)
    CreateEntity(2,MeshID(0), MaterialID(Yellow),   0,  60,  0)
    CreateEntity(3,MeshID(0), MaterialID(Green) ,   0, -60,  0)
    
    ; Camera 
    CreateCamera(0, 0, 0, 100, 100)
    CameraBackColor(0, RGB(50, 50, 50))
    MoveCamera(0,0, 100, 300, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    
    ; Light
    CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
    AmbientColor(RGB(50,50,50))
  
    Repeat
      Screen3DEvents()
      
      ExamineKeyboard()
            
      RenderWorld()
      Screen3DStats()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End