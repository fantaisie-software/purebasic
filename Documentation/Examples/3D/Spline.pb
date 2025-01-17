
; ------------------------------------------------------------
;
;   PureBasic - Spline
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;An example of using SimpleSpline To make an Entity smoothly
;follow a predefined path With spline interpolation.



Define.f Time, TimeN, pas = 1, x, y, z, TimeSinceLastFrame

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Spline - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main"            , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, 0, RGB(175, 175, 175))


;- Ground
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1200, 1200, 1, 1, 5, 5)
CreateEntity(0, MeshID(0), MaterialID(0), 500, 0, -500)

;- Cylinder - check point
CreateCylinder(3, 10, 100)
CreateEntity(4, MeshID(3), #PB_Material_None, 50,  0,   50)
CreateEntity(5, MeshID(3), #PB_Material_None, 50,  0, -950)
CreateEntity(6, MeshID(3), #PB_Material_None, 950, 0, -950)
CreateEntity(7, MeshID(3), #PB_Material_None, 950, 0,   50)
CreateEntity(8, MeshID(3), #PB_Material_None, 450, 0, -450)

;- Robot
;
LoadMesh(1, "robot.mesh")
CreateEntity(1, MeshID(1), #PB_Material_None, 0, 0, 0)
ScaleEntity(1, 3, 3, 3)
StartEntityAnimation(1, "Walk")

;- Ninja
;
LoadMesh(2, "ninja.mesh")
CreateEntity(2, MeshID(2), #PB_Material_None, 500, 0, 400)
ScaleEntity(2, 1.4, 1.4, 1.4)
StartEntityAnimation(2, "Walk", #PB_EntityAnimation_Manual)

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 500, 1500, 1450, #PB_Absolute)
CameraFOV(0, 28)
CameraBackColor(0,$846748)
CameraLookAt(0, 500, 0, -500)

;- Light
;
AmbientColor(RGB(25, 25, 25))
CreateLight(0, RGB(255,255,255), 750, 750, 750)

;- Spline Robot
;
spline = CreateSpline(#PB_Any)
AddSplinePoint(spline, EntityX(4), 0, EntityZ(4))
AddSplinePoint(spline, EntityX(8), 0, EntityZ(8))
AddSplinePoint(spline, EntityX(5), 0, EntityZ(5))
AddSplinePoint(spline, EntityX(6), 0, EntityZ(6))
AddSplinePoint(spline, EntityX(8), 0, EntityZ(8))
AddSplinePoint(spline, EntityX(7), 0, EntityZ(7))
AddSplinePoint(spline, EntityX(4), 0, EntityZ(4))

;- Spline Ninja
;
splineN = CreateSpline(#PB_Any)
AddSplinePoint(splineN, EntityX(2), EntityY(2), EntityZ(2))
AddSplinePoint(splineN, EntityX(1), EntityY(1), EntityZ(1))

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  ; Robot
  ComputeSpline(spline, time) ; Should be called before using SplineX(); SplineY() and SplineZ()
  x = SplineX(spline)
  y = SplineY(spline)
  z = SplineZ(spline)
  
  EntityLookAt(1, x, EntityY(1), z, 1, 0, 0)
  MoveEntity(1, x, y, z, #PB_Absolute)
  
  time + pas * TimeSinceLastFrame / 35
  
  If time > 1
    Time = 0
  EndIf
  
  ; Ninja
  ComputeSpline(splineN, TimeSinceLastFrame/2) ; Should be called before using SplineX(); SplineY() and SplineZ()
  x = SplineX(splineN)
  y = SplineY(splineN)
  z = SplineZ(splineN)
  
  EntityLookAt(2, x, EntityY(2), z)
  MoveEntity(2, x, y, z, #PB_Absolute)
  AddEntityAnimationTime(2, "Walk", TimeSinceLastFrame*1000 / 2)
  
  UpdateSplinePoint(splineN, 0, EntityX(2), EntityY(2), EntityZ(2))
  UpdateSplinePoint(splineN, 1, EntityX(1), EntityY(1), EntityZ(1))
  
  TimeSinceLastFrame = RenderWorld() / 1000
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)

