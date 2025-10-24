; onde 3D - Pf shadoko - 2015

EnableExplicit


Macro f3:vector3:EndMacro

Structure MeshVertexV
    p.f3
    n.f3
    t.f3
    u.f
    v.f
    color.l
EndStructure

Macro add3d(p,p1,p2)
    p\x=p1\x+p2\x
    p\y=p1\y+p2\y
    p\z=p1\z+p2\z
EndMacro

Macro sub3D(p,p1,p2)
    p\x=p1\x-p2\x
    p\y=p1\y-p2\y
    p\z=p1\z-p2\z
EndMacro

Macro lng3D(v)
    Sqr(V\x * V\x + V\y * V\y + V\z * V\z)
EndMacro

Procedure Norme3D(*V.f3,l.f=1)
    Protected.f lm
    lm = l / lng3D(*v)
    *V\x * lm
    *V\y * lm
    *V\z * lm  
EndProcedure

Procedure cross3d(*r.f3,*p.f3,*q.f3)
    *r\x=*p\y * *q\z - *p\z * *q\y 
    *r\y=*p\z * *q\x - *p\x * *q\z 
    *r\z=*p\x * *q\y - *p\y * *q\x 
EndProcedure

Procedure NormalizeMesh2(mesh)
	Protected nv,ni,i,sm,f0,f1,f2
	Protected.f3 ps,v1,v2,ecart
	
	For sm=0 To SubMeshCount(mesh)-1
		nv=MeshVertexCount(mesh,sm)-1
		ni=MeshIndexCount(mesh,sm)-1
		Dim v.MeshVertexv(nv)
		Dim f.MeshFace(ni)
		GetMeshData(mesh,sm,v(),#PB_Mesh_Vertex,0,nv)  
		GetMeshData(mesh,sm,f(),#PB_Mesh_Face,0,ni) 
		For i=0 To ni Step 3
			f0=f(i  )\Index
			f1=f(i+1)\Index
			f2=f(i+2)\Index
			sub3d(v1,v(f1)\p,v(f0)\p)
			sub3d(v2,v(f2)\p,v(f0)\p)
			cross3d(ps,v1,v2)
			add3d(v(f0)\n,v(f0)\n,ps)
			add3d(v(f1)\n,v(f1)\n,ps)
			add3d(v(f2)\n,v(f2)\n,ps)
		Next
		For i=0 To nv:Norme3D(v(i)\n,1):Next
		SetMeshData(mesh,sm,v(),#PB_Mesh_Normal,0,nv)
	Next
EndProcedure

Structure Tonde
  cpt.l
  lv.w
  ct.w
  ef.b
  GoNb.b
  dx.w
  dy.w
  Array a0.w(0,0)
  Array a1.w(0,0)
  Array a2.w(0,0)
  Array a3.w(0,0)
  Array Tonde.w(255)
  Array gocp.l(63)
  Array mx.l(63)
  Array my.l(63)
EndStructure

Procedure onde2D(*o.tonde)
  Macro sinL(a, li, ls)
    (Sin(a / 512) + 1) * (ls - li) / 2 + li
  EndMacro
  Protected i,j,pox,poy,aa1
  With *o
    If \cpt=0
      Dim \a0(\dy - 1,\dx - 1)
      Dim \a1(\dy - 1,\dx - 1)
      Dim \a2(\dy - 1,\dx - 1)
      Dim \a3(\dy - 1,\dx - 1)
      Dim \Tonde(255)
      Dim \gocp(63)
      Dim \mx(63)
      Dim \my(63)
      For i = 0 To \lv: \tonde(i) = \ct * \lv*Sin((2 * i * #PI)/\lv ): Next
      For i = 0 To \GoNb - 1: \gocp(i) = i * (\lv / \GoNb): \mx(i) = 0: \my(i) = 0: Next
    ElseIf \cpt<500
      ; arrivée des perturbations
      If \ef<4
      For i = 0 To \GoNb - 1
        If \gocp(i) = 0
          Select \ef
            Case 1: pox = Random (\dx - 16,16)         : poy = Random (\dy - 16,16)
            Case 2: pox = sinL(\cpt * 40, 16, \dx - 16): poy = sinL(\cpt * 48, 16, \dy - 16)
            Case 3: pox = sinL(\cpt * 20, 16, \dx - 16): poy = sinL(\cpt * 24, 16, \dy - 16)
          EndSelect
          \mx(i) = pox
          \my(i) = poy
        EndIf
        \a1( \my(i),\mx(i))  - \tonde(\gocp(i))
        \gocp(i) = (\gocp(i) + 1) % \lv
      Next
    Else
      \a1(\dy/2,\dx/2)-Sin(\cpt/\lv*5/3*#PI)*\ct*40
    EndIf
  EndIf
    ; propagation (si un programmeur ASM veut bien convertir cette routine...)
    CopyArray(\a1(),\a0())
    CopyArray(\a2(),\a1())
    For j = 1 To \dy-2
      For i = 1 To \dx-2
        aa1 = \a1(j,i) /2
        \a2(j,i + 1) + aa1
        \a2(j,i - 1) + aa1
        \a2(j + 1,i) + aa1
        \a2(j - 1,i) + aa1
        \a2(j,i) - \a1(j,i) - \a0(j,i)
      Next
    Next
    ; amortissement temporel
    For j = 1 To \dy-2
      For i = 1 To \dx-2
        \a3(j,i)+ (\a2(j,i) - \a3(j,i))*0.2
      Next
    Next
    ; attenuation (sur les bords), mettez en commentaire, l'onde se reflechira !
    If \ef<4
    For i = 0 To \dx - 1: \a1(1,i)/2: \a1(\dy-2,i)/2: Next
    For j = 0 To \dy - 1: \a1(j,1)/2: \a1(j,\dx-2)/2: Next 
    EndIf
    \cpt+1
  EndWith
  
EndProcedure

Procedure planmodif(*o.tonde)
  Protected i,j
  Protected Dim MeshData.MeshVertex(0)
  onde2d(*o)
  GetMeshData(0, 0, MeshData(), #PB_Mesh_Vertex,0, MeshVertexCount(0,0)-1)
  For j=2 To *o\dy-3
    For i=2 To *o\dx-3
  ;    MeshData(j* *o\dx+i)\y =-*o\a3(j,i)/64
    Next
  Next
  ;SetMeshData(0,0, MeshData(), #PB_Mesh_Vertex, 0, MeshVertexCount(0,0)-1)
  ;NormalizeMesh2(0)
EndProcedure

Define.f KeyX, KeyY,keyz, MouseX, MouseY
Define i,j,modif,cpt,ex,ey,CubeMapTexture,p
Define o.tonde
o\dx= 128     ;essayez avec 256 pour les machines un peu rapide
o\dy= 128     ;                    "           "      
o\lv = 8*2    ;largeur des vagues (valeur minimum: 8) 
o\ct = 64*2   ;hauteur des vagues
o\ef = 1      ;effets [F1/F2/F3/F4]
o\GoNb = 8    ;nombre de "gouttes" simultanées

modif=1  
cpt=0   

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

OpenWindow(0, 0, 0, 400,400, "Onde 2D")
ex=WindowWidth (0,#PB_Window_InnerCoordinate)
ey=WindowHeight(0,#PB_Window_InnerCoordinate)
OpenWindowedScreen(WindowID(0), 0, 0, ex, ey, 0, 0, 0 ,#PB_Screen_NoSynchronization)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0, -500, 300, -500, #PB_Absolute):CameraLookAt(0, 0, 100, 0):CameraFOV(0,45)
SkyBox("desert07.jpg")
CreateLight(0,$777777, -10000, 10000, -10000)
AmbientColor($888888)

;AmbientColor($111111* 4)
Fog($ffffff,1,10000,10001);     <---  !!!   required to use these shaders !!!

;CreateLight(0, $111111* 8*10, 8000, 4000,0)

CompilerIf 0
Macro lt(face):LoadTexture(#PB_Any,"desert07_"+face+".jpg"):EndMacro
CompilerIf #PB_Compiler_Version < 620
  CreateCubicTexture(0,lt("RT"),lt("LF"),lt("UP"),lt("DN"),lt("FR"),lt("BK"))
CompilerElse
  CreateCubicTexture(0,lt("px"),lt("nx"),lt("py"),lt("ny"),lt("pz"),lt("nz"))
CompilerEndIf
CreateTexture(1,1,1):StartDrawing(TextureOutput(1)):DrawingMode(#PB_2DDrawing_AllChannels):Box(0,0,1,1,$ff0000ff):StopDrawing()
CreateShaderMaterial(1,#PB_Material_CubicEnvShader)
MaterialShaderTexture(1,TextureID(0),TextureID(1),0,0)
MaterialShaderParameter(1,1,"glossy",#PB_Shader_Float,0.8,0,0,0)
CreatePlane(0,1025,1025,o\dx-1,o\dy-1,1,1)
CreateEntity(0, MeshID(0), MaterialID(1))

CreateShaderMaterial(2, #PB_Material_CubicEnvShader)
MaterialShaderTexture(2,TextureID(0),LoadTexture(2,"MRAMOR6X6.jpg"),0,0)
MaterialShaderParameter(2,1,"glossy",#PB_Shader_Float,0.8,0,0,0)
For i=-1 To 1
  For j=-1 To 1
    If i<>0 Or j<>0:CreateEntity(-1,CreateCube(1,1000), MaterialID(2),i*1000,-480,j*1000):EndIf
  Next
Next
CompilerEndIf

;Define Mesh = CreateCube(#PB_Any, 0.000000001)
Define Mesh = LoadMesh(#PB_Any, "robot.mesh")

;- Texture
Define Texture = CreateTexture(#PB_Any, 512, 512)

;- Material
Define Material = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any, "r2skin.jpg")))
AddMaterialLayer(Material, TextureID(Texture), #PB_Material_Add)

;- Entity
Define Entity = CreateEntity(#PB_Any, MeshID(Mesh), MaterialID(Material))
;HideEntity(Entity, 1)
;StartEntityAnimation(Entity, "Walk")
;RotateEntity(Entity, 0, -90, 0)

;Material = CreateMaterial(#PB_Any, LoadTexture(0, "clouds.jpg"))
;RotateMaterial(Material, 0.05, 1)

; Then create the billboard group and use the previous material
;
;Define Billboard = CreateBillboardGroup(#PB_Any, MaterialID(Material), 10, 10)

; AddBillboard(Billboard, -20, 20, 0)
; AddBillboard(Billboard,   0, 20, 0)
; AddBillboard(Billboard,  20, 20, 0)


Procedure menu()
  Protected p=4
  Macro DT(t1,etat=-1)
    DrawText(8,p,t1)
    If etat=0:DrawText(140,p,"OFF"):ElseIf etat=1:DrawText(140,p,"ON"):EndIf
    p+17
  EndMacro
  CreateSprite(0,180,180,#PB_Sprite_AlphaBlending)
  StartDrawing(SpriteOutput(0))
  DrawingMode(#PB_2DDrawing_AllChannels)
  DrawingFont(FontID(0))
  Box(0,0,180,180,$22ffffff)
  DrawingMode(#PB_2DDrawing_AllChannels|#PB_2DDrawing_Outlined)
  Box(0,0,180,180,$44ffffff)
  DrawingMode(#PB_2DDrawing_AllChannels)
  BackColor($22ffffff)
  FrontColor($ffffffff)
  dt("Moving :")
  dt("Arrow keys + Mouse")
  dt("")
  dt("Controls :")
  ;dt("[F1] Diffuse light",diff)
  ;dt("[F2] Specular light",spec)
  ;dt("[F3] Global rotation",rotg)
  ;dt("[F4] Local rotation",rotl)
  dt("[F12] Wireframe")
  dt("[Esc] / [Click]   Quit")
  StopDrawing()
EndProcedure

LoadFont(0,"arial",10)
menu()


i = 0
Repeat
  While WindowEvent():Wend
  ExamineMouse()
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  ExamineKeyboard()
  keyx=(-Bool(KeyboardPushed(#PB_Key_Left)<>0)+Bool(KeyboardPushed(#PB_Key_Right)<>0))*2
  keyy=(-Bool(KeyboardPushed(#PB_Key_Up  )<>0)+Bool(KeyboardPushed(#PB_Key_Down )<>0))*2+-MouseWheel()*50
  modif+Bool(KeyboardReleased(#PB_Key_Space)<>0)
  If KeyboardReleased(#PB_Key_F1):o\cpt=0:o\ef=1:modif=1:EndIf
  If KeyboardReleased(#PB_Key_F2):o\cpt=0:o\ef=2:modif=1:EndIf
  If KeyboardReleased(#PB_Key_F3):o\cpt=0:o\ef=3:modif=1:EndIf
  If KeyboardReleased(#PB_Key_F4):o\cpt=0:o\ef=4:modif=1:EndIf
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, keyz, KeyY)
  cpt+1
  
  If i > 0
    ;FreeEntity(Entity)
  EndIf
  If (modif & 1) And (cpt%2=0):planmodif(o):EndIf
  RenderWorld()
  glClear_(#GL_DEPTH_BUFFER_BIT)
  SetWindowTitle(0, "FPS: "+ Engine3DStatus(#PB_Engine3D_AverageFPS))
  
  menu()
  DisplayTransparentSprite(0, 8,8, 50) ; bug avec l'alpha
  ;DisplayTransparentSprite(0, 108, 108, 255) ; bug avec l'alpha
  
  FlipBuffers()
  i+1
Until KeyboardPushed(#PB_Key_Escape) Or MouseButton(3)
