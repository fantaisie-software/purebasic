#version 130

uniform float wavespeed;
uniform float waveheight;
uniform vec4 watercolor;
uniform vec4 fogcolor;

uniform sampler2D normalMap;
uniform sampler2D reflectMap;

varying vec3 onormal;
varying vec3 oviewdir;
varying vec4 oposo;
varying vec2 ouv;
varying float  ofogf;

void main(void)
{
	vec2 duv=vec2(wavespeed,0.0);
	vec3 tnm = (texture2D(normalMap,ouv+duv).xzy-texture2D(normalMap,ouv+0.5-duv).xzy)*waveheight;
	vec3 normal = normalize(onormal+tnm);
	float fresnel = abs(dot(oviewdir, normal));
	vec3 reflet = reflect(oviewdir,normal);
	vec2 coo =reflet.xz/reflet.y*0.2;
	vec4 colreflet=texture2D(reflectMap,coo);colreflet.a=1.0;
	vec4 color = mix( colreflet,watercolor,fresnel);			
	gl_FragColor=mix(fogcolor, color ,ofogf);
}
/*

	float2 duv = float2(wavespeed,0);
	float3 tnm = (tex2D(normalMap,uv+duv).xzy-tex2D(normalMap,uv+0.5-duv).xzy)*waveheight;
	normal = normalize(normal+tnm);
	float fresnel = abs(dot(viewdir, normal));
	float3 reflet = reflect(viewdir,normal);
	float2 coo =reflet.xz/reflet.y*0.2;
	float4 colreflet = tex2D(reflectMap,coo.xy);colreflet.a=1;
	float4 color = lerp( colreflet,watercolor,fresnel);	
	return lerp(fogcolor, color ,fogf);
*/