;
; ------------------------------------------------------------
;
;   PureBasic - MaterialScripts
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


;{ ============================= Library
Structure f2
  x.f
  y.f
EndStructure

Structure f3
  x.f
  y.f
  z.f
EndStructure

Structure PB_MeshVertexV
  p.f3
  n.f3
  t.f3
  u.f
  v.f
  color.l
EndStructure

Macro vec3d(v,vx,vy,vz)
  v\x=vx
  v\y=vy
  v\z=vz
EndMacro

Macro sub3D(p,p1,p2)
  p\x=p1\x-p2\x
  p\y=p1\y-p2\y
  p\z=p1\z-p2\z
EndMacro

Macro add3d(p,p1,p2)
  p\x=p1\x+p2\x
  p\y=p1\y+p2\y
  p\z=p1\z+p2\z
EndMacro

Procedure.f lng3D(*v.f3)
  ProcedureReturn Sqr(*V\x * *V\x + *V\y * *V\y + *V\z * *V\z)
EndProcedure

Procedure Norme3D(*V.f3,l.f=1)
  Protected.f lm
  lm = l / lng3d(*v)
  *V\x * lm
  *V\y * lm
  *V\z * lm
EndProcedure

Procedure Pvectoriel3d(*r.f3,*p.f3,*q.f3)
*r\x=*p\y * *q\z - *p\z * *q\y
*r\y=*p\z * *q\x - *p\x * *q\z
*r\z=*p\x * *q\y - *p\y * *q\x
EndProcedure

Procedure defmatrot(*p.f3,w.f, orientation=0)
  Global.f3 lo_p,lo_q,lo_r
  Protected pp.f3, l.f
 
  vec3d(lo_p,*p\x,*p\y,*p\z)
  l=lng3d(lo_p)
  Select orientation
    Case 0:vec3d(pp,Cos(w),0,Sin(w))
    Case 1:vec3d(pp,0,Cos(w),Sin(w))
    Case 2:vec3d(pp,Cos(w),Sin(w),0)
  EndSelect
  pvectoriel3d(lo_q,lo_p,pp  ):Norme3d(lo_q,l)
  pvectoriel3d(lo_r,lo_p,lo_q):Norme3d(lo_r,l)
EndProcedure

Procedure calcmatrot(*v.f3, *u.f3)
  Protected.f x=*u\x, y=*u\y, z=*u\z
  *v\x=lo_p\x * x + lo_q\x * y + lo_r\x * z
  *v\y=lo_p\y * x + lo_q\y * y + lo_r\y * z
  *v\z=lo_p\z * x + lo_q\z * y + lo_r\z * z
EndProcedure

Procedure.f Max(v1.f,v2.f)
  If v1>v2:ProcedureReturn v1:Else:ProcedureReturn v2:EndIf
EndProcedure

Procedure.f Min(v1.f,v2.f)
  If v1<v2:ProcedureReturn v1:Else:ProcedureReturn v2:EndIf
EndProcedure

Procedure.f limite(V.f, i.f, s.f)
  If V < i :v=i:EndIf
  If V > s :v=s:EndIf
  ProcedureReturn V
EndProcedure

Procedure.f POM(v.f)
  ProcedureReturn (Random(v*1000)-v*500)/500
EndProcedure

;##############################################################################################

Procedure CoRBinv(c.l)
  ProcedureReturn  RGBA(Blue(c),Green(c),Red(c),Alpha(c))
EndProcedure

Procedure ColorBlend(color1.l, color2.l, blend.f)
    Protected r.w,g.w,b.w,a.w
    r=  Red(color1) + (Red(color2)     - Red(color1)) * blend
    g=Green(color1) + (Green(color2) - Green(color1)) * blend
    b= Blue(color1) + (Blue(color2) -   Blue(color1)) * blend
    a=Alpha(color1) + (Alpha(color2) - Alpha(color1)) * blend
    ProcedureReturn  RGBA(r,g,b,a)
EndProcedure

Procedure GradientToArray(Array pal.l(1),n,gradient.s,inv.b=0,alpha.b=0)
    Protected i,j, apos,pos, acol.l,col.l,p,lt.s
    n-1
    Dim pal(n)
   
    Repeat
        apos=pos
        acol=col
        i+1
        lt=StringField(gradient,i,"/"):If lt="":Break:EndIf
        pos=ValF(lt)*n
        p=FindString(lt,",")
        If p
            col=Val(Mid(lt,p+1))
            If inv  :col=CoRBinv(col):EndIf
            If alpha:col | $ff000000:EndIf
        Else
            col=acol
        EndIf
        For j=apos To pos:pal(j)=ColorBlend(acol,col,(j-apos)/(pos-apos)):Next
    ForEver
EndProcedure

Procedure Array2Dlimit(Array t.f(2),*min.float,*max.float)
    Protected i,j,dx1,dy1
    Protected.f v,smin,smax
   
    dy1 = ArraySize(t(), 1)
    dx1 = ArraySize(t(), 2)
    smax = -1e10
    smin =  1e10
    For j=0 To dy1
        For i=0 To dx1
            v=t(j,i)
            If v<smin : smin=v: EndIf
            If v>smax : smax=v: EndIf
        Next
    Next
    *min\f=smin
    *max\f=smax
EndProcedure

Procedure blur2D(Array s.f(2),di.w, dj.w,pass=1,loop=1)
    If di=0 And dj=0:ProcedureReturn:EndIf
    Protected i,j,k,d,dii,djj,dx,dy,dij,tx.f
   
    dx = ArraySize(s(), 2):di=min(di,dx)
    dy = ArraySize(s(), 1):dj=min(dj,dy)
    Dim d.f(dy,dx)
    dii=di+1
    djj=dj+1
    dij = dii * djj
   
    If loop
        d=dx-dii/2:Dim lx(dx + 2*dii): For i = 0 To dx + 2*dii: lx(i) = (i+d) % (dx+1): Next
        d=dx-dii/2:Dim ly(dy + 2*djj): For i = 0 To dy + 2*djj: ly(i) = (i+d) % (dy+1): Next
    Else
        Dim lx(dx + 2*dii): For i = 0 To dx + 2*dii: lx(i) = limite(i-1-dii/2, 0, dx): Next
        Dim ly(dy + 2*djj): For i = 0 To dy + 2*djj: ly(i) = limite(i-1-djj/2, 0, dy): Next
    EndIf
    For k=1 To pass
        Dim ty.f(dx)
        For j = 0 To djj - 1: For i = 0 To dx: ty(i) + s(ly(j),i): Next: Next
        For j = 0 To dy
            For i = 0 To dx: ty(i) + s(ly(djj+j),i) - s(ly(j),i): Next
            tx=0:For i = 0 To dii-1: tx+ty(lx(i)): Next
            For i = 0 To dx: tx + ty(lx(dii+i)) - ty(lx(i) ): d(j,i) = tx / dij: Next
        Next
        CopyArray(d(),s())
    Next
EndProcedure

Procedure Embos2D(Array s.f(2), px.w=0, py.w=0)
  Protected i,j,dx,dy
  px=1<<Int(Abs(px))*Sign(px)
  py=1<<Int(Abs(py))*Sign(py)
 
  Macro gra(j0,i0,j1,i1)
    t(j0,i0)=Abs(s(j0,i0)-s(j0,i1)+px)+Abs(s(j0,i0)-s(j1,i0)+py)
  EndMacro
  dy = ArraySize(s(), 1)
  dx = ArraySize(s(), 2)
  Dim T.f(dy,dx)
  For j=0 To dy-1
    For i=0 To dx-1
      gra(j,i,j+1,i+1)
    Next
    gra(j,dx,j+1,0)
  Next
  For i = 0 To dx-1
    gra(dy,i,0,i+1)
  Next
  gra(dy,dx,0,0)
  CopyArray(t(),s())
EndProcedure

Procedure grad2D(Array s.f(2),delta=1)
    Protected i,j,dx,dy
   
    dy = ArraySize(s(), 1)
    dx = ArraySize(s(), 2)
    Dim d.f(dy,dx)
    For j=0 To dy
        For i=0 To dx
            d(j,i)= 4*s(j,i)   -s(j,(i-delta) & dx)-s(j,(i+delta) & dx)-s((j-delta) & dy,i)-s((j+delta) & dy,i)
        Next
    Next
    CopyArray(d(),s())
EndProcedure

Procedure superpose(Array s.f(2),n.w=1)
  Protected i,j,k,dx,dy,x,y,ii,jj
 
  dy = ArraySize(s(), 1)
  dx = ArraySize(s(), 2)
  Dim T.f(dy,dx)
  For k=1 To n
    x=Random(dx)
    y=Random(dy)
    For j=0 To dy
      For i=0 To dx
        t(i,j)+s((i+x) & dx,(j+y) & dy)
      Next
    Next
  Next
  CopyArray(t(),s())
EndProcedure

Procedure Noise2d(Array t.f(2), dx.w, dy.w,rnd, oinit.b, onb.b=16)
    Protected i,j,n,d,dd,d3,dx1=dx-1,dy1=dy-1,coef.f=9,den.f=1/(2*coef-2),amp.f=1/$1000
    Dim t(dy1, dx1)
   
    RandomSeed(rnd)
    n = 1<<oinit
    dd=min(dx,dy) / n: If dd<1:dd=1:EndIf
    j=0:While j<dy1:i=0:While i<dx1: t(j,i) = (Random($2000) - $1000)*amp:i+dd:Wend:j+dd:Wend
    While dd > 1
        If onb=0:amp=0:EndIf
        d = dd / 2:d3=d*3:amp/2
        j=d:While j<dy
            i=0:While i<dx
                t(j,i) = (-t((j - d3) & dy1,i) - t((j +d3) & dy1,i) + coef*(t((j - d) & dy1,i) + t((j + d) & dy1,i))) *den + (Random($2000) - $1000)*amp
            i+dd:Wend
        j+dd:Wend
        j=0:While j<dy
            i=d:While i<dx
                t(j,i) = (-t(j,(i - d3) & dx1) - t(j,(i +d3) & dx1) + coef*(t(j,(i - d) & dx1) + t(j,(i + d) & dx1))) *den + (Random($2000) - $1000)*amp
            i+dd:Wend
        j+d:Wend
        dd/2:onb-1
    Wend
EndProcedure

Procedure Finterpol(Array F.f(1),profil.s,dmin.f=1,dmax.f=0)
    Protected.l i,j,n,c,ac,rx,   t.s
    Protected.f y,dx,dy,p
   
    rx=ArraySize(f())
    n=CountString(profil,"/")
    Dim s.f2(n)
    For i=0 To n
        t=StringField(profil,i+1,"/")
        s(i)\x=ValF(t)*rx
        s(i)\y=ValF(StringField(t,2,","))*(dmax-dmin)+dmin
    Next
   
    For j=0 To n-1
        y=s(j)\y
        dx=s(j+1)\x-s(j)\x
        dy=s(j+1)\y-s(j)\y
        p=dy/dx
        ac=c
        While c<=s(j+1)\x
            f(c)=y+p*(c-ac):c+1
        Wend
    Next
EndProcedure

Procedure outline2d(Array t.f(2),dmin.f,dmax.f,outline.s="0,0/1,1",sminl.f=0,smaxl.f=0)
    Protected dx1,dy1,i,ii,j,k,xi
    Protected.f smin,smax,sr,tt,x,y0,y1,x0,dminl,dmaxl
   
    dy1 = ArraySize(t(), 1)
    dx1 = ArraySize(t(), 2)
    Array2Dlimit(t(),@smin,@smax)
    sr=smax-smin
   
    Dim conv.f(256)
    Finterpol(conv(),outline,dmin,dmax)
    If smaxl-sminl<>0
        ii=(sminl-smin)/sr*255:For i=0 To ii:conv(i)=conv(ii):Next
        ii=(smaxl-smin)/sr*255:For i=ii To 255:conv(i)=conv(ii):Next
    EndIf
   
    For j=0 To dy1
        For i=0 To dx1
            x=(t(j,i)-smin)/sr*255
            xi=Int(x):x0=x-xi
            y0=conv(xi)
            y1=conv(xi+1)
            t(j,i)=y1*x0+y0*(1-x0)
        Next
    Next
EndProcedure

Procedure textureArrayToColor(tex,Array t.f(2),grad.s="0,$000000/1,$ffffff")
    Protected i,j,n,dx,dy
    Protected.f min,max,r
   
    dx=ArraySize(t(),2)+1
    dy=ArraySize(t(),1)+1
    Dim bmp.l(dy-1,dx-1)
   
    Protected Dim grad.l(0):gradienttoarray(grad(),1024,grad,1)
    Array2Dlimit(t(),@min,@max):r=1023/(max-min)
    For j=0 To dy-1:For i=0 To dx-1:n=(t(j,i)-min)*r:bmp(j,i)=grad(n):Next:Next
   
    n=CreateTexture(tex,dx,dy):If tex=-1:tex=n:EndIf
    StartDrawing(TextureOutput(tex)):CopyMemory(@bmp(0,0),DrawingBuffer(),dx*dy*4):StopDrawing()
    ProcedureReturn tex
EndProcedure

Procedure textureArrayToNM(tex,Array t.f(2),amplitude.f)
    Protected i,j,n,dx,dy
    Protected.f h00,h10,h01,x,y,z,l, max=1/amplitude,max2=max*max
    Protected.f3 p
   
    dx=ArraySize(t(),2)+1
    dy=ArraySize(t(),1)+1
    Dim bmp.l(dy-1,dx-1)
    For j=0 To dy-1
        For i=0 To dx-1
            h00=t(j,i)
            h10=t(j,(i+1) % dx)
            h01=t((j+1) % dy,i)
            p\x=h00-h10
            p\y=h00-h01
            l=min(p\x*p\x+p\y*p\y,max2)
            p\z=Sqr(max2-l)
            Norme3D(p,127)
            bmp(j,i)=RGBA(p\z+128,p\y+128,p\x+128,255)
        Next
    Next
    n=CreateTexture(tex,dx,dy):If tex=-1:tex=n:EndIf
    StartDrawing(TextureOutput(tex)):CopyMemory(@bmp(0,0),DrawingBuffer(),dx*dy*4):StopDrawing()
    ProcedureReturn tex
EndProcedure

;##############################################################################################
;}===================================================================================================================================================

