
; ------------------------------------------------------------
;
;   PureBasic - NodeAnimation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Try to play with 'Weight' (and look at cylinder with red ribbon)
#Weight = 1 ; try different values btw 0 to 1

Declare AddPath0(No)
Declare AddPath1(No)
Declare AddPath2(No, Weight.f)
Declare AddPath3(No, Weight.f)

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " NodeAnimation - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main"            , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Additive)

;- Ground
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1200, 1200, 1, 1, 5, 5)
CreateEntity(0, MeshID(0), MaterialID(0), 500, 0, -500)

;- Cube
CreateCube(1, 100)
CreateEntity(1, MeshID(1), #PB_Material_None)

;- Sphere
CreateSphere(2, 50, 50, 50)
CreateEntity(2, MeshID(2), #PB_Material_None)

;- Cylinder
CreateCylinder(3, 5, 50)
CreateEntity(3, MeshID(3), #PB_Material_None)

;- Cylinder - check point
CreateCylinder(3, 15, 150)
CreateEntity(4, MeshID(3), #PB_Material_None, 50,  50,   50)
CreateEntity(5, MeshID(3), #PB_Material_None, 50,  50, -950)
CreateEntity(6, MeshID(3), #PB_Material_None, 950, 50, -950)
CreateEntity(7, MeshID(3), #PB_Material_None, 950, 50,   50)
CreateEntity(8, MeshID(3), #PB_Material_None, 450, 50, -450)

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 500, 1500, 1450, #PB_Absolute)
CameraFOV(0, 25)
CameraBackColor(0,$846748)
CameraLookAt(0, 500, 0, -500)

;- Node
;
CreateNode(0)
AttachNodeObject(0, EntityID(1))

;- Light
;
AmbientColor(RGB(25, 25, 25))
CreateLight(0, RGB(215, 190, 40), -750, 750, -750)

;create 3 ribbon trails, just For fun
;
GetScriptMaterial(1, "Examples/LightRibbonTrail")
CreateRibbonEffect(0, MaterialID(1), 1, 80, 1800)
RibbonEffectColor(0, 0, RGBA(255*0.8, 255*0.8, 0, 255), RGBA(1, 255, 255, 5))
RibbonEffectWidth(0, 0, 8, 3)
AttachRibbonEffect(0, EntityParentNode(3))

CreateRibbonEffect(1, MaterialID(1), 1, 80, 1800)
RibbonEffectColor(1, 0, RGBA(0, 255*0.8, 255*0.8, 255), RGBA(0, 255, 0, 5));RGBA(255, 255, 1, 5))
RibbonEffectWidth(1, 0, 8, 3)
AttachRibbonEffect(1, EntityParentNode(2))

CreateRibbonEffect(2, MaterialID(1), 1, 80, 1800)
RibbonEffectColor(2, 0, RGBA(0, 255, 0, 255), RGBA(1, 1, 1, 5))
RibbonEffectWidth(2, 0, 8, 3)
AttachRibbonEffect(2, EntityParentNode(1))

;- NodeAnimation
;
AddPath0(0)
AddPath1(1)

;Test Weight
;
AddPath2(2, #Weight)
AddPath3(3, 1.0 - #Weight)

Repeat
  
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  AddNodeAnimationTime(0, TimeSinceLastFrame * 2)
  AddNodeAnimationTime(1, TimeSinceLastFrame * 2)
  AddNodeAnimationTime(2, TimeSinceLastFrame * 2)
  AddNodeAnimationTime(3, TimeSinceLastFrame * 2)
  
  EntityLookAt(1, 450, EntityY(1), -450)
  
  TimeSinceLastFrame = RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)


Procedure AddPath0(NodeAnimation)
  Duration = 15000
  Time = Duration / 5 ; 5 keyFrame
  CreateNodeAnimation(NodeAnimation, NodeID(0), Duration, #PB_NodeAnimation_Spline, #PB_NodeAnimation_LinearRotation)
  
  ;Animation Cube
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 0.00,  50,  50,   50); key 0
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 1.25, 950,  50,   50); key 1
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 2.50, 950,  50, -950); key 2
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 3.75,  50,  50, -950); key 3
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 5.00,  50,  50,   50); key 4
  
  StartNodeAnimation(NodeAnimation)
EndProcedure


Procedure AddPath1(NodeAnimation)
  Duration = 15000
  Time = Duration / 5 ; 5 keyFrame
  CreateNodeAnimation(NodeAnimation, EntityParentNode(2), Duration, #PB_NodeAnimation_Spline, #PB_NodeAnimation_LinearRotation)
  
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 0.0,  50, 280,   50); key 0
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 1.0,  50,  50, -950); key 1
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 2.0, 950, 280, -950); key 2
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 4.0, 950,  50,   50); key 3
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 4.5, 450,  50, -450); key 4
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 5.0,  50, 280,   50); key 5
  
  StartNodeAnimation(NodeAnimation)
  
EndProcedure


Procedure AddPath2(NodeAnimation, Weight.f)
  Duration = 35000
  Time = Duration / 8
  CreateNodeAnimation(NodeAnimation, EntityParentNode(3), Duration, #PB_NodeAnimation_Spline, #PB_NodeAnimation_LinearRotation)
  
  ;Animation Cylinder
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 0.00, EntityX(4), EntityY(4)      , EntityZ(4))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 1.00, EntityX(8), EntityY(8) + 200, EntityZ(8))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 2.00, EntityX(5), EntityY(5)      , EntityZ(5))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 3.00, EntityX(8), EntityY(8) + 200, EntityZ(8))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 4.00, EntityX(6), EntityY(6)      , EntityZ(6))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 5.00, EntityX(8), EntityY(8) + 200, EntityZ(8))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 6.00, EntityX(7), EntityY(7)      , EntityZ(7))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 7.00, EntityX(8), EntityY(8) + 200, EntityZ(8))
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 8.00, EntityX(4), EntityY(4)      , EntityZ(4))
  
  StartNodeAnimation(NodeAnimation)
  SetNodeAnimationWeight(NodeAnimation, Weight)
EndProcedure

Procedure AddPath3(NodeAnimation, Weight.f)
  Duration = 15000
  Time = Duration / 5 ; 5 keyFrame
  CreateNodeAnimation(NodeAnimation, EntityParentNode(3), Duration, #PB_NodeAnimation_Spline, #PB_NodeAnimation_SphericalRotation)
  
  ;Animation Cylinder
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 0.0,  50,  50,   50); key 0
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 1.0,  50,  50, -950); key 1
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 2.0, 950, 250, -950); key 2
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 4.0, 950,  50,   50); key 3
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 4.5, 450,  50, -450); key 4
  CreateNodeAnimationKeyFrame(NodeAnimation, Time * 5.0,  50,  50,   50); key 5
  
  StartNodeAnimation(NodeAnimation)
  SetNodeAnimationWeight(NodeAnimation, Weight)
EndProcedure
