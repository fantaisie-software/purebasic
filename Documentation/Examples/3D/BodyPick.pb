
; ------------------------------------------------------------
;
;   PureBasic - BodyPick
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "BodyPick - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Parse3DScripts()

;- Materials
;
CreateMaterial(1, 0,$ff)
CreateMaterial(2, 0,$ff00)
CreateMaterial(3, 0,$ff0000)
CreateMaterial(4, 0,$ffff)
For i=1 To 4:MaterialShininess(i,32,$ffffff):next
DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"Dirt.jpg")))

;- Mesh
;
CapsuleMesh = CreateCapsule(#PB_Any, 1.5,3)
ConeMesh = CreateCone(#PB_Any, 3,4)
CubeMesh = CreateCube(#PB_Any, 4)
CylinderMesh = CreateCylinder(#PB_Any, 2,4)
IcoSphereMesh = CreateIcoSphere(#PB_Any, 2)
PlaneMesh = CreatePlane(#PB_Any, 200, 200, 40, 40, 4, 4)
SphereMesh = CreateSphere(#PB_Any, 2)
TorusMesh = CreateTorus(#PB_Any, 2, 1)
TubeMesh = CreateTube(#PB_Any, 2, 1, 2)

;-Entity
;
Capsule = CreateEntity(#PB_Any, MeshID(CapsuleMesh), MaterialID(1),0,5, 5)
Cone = CreateEntity(#PB_Any, MeshID(ConeMesh), MaterialID(2),0,5,10)
Cube = CreateEntity(#PB_Any, MeshID(CubeMesh), MaterialID(3),0,5,15)
Cylinder = CreateEntity(#PB_Any, MeshID(CylinderMesh), MaterialID(4),0,5,20)
IcoSphere = CreateEntity(#PB_Any, MeshID(IcoSphereMesh), MaterialID(1),0,5,25)
Plane = CreateEntity(#PB_Any, MeshID(PlaneMesh), MaterialID(DirtMaterial))
Sphere = CreateEntity(#PB_Any, MeshID(SphereMesh), MaterialID(2),0,5,30)
Torus = CreateEntity(#PB_Any, MeshID(TorusMesh), MaterialID(3),0,5,35)
Tube = CreateEntity(#PB_Any, MeshID(TubeMesh), MaterialID(4),0,5,40)

EntityRenderMode(Plane, 0)
;-Body
;
CreateEntityBody(Capsule, #PB_Entity_CapsuleBody, 1)
CreateEntityBody(Cone, #PB_Entity_ConeBody, 1)
CreateEntityBody(Cube, #PB_Entity_BoxBody, 1)
CreateEntityBody(Cylinder, #PB_Entity_CylinderBody, 1)
CreateEntityBody(IcoSphere, #PB_Entity_SphereBody, 1)
CreateEntityBody(Plane, #PB_Entity_PlaneBody, 0,0,1)
CreateEntityBody(Sphere, #PB_Entity_SphereBody, 1)
CreateEntityBody(Torus, #PB_Entity_CylinderBody, 1)
CreateEntityBody(Tube, #PB_Entity_CylinderBody, 1)

;- Light
;
CreateLight(0, RGB(255,255,255), 200, 50, 100)
AmbientColor($888888)

;- SkyBox
;
SkyBox("desert07.jpg")

;- Camera
;
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
MoveCamera(Camera, 100, 30, 20)
CameraLookAt(Camera, 0,0,0)

;- GUI
;
OpenWindow3D(0, 0, 0, 50 , 10 , "")
HideWindow3D(0,1)
ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor

Repeat
While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.03
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
    InputEvent3D(MouseX(), MouseY(),0)
    BodyPick(CameraID(Camera), MouseButton(#PB_MouseButton_Left), MouseX(), MouseY(), 1)
  EndIf
  
  If ExamineKeyboard()
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed
        
    MoveCamera  (Camera, KeyX, 0, KeyY)
    RotateCamera(Camera,  MouseY, MouseX, 0, #PB_Relative)
    
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
