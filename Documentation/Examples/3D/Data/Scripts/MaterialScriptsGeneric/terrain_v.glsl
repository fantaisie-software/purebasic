#version 130

//attribute vec3 tangent;

uniform mat4 	world_matrix;
uniform mat4 	view_matrix;
uniform vec4 viewp;
uniform vec4 lightp;

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
 	vec4 opos = world_matrix * gl_Vertex;
	gl_Position = view_matrix * opos;
	oviewdir = normalize(viewp.xyz - gl_Vertex.xyz);
	olightdir = normalize(lightp.xyz - gl_Vertex.xyz);
	vec3 tangent=cross(vec3(0.0,0.0,-1.0), gl_Normal);
	vec3 binormal = cross(tangent, gl_Normal); 
	mat3 rotation = mat3(tangent, binormal, gl_Normal); 
	ovcolor = gl_Color;
	odist=gl_Position.z;
	oheight=opos.y;
	ouv = (gl_TextureMatrix[0] * vec4(opos.xz,1,1)).xy;
	ouvs = (gl_TextureMatrix[1] * gl_MultiTexCoord0).xy;
	ouvc = opos.xz-olightdir.xz/olightdir.y*opos.y;
	ouvc = (gl_TextureMatrix[0] * vec4(ouvc*0.5,1,1)).xy;
	olightdir *= rotation; 
	oviewdir  *= rotation; 
}
