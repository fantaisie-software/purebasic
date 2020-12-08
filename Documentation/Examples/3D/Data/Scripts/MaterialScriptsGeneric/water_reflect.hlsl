

uniform float4x4 viewproj_matrix;
uniform float4 view_position;
uniform float4x4  	texmatx;
uniform float4 		fog;

void water_reflect_vertex(
					float4 pos		: POSITION, 
					float3 normal	: NORMAL,
					float3 tangent  : TANGENT, 
					float2 uv		: TEXCOORD0,

					out float4 opos		: POSITION,
					out float3 onormal	: TEXCOORD0,
					out float3 oviewdir	: TEXCOORD1,
					out float2 ouv		: TEXCOORD2,
					out float4 oposo	: TEXCOORD4,
					out float  ofogf	: FOG
				)
{
 	opos = mul(viewproj_matrix, pos);
	oposo=opos;
	onormal = normal;
	oviewdir = normalize(view_position - pos);	
	ouv = mul(texmatx,float4(uv,0,1)).xy;	
	if (fog.z == 0.0) ofogf=1.0; else ofogf = clamp((fog.z - gl_Position.z) * fog.w,0.0,1.0);
}

//======================================================================================
uniform float wavespeed;
uniform float waveheight;
uniform float4 watercolor;
uniform float4 fogcolor;

sampler2D reflectMap : register(s0);
//samplerCUBE reflectMap : register(s1);
sampler2D normalMap  : register(s1);

float4 water_reflect_pixel(
					float4 pos		: POSITION, 
					float3 normal	: TEXCOORD0,
					float3 viewdir	: TEXCOORD1,
					float2 uv   	: TEXCOORD2,
					float4 vcolor	: TEXCOORD3,
					float4 poso		: TEXCOORD4, 
					float  fogf		: FOG					
				) : COLOR 
{
	//viewdir=normalize(viewdir);
	//normal=normalize(normal);
	float2 duv = float2(wavespeed,0);
	float3 tnm = (tex2D(normalMap,uv+duv).xzy-tex2D(normalMap,uv+0.5-duv).xzy)*waveheight;
	normal = normalize(normal+tnm);
	float3 reflet = reflect(viewdir,normal);
	float fresnel = abs(dot(viewdir, normal));
	float2 coo =reflet.xz/reflet.y*0.2;
	float4 colreflet = tex2D(reflectMap,coo.xy);colreflet.a=1;
	//float4 colreflet = texCUBE(reflectMap,coo.xy);colreflet.a=1;
	float4 color = lerp( colreflet,watercolor,fresnel);	
	return lerp(fogcolor, color ,fogf);
}



