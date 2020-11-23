#version 130

uniform mat4 	world_matrix;
uniform mat4 	view_matrix;
uniform vec4 	lightPosition;

uniform vec4 	lightdif;
uniform vec4 	lightamb;
uniform float 	windspeedx;
uniform float 	windspeedz;
uniform float 	time;
uniform vec4 	fog;						

varying vec4 olight;
varying float ofogf;

void main(void)
{
 	vec4 opos = world_matrix * gl_Vertex;
	float force=(sin(time*gl_Color.r*20+gl_Color.b*10)+sin(time*3)+sin(time)+sin(time*0.2)+1)*gl_Color.g;
	opos.x+=windspeedx*force;
	opos.z+=windspeedz*force;	
	gl_Position = view_matrix * opos; 
	vec3 lightdir = normalize(lightPosition.xyz - gl_Vertex.xyz);
	olight = lightamb  +  lightdif * clamp(dot(lightdir, gl_Normal.xyz),0.0,1.0);
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	if (fog.z == 0.0) ofogf=1.0; else ofogf = clamp((fog.z - gl_Position.z) * fog.w,0.0,1.0);
}
