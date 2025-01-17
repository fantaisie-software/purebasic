
; ------------------------------------------------------------
;
;   PureBasic - SetMeshMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " SetMeshMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

MaterialFilteringMode(#PB_Default, #PB_Material_Anisotropic, 8)

;- Material
CreateMaterial(0, LoadTexture(0, "ValetCoeur.jpg"))
SetMaterialColor(0, #PB_Material_SelfIlluminationColor, RGB(255, 255, 255))
CreateMaterial(1, LoadTexture(1, "DosCarte.png"))

;- Create a mesh manually

; Define all the vertices and their attributes

CreateMesh(0)

; Recto
MeshVertex(-0.5,0,-0.5,0,0,$ffffff)
MeshVertex(0.5,0,-0.5,0,1,$ffffff)
MeshVertex(0.5,0,0.5,1,1,$ffffff)
MeshVertex(-0.5,0,0.5,1,0,$ffffff)

; Define all the faces, based on the vertex index
MeshFace(2,1,0,3)

; Verso
AddSubMesh()
MeshVertex(-0.5,0,-0.5,0,0,$ffffff)
MeshVertex(0.5,0,-0.5,0,1,$ffffff)
MeshVertex(0.5,0,0.5,1,1,$ffffff)
MeshVertex(-0.5,0,0.5,1,0,$ffffff)

MeshFace(0,1,2,3)

FinishMesh(#True)
NormalizeMesh(0)

SetMeshMaterial(0, MaterialID(0), 0)
SetMeshMaterial(0, MaterialID(1), 1)

;-Entity
CreateEntity(0, MeshID(0), #PB_Material_None)
ScaleEntity(0, 300, 1, 200)

;-Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 0, 500, #PB_Absolute)
CameraBackColor(0, RGB(80, 20, 20))

Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  
  ExamineKeyboard()
  
  RotateEntity(0, 1.1, 0.3, 1.0, #PB_Relative)
  
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

