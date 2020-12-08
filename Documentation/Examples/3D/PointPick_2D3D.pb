;
; ------------------------------------------------------------
;
;   PureBasic - PointPick 2D->3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, Depth = 150

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
    ParticleColorRange  (0, RGB(255, 255, 0), RGB(0, 255, 0))
    
    ParticleEmitterDirection(0, 0, -1, 0)
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 200, #PB_Absolute)
    
    LoadSprite(0, "Data/Textures/Geebee2.bmp")
    TransparentSpriteColor(0, RGB(255, 0, 255))
    
    Repeat
      Screen3DEvents()
                 
      If ExamineMouse()
        Depth + MouseWheel() * 10
        Mx = MouseX()
        My = MouseY()
        
        If PointPick(0, Mx, My)
          MoveParticleEmitter(0, CameraX(0) + PickX() * Depth, 
                                 CameraY(0) + PickY() * Depth,  
                                 CameraZ(0) + PickZ() * Depth, #PB_Absolute) 
        EndIf  
      EndIf
      
      ExamineKeyboard()
    
      RenderWorld()

      DisplayTransparentSprite(0, Mx - SpriteWidth(0)/2, My - SpriteHeight(0)/2)
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End