
; ------------------------------------------------------------
;
;   PureBasic - MeshManual
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1
#scale = 3



Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " MeshManual - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/fonts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

;- Material
CreateMaterial(0, LoadTexture(0, "White.jpg"))
DisableMaterialLighting(0, #True)

;- Mesh Plane
CreateMesh(0, #PB_Mesh_LineStrip, #PB_Mesh_Static)
MeshVertexPosition(-10, 0, -10)
MeshVertexColor(RGB(255,0,0))
MeshVertexPosition(-10, 0,  10)
MeshVertexColor(RGB(255,255,0))
MeshVertexPosition( 10, 0,  10)
MeshVertexColor(RGB(255,0,255))
MeshVertexPosition( 10, 0, -10)
MeshVertexColor(RGB(0,255,0))
MeshVertexPosition(-10, 0, -10)
MeshVertexColor(RGB(255,0,0))
FinishMesh(#False)

SetMeshMaterial(0, MaterialID(0))
Plane = CreateNode(#PB_Any, -40, 0, 0)
AttachNodeObject(Plane, MeshID(0))

;- Mesh Stars
CreateMesh(1, #PB_Mesh_PointList, #PB_Mesh_Static)
For i = 0 To 10000
  MeshVertexPosition(Random(200)-100, Random(200)-100, Random(200)-100)
  MeshVertexColor(RGB(255,255,0))
Next i
FinishMesh(#False)

SetMeshMaterial(1, MaterialID(0))

Stars = CreateNode(#PB_Any)
AttachNodeObject(Stars, MeshID(1))

;- Mesh Box
CreateMesh(2, #PB_Mesh_LineStrip, #PB_Mesh_Static)
MeshVertexPosition(-10, -10, -10)
MeshVertexPosition(-10, -10,  10)
MeshVertexPosition( 10, -10,  10)
MeshVertexPosition( 10, -10, -10)
MeshVertexPosition(-10, -10, -10)
AddSubMesh(#PB_Mesh_LineStrip)
MeshVertexPosition(-10,  10, -10)
MeshVertexPosition(-10,  10,  10)
MeshVertexPosition( 10,  10,  10)
MeshVertexPosition( 10,  10, -10)
MeshVertexPosition(-10,  10, -10)
AddSubMesh(#PB_Mesh_LineList)
MeshVertexPosition(-10, -10, -10)
MeshVertexPosition(-10,  10, -10)
MeshVertexPosition(-10, -10,  10)
MeshVertexPosition(-10,  10,  10)
MeshVertexPosition( 10, -10,  10)
MeshVertexPosition( 10,  10,  10)
MeshVertexPosition( 10, -10, -10)
MeshVertexPosition( 10,  10, -10)
FinishMesh(#False)

SetMeshMaterial(2, MaterialID(0))
Box = CreateNode(#PB_Any, 40, 0, 0)
AttachNodeObject(Box, MeshID(2))

;- Mesh Grid
CreateMesh(3, #PB_Mesh_LineList, #PB_Mesh_Static)
For i=0 To 20
  MeshVertexPosition(-20, 0, (i-10)*-2)
  MeshVertexColor(RGB(55,155,255))
  MeshVertexPosition(20, 0, (i-10)*-2)
  MeshVertexColor(RGB(55,155,255))
Next
For i=0 To 20
  MeshVertexPosition((i-10)*-2, 0, -20)
  MeshVertexColor(RGB(255,155,55))
  MeshVertexPosition((i-10)*-2, 0,  20)
  MeshVertexColor(RGB(255,155,55))
Next
FinishMesh(#False)

SetMeshMaterial(3, MaterialID(0))
Grid = CreateNode(#PB_Any, 0, 0, 0)
AttachNodeObject(Grid, MeshID(3))


;- Mesh Plane (using MeshIndex)
CreateMesh(4, #PB_Mesh_LineStrip, #PB_Mesh_Static)

; Define vertex position of index 0..3
MeshVertexPosition(-10, 0, -10)
MeshVertexPosition(-10, 0,  10)
MeshVertexPosition( 10, 0,  10)
MeshVertexPosition( 10, 0, -10)

; Define usage of vertices by referring To the indexes
MeshIndex(0)
MeshIndex(1)
MeshIndex(2)
MeshIndex(3)
MeshIndex(0)
FinishMesh(#False)

SetMeshMaterial(4, MaterialID(0))
Plane2 = CreateNode(#PB_Any, 0, 30, 0)
AttachNodeObject(Plane2, MeshID(4))

;- Mesh Box (using MeshIndex)
CreateMesh(5, #PB_Mesh_LineList, #PB_Mesh_Static)

; Define vertex position of index 0..7
MeshVertexPosition(-10, -10, -10)
MeshVertexPosition(-10, -10,  10)
MeshVertexPosition( 10, -10,  10)
MeshVertexPosition( 10, -10, -10)
MeshVertexPosition(-10,  10, -10)
MeshVertexPosition(-10,  10,  10)
MeshVertexPosition( 10,  10,  10)
MeshVertexPosition( 10,  10, -10)

; Define usage of vertices by referring To the indexes
MeshIndex(0)
MeshIndex(1)
MeshIndex(1)
MeshIndex(2)
MeshIndex(2)
MeshIndex(3)
MeshIndex(0)
MeshIndex(3)

MeshIndex(4)
MeshIndex(5)
MeshIndex(5)
MeshIndex(6)
MeshIndex(6)
MeshIndex(7)
MeshIndex(4)
MeshIndex(7)

MeshIndex(0)
MeshIndex(4)
MeshIndex(1)
MeshIndex(5)
MeshIndex(2)
MeshIndex(6)
MeshIndex(3)
MeshIndex(7)

FinishMesh(#False)

SetMeshMaterial(5, MaterialID(0))
Box2 = CreateNode(#PB_Any, 0, -30, 0)
AttachNodeObject(Box2, MeshID(5))

;-Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 40, 150, #PB_Absolute)
CameraFOV(0, 40)
CameraLookAt(0, NodeX(Grid),  NodeY(Grid),  NodeZ(Grid))
CameraBackColor(0, RGB(0, 0, 40))

;-Light
CreateLight(0, RGB(255,255,255), -10, 60, 10)
AmbientColor(RGB(90, 90, 90))

Repeat
  While WindowEvent():Wend
  
  ExamineKeyboard()
  
  RotateNode(Plane, 0.3, -0.3, -0.3, #PB_Relative)
  RotateNode(Stars, 0.1, 0.1, 0.1, #PB_Relative)
  RotateNode(Box, 0.3, 0.3, 0.3, #PB_Relative)
  RotateNode(Grid, 0.3, 0.3, 0.3, #PB_Relative)
  RotateNode(Plane2, 0.3, -0.3, -0.3, #PB_Relative)
  RotateNode(Box2, 0.3, 0.3, 0.3, #PB_Relative)
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1




