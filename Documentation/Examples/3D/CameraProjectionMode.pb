
; ------------------------------------------------------------
;
;   PureBasic - CameraProjectionMode Camera Orthographic
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CameraProjectionMode Camera Orthographic - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

CreateMaterial(0, LoadTexture(0, "White.jpg"))
DisableMaterialLighting(0, #True)

;- Mesh
CreateMesh(0, #PB_Mesh_LineStrip, #PB_Mesh_Static)
Define.f x, y, z, t

k=6;20
While t <= 2*#PI
  x.f = Cos(t) - Cos(k* t)/2 + Sin(14* t)/3
  y.f = Cos(14* t)/3 + Sin(t)- Sin(k* t)/2
  z.f = 0
  
  MeshVertexPosition(x, y, z)
  MeshVertexColor(RGB(255,0,0))
  
  t + 0.001
  
Wend

FinishMesh(#False)

SetMeshMaterial(0, MaterialID(0))
Plane = CreateNode(#PB_Any)
AttachNodeObject(Plane, MeshID(0))

;-Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 0, 1, #PB_Absolute)
CameraLookAt(0,0,0,0)

CameraBackColor(0, RGB(50, 250, 50))
Width.f = 2*#PI ; width of the plotting x range
Height.f = (600/800)*Width ; 800 is the windowed Screen width
CameraProjectionMode(0, #PB_Camera_Orthographic, Width, Height)

;glLineWidth_(2) thick lines only for opengl subsystem
Repeat
  While WindowEvent():Wend
  
  RotateNode(Plane, 0, 0, 0.5, #PB_Relative)
  RenderWorld()
  FlipBuffers()
  ExamineKeyboard()
  
Until KeyboardPushed(#PB_Key_Escape) Or quit = 1

