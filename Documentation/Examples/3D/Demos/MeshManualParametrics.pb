;
; ------------------------------------------------------------
;
;   PureBasic - Mesh Manual - SuperQuadratics
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;http://lrv.fri.uni-lj.si/~franc/SRSbook/geometry.pdf

; Use [F2]/[F3] - Change Render Material
; Use cursor to change SuperQuadratics

#Color = #True ; #False white mesh / #True color mesh

#TwoPi = 2.0 * #PI
#CameraSpeed = 1

Global Epsilon2.f = 1
Global Epsilon1.f = 1

#Scale = 20
#Delta = 1.0 / 10.0

Define.f KeyX, KeyY, MouseX, MouseY

Define.f x, y, z, nx, ny, nz, u, v, sx, sy, sz, Depth = 200
Define.l Co
Define.w t1, t2, t3

Declare CreateSuperQuadratics()
Declare UpdateSuperQuadratics()
Declare SuperQuadratics()

Macro Text3D(No, Texte, Color, Alignment, x, y, z, Sx, Sy)
  CreateText3D(No, Texte)
  Text3DColor(No, Color)
  Text3DAlignment(No, Alignment)
  
  CreateNode(No, x, y, z)
  AttachNodeObject(No, Text3DID(No))
  ScaleText3D(No, Sx, Sy, 1)
EndMacro

;Convert 2D to 3D
Macro Convert2DTo3D(Camera, x, y, d)
  If PointPick(Camera, x, y)
    sx = CameraX(Camera) + PickX() * d
    sy = CameraY(Camera) + PickY() * d
    sz = CameraZ(Camera) + PickZ() * d
  EndIf
