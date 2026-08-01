
; ------------------------------------------------------------
;
;   PureBasic - SetEntityCollisionFilter
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.4
#Speed = 60

#COL_Sphere   = 1 << 6
#COL_Box      = 1 << 7
#COL_Cylinder = 1 << 8
#COL_Ground   = 1 << 9

#SphereCollidesWith   = #COL_Ground | #COL_Box    | #COL_Cylinder
#BoxCollidesWith      = #COL_Ground | #COL_Sphere | #COL_Cylinder
#CylinderCollidesWith = #COL_Ground | #COL_Sphere | #COL_Box
#GroundCollidesWith   = #COL_Sphere | #COL_Box    | #COL_Cylinder

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY
Define.i Shoot

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " SetEntityCollisionFilter - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
InitScreenGadgets()

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

;- Materials
GetScriptMaterial(0, "Color/Blue")
GetScriptMaterial(1, "Color/Green")
GetScriptMaterial(2, "Color/Red")
GetScriptMaterial(3, "Color/Yellow")
CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))

;- Meshes
CreateCube(0, 2)
CreateSphere(1, 1)
CreateCylinder(2, 1, 4)

;- Entities
CreateEntity(0, MeshID(0), MaterialID(0),  4,  1.0, 0)
CreateEntity(1, MeshID(1), MaterialID(1), -4,  0.5, 0)
CreateEntity(2, MeshID(2), MaterialID(2),  0, -1.0, 0)
CreateEntity(4, MeshID(0), MaterialID(4),  0, -4.0, 0)
ScaleEntity(4, 5, 0.5, 5)

;- Body
CreateEntityBody(0, #PB_Entity_BoxBody, 1)
CreateEntityBody(1, #PB_Entity_SphereBody, 1)
CreateEntityBody(2, #PB_Entity_CylinderBody, 1)
CreateEntityBody(4, #PB_Entity_BoxBody, 0)

;-Filter
SetEntityCollisionFilter(0, #COL_Box     , #BoxCollidesWith)
SetEntityCollisionFilter(1, #COL_Sphere  , #SphereCollidesWith)
SetEntityCollisionFilter(2, #COL_Cylinder, #CylinderCollidesWith)
SetEntityCollisionFilter(4, #COL_Ground  , #GroundCollidesWith)

;- Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, -1, 8, 25, #PB_Absolute)
CameraLookAt(0, -1, 0, 0)

;- Light
CreateLight(0, $FFFFFF, 1560, 900, 500)
AmbientColor($330000)

;- GUI
TextScreenGadget(0, 20, 10, 400, 50, "Clic somewhere")
SetScreenGadgetFont(0,LoadFont(0,"Arial",24))

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * 0.05
    MouseY = -MouseDeltaY() * 0.05
    
    InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
    
    If MouseButton(#PB_MouseButton_Left)
      If Clic = 0
        If PointPick(0, MouseX(), MouseY())
          Clic = 1
          Shoot = CreateEntity(#PB_Any, MeshID(1), MaterialID(3), CameraX(0), CameraY(0), CameraZ(0))
          ScaleEntity(Shoot, 0.3, 0.3, 0.3)
          CreateEntityBody(Shoot, #PB_Entity_SphereBody, 1)
          ApplyEntityImpulse(Shoot, PickX() * #Speed, PickY() * #Speed, PickZ() * #Speed)
          SetEntityCollisionFilter(Shoot, #COL_Sphere  , #SphereCollidesWith)
        EndIf
      EndIf
    Else
      Clic = 0
    EndIf
  EndIf
  
  If ExamineKeyboard()
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
    
  EndIf
  
  
  CameraLookAt(0, 0, 0, 0)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  RenderScreenGadgets()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

