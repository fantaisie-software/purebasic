#version 130

uniform mat4 viewproj_matrix;

varying vec3 onormal;
varying vec3 overtex;
varying vec4 oposo;
varying vec2 ouv;

void main()
{
 	gl_Position = viewproj_matrix * gl_Vertex;
	oposo=gl_Position;
	onormal = gl_Normal.xyz;
	overtex=gl_Vertex.xyz;	
	ouv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
