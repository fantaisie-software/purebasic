
; ------------------------------------------------------------
;
;   PureBasic - Shader Point Sprite Sphere
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

Procedure.f POM(v.f)
    ProcedureReturn (Random(2000)-1000)*0.001*v
EndProcedure

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "CreateShaderMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,2,-100):CameraLookAt(0,0,0,0)
CreateLight(0,$ffffff, 0,0, 0)
AmbientColor($222222)

CreateMesh(0,#PB_Mesh_PointList)
For i=0 To 100000
	MeshVertex(pom(200),pom(200),pom(200),Random(64,8)*0.05,  0,RGB(Random(255),Random(255),Random(255)))
Next
FinishMesh(1)
CreateShaderMaterial(0,#PB_Material_PointSpriteSphereShader)
SetMaterialAttribute(0,#PB_Material_PointSprite,1)
MaterialShininess(0,64,$ffffff)

CreateEntity(0,MeshID(0),MaterialID(0))

Define.f a,da,r,MouseX,Mousey,depx,depz,dist,fly=1

Repeat
	While WindowEvent():Wend
	ExamineKeyboard()
	ExamineMouse()
	depx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.5
	depz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   ))+fly)*0.2+MouseWheel()*5
	MouseX = -MouseDeltaX() *  0.05
	MouseY = -MouseDeltaY() *  0.05
	RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
	dist+(depz-dist)*0.05:MoveCamera  (0, depX, 0, -dist)
	
	RenderWorld()
	FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)