EndMacro

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " MeshManualParameterics - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/fonts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateSuperQuadratics()
CreateMaterial(0, LoadTexture(0, "White.jpg"))
DisableMaterialLighting(0, #True)
MaterialShadingMode(0, #PB_Material_Wireframe)

SetMeshMaterial(0, MaterialID(0))

Centre = CreateNode(#PB_Any)
AttachNodeObject(Centre, MeshID(0))
ScaleNode(Centre, #scale, #scale, #scale)

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 40, 150, #PB_Absolute)
CameraFOV(0, 40)
CameraLookAt(0, NodeX(Centre),  NodeY(Centre),  NodeZ(Centre))
CameraBackColor(0, $330000)

CreateLight(0, RGB(55,55,255), -10, 60, 10)
CreateLight(0, RGB(255,55,55), 10, 60, -10)
AmbientColor(RGB(90, 90, 90))

Convert2DTo3D(0, CameraViewWidth(0)-140, 60, Depth)
Text3D(0, "               ", RGBA(255, 255, 0, 255),
       #PB_Text3D_Left | #PB_Text3D_Bottom, sx, sy, sz, 10, 10)

Convert2DTo3D(0, CameraViewWidth(0)/2, CameraViewHeight(0)-60, Depth)
Text3D(1, "SuperQuadratics", RGBA(  0, 255, 0, 255),
       #PB_Text3D_HorizontallyCentered | #PB_Text3D_VerticallyCentered, sx, sy, sz, 10, 10)

Convert2DTo3D(0, 40, 50, Depth)
Text3D(3, "Use cursor to change SuperQuadratics  ", RGBA(255, 255, 255, 255),
       #PB_Text3D_Left | #PB_Text3D_VerticallyCentered, sx, sy, sz, 6, 6)

Convert2DTo3D(0, 40, 100, Depth)
Text3D(2, "Use [F2]/[F3] - Change Render Material", RGBA(255, 255, 255, 255),
       #PB_Text3D_Left | #PB_Text3D_VerticallyCentered, sx, sy, sz, 6, 6)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_F2)
      MaterialShadingMode(0, #PB_Material_Wireframe)
    ElseIf KeyboardReleased(#PB_Key_F3)
      MaterialShadingMode(0, #PB_Material_Solid)
    EndIf
    
    If KeyboardPushed(#PB_Key_Right)
      Epsilon2 + 0.01
    ElseIf KeyboardPushed(#PB_Key_Left) And Epsilon2 > 0.01
      Epsilon2 - 0.01
    EndIf
    
    If KeyboardPushed(#PB_Key_Up)
      Epsilon1 + 0.01
    ElseIf KeyboardPushed(#PB_Key_Down) And Epsilon1 > 0.01
      Epsilon1 - 0.01
    EndIf
    
  EndIf
  
  UpdateSuperQuadratics()
  
  RotateNode(Centre, 0.3, 0.3, 0.3, #PB_Relative)
  
  Text3DCaption(0, StrF(Engine3DStatus(#PB_Engine3D_CurrentFPS), 2))
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

End

Macro Vertex(T, P, C)
  x = CalculateX(T, P)
  y = CalculateY(T, P)
  z = CalculateZ(P)
  
  ;nx = CalculateNX(T, P)
  ;ny = CalculateNY(T, P)
  ;nz = CalculateNZ(P)
  
  MeshVertexPosition(x, y, z)
  ;MeshVertexNormal(nx, ny, nz)
  If #Color
    MeshVertexColor(RGB(Abs(x*C),Abs(y*C), Abs(z*C)))
  EndIf
EndMacro

Macro SuperCos(Angle, Epsilon)
  (Pow(Abs(Cos(Angle)), Epsilon) * Sign(Cos(Angle)))
EndMacro

Macro SuperSin(Angle, Epsilon)
  (Pow(Abs(Sin(Angle)), Epsilon) * Sign(Sin(Angle)))
EndMacro

Procedure.d CalculateX(Theta.d, Phi.d)
  ProcedureReturn SuperCos(Phi, Epsilon1) * SuperCos(Theta, Epsilon2)
EndProcedure

Procedure.d CalculateY(Theta.d, Phi.d)
  ProcedureReturn SuperCos(Phi, Epsilon1) * SuperSin(Theta, Epsilon2)
EndProcedure

Procedure.d CalculateZ(Phi.d)
  ProcedureReturn SuperSin(Phi, Epsilon1)
EndProcedure

Procedure.d CalculateNX(Theta.d, Phi.d)
  ProcedureReturn SuperCos(Phi, 2.0-Epsilon1) * SuperCos(Theta, 2.0-Epsilon2)
EndProcedure

Procedure.d CalculateNY(Theta.d, Phi.d)
  ProcedureReturn SuperCos(Phi, 2.0-Epsilon1) * SuperSin(Theta, 2.0-Epsilon2)
EndProcedure

Procedure.d CalculateNZ(Phi.d)
  ProcedureReturn SuperSin(Phi, 2.0-Epsilon1)
EndProcedure

Procedure CreateSuperQuadratics()
  CreateMesh(0, #PB_Mesh_TriangleList, #PB_Mesh_Dynamic)
  SuperQuadratics()
  FinishMesh(#False)
EndProcedure

Procedure UpdateSuperQuadratics()
  UpdateMesh(0, 0)
  SuperQuadratics()
  FinishMesh(#False)
EndProcedure

Procedure SuperQuadratics()
  
  Protected.d Theta, Phi, Delta = #Delta
  Protected.d x, y, z, nx, ny, nz
  Co = #scale*8
  
  Theta = -#PI
  Phi = -0.5 * #PI
  While Theta <= #PI
    While Phi <= 0.5 * #PI
      
      Vertex(Theta, Phi, Co)
      Vertex(Theta + Delta, Phi, Co)
      Vertex(Theta + Delta, Phi + Delta, Co)
      Vertex(Theta, Phi + Delta, Co)
      
      MeshFace(VertexIndex, VertexIndex + 1, VertexIndex + 2)
      MeshFace(VertexIndex, VertexIndex + 2, VertexIndex + 3)
      
      VertexIndex + 4
      
      Phi + Delta
    Wend
    Phi = -0.5 * #PI
    Theta + Delta
  Wend
  
EndProcedure