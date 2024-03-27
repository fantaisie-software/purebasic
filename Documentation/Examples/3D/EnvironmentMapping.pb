;
; ------------------------------------------------------------
;
;   PureBasic - Environment mapping
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

Define.f a,da,r,MouseX,Mousey,depx,depz,dist

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops()
OpenWindow(0, 0,0, DesktopWidth(0)*0.8,DesktopHeight(0)*0.8, "Environment mapping - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0), 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(GetCurrentDirectory(), #PB_3DArchive_FileSystem )
Parse3DScripts()

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,2,0):CameraLookAt(0,0,0,10)
CreateLight(0, $ffffff, 8000, 5700,4500);  ;light on the sun of the skybox !
AmbientColor($444444)

; Ground
LoadTexture(0, "MRAMOR6X6.jpg")
CreateMaterial(0,TextureID(0))
CreatePlane(0,256,256,1,1,32,32)
CreateEntity(0,MeshID(0),MaterialID(0))

; objects
CreateSphere(0,1.5,32,32)
CreateCapsule(1,1,1.5)
CreateCylinder(2,1.5,2,32,1,1)
CreateTorus(3,1.5,0.6,32,32)
CreateCube(4,2.5)

tx_rock_diff=LoadTexture(#PB_Any,"dirt_grayrocky_diffusespecular.jpg")
tx_rock_normal=LoadTexture(#PB_Any,"dirt_grayrocky_normalheight.jpg")

Dim tx_Cubic(50)
Debug  #PB_Shader_Float
For j=0 To 6
	For i=0 To 6
		c+1
		CreateShaderMaterial(c, #PB_Material_CubicEnvBumpShader)
		tx_Cubic(c) = CreateCubeMapTexture(#PB_Any, 512,#PB_Texture_ManualUpdate, "")
		MaterialShaderTexture(c,TextureID(tx_Cubic(c)),TextureID(tx_rock_diff),TextureID(tx_rock_normal),0)
		SetMaterialAttribute(c,#PB_Material_TAM,#PB_Material_ClampTAM,0)
		SetMaterialColor(c,#PB_Material_AmbientColor|#PB_Material_DiffuseColor,RGBA(127*Random(2),127*Random(2),127*Random(2),0))
		MaterialShaderParameter(c,#PB_Shader_Fragment,"bumpy",#PB_Shader_Float, Random(1,0)*0.2,0,0,0)
		MaterialShaderParameter(c,#PB_Shader_Fragment,"glossy",#PB_Shader_Float,Random(2,1)*0.2,0,0,0)
		CreateEntity(c,MeshID(c%5),MaterialID(c), (i-3)*8,2,(j-3)*8)
		RotateEntity(c,Random(360),Random(360),Random(360),#PB_Absolute)
		EntityCubeMapTexture(tx_Cubic(c), c)  ; <- associate the entity to position the cubic texture
	Next
Next

; get the cubic texture (2 pass for better result)
For j=0 To 1
	For i=1 To c
		UpdateRenderTexture(tx_Cubic(i))
	Next
Next

; apply the ground reflection
CreateCamera(1,0,0,100,100)
CreateRenderTexture(1,CameraID(1),ScreenWidth()/1,ScreenHeight()/1)
AddMaterialLayer(0,TextureID(1),#PB_Material_ModulateX2)
SetMaterialAttribute(0,#PB_Material_ProjectiveTexturing,1,1)

Repeat
	While WindowEvent() : Wend
	ExamineKeyboard()
	ExamineMouse()
	depx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.1
	depz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.1+MouseWheel()*2
	MouseX = -MouseDeltaX() *  0.05
	MouseY = -MouseDeltaY() *  0.05
	RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
	dist+(depz-dist)*0.05:MoveCamera  (0, depX, 0, -dist)
	CameraReflection(1,0,EntityID(0))
	RenderWorld()
	FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)
