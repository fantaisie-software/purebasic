

uniform float4x4 	viewproj_matrix;
uniform float4 		view_position;
uniform float4 		lightPosition;
uniform float4 		lightAttenuation; 
uniform float4x4  	texmatx;
uniform float4 		fog;

void perpixel_vertex(
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
						out float  olightatt: TEXCOORD5,
						out float  ofogf	: FOG
						)
{
 	opos = mul(viewproj_matrix, pos);
	onormal = normal;
	oviewdir = view_position - pos;
	olightdir = lightPosition - pos;
    float Dist = distance(lightPosition,pos); 
    olightatt = 1/(lightAttenuation.y + lightAttenuation.z * Dist + lightAttenuation.w * Dist * Dist);
	ouv = mul(texmatx,float4(uv,0,1)).xy;
	ovcolor = vcolor;
	ofogf = saturate((fog.z - opos.z) * fog.w);
}

//======================================================================================

uniform float4 lightdif;
uniform float4 lightspec;
uniform float4 lightamb;
uniform float shininess;						
uniform float4 fogcolor;

sampler2D diffuseMap : register(s0);

float4 perpixel_pixel(
					float3 normal	: TEXCOORD0,
					float3 viewdir	: TEXCOORD1,
					float2 uv   	: TEXCOORD2,
					float4 vcolor	: TEXCOORD3,
					float3 lightdir	: TEXCOORD4,
					float lightatt	: TEXCOORD5,
					float  fogf		: FOG					
	) : COLOR 
	{
	normal=normalize(normal);
	lightdir=normalize(lightdir);
	viewdir=normalize(viewdir);
	
	float4 tcolor = float4(tex2D(diffuseMap,uv))*vcolor;
	
	float3 halfangle=normalize(lightdir + viewdir);
	float NdotL = dot(lightdir, normal);
	float NdotH = dot(halfangle, normal);
	float4 Lit = lit(NdotL,NdotH,shininess)*lightatt;
	//float4 color= tcolor*float4(vcolor.rgb,1) * (lightamb  +  lightdif * Lit.y)  +  lightspec * vcolor.a * Lit.z;
	float4 color= float4(tcolor.rgb,1) * (lightamb  +  lightdif * Lit.y)  +  lightspec * tcolor.a * Lit.z;

	return lerp(fogcolor, color,fogf);
}








