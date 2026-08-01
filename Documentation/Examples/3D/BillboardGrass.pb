
; ------------------------------------------------------------
;
;   PureBasic - Billboard
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Billboard - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; First create materials
;

GrassMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"grass1.png")))
SetMaterialAttribute(GrassMaterial,#PB_Material_AlphaReject,128)
SetMaterialAttribute(GrassMaterial,#PB_Material_TAM,#PB_Material_ClampTAM)
DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"Dirt.jpg")))


; Then create the billboard group and use the previous material
;
;-Billboard

Billboard = CreateBillboardGroup(#PB_Any, MaterialID(GrassMaterial), 50, 50, 0, 0, 0, -1, 1)
BillboardGroupCommonDirection(Billboard, 0, 1, 0)

For i = 0 To 4000
  AddBillboard(Billboard, Random(2000)-1000, Random(8) + 15, Random(2000) - 1000)
Next i

; create ground

MeshPlane = CreatePlane(#PB_Any, 2000, 2000, 40, 40, 40, 40)
CreateEntity(#PB_Any, MeshID(MeshPlane), MaterialID(DirtMaterial))

; Add house
MeshHouse = LoadMesh(#PB_Any, "tudorhouse.mesh")
House = CreateEntity(#PB_Any, MeshID(MeshHouse), #PB_Material_None, 0, 280, 0)
ScaleEntity(House, 0.5, 0.5, 0.5)

; light
CreateLight(0,$ffffff,1000,1000,1000)

; create camera
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
MoveCamera(Camera, 200, 100, 900, #PB_Absolute)
CameraLookAt(Camera, 0, 100, 0)

;sky
tx_sky=LoadTexture(#PB_Any,"sky.png")
SkyDome(TextureID(tx_sky),$cc6600,$0088ff,3,400,-0.5,0)

Repeat
  While WindowEvent():Wend  
  ExamineKeyboard()
  ExamineMouse()
  
  MouseX = -MouseDeltaX() * 0.05
  MouseY = -MouseDeltaY() * 0.05
  
  KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
  Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up)-MouseWheel()*20)*#CameraSpeed
  
  RotateCamera(Camera, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (Camera, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

