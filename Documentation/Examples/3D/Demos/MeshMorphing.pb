
; ------------------------------------------------------------
;
;   PureBasic - Shader examples
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Structure PB_MeshVertexV
  p.vector3
  n.vector3
  t.vector3
  u.f
  v.f
  color.l
EndStructure

Global n=64,n2=n/2
Global Dim p0.vector3(n,n)
Global Dim p1.vector3(n,n)
Global Dim t.PB_MeshVertexv(n,n) 

Define.f KeyX, KeyY, MouseX, MouseY, RollZ
Define cpt,co0,co1,co,cf,cf0,cf1,tx0,tx1, dt_trans=60*4,dt_tot=60*6
Define.f rx,ry,rz,trans 
Define ex, ey, i, j, fdf


Procedure ColorBlend(color1.l, color2.l, blend.f)
  Protected r.w,g.w,b.w,a.w
  r=  Red(color1) + (Red(color2)     - Red(color1)) * blend
  g=Green(color1) + (Green(color2) - Green(color1)) * blend
  b= Blue(color1) + (Blue(color2) -   Blue(color1)) * blend
  a=Alpha(color1) + (Alpha(color2) - Alpha(color1)) * blend
  ProcedureReturn  RGBA(r,g,b,a)
EndProcedure



Procedure material(n,tx,scale,culling,tx0=0,tx1=0)
  CreateShaderMaterial(n,0):MaterialShaderTexture(n,TextureID(tx0),TextureID(tx1),0,0)
  MaterialShininess(n,256,$ffffff)
  If culling:MaterialCullingMode(n,#PB_Material_AntiClockWiseCull):EndIf
  MaterialFilteringMode(n,#PB_Material_Anisotropic,4)
  ScaleMaterial(n,1/scale,1/scale)
EndProcedure



Procedure Mix3D(*R.Vector3, *V1.Vector3, *V2.Vector3, r.f)
  *R\x = *V1\x + r * (*V2\x - *V1\x)
  *R\y = *V1\y + r * (*V2\y - *V1\y)
  *R\z = *V1\z + r * (*V2\z - *V1\z)
EndProcedure



Procedure mesh_morph(r.f)
  Protected i, j
  
  For j=0 To n
    For i=0 To n
      Mix3D(t(i,j)\p,p0(i,j),p1(i,j) ,r)
    Next
  Next
  CreateDataMesh(0,t(),8+2)
  CreateEntity(0,MeshID(0),MaterialID(0))
  CreateEntity(1,MeshID(0),MaterialID(1))
EndProcedure



Procedure geometry(Array p.vector3(2),num,a.f,b.f,c.f,m=0)
  Protected.f u,v
  Protected i, j
  
  For j=0 To n
    For i=0 To n
      With p(i,j)  
        u=(j-n2*m)/n*2*#PI
        v=(i-n2*m)/n*2*#PI   
        Select num
          Case 0; double torre
            \x=(a+b*(Cos(u)*Sin(v/2)-Sin(u)*Sin(v)))*Cos(u*2)
            \y=(a+b*(Cos(u)*Sin(v/2)-Sin(u)*Sin(v)))*Sin(u*2)
            \z=-b*4*(Sin(u)*Sin(v/2)+Cos(u)*Sin(v))
          Case 1; sphere
            u/2
            \x=a*Sin(u)*Cos(v)
            \y=b*Sin(u)*Sin(v)
            \z=c*Cos(u)
          Case 2; shell
            u*4
            \x=(a+b*Cos(v))*Exp(c*u)*Cos(u)
            \y=(a+b*Cos(v))*Exp(c*u)*Sin(u)
            \z=(3*a+b*Sin(v))*Exp(c*u)-5
          Case 3; pillow
            u/2
            \x=a*Sin(u)
            \y=b*Sin(v)
            \z=c*Cos(u)*Cos(v)/Sqr(2)
          Case 4; tetraedra
            \x=a*Cos(u)
            \y=b*Cos(v)
            \z=-c*Cos(u+v)
          Case 5; flower
            \x=u*Cos(v)
            \y=u*Sin(v)
            \z=a*Cos(b*v)
          Case 6; hollow dice
            \x=a*Sin(u)
            \y=a*Sin(v)
            \z=a*Sin(u+v)
          Case 7; thing
            \x=a*(u/(1+u*u+v*v))
            \y=b*(v/(1+u*u+v*v))
            \z=-c*(u*v/(1+u*u+v*v))
          Case 8; drop
            u/2
            \x=b/2*a*Sin(u)*Cos(v)
            \y=b/2*a*Sin(u)*Sin(v)
            \z=8-a*4*Sin(u/2)
          Case 9; octaedra
            v/2
            \x=a*Pow(Cos(v),b)*Pow(Cos(u),c)
            \y=a*Pow(Cos(v),b)*Pow(Sin(u),c)
            \z=a*Pow(Sin(v),b)
          Case 10; berlingo
            u/#PI
            \x=b*a*(1+u)*Cos(v)
            \y=b*a*(1-u)*Sin(v)
            \z=-a*u
          Case 11 ;sort thing
            u/(2*#PI)
            b=3*Cos(u)/(Sqr(2)-a*Sin(2*u)*Sin(3*v))
            \x=b*(Cos(u)*Cos(2*v)+Sqr(2)*Sin(u)*Cos(v))
            \y=b*(Cos(u)*Sin(2*v)-Sqr(2)*Sin(u)*Sin(v))
            \z=-b*3*Cos(u)+8
        EndSelect
      EndWith 
    Next
  Next
EndProcedure



Procedure sample(Array p.vector3(2),num)
  ;num=1;If Random(1):num=12:Else:num=2:EndIf
  Select num
    Case 0:geometry(p(),0,4,1,0,0)
    Case 1:geometry(p(),1,8,6,3,0)
    Case 2:geometry(p(),2,3,4,-0.1,0)
    Case 3:geometry(p(),3,6,6,4,1)
    Case 4:geometry(p(),4,4,4,5,1)
    Case 5:geometry(p(),5,1,7,0,0)
    Case 6:geometry(p(),6,4,0,0,0)
    Case 7:geometry(p(),7,10,10,10,1)
    Case 8:geometry(p(),8,3,4,0,0)
    Case 9:geometry(p(),9,8,3,3,1)
    Case 10:geometry(p(),10,6,0.5,0,1)
    Case 11:geometry(p(),11,1,0,0,0)
    Case 12:geometry(p(),2,4,3,-0.15,0)
    Case 13:geometry(p(),5,2,3,0,0)
    Case 14:geometry(p(),9,7,3,1,1)
    Case 15:geometry(p(),9,6,1,3,1)
  EndSelect
EndProcedure



InitEngine3D()

ExamineDesktops()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Mesh morphing - [Space] pause  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures",#PB_3DArchive_FileSystem)
Parse3DScripts()
LoadTexture(0, "Dirt.jpg")
LoadTexture(1, "soil_wall.jpg")  
LoadTexture(2, "MRAMOR6X6.jpg")
LoadTexture(3, "Wood.jpg")
LoadTexture(4, "DosCarte.png")
LoadTexture(5, "RustySteel.jpg")
CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,0,-18):CameraLookAt(0,0,0,0)
CreateLight(0,$ffffff, 100, 100, -100):SetLightColor(0,#PB_Light_SpecularColor,$ffffff)
AmbientColor($777777)

vert_pg.s="%%#version 130%%uniform mat4 P25;//+25%uniform vec4 P80;//+80%uniform vec4 P46;//+46 0%uniform vec4 P43;//+43 0%uniform vec4 P32;//+32%%out vec3 oviewdir;%out vec3 olightdir;%out vec3 onormal;%out vec4 ovcolor;%out float olightatt;%out vec2 ouv;%out float ofogf;%%void main()%{%oviewdir=normalize(P80.xyz-gl_Vertex.xyz);%olightdir=normalize(P46.xyz-gl_Vertex.xyz);%gl_Position=P25*gl_Vertex;%onormal=gl_Normal;%float Dist=distance(P46,gl_Vertex);%olightatt=1.0/(P43.y+P43.z*Dist+P43.w*Dist*Dist);%ouv=(gl_TextureMatrix[0]*gl_MultiTexCoord0).xy;%ovcolor=gl_Color;%ofogf=P32.z>0?min(abs(gl_Position.z)*P32.w,1):0;%}%%%%%%%"
frag_pg.s="%%#version 130%%uniform vec4 P71;//+71 0%uniform vec4 P72;//+72 0%uniform vec4 P69;//+69 0%uniform float P37;//+37%uniform vec4 P31;//+31%uniform float blend;//0.5%%uniform sampler2D tx1;//0%uniform sampler2D tx2;//1%%in vec3 oviewdir;%in vec3 olightdir;%in vec3 onormal;%in vec4 ovcolor;%in float olightatt;%in vec2 ouv;%in float ofogf;%%void main()%{%vec3 normal=normalize(onormal);%vec3 viewdir=normalize(oviewdir);%vec3 lightdir=normalize(olightdir);%%vec4 tcolor=vec4(mix(texture(tx1,ouv),texture(tx2,ouv),blend))*ovcolor;%%float dif=max(dot(lightdir,normal),0)*olightatt;%float spe=pow(max(dot(normalize(lightdir+viewdir),normal),0),P37);%vec4 color=vec4(tcolor.rgb,1)*(P69+P71*dif)+P72*tcolor.a*spe;%gl_FragColor=mix(color,P31,ofogf);%}%%"

CreateShader(0,vert_pg,frag_pg)


For j=0 To n
  For i=0 To n
    With t(i,j)
      \u=i/n
      \v=j/n
      \color=$ffffffff
    EndWith
  Next
Next


Repeat
  While WindowEvent():Wend
  
  If cpt=0
    CopyArray(p1(),p0()):sample(p1(),Random(15))
    co0=co1:co1=RGB(Random(127),Random(127),Random(127))
    cf0=cf1:cf1=RGB(Random(255),Random(255),Random(255))
    tx0=tx1:tx1=Random(5)
    material(0,0,4,0,tx0,tx1)
    material(1,1,4,1,tx0,tx1)
  EndIf
  
  If cpt<=dt_trans
    trans=(1-Cos(cpt/dt_trans*#PI))/2
    mesh_morph(trans)
    MaterialShaderParameter(0,1,"blend",#PB_Shader_Float,trans,0,0,0)
    MaterialShaderParameter(1,1,"blend",#PB_Shader_Float,trans,0,0,0)
    co=ColorBlend(co0,co1,trans)
    SetMaterialColor(0,#PB_Material_AmbientColor|#PB_Material_DiffuseColor,$808080+co)
    SetMaterialColor(1,#PB_Material_AmbientColor|#PB_Material_DiffuseColor,$ffffff-co)
    cf=ColorBlend(cf0,cf1,trans)
    CameraBackColor(0,cf)
  EndIf
  
  ExamineMouse()
  ExamineKeyboard()
  
  If KeyboardReleased(#PB_Key_F12):fdf=1-fdf:If fdf:CameraRenderMode(0,#PB_Camera_Wireframe):Else:CameraRenderMode(0,#PB_Camera_Textured):EndIf:EndIf
  If KeyboardPushed(#PB_Key_Space)=0 And MouseButton(#PB_MouseButton_Right)=0:cpt=(cpt+1)%dt_tot:EndIf
  
  rx+0.8:ry+0.5:rz+0.6
  
  RotateEntity(0, rx, ry, rz, #PB_Absolute)
  RotateEntity(1, rx, ry, rz, #PB_Absolute)
  RenderWorld()
  FlipBuffers() 
  
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(#PB_MouseButton_Middle)
