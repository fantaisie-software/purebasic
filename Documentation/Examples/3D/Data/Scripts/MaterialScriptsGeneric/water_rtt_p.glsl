#version 130

uniform vec4 viewp;
uniform vec4 lightp;
uniform vec4 lightspec;
uniform float shininess;
uniform float wavespeed;
uniform float waveheight;
uniform vec4 fog;
uniform vec4 fogcolor;
uniform vec4 water;
uniform vec4 watercolor;

uniform sampler2D normalMap;
uniform sampler2D reflectMap;

varying vec3 onormal;
varying vec3 overtex;
varying vec4 oposo;
varying vec2 ouv;

void main(void)
{
	float f;
	vec4 fcolor;
	if (viewp.y<0) 
		{f = clamp((water.z - oposo.z) * water.w,0,1);fcolor=watercolor;}
	else 
		{if (fog.z == 0) f=1; else f = clamp((fog.z - oposo.z) * fog.w,0,1);fcolor=fogcolor;}
	if (f==0){gl_FragColor=fcolor;return;}
	vec2 duv=vec2(wavespeed,0.0);
	vec3 tnor = normalize(texture2D(normalMap,ouv+duv).xyz+texture2D(normalMap,ouv+0.5-duv).xyz-1)*waveheight;
	//vec3 tnor = normalize(texture2D(normalMap,ouv+duv).xyz-0.5)*waveheight;
	vec3 oviewdir = normalize(viewp.xyz - overtex);	
	float fresnel = abs(dot(oviewdir, onormal));
	vec3 coo=((oposo.xyz+tnor.xyz*5)/oposo.w*0.5+0.5);coo.y=1.0-coo.y;
	vec4 colreflet=texture2D(reflectMap,coo.xy);colreflet.a=1.0;
	vec4 color = mix(colreflet, vec4(watercolor.xyz,0) ,fresnel);
	if (shininess>0)
		{
		vec3 olightdir = normalize(lightp.xyz - overtex);	
		vec3 halfangle=normalize(olightdir + oviewdir);
		float NdotH = dot(halfangle,tnor.xzy);
		float spe=pow(NdotH,shininess);
		color+=lightspec * spe;
		}
	gl_FragColor=mix(fcolor, color ,f);
}
