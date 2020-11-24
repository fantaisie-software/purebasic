;
; ------------------------------------------------------------
;
;   PureBasic - Particle
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
    
    Parse3DScripts()
    
    LoadTexture(0, "dirt.jpg")
    CreateMaterial(0, TextureID(0))
    CreatePlane (0,256,256,1,1,8,8):CreateEntity(0, MeshID(0), MaterialID(0),0,0,0)
    
    LoadTexture(1, "smoke.png")
    CreateMaterial(1, TextureID(1))
    DisableMaterialLighting(1, 1)
    MaterialBlendingMode   (1, #PB_Material_AlphaBlend)
    
    LoadTexture(2, "flare.png")
    CreateMaterial(2, TextureID(2))
    DisableMaterialLighting(2, 1)
    MaterialBlendingMode   (2, #PB_Material_Add)
    
    ;-
    CreateParticleEmitter(1, 0, 0, 0, #PB_Particle_Point, 50, 5, 50)
    ParticleMaterial(1, MaterialID(1))
    ParticleSize(1, 5, 5)
    ParticleColorRange(1, RGB(155,0,0), RGB(200,0,0))
    ParticleColorFader(1, -0.5, -0.5, -0.5, -0.5)
    ParticleEmitterDirection(1, 0, 1, 0)
    ParticleTimeToLive  (1, 2,2)
    ParticleVelocity(1, #PB_Particle_Velocity,20)
    ParticleEmitterAngle(1, 45)
    ParticleAcceleration(1, 0.2, 0, 0)
    ParticleEmissionRate(1, 151)
    
    ;-
    CreateParticleEmitter(2, 0, 0, 0, #PB_Particle_Point, -50,0,50)
    ParticleMaterial(2, MaterialID(2))
    ParticleSize (2, 5, 5)
    ParticleColorRange(2, RGB(255,255,0), RGB(0,255,255))
    ParticleEmitterDirection(2, 0, 1, 0)
    ParticleTimeToLive  (2, 2,1)
    ParticleVelocity(2, #PB_Particle_Velocity,80)
    ParticleAcceleration(2, 0, -1, 0)
    ParticleEmissionRate(2, 100)
    
    ;-
    CreateParticleEmitter(3, 256, 256, 130, #PB_Particle_Point, 0,65, 0)
    ParticleMaterial    (3, MaterialID(2))
    ParticleSize        (3, 2, 2)
    ParticleEmitterDirection(3, 0, 1, 0)
    ParticleTimeToLive  (3, 2,4)
    ParticleVelocity(3, #PB_Particle_Velocity,-10)
    ParticleEmissionRate(3, 1000)
    
    ;-
    CreateParticleEmitter(4, 0, 0, 0, #PB_Particle_Point, -50, 5,-50)
    ParticleMaterial(4, MaterialID(1))
    ParticleSize(4, 5, 5)
    ParticleEmissionRate(4, 50)
    ParticleColorRange(4, RGB(0,255,0), RGB(0,0,255))
    ParticleColorFader(4, 1, 2, 2, -1)
    ParticleTimeToLive  (4, 1, 1)
    ParticleVelocity(4, #PB_Particle_Velocity,35)
    ParticleEmitterAngle(4,5)
    ParticleAcceleration(4, -0.5, 0, 0)
    ParticleEmitterDirection(4, 0, 1, 0)
    
    ;-
    CreateParticleEmitter(5, 0, 0, 0, #PB_Particle_Point, -50, 5, -50)
    ParticleMaterial(5, MaterialID(1))
    ParticleSize (5, 4, 4)
    ParticleEmissionRate(5, 100)
    ParticleColorRange(5, RGB(0,0,255), RGB(0,0,200))
    ParticleColorFader(5, -1, -1, -1, -1)
    ParticleTimeToLive (5, 1, 1)
    ParticleVelocity(5, #PB_Particle_Velocity, 30)
    ParticleEmitterAngle(5, 0)
    ParticleEmitterDirection(5, 0, 1, 0)
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 100, 40, 100, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    
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
      
      angle+4
      
      MoveParticleEmitter(5, Sin(Radian(angle))*10, 5, Cos(Radian(angle))*10, #PB_Absolute)
      
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