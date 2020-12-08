

uniform float4x4 viewproj_matrix;
uniform float4 view_position;
uniform float4 lightPosition;
uniform float4 lightAttenuation; 
uniform float4x4  	texmatx;
uniform float4 fog;

void bump_vertex(
						float4 pos		: POSITION, 
						float3 normal	: NORMAL,
						float3 tangent  : TANGENT, 
						float2 uv		: TEXCOORD0,
						float4 vcolor   : COLOR,

						out float4 opos			: POSITION,
						out float3 oviewdir		: TEXCOORD0,
						out float3 olightdir	: TEXCOORD1,
						out float2 ouv			: TEXCOORD2,
						out float4 ovcolor		: TEXCOORD3,
						out float  olightatt	: TEXCOORD4,
						out float  ofogf		: FOG
						)
{
	opos = mul(viewproj_matrix, pos);
	ouv = mul(texmatx,float4(uv,0,1)).xy;
	olightdir = normalize(lightPosition-pos);
	oviewdir = normalize(view_position - pos);
    float Dist = distance(lightPosition,pos); 
    olightatt = 1/(lightAttenuation.y + lightAttenuation.z * Dist + lightAttenuation.w * Dist * Dist);
	float3 binormal = cross(tangent, normal); 
	float3x3 rotation = float3x3(tangent, binormal, normal); 
	olightdir = (mul(rotation, olightdir)); 
	oviewdir  = (mul(rotation, oviewdir)); 
	
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
sampler2D normalMap  : register(s1);

float4 bump_pixel(
						float3 viewdir	: TEXCOORD0,
						float3 lightdir	: TEXCOORD1,
						float2 uv   	: TEXCOORD2,
						float4 vcolor	: TEXCOORD3,
						float lightatt	: TEXCOORD4,
						float  fogf		: FOG
	) : COLOR 
	{
	float3 pnormal = normalize(tex2D(normalMap, uv).xyz-0.5);
	//lightdir=normalize(lightdir);
	//viewdir=normalize(viewdir);
	
	float3 halfangle=normalize(lightdir + viewdir);
	float NdotL = dot(lightdir, pnormal);
	float NdotH = dot(halfangle, pnormal);
	float4 Lit = lit(NdotL,NdotH,shininess)*lightatt;	
	float4 tcolor = tex2D(diffuseMap,uv)*vcolor;
	float4 color= float4(tcolor.rgb,1) * (lightamb  +  lightdif * Lit.y)  +  lightspec * tcolor.a * Lit.z;
	return lerp(fogcolor,color,fogf);
}