Procedure texturediffuse(tex,dx,dy,rnd=0,f=0,lissage=0,grad.s="0,$000000/1,$ffffff",outline.s="0,0/1,1")
  Protected Dim t.f(0,0)
 
  Noise2d(t(),dx,dy,rnd,f)
  blur2D(t(),lissage,lissage,2)
  outline2d(t(),0,1,outline)
  ProcedureReturn textureArrayToColor(tex,t(),grad)
EndProcedure

Procedure texturenormal(tex,dx,dy,rnd=0,f=0,lissage=0,relief.f=1,outline.s="0,0/1,1")
  Protected Dim t.f(0,0)
 
  Noise2d(t(),dx,dy,rnd,f)
  blur2D(t(),lissage,lissage,2)
  outline2d(t(),0,1,outline)
  ProcedureReturn textureArraytoNM(tex,t(),relief)
EndProcedure

#n=1
#ecart=8
Global diff=1,
       spec=1,
       rotL=1,
       rotG=1,
       fdf=0

Procedure mesh_node(mesh,size.f,radius.f,nbseg_length=128,nbseg_section=32,txrepeat_length.f=16,txrepeat_section.f=2)
  Dim t.PB_MeshVertexV(nbseg_section,nbseg_length)
  Protected.f ai,aj,sx,sy,c.b, rs
  Protected.f3 p,ap,d,s,ss
 
  Macro ligne(jj)
    aj=jj/nbseg_length *2*#PI
    p\x = (Sin(aj)+2* Sin(2*aj))*size
    p\y = (Cos(aj)-2* Cos(2*aj))*size
    p\z = - 2*Sin(3*aj)*size
  EndMacro
 
  ligne(-1)
  For j=0 To nbseg_length
    ap=p:ligne(j)
    sub3d(d,p,ap):Norme3D(d,1)
    defmatrot(d,aj)
    For i=0 To nbseg_section
      With t(i,j)
        ai=i*2*#PI/nbseg_section
        s\y=Sin(ai)*radius
        s\z=Cos(ai)*radius
        calcmatrot(ss,s)
        add3d(\p,p,ss)
        Norme3D(ss):\n=ss
        \u=i*txrepeat_section/nbseg_section
        \v=j*txrepeat_length/nbseg_length
        \color=($ffffff)+$ff000000
      EndWith
    Next
  Next
  CreateDataMesh(mesh,t())
  BuildMeshTangents(mesh)
