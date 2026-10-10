
; ------------------------------------------------------------
;
;   PureBasic - Terrain : Physic
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; A robot moved by the physics engine on a terrain, with a camera following it.
;
;   [Up][Down]       Walk forward or backward
;   [Left][Right]    Turn
;   [X][C]           Strafe
;   [Space]          Jump
;   [F5][F6][F7]     Physics debug
;

#TerrainMiniX = 0
#TerrainMiniY = 0
#TerrainMaxiX = 0
#TerrainMaxiY = 0

#WalkSpeed   = 250  ; In units per second
#TurnSpeed   = 150  ; In degrees per second
#JumpSpeed   = 330  ; Vertical speed given by a jump, in units per second
#Gravity     = -600
#FeetOffsetY = 7.5  ; The bottom of the capsule body is 7.5 units above the body entity origin

#CameraDistance  = 220 ; Horizontal distance between the camera and the robot
#CameraHeight    = 120 ; Camera height above the robot feet
#CameraSmoothing = 8   ; How fast the camera catches up with the robot (per second)

Enumeration ; Entities
  #Robot     ; The robot we see
  #RobotBody ; An hidden capsule with the robot size, moved by the physics engine
EndEnumeration

Declare InitBlendMaps()


; Returns #True if the robot stands on something.
; The ray starts inside the capsule body, so it doesn't collide with it.
Procedure OnGround()
  Protected x.f = EntityX(#RobotBody)
  Protected z.f = EntityZ(#RobotBody)
  Protected Feet.f = EntityY(#RobotBody) + #FeetOffsetY

  ProcedureReturn Bool(RayCollide(x, Feet + 10, z, x, Feet - 4, z) > -1)
EndProcedure


Procedure MoveRobot(ElapsedTime.f)
  Protected ForwardX.f, ForwardZ.f, VelocityX.f, VelocityY.f, VelocityZ.f, Turn.f

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

  If KeyboardPushed(#PB_Key_Space) And OnGround()
    VelocityY = #JumpSpeed
  EndIf

  EntityVelocity(#RobotBody, VelocityX, VelocityY, VelocityZ)
  If Turn
    RotateEntity(#RobotBody, 0, Turn, 0, #PB_Relative)
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


InitEngine3D()

InitSprite()
InitKeyboard()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Terrain : Physic - [Arrows] Move  [X][C] Strafe  [Space] Jump  [F5][F6][F7] Physics debug  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/"       , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia" , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, #PB_Default, RGB(120, 120, 120))
WorldGravity(#Gravity)

MaterialFilteringMode(#PB_Default, #PB_Material_Anisotropic, 8)

;- Light
;
light = CreateLight(#PB_Any ,RGB(185, 185, 185), 4000, 1200, 1000, #PB_Light_Directional)
SetLightColor(light, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4))
LightDirection(light ,0.55, -0.3, -0.75)
AmbientColor(RGB(5, 5,5))

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
CameraBackColor(0, RGB(5, 5, 10))
MoveCamera(0, -3000, 700, 0, #PB_Absolute) ; Starts far away, then flies to the robot

;----------------------------------
;-terrain definition
SetupTerrains(LightID(Light), 3000, #PB_Terrain_NormalMapping)
;-initialize terrain
CreateTerrain(0, 513, 12000, 600, 3, "TerrainPhysic", "dat")
;-set all texture will be use when terrrain will be constructed
AddTerrainTexture(0,  0, 100, "dirt_grayrocky_diffusespecular.jpg",  "dirt_grayrocky_normalheight.jpg")
AddTerrainTexture(0,  1,  30, "grass_green-01_diffusespecular.jpg", "grass_green-01_normalheight.jpg")
AddTerrainTexture(0,  2, 200, "growth_weirdfungus-03_diffusespecular.jpg", "growth_weirdfungus-03_normalheight.jpg")

;-Construct terrains
For ty = #TerrainMiniY To #TerrainMaxiY
  For tx = #TerrainMiniX To #TerrainMaxiX
    Imported = DefineTerrainTile(0, tx, ty, "terrain513.png", ty % 2, tx % 2)
  Next
Next
BuildTerrain(0)

If Imported = #True
  InitBlendMaps()
  UpdateTerrain(0)

  ; If enabled, it will save the terrain as a (big) cache for a faster load next time the program is executed
  ; SaveTerrain(0, #False)
EndIf

; enable shadow terrain
TerrainRenderMode(0, 0)

;Add Physic Body
CreateTerrainBody(0, 0.1, 1)

;- Robot
LoadMesh(0, "robot.mesh")
CreateEntity(#Robot, MeshID(0), #PB_Material_None)
StartEntityAnimation(#Robot, "Walk")

CreateEntity(#RobotBody, MeshID(0), #PB_Material_None, 0, 426, 0)
HideEntity(#RobotBody, #True)
CreateEntityBody(#RobotBody, #PB_Entity_CapsuleBody, 1, 0, 0)
EntityAngularFactor(#RobotBody, 0, 0, 0) ; The robot never tilts, it is only turned with RotateEntity()
RotateEntity(#RobotBody, 0, -90, 0)      ; Look along +X

; Skybox
SkyBox("desert07.jpg")

;==================================
; create material
Red = GetScriptMaterial(#PB_Any, "Color/Red")
Blue = GetScriptMaterial(#PB_Any, "Color/Blue")
Yellow = GetScriptMaterial(#PB_Any, "Color/Yellow")
Green = GetScriptMaterial(#PB_Any, "Color/Green")

;==================================
; create Sphere
MeshSphere = CreateSphere(#PB_Any, 10.0)
For i = 0 To 5
  Entity=CreateEntity(#PB_Any, MeshID(MeshSphere), MaterialID(Green))
  MoveEntity(Entity, Random(2000)-1000, 800, Random(4000)-2000, #PB_Absolute)
  ; create bodies
  CreateEntityBody(Entity, #PB_Entity_SphereBody, 5.0)
Next

;==================================
; create Cylinder
MeshCylinder = CreateCylinder(#PB_Any, 10.0, 60)
For i = 0 To 5
  Entity=CreateEntity(#PB_Any, MeshID(MeshCylinder), MaterialID(Red))
  MoveEntity(Entity, Random(2000)-1000, 800, Random(4000)-2000, #PB_Absolute)
  ; create bodies
  CreateEntityBody(Entity, #PB_Entity_CylinderBody, 10.0, 0, 1)
Next

;==================================
; create Cube
MeshCube = CreateCube(#PB_Any, 25.0)
For i = 0 To 5
  Entity=CreateEntity(#PB_Any, MeshID(MeshCube), MaterialID(Yellow))
  MoveEntity(Entity, Random(2000)-1000, 800, Random(4000)-2000, #PB_Absolute)
  ; create bodies
  CreateEntityBody(Entity, #PB_Entity_BoxBody, 5.0)
Next

;- Main loop
Define ElapsedTime.f ; Time of the last frame, in seconds

Repeat
  While WindowEvent():Wend

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

End

Procedure Clamp(*var.float, min.f, max.f)
  If *var\f < min
    *var\f = min
  ElseIf *var\f > max
    *var\f = max
  EndIf
EndProcedure

Procedure InitBlendMaps()
  minHeight1.f = 70
  fadeDist1.f = 40
  minHeight2.f = 70
  fadeDist2.f = 15
  For ty = #TerrainMiniY To #TerrainMaxiY
    For tx = #TerrainMiniX To #TerrainMaxiX
      Size = TerrainTileLayerMapSize(0, tx, ty)
      For y = 0 To Size-1
        For x = 0 To Size-1
          Height.f = TerrainTileHeightAtPosition(0, tx, ty, 1, x, y)

          val.f = (Height - minHeight1) / fadeDist1
          Clamp(@val, 0, 1)
          SetTerrainTileLayerBlend(0, tx, ty, 1, x, y, val)

          val.f = (Height - minHeight2) / fadeDist2
          Clamp(@val, 0, 1)
          SetTerrainTileLayerBlend(0, tx, ty, 2, x, y, val)
        Next
      Next
      UpdateTerrainTileLayerBlend(0, tx, ty, 1)
      UpdateTerrainTileLayerBlend(0, tx, ty, 2)
    Next
  Next
EndProcedure
