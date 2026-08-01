
; ------------------------------------------------------------
;
;   PureBasic - TextureAddressingMode
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Procedure.f POM(v.f)
  ProcedureReturn (Random(1000)-500)/500*v
EndProcedure

InitEngine3D()
InitSprite()
InitKeyboard()

WinW = 1024
WinH = 800

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " TextureAddressingMode - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Parse3DScripts()

;cubes 
CreateCube(1, 1)
LoadTexture(0,"Dr_Bunsen_Head.jpg"):CreateMaterial(0,TextureID(0)):ScaleMaterial(0,0.5,0.5):MaterialFilteringMode(0,#PB_Material_Anisotropic,4)
CopyMaterial(0,1):SetMaterialAttribute(1,#PB_Material_TAM,#PB_Material_MirrorTAM)
CopyMaterial(0,2):SetMaterialAttribute(2,#PB_Material_TAM,#PB_Material_ClampTAM)
CopyMaterial(0,3):SetMaterialAttribute(3,#PB_Material_TAM,#PB_Material_BorderTAM)
For i=0 To 3:CreateEntity(i, MeshID(1), MaterialID(i),0,0,i*2-3):Next 

;grass
LoadTexture(10,"grass2.png"):CreateMaterial(10,TextureID(10))
MaterialBlendingMode(10,#PB_Material_AlphaBlend)
MaterialCullingMode(10,#PB_Material_NoCulling)
CopyMaterial(10,11):SetMaterialAttribute(11,#PB_Material_TAM,#PB_Material_ClampTAM)

CreatePlane(0,1,1,1,1,1,1):TransformMesh(0,0,0,0,1,1,1,-90,0,0) 
For i=0 To 100
  n=CreateEntity(-1, MeshID(0), MaterialID(10),pom(4)-6,0,pom(4)):RotateEntity(n,0,Random(360),0):RotateEntity(n,0,Random(360),0); without clamp (bug)
  n=CreateEntity(-1, MeshID(0), MaterialID(11),pom(4)+6,0,pom(4)):RotateEntity(n,0,Random(360),0):RotateEntity(n,0,Random(360),0); with clamp
Next  

;light
CreateLight(0, RGB(255,255,255), 50, 50, 50)

;camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 0, 5)
CameraLookAt(0, 0, 0, 0)
CameraBackColor(0, $444444)

Repeat
  ExamineKeyboard()
  a.f+0.005
  MoveCamera(0,Cos(a)*5,1,Sin(a)*5, #PB_Absolute)
  CameraLookAt(0,0,0,0)
  RenderWorld()
  FlipBuffers()    
Until WindowEvent() = #PB_Event_CloseWindow Or KeyboardReleased(#PB_Key_Escape)
End
