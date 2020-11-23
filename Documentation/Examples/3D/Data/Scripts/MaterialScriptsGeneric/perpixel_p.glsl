#version 130

uniform vec4 lightdif;
uniform vec4 lightspec;
uniform vec4 lightamb;
uniform float shininess;						
uniform vec4 fogcolor;

uniform sampler2D diffuseMap;

varying vec3 onormal;
varying vec3 oviewdir;
varying vec2 ouv;
varying vec4 ovcolor;
varying vec3 olightdir;
varying float  olightatt;
varying float  ofogf;


void main()
	{
	vec3 normal=normalize(onormal);
	vec3 lightdir=normalize(olightdir);
	vec3 viewdir=normalize(oviewdir);
	
	vec4 tcolor = vec4(texture2D(diffuseMap,ouv))*ovcolor;
	
	vec3 halfangle=normalize(lightdir + viewdir);
	float NdotL = dot(lightdir, normal);
	float NdotH = dot(halfangle, normal);
	float dif=max(NdotL, 0.0)*olightatt;
	float spe=pow(NdotH,shininess);
	vec4 color= vec4(tcolor.rgb,1.0) * (lightamb  +  lightdif * dif)  +  lightspec * tcolor.a * spe;
	gl_FragColor=mix(fogcolor, color ,ofogf);
}
