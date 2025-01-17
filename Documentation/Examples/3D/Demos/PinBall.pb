;
; ------------------------------------------------------------
;
;   PureBasic - PinBall demo
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Macro CreateCadre(x, y, z, sx, sy, sz, m, r, f)
  Cadre = CreateEntity(#PB_Any, MeshID(1), MaterialID(2), x, y, z)
  ScaleEntity(Cadre, sx, sy, sz)
  CreateEntityBody(Cadre, #PB_Entity_BoxBody, m, r, f)
EndMacro

Macro CreateBumper (x, y, z, m, r, f)
  Cylinder = CreateEntity(#PB_Any, MeshID(3), MaterialID(0), x, y, z)
  CreateEntityBody(Cylinder, #PB_Entity_CylinderBody, m, r, f)
EndMacro

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY, Angle = 145

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "PinBall - [LeftShift/LeftControl]  [RightShift/RightControl] [Space]     [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative)
;WorldDebug(#PB_World_DebugBody)

;-Materials
CreateMaterial(0, LoadTexture(0, "Wood.jpg"))
GetScriptMaterial(1, "SphereMap/SphereMappedRustySteel")
GetScriptMaterial(2, "Color/Blue")
GetScriptMaterial(3, "Scene/GroundBlend")

;-Ground
CreatePlane(0, 100, 100, 10, 10, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(3), 0, 0, 0)
EntityRenderMode(0, 0)
CreateEntityBody(0, #PB_Entity_BoxBody, 0, 0, 1)

;-Mesh
CreateCube(1, 1.0)
CreateSphere(2, 1, 30, 30)
CreateCylinder(3, 2, 10)

;-Entity
Sphere = CreateEntity(#PB_Any, MeshID(2), MaterialID(1), 21, 1.01, 20)
CreateEntityBody(Sphere, #PB_Entity_SphereBody, 0.5, 1, 0.5)
EntityLinearFactor(Sphere, 1, 0, 1)

; Cadre
CreateCadre(-22, 2,  25,  6, 4,  1, 0, 0.0, 1) : RotateEntity(Cadre, 0, -30, 0)
CreateCadre( 21, 2, -40, 11, 4,  1, 0, 1.0, 1) : RotateEntity(Cadre, 0, -50, 0)
CreateCadre(-21, 2, -40, 11, 4,  1, 0, 1.0, 1) : RotateEntity(Cadre, 0,  50, 0)
CreateCadre(  0, 2, -45, 50, 4,  1, 0, 1.0, 0)
CreateCadre( 21, 2,  45,  8, 4,  1, 0, 1.0, 0)
CreateCadre(-25, 2,   0,  1, 4, 90, 0, 0.2, 1)
CreateCadre( 25, 2,   0,  1, 4, 90, 0, 0.2, 1)
CreateCadre( 17, 2,   5,  1, 4, 80, 0, 0.2, 1)

; Bumper
CreateBumper( -4, 0,  0, 0, 1.5, 1)
CreateBumper(-15, 0, -8, 0, 1.5, 1)
CreateBumper(  7, 0, -8, 0, 1.5, 1)

; Flipper
FlipL = CreateEntity(#PB_Any, MeshID(1), MaterialID(1), -18, 0.2, 30)
ScaleEntity(FlipL, 14, 1, 2)
CreateEntityBody(FlipL, #PB_Entity_BoxBody, 0.5, 0, 2)
HingeJoint(0, EntityID(FlipL), -7, -0.6, 1, 0, 1, 0, EntityID(0), -18, 0.2, 30, 0, 1, 0)
EnableHingeJointAngularMotor(0, 1, 55, 40)

FlipR = CreateEntity(#PB_Any, MeshID(1), MaterialID(1), 15.5, 0.2, 30)
ScaleEntity(FlipR, 14, 1, 2)
CreateEntityBody(FlipR, #PB_Entity_BoxBody, 0.5, 0, 2)
HingeJoint(1, EntityID(FlipR), 7, -0.6, 1, 0, 1, 0, EntityID(0), 15.5, 0.2, 30, 0, 1, 0)
EnableHingeJointAngularMotor(1, 1, 55, 40)

;-Camera
CreateCamera(0, 0,  0, 100, 100)
MoveCamera(0, 0, 35, 60, #PB_Absolute)
CameraFOV(0, 55)
CameraLookAt(0, 0,  0, 20)

;-Skybox
SkyBox("desert07.jpg")

;-Light
CreateLight(0, RGB(255, 255, 255), 100, 800, -500)
AmbientColor(RGB(20, 20, 20))

Repeat
  While WindowEvent():Wend     
  ExamineMouse()
  
  If ExamineKeyboard()
    If KeyboardPushed(#PB_Key_LeftShift) Or KeyboardPushed(#PB_Key_LeftControl)
      DisableEntityBody(FlipL, 0)
      HingeJointMotorTarget(0, 18, 0.08)
    Else
      HingeJointMotorTarget(0, -18, 0.08)
    EndIf
    
    If KeyboardPushed(#PB_Key_RightShift) Or KeyboardPushed(#PB_Key_RightControl)
      DisableEntityBody(FlipR, 0)
      HingeJointMotorTarget(1, -18, 0.08)
    Else
      HingeJointMotorTarget(1, 18, 0.08)
    EndIf
    
    If KeyboardPushed(#PB_Key_Space)
      ApplyEntityImpulse(Sphere, 0, 0, -3)
    EndIf
    
  EndIf
  
  If EntityZ(Sphere) > 50
    MoveEntity(Sphere, 21, 1.01, 20, #PB_Absolute)
  EndIf
  
  ApplyEntityImpulse(Sphere, 0, 0, 0.1)
  SetEntityAttribute(Sphere, #PB_Entity_MaxVelocity, 100)
  
  RenderWorld(40)
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

End
