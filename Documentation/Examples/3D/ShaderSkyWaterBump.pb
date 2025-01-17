
; ------------------------------------------------------------
;
;   PureBasic - Shader Sky Water Bump
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "CreateShaderMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia", #PB_3DArchive_FileSystem)
Add3DArchive(GetCurrentDirectory(), #PB_3DArchive_FileSystem )
Parse3DScripts()

#end_distance=1000

tx_water=LoadTexture(#PB_Any,"waternormal.png")
tx_sky=LoadTexture(#PB_Any,"sky.png")
tx_rock_diff=LoadTexture(#PB_Any,"dirt_grayrocky_diffusespecular.jpg")
tx_rock_normal=LoadTexture(#PB_Any,"dirt_grayrocky_normalheight.jpg")

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,2,0):CameraLookAt(0,2,0,10)
CreateLight(0,$ffffff, -1000, 1000, 00)
AmbientColor($444444)
Fog($8888aa,1,0,#end_distance):CameraBackColor(0,$8888aa)

;water
CreateShaderMaterial(0,#PB_Material_WaterShader)
MaterialShaderTexture(0,TextureID(tx_water),0,0,0)
SetMaterialColor(0,2,$00332200)
SetMaterialColor(0,4,$ffaa8866)
MaterialShininess(0,64)
MaterialFilteringMode(0,#PB_Material_Anisotropic)
CreatePlane(0,#end_distance*2,#end_distance*2,1,1,128,128)
CreateEntity(0,MeshID(0),MaterialID(0))

SkyDome(TextureID(tx_sky),$cc6600,$0088ff,3,400,-0.5,0)

CreateSphere(2,1.5,32,32)
CreateTorus(3,1.5,0.6,32,32)
CreateCube(4,2.5)
CreateCylinder(5,1.5,2,32,1,1)
CreateCapsule(6,1,1.5)

For i=0 To 9
	CreateShaderMaterial(i+2,#PB_Material_BumpShader)
	MaterialShaderTexture(i+2,TextureID(tx_rock_diff),TextureID(tx_rock_normal),0,0)
	SetMaterialColor(i+2,3,RGB(128+Random(127),128+Random(127),128+Random(127)))
	MaterialShininess(i+2,32*Pow(2,Random(5)),$ffffff)
	MaterialShaderParameter(i+2,#PB_Shader_Fragment,"bumpy",#PB_Shader_Float,Random(3,0)/2,0,0,0)
	CreateEntity(i+2,MeshID(i%5+2),MaterialID(i+2)):RotateEntity(i+2,Random(360),Random(360),Random(360),#PB_Absolute)
Next

Define.f a,da,r,MouseX,Mousey,depx,depz,dist

Repeat
	While WindowEvent():Wend
	ExamineKeyboard()
	ExamineMouse()
	depx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.1
	depz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.1+MouseWheel()*5
	MouseX = -MouseDeltaX() *  0.05
	MouseY = -MouseDeltaY() *  0.05
	RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
	dist+(depz-dist)*0.05:MoveCamera  (0, depX, 0, -dist)
	da+0.002
	For i=0 To 9
		a.f=(i-2)*2*#PI/10+da
		MoveEntity(i+2,Cos(a)*8,2,Sin(a)*8,#PB_Absolute)
		RotateEntity(2+i,0.5,0.5,0.5,#PB_Relative)
	Next
	
	MoveEntity(0,CameraX(0),0,CameraZ(0),#PB_Absolute)
	RenderWorld()
	FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)

