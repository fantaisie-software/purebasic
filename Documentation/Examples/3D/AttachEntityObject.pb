
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "AttachEntityObject -  [Space]   [Return]   [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)


Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, -1, RGB(175, 175, 255))

;Material
;
DirtMaterial  = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any, "Dirt.jpg")))
RedMaterial   = GetScriptMaterial(#PB_Any, "Color/Red")
GreenMaterial = GetScriptMaterial(#PB_Any, "Color/Green")

;Mesh
;
PlaneMesh = CreatePlane(#PB_Any, 1500, 1500, 40, 40, 15, 15)
RoboTMesh = LoadMesh(#PB_Any, "robot.mesh")
SphereMesh = CreateSphere(#PB_Any, 10)

; Entity
;
Ground = CreateEntity(#PB_Any,MeshID(PlaneMesh),MaterialID(DirtMaterial)) ; Ground
EntityRenderMode(Ground, 0)

Entity      = CreateEntity(#PB_Any, MeshID(RoboTMesh), #PB_Material_None)    ; Robot
RedSphere   = CreateEntity(#PB_Any, MeshID(SphereMesh), MaterialID(RedMaterial))
GreenSphere = CreateEntity(#PB_Any, MeshID(SphereMesh), MaterialID(GreenMaterial))

; AttachObject
;
AttachEntityObject(Entity, "Joint18", EntityID(RedSphere), 10, -8, -5, 0, 0, 0)
AttachEntityObject(Entity, "Joint15", EntityID(GreenSphere), 10, -8, 0, 0, 0, 0)

; Fog
;
Fog(RGB(255,255,255*0.8), 1, 0, 10000)

; SkyBox
;
SkyBox("desert07.jpg")

; Camera
;
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
MoveCamera(Camera, 0, 120, 500, #PB_Absolute)
CameraLookAt(Camera, EntityX(Entity), EntityY(Entity) + 40, EntityZ(Entity))

;Light
;
CreateLight(#PB_Any, RGB(255, 255, 255), -40, 100, 80)
AmbientColor(RGB(80, 80, 80))

Repeat
  While WindowEvent():Wend      
  If ExamineMouse()
    MouseX = -MouseDeltaX()/10
    MouseY = -MouseDeltaY()/10
  EndIf
  
  RobotMove = #False
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_Space)
      DetachEntityObject(Entity, EntityID(RedSphere))
    EndIf
    
    If KeyboardReleased(#PB_Key_Return)
      AttachEntityObject(Entity, "Joint18", EntityID(RedSphere), 10, -8, -5,  0, 0, 0)
    EndIf
    
    If KeyboardPushed(#PB_Key_Left)
      MoveEntity(Entity, -1 * Speed, 0, 0)
      RotateEntity(Entity, 0, 180, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Right)
      MoveEntity(Entity, 1 * Speed, 0, 0)
      RotateEntity(Entity, 0, 0, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Up)
      MoveEntity(Entity, 0, 0, -1 * Speed)
      RotateEntity(Entity, 0, 90, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_Down)
      MoveEntity(Entity, 0, 0, 1 * Speed)
      RotateEntity(Entity, 0, -90, 0)
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_PageUp) And Speed < 2.0
      Speed + 0.05
    ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1
      Speed - 0.05
    EndIf
    
  EndIf
  
  If RobotMove
    If EntityAnimationStatus(Entity, "Walk") = #PB_EntityAnimation_Stopped ; Loop
      StartEntityAnimation(Entity, "Walk", #PB_EntityAnimation_Manual)     ; Start the animation from the beginning
    EndIf
  Else
    StopEntityAnimation(Entity, "Walk")
  EndIf
  
  AddEntityAnimationTime(Entity, "Walk", TimeSinceLastFrame)
  
  RotateCamera(Camera, MouseY, MouseX, RollZ, #PB_Relative)
  MoveCamera  (Camera, KeyX, 0, KeyY)
  
  TimeSinceLastFrame = RenderWorld() * Speed
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

