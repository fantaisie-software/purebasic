
; ------------------------------------------------------------
;
;   PureBasic - AttachEntityObject
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;[Space] = DetachObject
;[RETURN] = AttachObject



Define.f KeyX, KeyY, MouseX, MouseY, Speed = 1.0
Define.i RobotMove

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "AttachEntityObject -  [Space]   [Return]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data"                 , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Particles"       , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; First create our material
;
CreateMaterial(10, LoadTexture(10, "PureBasic.bmp"))
SetMaterialColor(10, #PB_Material_SelfIlluminationColor, RGB(165, 165, 165))

; Then create the billboard group and use the previous material
;
CreateBillboardGroup(0, MaterialID(10), 40, 10)
AddBillboard(0, 0, 0, 0)

GetScriptMaterial(1, "Color/Red")
GetScriptMaterial(2, "Color/Green")
CreateMaterial(3, LoadTexture(3, "r2skin.jpg"))
SetMaterialColor(3, #PB_Material_SelfIlluminationColor, RGB(75, 75, 75))

; Particle
;
GetScriptParticleEmitter(0, "Examples/PurpleFountain")
Jet = GetScriptParticleEmitter(#PB_Any, "Examples/JetEngine1")

;Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 700, 700, 70, 70, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)

;Mesh
;
LoadMesh(1, "robot.mesh")
CreateSphere(2, 10)

; Entity
;
CreateEntity(1, MeshID(1), MaterialID(3))
CreateEntity(2, MeshID(2), MaterialID(1))
CreateEntity(3, MeshID(2), MaterialID(2))

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 120, 400, #PB_Absolute)
CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))

; Light
;
AmbientColor(RGB(0, 0, 0))

CreateLight(0, RGB(255, 255, 155))
SetLightColor(0, #PB_Light_SpecularColor, RGB(255, 255, 255))
LightAttenuation(0, 400, 0.1)

CreateLight(1, RGB(255, 255, 155))
SetLightColor(1, #PB_Light_SpecularColor, RGB(255, 255, 255))
LightAttenuation(1, 400, 0.1)

; Attach objects
;
AttachEntityObject(1, "Joint18", EntityID(2), 10, -8, -5, 0, 0, 0)
AttachEntityObject(1, "Joint15", EntityID(3), 10, -8, 0, 0, 0, 0)
AttachEntityObject(1, "Joint15", ParticleEmitterID(0), 15, 0, 0, 0, 0, 45)
AttachEntityObject(1, "Joint18", ParticleEmitterID(Jet), 15, -12, -5, 0, 0, -90)
AttachEntityObject(1, "Joint1" , BillboardGroupID(0), 0, 50, 0, 0, 0, 0)
AttachEntityObject(1, "Joint18", LightID(0), 10, -35, 20, 0, 0, 0)
AttachEntityObject(1, "Joint15", LightID(1), 10, -35, -20, 0, 0, 0)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX()/10
    MouseY = -MouseDeltaY()/10
  EndIf
  
  RobotMove = #False
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_Space)
      DetachEntityObject(1, EntityID(2))
      DetachEntityObject(1, BillboardGroupID(0))
      DetachEntityObject(1, LightID(1))
      DetachEntityObject(1, ParticleEmitterID(Jet))
    EndIf
    
    If KeyboardReleased(#PB_Key_Return)
      AttachEntityObject(1, "Joint18", EntityID(2), 10, -8, -5, 0, 0, 0)
      AttachEntityObject(1, "Joint1", BillboardGroupID(0), 0, 60, 0, 0, 0, 0)
      AttachEntityObject(1, "Joint15", LightID(1), 0, -35, 0, 0, 0, 0)
      AttachEntityObject(1, "Joint18", ParticleEmitterID(Jet), 15, -12, -5, 0, 0, -90)
    EndIf
    
    If KeyboardPushed(#PB_Key_Left)
      MoveEntity(1, -1 * Speed, 0, 0)
      RotateEntity(1, 0, 180, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Right)
      MoveEntity(1, 1 * Speed, 0, 0)
      RotateEntity(1, 0, 0, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Up)
      MoveEntity(1, 0, 0, -1 * Speed)
      RotateEntity(1, 0, 90, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Down)
      MoveEntity(1, 0, 0, 1 * Speed)
      RotateEntity(1, 0, -90, 0)
      RobotMove = #True
    EndIf
    
  EndIf
  
  If RobotMove
    If EntityAnimationStatus(1, "Walk") = #PB_EntityAnimation_Stopped ; Loop
      StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual)     ; Start the animation from the beginning
    EndIf
  Else
    StopEntityAnimation(1, "Walk")
  EndIf
  
  AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame)
  
  CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
  
  TimeSinceLastFrame = RenderWorld() * Speed
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

