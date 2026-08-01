
; ------------------------------------------------------------
;
;   PureBasic - Shader
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "CreateShader - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(GetCurrentDirectory(), #PB_3DArchive_FileSystem )
Parse3DScripts()

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,3,-6):CameraLookAt(0,0,0,0)
CreateLight(0,$ffffff, -10000, 10000, 0)
AmbientColor($111111*8)
CameraBackColor(0,$444488)

vert_pg.s="%%#version 130%%uniform mat4 P25;//+25%uniform vec4 P80;//+80%uniform vec4 P46;//+46 0%uniform vec4 P43;//+43 0%uniform vec4 P32;//+32%%out vec3 oviewdir;%out vec3 olightdir;%out vec3 onormal;%out vec4 ovcolor;%out float olightatt;%out vec2 ouv;%out float ofogf;%%void main()%{%oviewdir=normalize(P80.xyz-gl_Vertex.xyz);%olightdir=normalize(P46.xyz-gl_Vertex.xyz);%gl_Position=P25*gl_Vertex;%onormal=gl_Normal;%float Dist=distance(P46,gl_Vertex);%olightatt=1.0/(P43.y+P43.z*Dist+P43.w*Dist*Dist);%ouv=(gl_TextureMatrix[0]*gl_MultiTexCoord0).xy;%ovcolor=gl_Color;%ofogf=P32.z>0?min(abs(gl_Position.z)*P32.w,1):0;%}%%%%%%%"
frag_pg.s="%%#version 130%%uniform vec4 P71;//+71 0%uniform vec4 P72;//+72 0%uniform vec4 P69;//+69 0%uniform float P37;//+37%uniform vec4 P31;//+31%uniform float blend;//0.5%%uniform sampler2D tx1;//0%uniform sampler2D tx2;//1%%in vec3 oviewdir;%in vec3 olightdir;%in vec3 onormal;%in vec4 ovcolor;%in float olightatt;%in vec2 ouv;%in float ofogf;%%void main()%{%vec3 normal=normalize(onormal);%vec3 viewdir=normalize(oviewdir);%vec3 lightdir=normalize(olightdir);%%vec4 tcolor=vec4(mix(texture(tx1,ouv),texture(tx2,ouv),blend))*ovcolor;%%float dif=max(dot(lightdir,normal),0)*olightatt;%float spe=pow(max(dot(normalize(lightdir+viewdir),normal),0),P37);%vec4 color=vec4(tcolor.rgb,1)*(P69+P71*dif)+P72*tcolor.a*spe;%gl_FragColor=mix(color,P31,ofogf);%}%%"
vert_pg=ReplaceString(vert_pg,"%",#LF$)
frag_pg=ReplaceString(frag_pg,"%",#LF$)
CreateShader(0,vert_pg,frag_pg)
CreateShaderMaterial(0,0)
LoadTexture(1,"grass.jpg")
LoadTexture(0,"RustySteel.jpg")
MaterialShaderTexture(0,TextureID(0),TextureID(1),0,0)
MaterialShininess(0,64,$ffffff)
ScaleMaterial(0,0.125,0.5)
MaterialFilteringMode(0,#PB_Material_Anisotropic)
CreateTorus(0,2,1,32,32)
CreateEntity(0,MeshID(0),MaterialID(0))

Define.f MouseX,Mousey,depx,depz,dist,val,blend

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
  RotateEntity(0,0.1,0.1,0.1, #PB_Relative)
  
  val+0.02:blend=(Sin(val)+1)/2
  MaterialShaderParameter(0,#PB_Shader_Fragment,"blend",#PB_Shader_Float,blend,0,0,0)
  
  RenderWorld()
  FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)

