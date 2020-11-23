

uniform float4x4 	viewproj_matrix;
uniform float4 		view_position;
uniform float4 		lightPosition;
uniform float4x4  	texmatx;
uniform float4 		fog;

void flow_vertex(
						float4 pos		: POSITION, 
						float3 normal	: NORMAL,
						float2 uv		: TEXCOORD0,
						float4 vcolor   : COLOR,

						out float4 opos		: POSITION,
						out float3 onormal	: TEXCOORD0,
						out float3 oviewdir	: TEXCOORD1,
						out float2 ouv		: TEXCOORD2,
						out float4 ovcolor	: TEXCOORD3,
						out float3 olightdir: TEXCOORD4,
						out float  ofogf	: FOG
				)
{
 	opos = mul(viewproj_matrix, pos);
	onormal = normal;
	oviewdir = view_position - pos;
	olightdir = lightPosition - pos;
	ouv = mul(texmatx,float4(uv,0,1)).xy;
	ovcolor = vcolor;
	ofogf = saturate((fog.z - opos.z) * fog.w);
}

//======================================================================================

uniform float texrepeat;
uniform float4 lightdif;
uniform float4 lightspec;
uniform float4 lightamb;
uniform float shininess;
uniform float4 fogcolor;
uniform float timeval;

sampler2D flowMap  : register(s0);
sampler2D noiseMap : register(s1);

float4 flow_pixel(
					float3 normal   : TEXCOORD0,
					float3 viewdir	: TEXCOORD1,
					float2 uv   	: TEXCOORD2,
					float4 vcolor	: TEXCOORD3,
					float3 lightdir	: TEXCOORD4,
					float  fogf		: FOG
				) : COLOR 
{
	normal=normalize(normal);
	lightdir=normalize(lightdir);
	viewdir=normalize(viewdir);

	float r1 = frac(timeval    )*2;
	float r2 = frac(timeval+0.5)*2;
	float2 duv=(tex2D( flowMap, uv ).rg-0.5)*0.5;
	float2 uv1=(uv    )*texrepeat-r1*duv;
	float2 uv2=(uv+0.5)*texrepeat-r2*duv;
	float r=abs(1-r2);
	float4 tcolor = r*tex2D(noiseMap,uv1)+(1-r)*tex2D(noiseMap,uv2);   
   
	float3 halfangle=normalize(lightdir + viewdir);
	float NdotL = dot(lightdir, normal);
	float NdotH = dot(halfangle, normal);
	float4 Lit = lit(NdotL,NdotH,shininess);
	float4 color= tcolor*float4(vcolor.rgb,1) * (lightamb  +  lightdif * Lit.y)  +  lightspec * vcolor.a * Lit.z;
	//float4 color= tcolor * (lightamb  +  lightdif * Lit.y)  +  lightspec * Lit.z;

	return lerp(fogcolor, color,fogf);
   
}