EndProcedure

Procedure mesh_foliage(mesh,size.f,n=8)
    Protected.f n2.l=n/2,   r1,r2, cx,cy,cz,fq,phase,souplesse=10
    fq=min(250/size,255)
    phase=Random(200)
    Global Dim t.PB_MeshVertexv(n,n)
   
    For j=0 To n:jn=j/n
        For i=0 To n
            With t(i,j)
                cx=(i-n2)/n*size
                cy=(j)/n*size
                vec3d(\p,cx,cy,0)
                vec3d(\n,0,1,0)
                \u=i/n
                \v=j/n
                \Color=RGBA(fq,min((cx*cx+cy*cy)*souplesse,255),phase,0);:Debug min((cx*cx+cy*cy)*souplesse,255)
            EndWith
        Next
    Next
    CreateDataMesh(mesh,t())
   BuildMeshTangents(mesh)
EndProcedure

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
  dt("[F1] Diffuse light",diff)
  dt("[F2] Specular light",spec)
  dt("[F3] Global rotation",rotg)
  dt("[F4] Local rotation",rotl)
  dt("[F12] Wireframe")
  dt("[Esc] / [Click]   Quit")
  StopDrawing()
EndProcedure

Define.f MouseX,Mousey,keyx,keyz,a,ai


InitEngine3D(#PB_Engine3D_DebugLog):InitSprite():InitKeyboard():InitMouse()
ExamineDesktops()
ex=DesktopWidth (0)*0.8
ey=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(ex),DesktopUnscaledY(ey), "Demo Shader", #PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, ex, ey, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts/MaterialScriptsGeneric", #PB_3DArchive_FileSystem )
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

;-------------------- scene
CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,2,-20):CameraLookAt(0,0,0,0):CameraBackColor(0,$ff4444)
AmbientColor($111111* 4)
SkyBox("desert07.jpg")
Fog($ffffff,1,10000,10001);     <---  !!!   required to use these shaders !!!

