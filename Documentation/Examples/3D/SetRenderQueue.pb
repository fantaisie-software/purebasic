
; ------------------------------------------------------------
;
;   PureBasic - SetRenderQueue
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Use [F5]/[F6]



#CameraSpeed = 1

#Camera    = 0
#Entity0   = 0
#Entity1   = 1
#Material0 = 0
#Material1 = 1
#Mesh      = 0
#Texture0  = 0
#Texture1  = 1

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " SetRenderQueue - [F5] [F6] [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)

CreateMaterial(#Material0, LoadTexture(#Texture0, "clouds.jpg"))
CreateMaterial(#Material1, LoadTexture(#Texture1, "Dirt.jpg"))

CreateCube(#Mesh, 20)
CreateEntity(#Entity0, MeshID(#Mesh), MaterialID(#Material0),  5, 0, 0)
CreateEntity(#Entity1, MeshID(#Mesh), MaterialID(#Material1), -5, 0, 0)


SkyBox("stevecube.jpg")

CreateCamera(#Camera, 0, 0, 100, 100)
MoveCamera(#Camera, 0, 40, 150, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  If ExamineKeyboard()
    If KeyboardReleased(#PB_Key_F5)
      SetRenderQueue(EntityID(#Entity0), 1)
      SetRenderQueue(EntityID(#Entity1), 0)
    ElseIf KeyboardReleased(#PB_Key_F6)
      SetRenderQueue(EntityID(#Entity0), 0)
      SetRenderQueue(EntityID(#Entity1), 1)
    EndIf
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

