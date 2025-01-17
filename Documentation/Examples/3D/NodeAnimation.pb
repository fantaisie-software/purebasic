
; ------------------------------------------------------------
;
;   PureBasic - NodeAnimation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;An example of using AnimationTracks To make a node smoothly
;follow a predefined path With spline interpolation.

Declare AddPath(NodeAnimation)
Define.f Duration = 10000, Time = Duration / 4

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " NodeAnimation - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data"                , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

;- Barrel
CreateEntity(1, LoadMesh(1, "Barrel.mesh"), #PB_Material_None)
ScaleEntity(1, 9, 9, 9)

;- Camera
CreateCamera(0, 0, 0, 100, 100)

;- Node
CreateNode(0)
AttachNodeObject(0, CameraID(0))

;- Light
AmbientColor(RGB(75, 75, 75))
CreateLight(0, RGB(235, 253, 126), -750, 750, -750)

;- SkyBox
SkyBox("desert07.jpg")

;- NodeAnimation
NodeAnimation = CreateNodeAnimation(#PB_Any, NodeID(0), Duration, #PB_NodeAnimation_Spline, #PB_NodeAnimation_LinearRotation)

CreateNodeAnimationKeyFrame(NodeAnimation, Time * 0,  200,   0,    0); key 0
CreateNodeAnimationKeyFrame(NodeAnimation, Time * 1,    0, -50,  100); key 1
CreateNodeAnimationKeyFrame(NodeAnimation, Time * 2, -500, 100,    0); key 2
CreateNodeAnimationKeyFrame(NodeAnimation, Time * 3,    0, 200, -300); key 3
CreateNodeAnimationKeyFrame(NodeAnimation, Time * 4,  200,   0,    0); key 4

StartNodeAnimation(NodeAnimation)

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  AddNodeAnimationTime(NodeAnimation, TimeSinceLastFrame)
  CameraLookAt(0, EntityX(1), EntityY(1), EntityZ(1))
  
  TimeSinceLastFrame = RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)

