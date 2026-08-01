
; ------------------------------------------------------------
;
;   PureBasic - PointJoint (Bridge)
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1
#NbPlanks = 30
Define.f KeyX, KeyY, MouseX, MouseY
Dim Plank(#NbPlanks)

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "PointJoint -  [Space]   [Return]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

;Materials
;
CreateMaterial(0, LoadTexture(0, "Wood.jpg"))
GetScriptMaterial(1, "SphereMap/SphereMappedRustySteel")
CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
GetScriptMaterial(3, "Scene/GroundBlend")

; Bridge
CreateCube(1, 1.0)
For i = 1 To #NbPlanks
  Plank(i)=CreateEntity(#PB_Any, MeshID(1), MaterialID(0))
  ScaleEntity(Plank(i), 2.8, 0.8, 20)
  MoveEntity(Plank(i), i * 3, 16, 0, #PB_Absolute)
  CreateEntityBody(Plank(i), #PB_Entity_BoxBody, 1.0)
Next i

Pas.f = 1.5
PointJoint(#PB_Any, EntityID(Plank(1)), -Pas, 0, -5)
For i= 1 To #NbPlanks-2
  Joint=PointJoint(#PB_Any, EntityID(Plank(i+1)), -Pas, 0, -5, EntityID(Plank(i)), Pas, 0, -5)
Next i
PointJoint(#PB_Any, EntityID(Plank(#NbPlanks)),  Pas, 0, -5)
PointJoint(#PB_Any, EntityID(Plank(#NbPlanks-1)),  Pas, 0, -5, EntityID(Plank(#NbPlanks)), -Pas, 0, -5)

PointJoint(#PB_Any, EntityID(Plank(1)), -Pas, 0, 5)
For i= 1 To #NbPlanks-2
  Joint=PointJoint(#PB_Any, EntityID(Plank(i+1)),  -Pas, 0, 5, EntityID(Plank(i)), Pas, 0, 5)
Next i
PointJoint(#PB_Any, EntityID(Plank(#NbPlanks)),  Pas, 0, 5)
toto=PointJoint(#PB_Any, EntityID(Plank(#NbPlanks-1)),  Pas, 0, 5, EntityID(Plank(#NbPlanks)), -Pas, 0, 5)

; Objects
;
CreateSphere(2, 2, 30, 30)

C = Plank(1)
For i = 1 To #NbPlanks/2
  Perso = CreateEntity(#PB_Any, MeshID(2), MaterialID(1), EntityX(C) +i * 5, EntityY(C)+ i * 2, EntityZ(C))
  CreateEntityBody(Perso, #PB_Entity_SphereBody, 1.0, 0.3, 0.5)
Next i

For i = 1 To #NbPlanks/2
  Perso = CreateEntity(#PB_Any, MeshID(1), MaterialID(2), EntityX(C) +i * 5, EntityY(C)+ i * 4, EntityZ(C))
  ScaleEntity(Perso, 3, 3, 3)
  CreateEntityBody(Perso, #PB_Entity_BoxBody, 1.0)
Next i

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, -20, 30, -40, #PB_Absolute)
CameraLookAt(0, EntityX(C) + 25, EntityY(C) + 10,  EntityZ(C))

; Sky
;
SkyTexture = LoadTexture(#PB_Any, "sky.png")
SkyDome(TextureID(SkyTexture), $cc6600, $0088ff, 3, 400, -0.5, 0)


;ground
;
#EndDistance=1024*4
TextureGround = LoadTexture(#PB_Any,"Dirt.jpg")
CreateMaterial(2, TextureID(TextureGround))
CreatePlane(2, #EndDistance, #EndDistance, 16, 16, #EndDistance/64, #EndDistance/64)
CreateEntity(2, MeshID(2), MaterialID(2), 0, -30, 0)
CreateEntityBody(2,#PB_Entity_PlaneBody)

; Light
;
CreateLight(0, RGB(255, 255, 255), 10, 80, -50)
AmbientColor($888888)

WorldGravity(-20)

Plank = 1
Repeat
  While WindowEvent():Wend    
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    If KeyboardPushed(#PB_Key_Space)
      ApplyEntityImpulse(Plank(#NbPlanks/2), 0, 20, 0)
    EndIf
    If KeyboardReleased(#PB_Key_Return)
      
      If Plank <= #NbPlanks
        DisableEntityBody(Plank(Plank), 0)
        FreeEntityJoints(Plank(Plank))
        Plank + 1
      EndIf
      
    EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed
    
  EndIf
  
  MoveCamera  (0, KeyX, 0, KeyY)
  RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)
  
  RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1 Or MouseButton(3)
