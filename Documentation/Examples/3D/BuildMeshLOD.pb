
; ------------------------------------------------------------
;
;   PureBasic - BuildMeshLOD
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

InitEngine3D()
InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "BuildMeshLOD - [F12] Wireframe/Solid  - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home+"Examples/3D/Data/Packs/Sinbad.zip", #PB_3DArchive_Zip)

Parse3DScripts()

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,30,20,-20):CameraLookAt(0,0,0,40)
CreateLight(0,$ffffff, -10000, 10000, 0)
AmbientColor($111111*3)
CameraBackColor(0,$444488)

; automatic creation of lod
LoadMesh(0, "Sinbad.mesh")
BuildMeshLOD(0,4,40,0.5)

; manual creation of lod
CreateSphere(1,4,32,32)
CreateSphere(2,4,16,16):AddMeshManualLOD(1,2,40)
CreateSphere(3,4,8,8):AddMeshManualLOD(1,3,80)
CreateSphere(4,4,4,4  ):AddMeshManualLOD(1,4,160)
AddMeshManualLOD(1,4,0)

 CreateSphere(5,4,32,32)
CreateSphere(6,4,16,16):AddMeshManualLOD(5,6,40)
CreateSphere(7,4,8,8):AddMeshManualLOD(5,7,80)
CreateSphere(8,4,4,4  ):AddMeshManualLOD(5,8,160)
AddMeshManualLOD(5,8,0)

For i=0 To 20
  CreateEntity(-1,MeshID(0),0,   0,0,i*15)
  CreateEntity(-1,MeshID(1),0, -20,0,i*15)
  CreateEntity(-1,MeshID(5),0,  20,0,i*15)
Next

Define.f a,da,r,MouseX,Mousey,depx,depz,depza,Wireframe=1
Repeat
	While WindowEvent():Wend
	ExamineKeyboard()
	ExamineMouse()
  If KeyboardReleased(#PB_Key_F12):Wireframe=1-Wireframe:EndIf
  If Wireframe:CameraRenderMode(0, #PB_Camera_Wireframe):Else:CameraRenderMode(0, #PB_Camera_Textured):EndIf
	depx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*1
	depz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   ))+MouseWheel()*10)*1
	MouseX = -MouseDeltaX() *  0.05
	MouseY = -MouseDeltaY() *  0.05
	RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
	depza+(depz-depza)*0.05:MoveCamera  (0, depX, 0, -depza)
	
	RenderWorld()
	FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)

