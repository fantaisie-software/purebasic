;
; ------------------------------------------------------------
;
;   PureBasic - Shader Ocean
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops()
OpenWindow(0, 0,0, DesktopWidth(0)*0.8,DesktopHeight(0)*0.8, "CreateShaderMaterial - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0), 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(GetCurrentDirectory(), #PB_3DArchive_FileSystem )
Parse3DScripts()

#end_distance=1000
#sky_height=200

#ocean_wavebig=0.5
#ocean_wavelittle=0.5
#ocean_swell=0.5
#ocean_foam=0.6

tx_sky=LoadTexture(#PB_Any,"sky.png")
tx_water=LoadTexture(#PB_Any,"waternormal.png")
tx_foam=LoadTexture(#PB_Any,"foam.png")

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,5,0):CameraLookAt(0,2,0,10)
CreateLight(0,$ffffff, -10000, 10000, 0)
AmbientColor($444444)
Fog($8888aa,1,0,#end_distance):CameraBackColor(0,$8888aa)

;ocean
CreateShaderMaterial(0,#PB_Material_OceanShader)
MaterialShaderTexture(0,TextureID(tx_water),TextureID(tx_foam),0,0)
SetMaterialColor(0,#PB_Material_AmbientColor,$ff664400)	;water color
SetMaterialColor(0,#PB_Material_DiffuseColor,$ff886644)	;water sky reflect
MaterialShininess(0,64,$ffffff)			
MaterialFilteringMode(0,#PB_Material_Anisotropic)
MaterialShaderParameter(0,0,"wavebig",		1,#ocean_wavebig,0,0,0)
MaterialShaderParameter(0,0,"swell",			1,#ocean_swell,0,0,0)
MaterialShaderParameter(0,1,"wavelittle",	1,#ocean_wavelittle,0,0,0)
MaterialShaderParameter(0,1,"foam",				1,#ocean_foam,0,0,0)
CreatePlane(0,250,250,250,250,16,16)
CreateEntity(0,MeshID(0),MaterialID(0))
Debug #PB_Shader_Vector3
;sky
CreateShaderMaterial(1,#PB_Material_SkyShader)
MaterialShaderTexture(1,TextureID(tx_sky),0,0,0)
SetMaterialColor(1,#PB_Material_AmbientColor,$ff4400)
SetMaterialColor(1,#PB_Material_DiffuseColor,$0088ff)
MaterialCullingMode(1,#PB_Material_NoCulling)
MaterialShaderParameter(1,#PB_Shader_Fragment,"speed",#PB_Shader_Vector3,   2,0,0,0)
MaterialShaderParameter(1,#PB_Shader_Fragment,"height",#PB_Shader_Float,   #sky_height,0,0,0)
CreateSphere(1,1)
CreateEntity(1,MeshID(1),MaterialID(1))
ScaleEntity(1,#end_distance,#sky_height,#end_distance)


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
	
	MoveEntity(0,CameraX(0),0,CameraZ(0),#PB_Absolute)
	MoveEntity(1,CameraX(0),0,CameraZ(0),#PB_Absolute)
	RenderWorld()
	FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)
