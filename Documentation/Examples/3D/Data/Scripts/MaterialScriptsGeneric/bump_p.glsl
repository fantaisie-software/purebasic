#version 130
						
uniform vec4 lightdif;
uniform vec4 lightspec;
uniform vec4 lightamb;
uniform float shininess;
uniform vec4 fogcolor;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;

varying vec3 oviewdir;
varying vec3 olightdir;
varying vec2 ouv;
varying vec4 ovcolor;
varying float  olightatt;
varying float  ofogf;

void main()
	{
	vec3 pnormal = normalize(texture2D(normalMap, ouv).xyz-0.5);
	//olightdir=normalize(olightdir);
	//oviewdir=normalize(oviewdir);
	
	vec3 halfangle=normalize(olightdir + oviewdir);
	float NdotL = dot(olightdir, pnormal);
	float NdotH = dot(halfangle, pnormal);
	float dif=max(NdotL, 0.0)*olightatt;
	float spe=pow(NdotH,shininess);
	vec4 tcolor = vec4(texture2D(diffuseMap,ouv))*ovcolor;
	vec4 color= vec4(tcolor.rgb,1.0) * (lightamb  +  lightdif * dif)  +  lightspec * tcolor.a * spe;
	gl_FragColor=mix(fogcolor, color ,ofogf);
}








