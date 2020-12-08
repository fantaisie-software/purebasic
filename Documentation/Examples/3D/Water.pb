;
; ------------------------------------------------------------
;
;   PureBasic - Water
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
  
  For k = 0 To 0
    
    If Screen3DRequester()
      
      Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
      Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
      Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Water", #PB_3DArchive_FileSystem)
      Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
      Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
      Parse3DScripts()
      
      WorldShadows(#PB_Shadow_TextureAdditive)
      
      SkyBox("desert07.jpg")
      Fog(RGB(128,128,128), 10, 10, 10000)
      
      GetScriptMaterial(0, "Color/Red")
      
      CreateSphere(0, 10)
      
      For i=0 To 9
        CreateEntity(i, MeshID(0), MaterialID(0), i * 40, 0, i * 40)
      Next

      CreateCamera(0,0,0,100,100)
      MoveCamera(0, 0, 30 , 140, #PB_Absolute)
      
      CameraLookAt(0, 4 * 30, 0, 40)
      
      ;-Water
      CreateWater(0, 0, -15, 0, 0, #PB_World_WaterLowQuality | #PB_World_WaterCaustics | #PB_World_WaterSmooth | #PB_World_WaterFoam | #PB_World_WaterGodRays)
      Sun(10000, 1000, 6000, RGB(238, 173, 148))
      
      ;-Light
      CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
      AmbientColor(RGB(50,50,50))
      
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
        
        For i=0 To 9
          MoveEntity(i, EntityX(i), WaterHeight(0, EntityX(i), EntityZ(i)), EntityZ(i), #PB_Absolute)
        Next 
        
        RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
        MoveCamera  (0, KeyX, 0, KeyY)
        
        RenderWorld()
        
        FlipBuffers()
      Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
      
    EndIf
    
  Next
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End