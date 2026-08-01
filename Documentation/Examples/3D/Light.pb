
; ------------------------------------------------------------
;
;   PureBasic - Light
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.2

Procedure.l HSLToRGB(hue.a, saturation.a, lightness.a, alpha=0)
  Protected.f h=hue *6/256
  Protected.f s=saturation/255
  Protected.f l=lightness/255
  Protected.f c,x,r_,v_,b_,m
  c=(1-Abs(2*l-1))*s
  x=c*(1-Abs(Mod(h, 2) -1))
  Select Int(h)
    Case 0:r_=c:v_=x
    Case 1:r_=x:v_=c
    Case 2:v_=c:b_=x
    Case 3:v_=x:b_=c
    Case 4:r_=x:b_=c
    Case 5:r_=c:b_=x
  EndSelect
  m=l-c/2
  Protected r,v,b
  r=Int((r_+m)*255)
  v=Int((v_+m)*255)
  b=Int((b_+m)*255)
  ProcedureReturn RGBA(r,v,b,alpha)
EndProcedure

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Light - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main",#PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Sinbad.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_TextureAdditive, 50, $888888,2048)

; mesh
LoadMesh(0, "Sinbad.mesh")
CreateCylinder(1,10,2,64,1,1)

;texture
LoadTexture(1, "MRAMOR6X6.jpg")
LoadTexture(3, "flare.png")

;material
CreateMaterial(5,TextureID(1))
MaterialShininess(5,64,$ffffff)

;entity
CreateEntity (0, MeshID(0), 0,0,5,0)
StartEntityAnimation(0, "Dance")
CreateEntity (1, MeshID(1), MaterialID(5),0,-1,0)
EntityRenderMode(1, 0)

;light
Macro light(num,color,x,y,z)
  CreateLight(num,color,x,y,z)
  CreateMaterial(num, TextureID(3))
  MaterialBlendingMode(num,#PB_Material_Add)
  SetMaterialColor(num,#PB_Material_SelfIlluminationColor,color)
  SetMaterialColor(num,#PB_Material_DiffuseColor,0)
  CreateBillboardGroup(num,MaterialID(num),20,20,x,y,z)
  AddBillboard(num,0,0,0)
EndMacro
light(0,RGB(255,0,0), 10,5,0)
light(1,RGB(0,255,0),-10,5,0)
light(2,RGB(0,0,255),  0,10,5)

AmbientColor($222222)

;camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 5, 20, #PB_Absolute)
CameraLookAt(0,0,5,0)

Repeat
  While WindowEvent():Wend  
  ExamineMouse()
  ExamineKeyboard()
  
  MouseX = -MouseDeltaX() * 0.05
  MouseY = -MouseDeltaY() * 0.05
  
  KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
  Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up)-MouseWheel()*4)*#CameraSpeed    
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  ;light color change
  hue+1
  For num=0 To 2
    color=HSLToRGB((hue+num*80) & 255,255,128)
    SetLightColor(num,#PB_Light_DiffuseColor,color)
    SetLightColor(num,#PB_Light_SpecularColor,color)
    SetMaterialColor(num,#PB_Material_SelfIlluminationColor,color)
  Next
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1 Or MouseButton(3)
