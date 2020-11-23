#version 130

uniform sampler2D tex;
uniform vec4 fogcolor;

varying vec4 olight;
varying float ofogf;

void main(void)
{ 

	vec4 tcolor = texture2D(tex,gl_TexCoord[0].xy);
	if (tcolor.a<0.5) discard;
	gl_FragColor=mix(fogcolor, tcolor * olight ,ofogf);
}
