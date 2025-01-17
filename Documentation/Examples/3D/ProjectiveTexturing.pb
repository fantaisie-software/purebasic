
; ------------------------------------------------------------
;
;   PureBasic - Projective Texturing
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Use the keyboard arrows to move the card
; Use F12 to switch between wireframe and textured
;

Define.f MouseX, MouseY, cx, cz=1

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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Projective Texturing -  [F12]  [Arrow keys] : Orient camera     [Esc] : Quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Parse3DScripts()

SetupMaterial(1, "grass.jpg",2)
SetupMaterial(2, "Dirt.jpg",2)
SetupMaterial(3, "RustySteel.jpg",2)

CreateCamera(1,0,0,2,4)
CameraFOV(1,40)
MoveCamera(1,0,80,0)

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,0,80,-80)
CameraLookAt(0, 0,0,0)
CreateLight(0,$ffffff, 10000, 000, 2000)
AmbientColor($888888)

For i=1 To 3
  LoadTexture(0,  "ValetCoeur.jpg")
  AddMaterialLayer(i,TextureID(0),#PB_Material_Add)
  SetMaterialAttribute(i,#PB_Material_ProjectiveTexturing,1,1)
  SetMaterialAttribute(i,#PB_Material_TAM,#PB_Material_BorderTAM,1)
Next
CreatePlane(1,200,200,1,1,4,4)
CreateEntity(1,MeshID(1),MaterialID(1))
CreateIcoSphere(0,15,3)
For i=2 To 50
  CreateEntity(i,MeshID(0),MaterialID(Random(3,2)),pom(80),pom(0),pom(80))
  ScaleEntity(i,1+pom(0.5),0.5,1+pom(0.5))
  RotateEntity(i,0,pom(180),0)
Next

Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  ExamineKeyboard()
  cx-(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*1
  cz+(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*1
  If KeyboardReleased(#PB_Key_F12):fdf=1-fdf:If fdf:CameraRenderMode(0,#PB_Camera_Wireframe):Else:CameraRenderMode(0,#PB_Camera_Textured):EndIf:EndIf
  CameraLookAt(1,cx,0,cz)
  CreateLine3D(100,CameraX(1),CameraY(1),CameraY(1),$ffffff,cx,0,cz,$ffffff)
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)

