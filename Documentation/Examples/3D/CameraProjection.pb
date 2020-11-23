;
; ------------------------------------------------------------
;
;   PureBasic - CameraProjectionX/Y
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY 

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    LoadTexture(0, "flare.png")
    
    CreateMaterial(0, TextureID(0))
    DisableMaterialLighting(0, 1)
    MaterialBlendingMode   (0, #PB_Material_Add)
    
  
    CreateParticleEmitter(0, 10, 1, 1, 0)
    ParticleMaterial    (0, MaterialID(0))
    ParticleTimeToLive  (0, 0, 3)
    ParticleEmissionRate(0, 80)
    ParticleSize        (0, 8, 8)
    ParticleColorRange  (0, RGB(255, 0, 0), RGB(0, 0, 0))
    
    MoveParticleEmitter(0, -50, 0, 0)
    ParticleEmitterDirection(0, 0, -1, 0)
    
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 200, #PB_Absolute)
    
    LoadSprite(0, #PB_Compiler_Home + "examples/3d/Data/Textures/Geebee2.bmp")
    TransparentSpriteColor(0, RGB(255, 0, 255))
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = MouseDeltaY() * #CameraSpeed * 0.05
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
          
      RotateCamera(0, MouseY, MouseX, RollZ, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      
      x = CameraProjectionX(0, ParticleEmitterX(0), ParticleEmitterY(0), ParticleEmitterZ(0)) - SpriteWidth(0)/2
      y = CameraProjectionY(0, ParticleEmitterX(0), ParticleEmitterY(0), ParticleEmitterZ(0)) - SpriteHeight(0)/2
      DisplayTransparentSprite(0, x, y)
      
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End