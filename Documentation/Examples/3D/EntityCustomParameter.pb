
; ------------------------------------------------------------
;
;   PureBasic - EntityCustomParameter
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "EntityCustomParameter - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,0,-10):CameraLookAt(0,0,0,0)
CreateLight(0,$ffffff, -10000, 10000, 0)
AmbientColor($111111*3)
CameraBackColor(0,$444488)

Define.s vert_pg,frag_pg
vert_pg="%#version 130%%uniform float einflate;//+90 1%uniform mat4 worldviewproj_matrix;//+25%uniform vec4 camera_pos_os;//+80%uniform vec4 light_pos_os;//+46 0%uniform vec4 light_att;//+43 0%uniform vec4 fog_params;//+32%%varying vec3 oviewdir;%varying vec3 olightdir;%varying vec3 onormal;%varying vec4 ovcolor;%varying float olightatt;%varying float ofogf;%%void main()%{%vec3 vertex=gl_Vertex.xyz+(gl_Normal*einflate);%oviewdir=normalize(camera_pos_os.xyz-vertex);%olightdir=normalize(light_pos_os.xyz-vertex);%gl_Position=worldviewproj_matrix*vec4(vertex,1);%onormal=gl_Normal;%float Dist=distance(light_pos_os,gl_Vertex);%olightatt=1/(light_att.y+light_att.z*Dist+light_att.w*Dist*Dist);%ovcolor=gl_Color;%ofogf=fog_params.z>0?min(abs(gl_Position.z)*fog_params.w,1):0;%}%"
frag_pg="%#version 130%%uniform vec4 ecolor;//+90 2%uniform vec4 diffuse_ml;//+71 0%uniform vec4 specular_ml;//+72 0%uniform vec4 ambient_ml;//+69 0%uniform float shininess;//+37%uniform vec4 fog_colour;//+31%%varying vec3 oviewdir;%varying vec3 olightdir;%varying vec3 onormal;%varying vec4 ovcolor;%varying float olightatt;%varying float ofogf;%%void main()%{%vec3 normal=normalize(onormal);if(gl_FrontFacing==false)normal*=-1;%vec3 viewdir=normalize(oviewdir);%vec3 lightdir=normalize(olightdir);%float dif=max(dot(lightdir,normal),0)*olightatt;%float spe=pow(max(dot(normalize(lightdir+viewdir),normal),0),shininess);%vec4 color=ecolor*(ambient_ml+diffuse_ml*dif)+specular_ml*spe;%gl_FragColor=mix(color,fog_colour,ofogf);%}%"

CreateShader(0,vert_pg,frag_pg)
CreateShaderMaterial(0,0)
MaterialShininess(0,64,$ffffff)
CreateTorus(0,1,0.5,32,32)
For i=0 To 4
  CreateEntity(i,MeshID(0),MaterialID(0),(i-2)*3,0,0)
  col=Random($ffffff)
Next

Define.f MouseX,Mousey,depx,depz,dist,angle,anglei

Repeat
  While WindowEvent():Wend
  ExamineKeyboard()
  ExamineMouse()
  angle+0.1
  For i=0 To 4
    RotateEntity(i,0.2,0.2,0.2, #PB_Relative)
    
    ;we can Define a different inflate value For each entity
    EntityCustomParameter(i,0,1,Sin(angle+i)*0.25,0,0,0)
    
    ;we can define a different color for each entity
    anglei=angle+i
    col=RGB((Sin(anglei)+1)/2*255,(Sin(anglei+2)+1)/2*255,(Sin(anglei+4)+1)/2*255)
    EntityCustomParameter(i,0,2,Red(col)/255,Green(col)/255,Blue(col)/255,0); color must be converted in 4 float (0->1)
  Next  
  RenderWorld()
  FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)

