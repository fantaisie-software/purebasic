;
; ------------------------------------------------------------
;
;   PureBasic - Third Person
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; A robot moved by the physics engine (walk, turn, strafe, jump and climb stairs),
; with a camera following it.
;

#WalkSpeed   = 250  ; In units per second
#TurnSpeed   = 150  ; In degrees per second
#JumpSpeed   = 330  ; Vertical speed given by a jump, in units per second
#StepSpeed   = 200  ; Vertical speed given to climb a stair step
#Gravity     = -600
#FeetOffsetY = 7.5  ; The bottom of the capsule body is 7.5 units above the body entity origin

#CameraDistance  = 220 ; Horizontal distance between the camera and the robot
#CameraHeight    = 120 ; Camera height above the robot feet
#CameraSmoothing = 8   ; How fast the camera catches up with the robot (per second)

#DynamicGroup = 1 ; Default collision group of the dynamic bodies
#StaticGroup  = 2 ; Default collision group of the static bodies

Enumeration ; Meshes
  #RobotMesh
  #PlaneMesh
  #CubeMesh
EndEnumeration

Enumeration ; Materials
  #GridMaterial
  #DirtMaterial
  #WoodMaterial
  #BlendMaterial
EndEnumeration

Enumeration ; Entities
  #Robot     ; The robot we see
  #RobotBody ; An hidden capsule with the robot size, moved by the physics engine
  #Ground
EndEnumeration


