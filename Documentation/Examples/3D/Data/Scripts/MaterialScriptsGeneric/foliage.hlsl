

uniform float4x4 	world_matrix;
uniform float4x4 	view_matrix;
uniform float4 		lightPosition;

uniform float4x4  	texmatx;
uniform float4 		lightdif;
uniform float4 		lightamb;
uniform float 		windspeedx;
uniform float 		windspeedz;
uniform float 		time;
uniform float4 		fog;						

void foliage_vertex(
						float4 pos		: POSITION, 
						float3 normal	: NORMAL,
						float2 uv		: TEXCOORD0,
						float4 vcolor   : COLOR,

						out float4 opos		: POSITION,
						out float2 ouv		: TEXCOORD0,
						out float olight	: TEXCOORD1,
						out float  ofogf	: FOG
						)
{
 	opos = mul(world_matrix, pos);
	float force=(sin(time*vcolor.r*20+vcolor.b*10)+sin(time*3)+sin(time)+sin(time*0.2)+1)*vcolor.g;
	opos.x+=windspeedx*force;
	opos.z+=windspeedz*force;	
	opos = mul(view_matrix, opos);
	float3 lightdir = normalize(lightPosition - pos);
	olight = lightamb  +  lightdif * saturate(dot(lightdir, normal));
	ouv = mul(texmatx,float4(uv,0,1)).xy;
	ofogf = saturate((fog.z - opos.z) * fog.w);
}
//======================================================================================

uniform float4 fogcolor;

sampler2D diffuseMap : register(s0);

float4 foliage_pixel(
					float2 uv   	: TEXCOORD0,
					float 	light	: TEXCOORD1,
					float  fogf		: FOG
					
	) : COLOR 
	{
	float4 tcolor = float4(tex2D(diffuseMap,uv));
	if (tcolor.a<0.5) discard;
	return lerp(fogcolor, tcolor * light,fogf);
}








