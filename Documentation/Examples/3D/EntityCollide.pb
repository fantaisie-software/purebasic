
; ------------------------------------------------------------
;
;   PureBasic - EntityCollide
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.4
#Speed = 60

#MainWindow = 0
#TextGadget = 0



Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY
Define.i Shoot

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " EntityCollide - [Esc] quit",#PB_Window_ScreenCentered)
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

;- Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, -1, 8, 25, #PB_Absolute)
CameraLookAt(0, -1, 0, 0)

;- Light
CreateLight(0, $FFFFFF, 1560, 900, 500)
AmbientColor($330000)

;- GUI
OpenScreenWindow(#MainWindow, 8,8, 160 , 60 , "EntityCollide")
TextScreenGadget(#TextGadget, 10 , 20 , 200 , 30 , "Clic somewhere")


Repeat
  While WindowEvent():Wend
    
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        
    If MouseButton(#PB_MouseButton_Left)
      If Clic = 0
        If PointPick(0, MouseX(), MouseY())
          Clic = 1
          Shoot = CreateEntity(#PB_Any, MeshID(1), MaterialID(3), CameraX(0), CameraY(0), CameraZ(0))
          ScaleEntity(Shoot, 0.3, 0.3, 0.3)
          CreateEntityBody(Shoot, #PB_Entity_SphereBody, 1)
          ApplyEntityImpulse(Shoot, PickX() * #Speed, PickY() * #Speed, PickZ() * #Speed)
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
  
  If Shoot
    For i=0 To 2
      If EntityCollide(Shoot, i)
        FreeEntity(Shoot)
        FreeEntity(i)
        Shoot = 0
        Break
      EndIf
    Next
  EndIf
  
  MoveCamera  (0, KeyX, 0, KeyY)
  CameraLookAt(0, 0, 0, 0)
  
  RenderWorld()
  RenderScreenGadgets()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

