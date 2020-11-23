;
; ------------------------------------------------------------
;
;   PureBasic - Particle
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; [F5] = Enable/Disable ParticleEmitter 0
; [F6] = SpeedFactor + for ParticleEmitter 1
; [F7] = SpeedFactor - for ParticleEmitter 1

#CameraSpeed = 1
#MaxSpeedFactor = 10
#MinSpeedFactor = 0

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, speedFactor = 1.0, percent = 0.01

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
      ParticleTimeToLive  (0, 2, 2)
      ParticleEmissionRate(0, 20)
      ParticleSize        (0, 30, 30)
      ParticleColorRange  (0, RGB(255,0,0), RGB(255, 0, 255))

    CreateParticleEmitter(1, 10, 1, 1, 0)
      ParticleMaterial    (1, MaterialID(0))
      ParticleTimeToLive  (1, 2, 2)
      ParticleEmissionRate(1, 20)
      ParticleSize        (1, 30, 30)
      ParticleColorRange  (1, RGB(255, 255, 0), RGB(0, 255, 0))

    MoveParticleEmitter(1, -50, 0, 0)
  
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 100, #PB_Absolute)
          
    Repeat
      Screen3DEvents()
        
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf  
      
      If ExamineKeyboard()
        
        If KeyboardReleased(#PB_Key_F5)
          Disable = 1 - Disable
          DisableParticleEmitter(0, Disable)
        EndIf
        
        If KeyboardPushed(#PB_Key_F6) 
          speedFactor = speedFactor + percent * (#MaxSpeedFactor - speedFactor)
          ParticleSpeedFactor(1, speedFactor)
        EndIf
        
        If KeyboardPushed(#PB_Key_F7) 
          speedFactor = speedFactor + percent * (#MinSpeedFactor - speedFactor)
          ParticleSpeedFactor(1, speedFactor)
        EndIf
    
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
    
      RenderWorld()
      Screen3DStats()

      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf
  
End