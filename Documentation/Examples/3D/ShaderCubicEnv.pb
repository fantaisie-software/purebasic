
; ------------------------------------------------------------
;
;   PureBasic - Shader Cubic Environment
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "CreateShaderMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

SkyBox("desert07.jpg")

tx_Cubic=LoadTexture(#PB_Any,"desert07.jpg")
tx_rock_diff=LoadTexture(#PB_Any,"dirt_grayrocky_diffusespecular.jpg")
tx_rock_normal=LoadTexture(#PB_Any,"dirt_grayrocky_normalheight.jpg")

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,2,0):CameraLookAt(0,2,0,10)
CreateLight(0, $ffffff, 8000, 5700,4500);  ;light on the sun of the skybox !
AmbientColor($444444)

CreateCylinder(0,1.5,2,32,1,1)
CreateCapsule(1,1,1.5)
CreateSphere(2,1.5,32,32)
CreateTorus(3,1.5,0.6,32,32)
CreateCube(4,2.5)

For i=0 To 9
	CreateShaderMaterial(i,#PB_Material_CubicEnvBumpShader)
	MaterialShaderTexture(i,TextureID(tx_Cubic),TextureID(tx_rock_diff),TextureID(tx_rock_normal),0)
	SetMaterialAttribute(i,#PB_Material_TAM,#PB_Material_ClampTAM,0)
	SetMaterialColor(i,3,RGB(128+Random(127),128+Random(127),128+Random(127)))
	MaterialShininess(i,32*Pow(2,Random(5)),$ffffff)
	MaterialShaderParameter(i,#PB_Shader_Fragment,"bumpy",#PB_Shader_Float,Random(3,0)/3,0,0,0)
	MaterialShaderParameter(i,#PB_Shader_Fragment,"glossy",#PB_Shader_Float,Random(3,1)/6,0,0,0)
	CreateEntity(i,MeshID(i%5),MaterialID(i)):RotateEntity(i,Random(360),Random(360),Random(360),#PB_Absolute)
Next

Define.f a,da,r,MouseX,Mousey,depx,depz,dist

Repeat
	While WindowEvent():Wend
	ExamineKeyboard()
	ExamineMouse()
	depx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.1
	depz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.1+MouseWheel()*2
	MouseX = -MouseDeltaX() *  0.05
	MouseY = -MouseDeltaY() *  0.05
	RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
	dist+(depz-dist)*0.05:MoveCamera  (0, depX, 0, -dist)
	da+0.001
	For i=0 To 9
		a.f=i*2*#PI/10+da
		MoveEntity(i,Cos(a)*8,2,Sin(a)*8,#PB_Absolute)
		RotateEntity(i,0.2,0.2,0.2,#PB_Relative)
	Next
	RenderWorld()
	FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)