; Returns #True if the robot stands on something.
; The ray starts inside the capsule body, so it doesn't collide with it.
Procedure OnGround()
  Protected x.f = EntityX(#RobotBody)
  Protected z.f = EntityZ(#RobotBody)
  Protected Feet.f = EntityY(#RobotBody) + #FeetOffsetY

  ProcedureReturn Bool(RayCollide(x, Feet + 10, z, x, Feet - 4, z) > -1)
EndProcedure


; Returns #True if there is a stair step in front of the feet, but nothing in front of the waist.
; Only static objects are steps (collision mask #StaticGroup): the robot pushes the dynamic cubes instead of climbing them.
Procedure InFrontOfStep(DirectionX.f, DirectionZ.f)
  Protected x.f = EntityX(#RobotBody)
  Protected z.f = EntityZ(#RobotBody)
  Protected Feet.f = EntityY(#RobotBody) + #FeetOffsetY
  Protected ToX.f = x + DirectionX * 40
  Protected ToZ.f = z + DirectionZ * 40

  If RayCollide(x, Feet + 8, z, ToX, Feet + 8, ToZ, #DynamicGroup, #StaticGroup) > -1 And RayCollide(x, Feet + 45, z, ToX, Feet + 45, ToZ) = -1
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure


Procedure MoveRobot(ElapsedTime.f)
  Protected ForwardX.f, ForwardZ.f, VelocityX.f, VelocityY.f, VelocityZ.f, Turn.f, Moving
  Static Walking

  ; The direction the robot looks to
  ForwardX = EntityDirectionX(#RobotBody)
  ForwardZ = EntityDirectionZ(#RobotBody)

  ; The physics engine moves the body. Its vertical speed is kept, so the gravity still applies.
  VelocityY = GetEntityAttribute(#RobotBody, #PB_Entity_LinearVelocityY)

  If KeyboardPushed(#PB_Key_Up)
    VelocityX = ForwardX * #WalkSpeed
    VelocityZ = ForwardZ * #WalkSpeed
  ElseIf KeyboardPushed(#PB_Key_Down)
    VelocityX = -ForwardX * #WalkSpeed / 2
    VelocityZ = -ForwardZ * #WalkSpeed / 2
  EndIf

  ; Strafe: the left of the robot is (ForwardZ, -ForwardX)
  If KeyboardPushed(#PB_Key_X)
    VelocityX + ForwardZ * #WalkSpeed / 2
    VelocityZ - ForwardX * #WalkSpeed / 2
  ElseIf KeyboardPushed(#PB_Key_C)
    VelocityX - ForwardZ * #WalkSpeed / 2
    VelocityZ + ForwardX * #WalkSpeed / 2
  EndIf

  If KeyboardPushed(#PB_Key_Left)
    Turn = #TurnSpeed * ElapsedTime
  ElseIf KeyboardPushed(#PB_Key_Right)
    Turn = -#TurnSpeed * ElapsedTime
  EndIf

  If OnGround()
    If KeyboardPushed(#PB_Key_Space)
      VelocityY = #JumpSpeed
    ElseIf KeyboardPushed(#PB_Key_Up) And InFrontOfStep(ForwardX, ForwardZ)
      VelocityY = #StepSpeed
    EndIf
  EndIf

  EntityVelocity(#RobotBody, VelocityX, VelocityY, VelocityZ)
  If Turn
    RotateEntity(#RobotBody, 0, Turn, 0, #PB_Relative)
  EndIf

  ; Walk only when moving or turning, else stand idle. The animations are only switched when the state changes,
  ; as starting an animation again restarts it from its first frame.
  Moving = Bool(VelocityX Or VelocityZ Or Turn)
  If Moving <> Walking
    Walking = Moving
    If Walking
      StopEntityAnimation(#Robot, "Idle")
      StartEntityAnimation(#Robot, "Walk")
    Else
      StopEntityAnimation(#Robot, "Walk")
      StartEntityAnimation(#Robot, "Idle")
    EndIf
  EndIf

  ; Put the robot we see on its body. Its mesh origin is at its feet, and it looks along +X instead of -Z, so turn it by 90 degrees.
  MoveEntity(#Robot, EntityX(#RobotBody), EntityY(#RobotBody) + #FeetOffsetY, EntityZ(#RobotBody), #PB_Absolute)
  RotateEntity(#Robot, 0, EntityYaw(#RobotBody) + 90, 0, #PB_Absolute)
EndProcedure


Procedure FollowRobot(ElapsedTime.f)
  ; Smoothly moves the camera behind the robot (the angle 0 is behind the object), then looks at its shoulder
  CameraFollow(0, EntityID(#RobotBody), 0, EntityY(#Robot) + #CameraHeight, #CameraDistance,
               ElapsedTime * #CameraSmoothing, ElapsedTime * #CameraSmoothing, #False)
  CameraLookAt(0, EntityX(#Robot), EntityY(#Robot) + 70, EntityZ(#Robot))
EndProcedure


; The default sleeping thresholds of the physics engine are made for a world in meters. With the units of this world
; (a gravity of 600), a resting body never gets slow enough to sleep: it keeps jittering, which flickers at long range.
; A sleeping body is woken up as soon as something touches it.
Procedure EnableSleeping(Entity)
  SetEntityAttribute(Entity, #PB_Entity_LinearSleeping, 20)
  SetEntityAttribute(Entity, #PB_Entity_AngularSleeping, 1.5)
EndProcedure


; Spiral staircase around (x, z)
Procedure MakeSpiralStair(x.f, z.f, StepCount)
  Protected i, Angle.f, Ent

  For i = 0 To StepCount - 1
    Angle = i * 30
    Ent = CreateEntity(#PB_Any, MeshID(#CubeMesh), MaterialID(#DirtMaterial))
    ScaleEntity(Ent, 130, 7, 48)
    MoveEntity(Ent, x + Cos(Radian(Angle)) * 240, i * 28, z - Sin(Radian(Angle)) * 240, #PB_Absolute)
    RotateEntity(Ent, 0, Angle, 0)
    CreateEntityBody(Ent, #PB_Entity_StaticBody)
  Next
EndProcedure


; Straight stairs going along +Z from (x, z), with a platform at the top and a pyramid of cubes on it
Procedure MakeStair(x.f, z.f, StepCount)
  Protected i, Row, Ent, PlatformY.f, PlatformZ.f

  ; Steps, 11 units high and 48 units deep. They are 38.4 units apart, so they overlap a bit.
  For i = 0 To StepCount - 1
    Ent = CreateEntity(#PB_Any, MeshID(#CubeMesh), MaterialID(#DirtMaterial))
    ScaleEntity(Ent, 130, 11, 48)
    MoveEntity(Ent, x, i * 11, z + i * 38.4, #PB_Absolute)
    CreateEntityBody(Ent, #PB_Entity_StaticBody)
  Next

  ; Platform, starting at the last step
  PlatformY = StepCount * 11
  PlatformZ = z + (StepCount - 1) * 38.4 + 144
  Ent = CreateEntity(#PB_Any, MeshID(#CubeMesh), MaterialID(#DirtMaterial))
  ScaleEntity(Ent, 650, 11, 240)
  MoveEntity(Ent, x, PlatformY, PlatformZ, #PB_Absolute)
  CreateEntityBody(Ent, #PB_Entity_StaticBody)

  ; Pyramid of 20 units dynamic cubes: each row has one cube less, and is shifted by half a cube
  For Row = 0 To 7
    For i = 0 To 7 - Row
      Ent = CreateEntity(#PB_Any, MeshID(#CubeMesh), MaterialID(#BlendMaterial))
      ScaleEntity(Ent, 20, 20, 20)
      MoveEntity(Ent, x - 20 + Row * 10.25 + i * 20.5, PlatformY + 16 + Row * 20.5, PlatformZ, #PB_Absolute)
      CreateEntityBody(Ent, #PB_Entity_BoxBody, 0.5)
      EnableSleeping(Ent)
    Next
  Next
EndProcedure


; Wooden boxes which can be pushed, and static blocks (some are floating: jump on them!)
Procedure AddBoxes()
  Protected i, Ent, x.f, z.f, SizeX.f, SizeY.f, SizeZ.f

  For i = 0 To 100
    If Random(1)
      SizeX = Random(60) + 30
      SizeY = Random(60) + 30
      SizeZ = Random(60) + 30
      Ent = CreateEntity(#PB_Any, MeshID(#CubeMesh), MaterialID(#WoodMaterial), Random(5000) - 2600, 100, Random(5000) - 2500)
      RotateEntity(Ent, 0, Random(360), 0)
      ScaleEntity(Ent, SizeX, SizeY, SizeZ)
      CreateEntityBody(Ent, #PB_Entity_BoxBody, SizeX * SizeY * SizeZ / 7000, 0, 2) ; The mass depends on the volume
      EnableSleeping(Ent)
    Else
      SizeX = Random(60) + 30
      SizeY = Random(160) + 30
      SizeZ = Random(60) + 30

      ; Not too close to the robot start position
      Repeat
        x = Random(5000) - 2500
      Until x < -400 Or x > 400
      Repeat
        z = Random(5000) - 2500
      Until z < -400 Or z > 400

      Ent = CreateEntity(#PB_Any, MeshID(#CubeMesh), MaterialID(#DirtMaterial), x, SizeY / 2 + Random(90), z)
      RotateEntity(Ent, 0, Random(360), 0)
      ScaleEntity(Ent, SizeX, SizeY, SizeZ)
      CreateEntityBody(Ent, #PB_Entity_StaticBody)
    EndIf
  Next
EndProcedure


InitEngine3D()
InitSprite()
InitKeyboard()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Third Person - [Arrows] Move  [X][C] Strafe  [Space] Jump  [F5][F6][F7] Physics debug  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; Stencil shadows: set them before loading or creating meshes. The casters farther than 3000 units are ignored.
WorldShadows(#PB_Shadow_Additive, 3000)

;- Materials
Texture = CreateTexture(#PB_Any, 256, 256) ; A grid tile
StartDrawing(TextureOutput(Texture))
Box(0, 0, 256, 256, RGB(0, 34, 85))
DrawingMode(#PB_2DDrawing_Outlined)
Box(0, 0, 256, 256, RGB(255, 255, 255))
Box(10, 10, 236, 236, RGB(0, 255, 255))
StopDrawing()
CreateMaterial(#GridMaterial, TextureID(Texture))
MaterialFilteringMode(#GridMaterial, #PB_Material_Anisotropic, 8)

CreateMaterial(#DirtMaterial, TextureID(LoadTexture(#PB_Any, "Dirt.jpg")))
CreateMaterial(#WoodMaterial, TextureID(LoadTexture(#PB_Any, "Wood.jpg")))
GetScriptMaterial(#BlendMaterial, "Scene/GroundBlend")

;- Ground
WorldGravity(#Gravity)
CreatePlane(#PlaneMesh, 5000, 5000, 100, 100, 100, 100)
CreateEntity(#Ground, MeshID(#PlaneMesh), MaterialID(#GridMaterial))
EntityRenderMode(#Ground, 0) ; The ground receives the shadows but doesn't cast any
CreateEntityBody(#Ground, #PB_Entity_StaticBody)

;- Robot
LoadMesh(#RobotMesh, "robot.mesh")
CreateEntity(#Robot, MeshID(#RobotMesh), #PB_Material_None)
StartEntityAnimation(#Robot, "Idle") ; MoveRobot() switches to "Walk" when the robot moves

CreateEntity(#RobotBody, MeshID(#RobotMesh), #PB_Material_None, 0, 26, 0)
HideEntity(#RobotBody, #True)
CreateEntityBody(#RobotBody, #PB_Entity_CapsuleBody, 1, 0, 0)
EntityAngularFactor(#RobotBody, 0, 0, 0) ; The robot never tilts, it is only turned with RotateEntity()
RotateEntity(#RobotBody, 0, -90, 0)      ; Look along +X, to the stairs

;- Scenery
CreateCube(#CubeMesh, 1)
AddBoxes()
MakeSpiralStair(120, 120, 15)
MakeStair(360, 220, 15)

; A sun: a directional light, so all the objects cast their shadows in the same direction
CreateLight(0, RGB(190, 190, 180), 0, 0, 0, #PB_Light_Directional)
LightDirection(0, 0.5, -0.8, 0.35)
AmbientColor(RGB(90, 90, 100)) ; The shadows only get the ambient light
Fog(RGB(210, 210, 210), 1, 0, 10000)
SkyBox("desert07.jpg")

;- Camera
CreateCamera(0, 0, 0, 100, 100)
CameraRange(0, 5, 10000) ; A finite range gives enough depth precision to avoid flickering shadows at long range
MoveCamera(0, -3000, 700, 0, #PB_Absolute) ; Starts far away, then flies to the robot

;- Main loop
Define ElapsedTime.f ; Time of the last frame, in seconds

Repeat
  While WindowEvent() : Wend

  ExamineKeyboard()
  If KeyboardReleased(#PB_Key_F5)
    WorldDebug(#PB_World_DebugBody)
  ElseIf KeyboardReleased(#PB_Key_F6)
    WorldDebug(#PB_World_DebugEntity)
  ElseIf KeyboardReleased(#PB_Key_F7)
    WorldDebug(#PB_World_DebugNone)
  EndIf

  MoveRobot(ElapsedTime)
  FollowRobot(ElapsedTime)

  ElapsedTime = RenderWorld() / 1000
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)
