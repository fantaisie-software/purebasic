

uniform float4x4 viewproj_matrix;
uniform float4 view_position;
uniform float4 fog;

void flow_reflect_vertex(
					float4 pos		: POSITION, 
					float3 normal	: NORMAL,
					float3 tangent  : TANGENT, 
					float2 uv		: TEXCOORD0,
					float4 vcolor   : COLOR,
					
					out float4 opos		: POSITION,
					out float3 onormal	: TEXCOORD0,
					out float3 oviewdir	: TEXCOORD1,
					out float2 ouv		: TEXCOORD2,
					out float4 ovcolor	: TEXCOORD3,
					out float  ofogf	: FOG
				)
{
 	opos = mul(viewproj_matrix, pos);
	onormal = normal;
	oviewdir = normalize(view_position - pos);
	
	ouv=uv;
	
	ovcolor = vcolor;
	ofogf = saturate((fog.z - opos.z) * fog.w);
}

//======================================================================================
uniform float timeval;
uniform float4 fogcolor;

sampler2D flowMap  	: register(s0);
sampler2D reflectMap : register(s1);
sampler2D normalMap  : register(s2);

float4 flow_reflect_pixel(
					float3 normal: TEXCOORD0,
					float3 viewdir: TEXCOORD1,
					float2 uv   	: TEXCOORD2,
					float4 vcolor	: TEXCOORD3,
					float  fogf		: FOG					
				) : COLOR 
{
   float r1 = frac(timeval)*2;
   float r2 = frac(timeval+0.5)*2;
   float2 duv=(tex2D( flowMap, uv ).rg-0.5);
   float vit=length(duv);
   duv*=0.5;
   float scale=64;
   float2 uv1=uv*scale-r1*duv;
   float2 uv2=uv*scale-r2*duv+0.5;
   float r=abs(1-r2);
   float3 tnm = r*(tex2D(normalMap,uv1).xzy-0.5)+(1-r)*(tex2D(normalMap,uv2).xzy-0.5);
   //float3 tnm = (tex2D(normalMap,uv*scale).xzy-0.5);
   
   normal=normalize(normal+tnm*vit*2);
   float3 reflet=reflect(viewdir,normal);
   float fresnel = abs(dot(viewdir, normal));
   float2 coo =(reflet.xz/reflet.y)*0.2;
   float4 color = lerp( tex2D(reflectMap,coo),vcolor,fresnel);
   color=lerp(color,float4(1,1,1,1),vit);
   
   return lerp(fogcolor, color ,fogf);
}



