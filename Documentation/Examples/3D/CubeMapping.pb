
; ------------------------------------------------------------
;
;   PureBasic - CubeMapping
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CubeMapping - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; camera
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
MoveCamera(Camera, 100, 100, 100, #PB_Absolute)
CameraLookAt(Camera,0,50,0)

; light
CreateLight(0,$ffffff,1000,1000,1000)

; robot
CreateCubeMapTexture(0, 256, #PB_Texture_AutomaticUpdate, "")
LoadTexture(1, "r2skin.jpg")

CreateShaderMaterial(0,#PB_Material_CubicEnvShader)
MaterialShaderTexture(0,TextureID(0),TextureID(1),0,0)

LoadMesh(0,"robot.mesh")
CreateEntity(0, MeshID(0), MaterialID(0))
EntityCubeMapTexture(0, 0)

; spheres
CreateSphere(1,20)
For i=0 To 3
  CreateMaterial(i+2,0,Random($ffffff))
  MaterialShininess(i+2,64,$ffffff)
  CreateEntity(i+2,MeshID(1),MaterialID(i+2))
Next


SkyBox("desert07.jpg")

Define.f angle,anglei
Repeat
  While WindowEvent():Wend  
    
  angle+0.01
  For i=0 To 3
    anglei=angle+i/4*2*#PI
    MoveEntity(i+2,Cos(anglei)*100,50,Sin(anglei)*100,#PB_Absolute)
  Next
  
  RenderWorld()
  FlipBuffers()
  ExamineKeyboard()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

