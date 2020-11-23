#version 130

attribute vec3 tangent;

uniform mat4 viewproj_matrix;
uniform vec4 view_position;
uniform vec4 lightPosition;
uniform vec4 lightAttenuation; 
uniform vec4 fog;

varying vec3 oviewdir;
varying vec3 olightdir;
varying vec2 ouv;
varying vec4 ovcolor;
varying float  olightatt;
varying float  ofogf;

void main()
{
	gl_Position = viewproj_matrix * gl_Vertex;
	ouv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	oviewdir = normalize(view_position.xyz - gl_Vertex.xyz);
	olightdir = normalize(lightPosition.xyz - gl_Vertex.xyz);
    float Dist = distance(lightPosition,gl_Vertex); 
    olightatt = 1.0/(lightAttenuation.y + lightAttenuation.z * Dist + lightAttenuation.w * Dist * Dist);
	vec3 binormal = cross(tangent, gl_Normal); 
	mat3 rotation = mat3(tangent, binormal, gl_Normal); 
	olightdir = olightdir*rotation; 
	oviewdir  = oviewdir*rotation; 
	
	ovcolor = gl_Color;
	if (fog.z == 0.0) ofogf=1.0; else ofogf = clamp((fog.z - gl_Position.z) * fog.w,0.0,1.0);
}
