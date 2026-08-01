
; ------------------------------------------------------------
;
;   PureBasic - Ribbon
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



Define yaw.f, X.f, Y.f, Z.f, FOV.f, Timer.i

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Ribbon - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; Ground
;
GetScriptMaterial(0, "Scene/GroundBlend")
CreatePlane(0, 10000, 10000, 100, 100, 50, 50)
CreateEntity(0, MeshID(0), MaterialID(0))

; Node for Ribbon and Billboard
;
CreateNode(0, 0, 500, 0)

;Ribbon
;
GetScriptMaterial(1, "Scene/RibbonTrail")
CreateRibbonEffect(0, MaterialID(1), 1, 80, 1750)
RibbonEffectColor(0, 0, RGBA(255, 255, 255, 255), RGBA(0, 0, 255, 255))
RibbonEffectWidth(0, 0, 50, 3)
AttachRibbonEffect(0, NodeID(0))

; Billboard
;
GetScriptMaterial(2, "Scene/burst")
CreateBillboardGroup(0, MaterialID(2), 512, 512)
AddBillboard(0, 0, 0, 0)

AttachNodeObject(0, BillboardGroupID(bGrp))

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 2000, 100, 2000, #PB_Absolute)
CameraLookAt(0, 0, 1500, 0)
CameraFOV(0, 60)

; Skybox
;
SkyBox("desert07.jpg")

Repeat
  While WindowEvent():Wend
  ExamineKeyboard()
  
  If Timer < ElapsedMilliseconds()
    Timer = ElapsedMilliseconds() + 5
    yaw + 0.1
  EndIf
  
  ;Ribbon
  X = 1000 + 500 * Cos(ElapsedMilliseconds() / 250)
  Y = 1500 + 750 * Cos(ElapsedMilliseconds() / 350)
  Z = 500  + 250 * Cos(ElapsedMilliseconds() / 750)
  MoveNode(0, X, Y, Z, #PB_Absolute)
  
  ;Camera
  FOV = 60 - 30 * Cos(ElapsedMilliseconds() / 2500)
  RotateCamera(0, 0, yaw, 0)
  CameraFOV(0, FOV)
  CameraLookAt(0, X, Y, Z)
  
  
  RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

