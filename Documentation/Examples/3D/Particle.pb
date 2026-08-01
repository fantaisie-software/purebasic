
; ------------------------------------------------------------
;
;   PureBasic - Particle
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1



Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Particle - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

Parse3DScripts()

CreateCamera(0, 0, 0, 100, 100)
CameraBackColor(0,$884444)

; ground
LoadTexture(0, "Dirt.jpg")
CreateMaterial(0, TextureID(0))
CreatePlane (0,1000,1000,1,1,32,32)
CreateEntity(0, MeshID(0), MaterialID(0),0,0,0)

LoadTexture(1, "smoke2.png")
CreateMaterial(1, TextureID(1))
DisableMaterialLighting(1, 1)
MaterialBlendingMode   (1, #PB_Material_AlphaBlend)
SetMaterialAttribute(1,#PB_Material_TAM,#PB_Material_ClampTAM)

LoadTexture(2, "flare.png")
CreateMaterial(2, TextureID(2))
DisableMaterialLighting(2, 1)
MaterialBlendingMode   (2, #PB_Material_Add)

LoadTexture(3, "flaretrail.png")
CreateMaterial(3, TextureID(3))
DisableMaterialLighting(3, 1)
MaterialBlendingMode   (3, #PB_Material_Add)
SetMaterialAttribute(3,#PB_Material_TAM,#PB_Material_ClampTAM)

LoadTexture(4, "water.png")
CreateMaterial(4, TextureID(4))
DisableMaterialLighting(4, 1)
MaterialBlendingMode   (4, #PB_Material_AlphaBlend)
SetMaterialAttribute(4,#PB_Material_TAM,#PB_Material_ClampTAM)


; Fire
;
CreateParticleEmitter(1, 0, 0, 0, 0,50,5,50)
ParticleMaterial    (1, MaterialID(1))
ParticleSize        (1, 3,3)
ParticleColorRange(1, $00ffff, $0000ff)
ParticleColorFader(1, -1, -1, -1, -0.5)
ParticleEmitterDirection(1, 0, 1, 0)
ParticleEmitterAngle(1,30)
ParticleTimeToLive  (1, 2,2)
ParticleVelocity(1, 2,20)
ParticleAcceleration(1, 0.2, 0, 0)
ParticleScaleRate(1,5)
ParticleAngle(1,-180,180,-90,90)
ParticleEmissionRate(1, 50)


; Water fall
;
CreateParticleEmitter(2, 0, 0, 0, 0, -50,0,50)
ParticleMaterial    (2, MaterialID(4))
ParticleSize        (2, 1,1):ParticleScaleRate(2,5)
ParticleColorFader(2, 0, 0, 0, -0.4)
ParticleEmitterDirection(2, 0, 1, 0)
ParticleTimeToLive  (2, 2,2)
ParticleVelocity(2, 2,100)
ParticleAcceleration(2, 0, -1, 0)
ParticleEmitterAngle(2,5)
ParticleAngle(2,-180,180,-180,180)
ParticleEmissionRate(2, 100)


; Snow
;
CreateParticleEmitter(3, 50, 50, 0, 0, 50,40,-50)
ParticleMaterial    (3, MaterialID(2))
ParticleSize        (3, 2, 2)
ParticleEmitterDirection(3, 0, 1, 0)
ParticleTimeToLive  (3, 4,4)
ParticleVelocity(3, 2,-10)
ParticleEmissionRate(3, 50)


; FireWorks
;
CreateParticleEmitter(4, 0, 0, 0, 0, -50,5,-50)
ParticleMaterial    (4, MaterialID(3))
ParticleSize        (4, 10,10)
ParticleColorRange(4, $ff0088, $0088ff)
ParticleEmitterDirection(4, 0, 1, 0)
ParticleEmitterAngle(4,30)
ParticleTimeToLive  (4, 1.5,1.5)
ParticleVelocity(4, 2,80)
ParticleAcceleration(4, 0, -1, 0)
ParticleAngle(4,0,0,0,360)
ParticleEmissionRate(4, 100)


; Multicolor torch
;
CreateParticleEmitter(5, 0, 0, 0, 0, 0,0,0)
ParticleMaterial    (5, MaterialID(1))
ParticleSize        (5, 1,1)
ParticleEmissionRate(5, 25)
ParticleColorRange(5, $00ff00, $ffff00)
ParticleColorFader(5, 0.5, 0, 0, -0.5)
ParticleTimeToLive  (5, 2, 2)
ParticleVelocity(5, 2,30)
ParticleEmitterAngle(5,5)
ParticleScaleRate(5,8)
ParticleAngle(5,-180,180,-90,90)
ParticleEmitterDirection(5, 0, 1, 0)


; Red circle
;
CreateParticleEmitter(6, 0, 0, 0, 0, 0,0,0)
ParticleMaterial    (6, MaterialID(2))
ParticleSize        (6, 4,4)
ParticleEmissionRate(6, 40)
ParticleColorRange(6, $0000ff, $0000ff)
ParticleScaleRate(6,-2)
ParticleTimeToLive  (6, 2, 2)
ParticleVelocity(6, 2,0)

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  a.f+0.005
  MoveCamera(0,Cos(a)*120,30,Sin(a)*120,#PB_Absolute)
  ParticleEmitterDirection(5, Sin(a*5), 1, Cos(a*5))
  MoveParticleEmitter(6, Sin(a*5)*20, 2, Cos(a*5)*20,#PB_Absolute)
  CameraLookAt(0,0,0,0)
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1


