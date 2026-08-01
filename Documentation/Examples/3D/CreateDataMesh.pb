
; ------------------------------------------------------------
;
;   PureBasic - CreateDataMesh
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#PB_Mesh_Normalize=8

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CreateDataMesh - [F12] Wireframe -  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures",#PB_3DArchive_FileSystem)
Parse3DScripts()

;camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,0,0,20)
CameraLookAt(0,0,0,0)

;light
CreateLight(0,$ffffff, 10000, 10000, 0000)
AmbientColor($777777)

;material
LoadTexture(0, "Dirt.jpg")
CreateMaterial(0,TextureID(0))
MaterialFilteringMode(0,#PB_Material_Anisotropic)
MaterialShininess(0,32,$888888)
ScaleMaterial(0,0.1,0.025)

CopyMaterial(0,1)
SetMaterialColor(1,#PB_Material_DiffuseColor,$ff)
SetMaterialColor(1,#PB_Material_AmbientColor,$ff)
MaterialCullingMode(1,#PB_Material_AntiClockWiseCull) 

;mesh
Define.f u,v, a=3,b=4,c=-0.1,   nx.l=32,ny.l=256
Dim t.MeshVertex(nx,ny)
For j=0 To ny
  For i=0 To nx
    u=j/ny*2*#PI
    v=i/nx*2*#PI   
    
    With t(i,j)
      \u=i/nx
      \v=j/ny
      \color=$ffffff
      u*4
      \x=(a+b*Cos(v))*Exp(c*u)*Cos(u)
      \y=(a+b*Cos(v))*Exp(c*u)*Sin(u)
      \z=(3*a+b*Sin(v))*Exp(c*u)-5
    EndWith
  Next
Next
CreateDataMesh(mesh,t(),#PB_Mesh_DiagonalClosestNormal+#PB_Mesh_Normalize)

;entity
CreateEntity(0,MeshID(0),MaterialID(0))
CreateEntity(1,MeshID(0),MaterialID(1))
AttachEntityObject(0,"",EntityID(1))

Repeat     
  While WindowEvent():Wend
  ExamineKeyboard()
  If KeyboardReleased(#PB_Key_F12):Wireframe=1-Wireframe:EndIf
  If Wireframe:MaterialShadingMode(0, #PB_Material_Wireframe):Else:MaterialShadingMode(0,#PB_Material_Solid):EndIf
  
  RotateEntity(0,0.5,0.3,0.4,#PB_Relative)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)
