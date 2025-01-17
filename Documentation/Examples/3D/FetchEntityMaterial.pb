
; ------------------------------------------------------------
;
;   PureBasic - FetchEntityMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#Camera    = 0
#Entity0   = 0
#Entity1   = 1
#Light     = 0
#Material0 = 0
#Material1 = 1
#Mesh0     = 0
#Mesh1     = 1
#Texture0  = 0


Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " FetchEntityMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

CreateMaterial(#Material0, LoadTexture(#Texture0, "clouds.jpg"))

CreateSphere(#Mesh0, 40, 50, 50)
CreateEntity(#Entity0,MeshID(#Mesh0), MaterialID(#Material0), -60, 0, 0)

; Get the MaterialID
FetchEntityMaterial(#Entity0, #Material1)

; Create a cube with materialID
CreateCube(#Mesh1, 40)
CreateEntity(#Entity1, MeshID(#Mesh1), MaterialID(#Material1), 60, 0, 0)

; Camera
CreateCamera(#Camera, 0, 0, 100, 100)
CameraBackColor(#Camera, RGB(30, 0, 0))
MoveCamera(#Camera, 0, 100, 300, #PB_Absolute)
CameraLookAt(#Camera, 0, 0, 0)

; Light
CreateLight(#Light, RGB(255, 255, 255), 560, 900, 500)
AmbientColor(0)

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

