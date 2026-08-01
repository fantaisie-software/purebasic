
; ------------------------------------------------------------
;
;   PureBasic - CameraFollow
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 2

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "CameraFollow - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; First create materials
;

GrassMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"grass1.png")))
SetMaterialAttribute(GrassMaterial,#PB_Material_AlphaReject,128)
SetMaterialAttribute(GrassMaterial,#PB_Material_TAM,#PB_Material_ClampTAM)
DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"Dirt.jpg")))
NinjaRed = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"nskinrd.jpg")))

; Then create the billboard group and use the previous material
;
;-Billboard

Billboard = CreateBillboardGroup(#PB_Any, MaterialID(GrassMaterial), 60, 60)
For i = 0 To 1000
  AddBillboard(Billboard, Random(2000)-1000, 30, Random(2000) - 1000)
Next i

; create ground
MeshPlane = CreatePlane(#PB_Any, 2000, 2000, 40, 40, 4, 4)
CreateEntity(#PB_Any, MeshID(MeshPlane), MaterialID(DirtMaterial))

; Add house
MeshHouse = LoadMesh(#PB_Any, "tudorhouse.mesh")
House = CreateEntity(#PB_Any, MeshID(MeshHouse), #PB_Material_None, 0, 280, 0)
ScaleEntity(House, 0.5, 0.5, 0.5)

;- Ninja
NinjaMesh = LoadMesh(#PB_Any, "ninja.mesh")
Ninja = CreateEntity(#PB_Any, MeshID(NinjaMesh), MaterialID(NinjaRed), 500, 0, 400)
ScaleEntity(Ninja, 0.5, 0.5, 0.5)
StartEntityAnimation(Ninja, "Walk")

; SkyBox
SkyBox("desert07.jpg")

; light
CreateLight(0,$ffffff,1000,1000,1000)

; create camera
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)


Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.03
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()   
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed
  EndIf
  
  
  MoveEntity(Ninja, KeyX, 0, KeyY, #PB_Relative)
  Yaw(EntityID(Ninja), MouseX, #PB_World|#PB_Relative)
  CameraFollow(Camera, EntityID(Ninja), 0, EntityY(Ninja) + 80, 160, 0.1, 0.1, #False)
  CameraLookAt(Camera, EntityX(Ninja), 40, EntityZ(Ninja))
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

