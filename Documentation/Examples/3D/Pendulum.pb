
; ------------------------------------------------------------
;
;   PureBasic - Pendulum waves experiment
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
; Thanks to kelebrindae for this nice code.


InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Pendulum waves experiment - [Arrows]   [Esc] : Quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Parse3DScripts()

WorldShadows(#PB_Shadow_Additive)

; Texture
LoadTexture(1,"Wood.jpg")

; Materials
CreateMaterial(1, TextureID(1),$88bbbb)
MaterialShininess(1,32,$888888)

CreateMaterial(2, 0, $D0B86B)
MaterialShininess(2,64,$ffffff)

CreateMaterial(3, TextureID(1), $668888)
;MaterialShininess(3,64,$ffffff)

; Entities
;
CreatePlane(1, 40, 40, 20, 20, 2,4)
sol = CreateEntity(#PB_Any, MeshID(1), MaterialID(1))

CreateCube(2, 1)
support = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
ScaleEntity(support, 20, 0.3, 0.3)
MoveEntity(support, 0, 10, 0, #PB_Absolute)

support2 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
ScaleEntity(support2, 0.4, 12, 0.4)
RotateEntity(support2, 30, 0, 0)
MoveEntity(support2, 10, 5, -3, #PB_Absolute)

support3 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
ScaleEntity(support3, 0.4, 12, 0.4)
RotateEntity(support3, -30, 0, 0)
MoveEntity(support3, 10, 5, 3, #PB_Absolute)

support4 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
ScaleEntity(support4, 0.4, 12, 0.4)
RotateEntity(support4, 30, 0, 0)
MoveEntity(support4,-10,5,-3, #PB_Absolute)

support5 = CreateEntity(#PB_Any, MeshID(2), MaterialID(3))
ScaleEntity(support5, 0.4, 12, 0.4)
RotateEntity(support5, -30, 0, 0)
MoveEntity(support5, -10, 5, 3, #PB_Absolute)

; Pendulums
#NBPENDULUM = 16
Global Dim sph.i(#NBPENDULUM + 1)
Global position.f, stringLength.f
CreateSphere(3, 0.5,16,16)

For i=1 To #NBPENDULUM
  
  stringLength = 980.6 * Pow(15 / ( 2 * #PI * (24 + i) ), 2)
  position = -9.3 + i * 1.10
  
  ; Create a sphere
  sph(i) = CreateEntity(#PB_Any, MeshID(3), MaterialID(2))
  MoveEntity(sph(i), EntityX(support) + position, EntityY(support) - stringLength,EntityZ(support), #PB_Absolute)
  CreateEntityBody(sph(i), #PB_Entity_SphereBody)
  
  ; Attach the support and the sphere
  PointJoint(#PB_Any, EntityID(sph(i)), 0, stringLength, 0,     0, position, 0, 0 )
  CreateLine3D(100 + i, EntityX(support) + position, EntityY(support), EntityZ(support), $77FF00, EntityX(sph(i)), EntityY(sph(i)), EntityZ(sph(i)), $77FF00)
  
  ; Gently push the sphere
  ApplyEntityImpulse(sph(i),0,0,4)
Next

; Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 16, 12, 16, #PB_Absolute)
CameraLookAt(0, 0, 5, 0)

; Light
AmbientColor($888888)
CreateLight(0,$ffffff, -200,200, 000)

;- Main loop
Define.f KeyX, KeyY,keyz,dist, MouseX, MouseY,dist

Repeat
  While WindowEvent():Wend
  ExamineMouse()
  ExamineKeyboard()
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  keyx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.2
  keyz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.2+MouseWheel():dist+(keyz-dist)*0.1
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, keyy, -dist)  
  
  ; Redraw the line3D to  figure the prendulums' strings
  For i=1 To #NBPENDULUM
    position = -9.3 + i * 1.10
    CreateLine3D(100 + i, EntityX(support) + position, EntityY(support), EntityZ(support), $77FF00, EntityX(sph(i)), EntityY(sph(i)), EntityZ(sph(i)), $77FF00)
  Next i
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1