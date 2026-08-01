
; ------------------------------------------------------------
;
;   PureBasic - Reflection
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Use the keyboard arrows to move/roll the plan
; Use F12 to switch between wireframe and textured
;

Define.f MouseX,Mousey, a, ap, dp, co, si

Procedure.f POM(v.f)
  ProcedureReturn (Random(v*1000)-v*500)/500
EndProcedure

Procedure SetupMaterial(n, Filename$, scale.f=1)
  LoadTexture(n, Filename$)
  CreateMaterial(n,TextureID(n))
  ScaleMaterial(n,0.5/scale,1/scale)
EndProcedure

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Reflection -          [Arrows] mirror moving   [F12] Wireframe    [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,0,20,-40)
CameraLookAt(0, 0,0,0)
CreateLight(0,$ffffff, 10000, 5000, 2000)
AmbientColor($888888)

CreateCamera(1,0,0,100,100)
CreateRenderTexture(0,CameraID(1),ScreenWidth()/1,ScreenHeight()/1)
CreateMaterial(1,TextureID(0))
SetMaterialAttribute(1,#PB_Material_ProjectiveTexturing,1)
LoadTexture(1, "MRAMOR6X6.jpg")
AddMaterialLayer(1,TextureID(1),#PB_Material_Modulate)
CreatePlane(1,100,100,1,1,4,4)
CreateEntity(1,MeshID(1),MaterialID(1))

SetupMaterial(2, "RustySteel.jpg",2)
SetupMaterial(3, "Dirt.jpg",2)
SetupMaterial(4, "soil_wall.jpg",2)
SetupMaterial(5, "Wood.jpg",2)

CreateIcoSphere(0,3,3)
For i=100 To 150
  CreateEntity(i,MeshID(0),MaterialID(2+Random(3)),pom(32),pom(4),pom(32))
  ScaleEntity(i,1,1+pom(0.7),1)
  RotateEntity(i,pom(180),pom(180),pom(180))
Next

Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  ExamineKeyboard()
  ap+(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.01
  dp-(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.1
  If KeyboardReleased(#PB_Key_F12) : fdf=1-fdf : If fdf : CameraRenderMode(0,#PB_Camera_Wireframe) : Else : CameraRenderMode(0,#PB_Camera_Textured) : EndIf : EndIf
  a+0.002
  MoveCamera(0,Cos(a)*50,10,Sin(a)*50,#PB_Absolute)
  CameraLookAt(0,0,0,0)
  
  co=Cos(ap)
  si=Sin(ap)
  MoveEntity(1,si*dp,-co*dp,0, #PB_Absolute)
  EntityDirection(1, si, co, 0, #PB_World, #PB_Vector_Y)
  
  CameraReflection(1,0,EntityID(1))
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)

