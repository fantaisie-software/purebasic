uniform sampler2D RT;
uniform sampler2D NormalMap;
varying vec2 oUv0;
varying vec2 oUv1;

void main()
{
	vec4 normal = texture2D(NormalMap, oUv0*1) - 0.5;

	gl_FragColor = texture2D(RT, oUv0 + normal.xy * 0.02);
}