CreateLight(0, $111111* 8*diff, 8000, 4000,0)
       
mesh_node(0,1,0.8,  64,16,   16,2)

; ================================================== PerPixel Lighting
texturediffuse(3,256,256,0,3,0,"0,$4400ffff/0.4,$440000ff/0.5,$ff44aaff/1,$ff4466aa")
GetScriptMaterial(0,"perpixel"):MaterialTextureAliases(0,TextureID(3),0,0,0)
SetMaterialColor(0,#PB_Material_SpecularColor,$ffffff):MaterialShininess(0,132)

; ================================================== Bump
texturediffuse(5,256,256,0,3,2,"0,$ff444400/0.2,$ffaaaa00/1,$ff44ffff","0,1/0.5,0/1,1")
texturenormal(6,256,256,0,3,2, 16,"0,1/0.5,0/1,1")
GetScriptMaterial(1,"bump"):MaterialTextureAliases(1,TextureID(5),TextureID(6),0,0)
SetMaterialColor(1,#PB_Material_SpecularColor,$ffffff):MaterialShininess(1,64)

For i=0 To #n
    MaterialFilteringMode(i,#PB_Material_Anisotropic,4)
    ai.f=i*2*#PI/(#n+1):CreateEntity(i,MeshID(0),MaterialID(i))
    RotateEntity(i,Random(360),Random(360),Random(360))
Next

; ================================================== Water RTT
CreateCamera(1,0,0,100,100):CreateRenderTexture(10,CameraID(1),ex,ey)
texturenormal(11,128,128,0,3,2,8,"0,0/0.5,1/1,0")
GetScriptMaterial(10,"water_rtt")
MaterialTextureAliases(10,TextureID(11),TextureID(10),0,0)
MaterialBlendingMode(10,#PB_Material_AlphaBlend)
SetMaterialColor(10,#PB_Material_DiffuseColor,$44444400)

CreatePlane(10,100,100,128,128,20,20)
CreateEntity(10,MeshID(10),MaterialID(10),0,0,0)

texturediffuse(12,256,256,0,4,0,"0,$002244/0.5,$44/0.6,$4400/1,$ff004466");underwater ground plane
CreateMaterial(12,TextureID(12))
CreateEntity(12,MeshID(10),MaterialID(12),0,-1,0)

; ================================================== grass
CreateTexture(20,1024,1024):StartDrawing(TextureOutput(20)):DrawingMode(#PB_2DDrawing_AllChannels):For ii=0 To 100:ai.f=pom(#PI/2):col=RGBA(100+Random(100),150+Random(100),0,255):For i=-5 To 5:LineXY(512+i,0,512+Sin(ai)*512,Cos(ai)*1024,col):Next:Next:StopDrawing()
GetScriptMaterial(20,"foliage"):MaterialTextureAliases(20,TextureID(20),0,0,0):MaterialCullingMode(20,#PB_Material_NoCulling)
MaterialFilteringMode(20,#PB_Material_Anisotropic,4)
For i= 0 To 20
    mesh_foliage(20+i,2+pom(1),8)
    CreateEntity(20+i,MeshID(20+i),MaterialID(20),pom(2),0,pom(2))
    RotateEntity(20+i,0,pom(180),0)
Next

LoadFont(0,"arial",10)
menu()

Repeat
  While WindowEvent()
  Wend
  ExamineMouse()
  ExamineKeyboard()
  If KeyboardReleased(#PB_Key_F1 ):diff=1-diff:menu():SetLightColor(0,#PB_Light_DiffuseColor ,diff*$111111* 15*diff):EndIf
  If KeyboardReleased(#PB_Key_F2 ):spec=1-spec:menu():SetLightColor(0,#PB_Light_SpecularColor,spec*$111111* 15*spec):EndIf
  If KeyboardReleased(#PB_Key_F3 ):rotG=1-rotG:menu():EndIf:If rotG:For i=0 To #n:ai=a+i*2*#PI/(#n+1):MoveEntity(i,#ecart*Cos(ai),4,#ecart*Sin(ai),#PB_Absolute):Next:a+0.002:EndIf
  If KeyboardReleased(#PB_Key_F4 ):rotL=1-rotL:menu():EndIf:If rotL:For i=0 To #n:RotateEntity(i,0.1,0.2,0.3,#PB_Relative):Next:EndIf
  If KeyboardReleased(#PB_Key_F12):fdf=1-fdf:If fdf:CameraRenderMode(0,#PB_Camera_Wireframe):Else:CameraRenderMode(0,#PB_Camera_Textured):EndIf:EndIf
  keyx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.1
  keyz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.1+MouseWheel()*1
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, -keyz)
  CameraReflection(1,0,EntityID(10))
  RenderWorld()
  DisplayTransparentSprite(0,8,8)
  FlipBuffers()
Until MouseButton(#PB_MouseButton_Left) Or KeyboardReleased(#PB_Key_Escape)

