#version 130
						
uniform vec4 viewp;
uniform vec4 lightdif;
uniform vec4 lightspec;
uniform vec4 lightamb;
uniform float shininess;
uniform vec4 fog;
uniform vec4 fogcolor;
uniform vec4 water;
uniform vec4 watercolor;
uniform float wavespeed;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D srateMap;
uniform sampler2D causticMap;

varying vec3 oviewdir;
varying vec3 olightdir;
varying vec2 ouv;
varying vec2 ouvs;
varying vec2 ouvc;
varying vec4 ovcolor;
varying float  odist;
varying float  oheight;

void main()
	{
	vec4 tcolor = vec4(texture2D(diffuseMap,ouv))*ovcolor;
	float f;
	vec4 fcolor;
	if (oheight<0) 
		{
		tcolor.a= 0;
		if (viewp.y>=0) f = clamp((water.z - odist*oheight/(oheight-viewp.y)) * water.w,0,1); else f = clamp((water.z - odist) * water.w,0,1);
		fcolor=watercolor;	if (f==0){gl_FragColor=fcolor;return;}
		vec2 duv=vec2(wavespeed,0);
		tcolor.rgb-= pow(abs(texture2D(causticMap,ouvc+duv).x-texture2D(causticMap,ouvc+0.5-duv).x),0.8);
		}
	else 
		{
		if (fog.z == 0) f=1; else f = clamp((fog.z - odist) * fog.w,0,1);fcolor=fogcolor;	if (f==0){gl_FragColor=fcolor;return;}
		}
	vec3 tnor=texture2D(normalMap, ouv).xyz-0.5;
	if (ouvs.x>0) tnor.y+=(texture2D(srateMap, ouvs).x-0.5)*ouvs.x*2 ;
	tnor = normalize(tnor);	
	float NdotL = dot(olightdir, tnor);
	float dif=max(NdotL, 0);
	vec4 color= (vec4(tcolor.rgb,1)) * (lightamb  +  lightdif * dif +min(tnor.y*0.2,0));
	
	if (tcolor.a>0)
		{
		vec3 halfangle=normalize(olightdir + oviewdir);
		float NdotH = dot(halfangle, tnor);
		float spe=pow(NdotH,shininess);
		color+=lightspec * tcolor.a * spe;
		}
		gl_FragColor=mix(fcolor, color ,f);
}








