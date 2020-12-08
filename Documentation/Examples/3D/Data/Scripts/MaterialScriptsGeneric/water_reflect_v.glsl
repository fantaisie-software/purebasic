#version 130

uniform mat4 viewproj_matrix;
uniform vec4 view_position;
uniform vec4 		fog;

varying vec3 onormal;
varying vec3 oviewdir;
varying vec4 oposo;
varying vec2 ouv;
varying float  ofogf;

void main()
{
 	gl_Position = viewproj_matrix * gl_Vertex;
	oposo=gl_Position;
	onormal = gl_Normal.xyz;
	oviewdir = normalize(view_position.xyz - gl_Vertex.xyz);	
	ouv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	if (fog.z == 0.0) ofogf=1.0; else ofogf = clamp((fog.z - gl_Position.z) * fog.w,0.0,1.0);
}
