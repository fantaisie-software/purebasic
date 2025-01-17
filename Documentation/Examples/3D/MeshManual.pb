
; ------------------------------------------------------------
;
;   PureBasic - Manual Mesh
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.1


Define.f KeyX, KeyY, MouseX, MouseY

Define.f x, y, z, nx, ny, nz, u, v
Define.l Co
Define.w t1, t2, t3

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Manual Mesh - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)

; Create a pyramid, manualy... 5 vertex
; (to have independant UV and normal (for raised edges) on each face, you have to duplicate vertex : 4 + 4*3 = 16 vertex)

CreateMesh(0, #PB_Mesh_TriangleList)

;vertex
MeshVertex(-1,0, 1,   0,0,      $ffffff,0,0,0)    ;base
MeshVertex( 1,0, 1,   1,0,      $ffffff,0,0,0)
MeshVertex(-1,0,-1,   0,1,      $ffffff,0,0,0)
MeshVertex( 1,0,-1,   1,1,      $ffffff,0,0,0)
MeshVertex( 0,1.4, 0,   0.5,0.5,  $ffffff,0,0,0)  ;top
;faces
MeshFace(0,1,3,2) ;base (4 vertex)
MeshFace(0,1,4)   ;side (3 vertex)
MeshFace(1,3,4)
MeshFace(3,2,4)
MeshFace(2,0,4)

FinishMesh(#True)
NormalizeMesh(0)

CreateMaterial(0, LoadTexture(0, "Caisse.png"))
SetMaterialColor(0, #PB_Material_AmbientColor|#PB_Material_DiffuseColor, -1)
MaterialCullingMode(0,#PB_Material_NoCulling)

CreateEntity(0, MeshID(0), MaterialID(0))

;normal camera
CreateCamera(0, 0, 0, 50, 100)
MoveCamera(0, 0, 0, -5, #PB_Absolute)
CameraLookAt(0,0,0,0)
CameraBackColor(0,$777777)

;wireframe camera
CreateCamera(1, 50, 0, 100, 100)
MoveCamera(1, 0, 0, -5, #PB_Absolute)
CameraLookAt(1,0,0,0)
CameraRenderMode(1,#PB_Camera_Wireframe)

;light
CreateLight(0, $ffffff, 300, 600, -100)
AmbientColor($777777)

Repeat
  While WindowEvent():Wend
  ExamineKeyboard()
  
  RotateEntity(0, 1, 1, 1, #PB_Relative)
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative):MoveCamera  (0, KeyX, 0, KeyY)
  RotateCamera(1, MouseY, MouseX, 0, #PB_Relative):MoveCamera  (1, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

