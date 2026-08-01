
; ------------------------------------------------------------
;
;   PureBasic - CheckObjectVisibility
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



Define.f KeyX, KeyY, MouseX, MouseY, Speed = 1.0
Define.i RobotMove

#CameraSpeed = 2

InitEngine3D(#PB_Engine3D_DebugLog)

InitSprite()
InitKeyboard()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CheckObjectVisibility -  [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main",     #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/fonts"           , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()


;- Material
;
GetScriptMaterial(1, "Color/Red")
GetScriptMaterial(2, "Color/Green")
GetScriptMaterial(3, "Color/Blue")
GetScriptMaterial(4, "Color/Yellow")
CreateMaterial(5, LoadTexture(5, "r2skin.jpg"))

;- Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 700, 700, 70, 70, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)

;- Mesh
;
LoadMesh(1, "robot.mesh")
CreateSphere(2, 10)
LoadMesh(3, "PureBasic.mesh")

;- Entity
;
CreateEntity(1, MeshID(1), MaterialID(5))
CreateEntity(2, MeshID(3), MaterialID(1), -200, 12,  100)
CreateEntity(3, MeshID(2), MaterialID(2),  200, 10, -100)
CreateEntity(4, MeshID(2), MaterialID(3),  200, 10,  100)
CreateEntity(5, MeshID(2), MaterialID(4), -200, 10, -100)

ScaleEntity(3, 2, 2, 2)

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 120, 400, #PB_Absolute)
CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))

CreateCamera(1, 0, 0, 100, 100)
CameraFOV(1, 60)

;- TextureRTT
;
CreateRenderTexture(10, CameraID(1), 800, 600, #PB_Texture_AutomaticUpdate)
CreateMaterial(10, TextureID(10))
SetMaterialColor(10, #PB_Material_SelfIlluminationColor, RGB(255, 255, 255))

;- Billboard group
;
CreateBillboardGroup(0, MaterialID(10), 68, 48)
AddBillboard(0, 0, 0, 0)

;- Attach objects
;
AttachEntityObject(1, "Joint1", CameraID(1), 0, 0, 0, -20, -90, 0)
AttachEntityObject(1, "Joint1", BillboardGroupID(0), 0, 60, 0, 0, 0, 0)

;-Light
;
CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
AmbientColor($888888)

;- Skybox
;
SkyBox("desert07.jpg")

WorldShadows(#PB_Shadow_Additive)

;- Text3D
CreateText3D(0, "")
Text3DColor(0, RGBA(0, 255, 255, 255))
Text3DAlignment(0, #PB_Text3D_HorizontallyCentered | #PB_Text3D_VerticallyCentered)

AttachEntityObject(1, "Joint1", Text3DID(0))
MoveText3D(0, 0, 30, 0)
ScaleText3D(0, 6, 6, 0)

Repeat
  While WindowEvent():Wend  
  ExamineKeyboard()
  
  RobotMove = #False
  
  RobotdX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
  Robotdz = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed
  
  If Robotdx Or Robotdz:RobotMove=#True:EndIf
  
  MoveEntity(1,Robotdx*Speed,0,Robotdz*speed)
  EntityDirection(1,Robotdx,0,Robotdz,#PB_Parent,#PB_Vector_X)
  
  If KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0
    Speed + 0.05
  ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1
    Speed - 0.05
  EndIf
  
  If RobotMove
    If EntityAnimationStatus(1, "Walk") = #PB_EntityAnimation_Stopped ; Loop
      StartEntityAnimation(1, "Walk", #PB_EntityAnimation_Manual)     ; Start the animation from the beginning
    EndIf
  Else
    StopEntityAnimation(1, "Walk")
  EndIf
  
  AddEntityAnimationTime(1, "Walk", TimeSinceLastFrame * Speed*1.5)
  
  RotateEntity(2, 0, 1, 0, #PB_Relative)
  
  CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))
  
  ;Check Objects
  Object$ = ""
  
  If CheckObjectVisibility(1, EntityID(2))
    Object$ + "PureBasic ! "
  EndIf
  If CheckObjectVisibility(1, EntityID(3))
    Object$ + "Green Sphere ! "
  EndIf
  If CheckObjectVisibility(1, EntityID(4))
    Object$ + "Blue Sphere ! "
  EndIf
  If CheckObjectVisibility(1, EntityID(5))
    Object$ + "Yellow Sphere ! "
  EndIf
  
  If Object$ = ""
    Object$ = "nothing !"
  EndIf
  
  Text3DCaption(0, "I can see " + Object$)
  
  TimeSinceLastFrame = RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

