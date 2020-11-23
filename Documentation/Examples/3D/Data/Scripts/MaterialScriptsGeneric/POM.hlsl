    float3 expand(float3 v)
    {
       return (v - 0.5) * 2;
    }

    void POM_Vert(float4 position   : POSITION, 
                  float3 normal      : NORMAL, 
                  float2 uv         : TEXCOORD0, 
                  float3 tangent     : TANGENT0, 
                  // outputs 
                  out float4 oPosition    : POSITION, 
                  out float2 oUv          : TEXCOORD0, 
                  out float3 oLightDir    : TEXCOORD1,
                 out float3 oEyeDir       : TEXCOORD2, 
                 out float3 oNormal        : TEXCOORD3,
               out float oAttenuation: TEXCOORD4,   
               out float2 oParallaxOffsetTS : TEXCOORD5,    
                  // parameters 
                  uniform float fHeightMapScale,
                  uniform float scale,
                  uniform float4 lightPosition,
                  uniform float3 eyePosition, 
                  uniform float4x4 worldViewProj,
                  uniform float4 lightAttenuation) 
    {  
       // calculate output position 
       oPosition = mul(worldViewProj, position); 

       // pass the main uvs straight through unchanged 
       oUv = uv * scale; 

       float Dist = distance(mul(worldViewProj, lightPosition), mul(worldViewProj, position)); 
       oAttenuation = 1/(lightAttenuation.y + lightAttenuation.z * Dist + lightAttenuation.w * Dist * Dist);
       
       // calculate tangent space light vector 
       // Get object space light direction 
       float3 lightDir = normalize(lightPosition.xyz -  (position * lightPosition.w));
       
       float3 eyeDir = eyePosition - position.xyz; 
       
       // Calculate the binormal (NB we assume both normal and tangent are 
       // already normalised) 
       // NB looks like nvidia cross params are BACKWARDS to what you'd expect 
       // this equates to NxT, not TxN 
       float3 binormal = cross(tangent, normal); 
        
       // Form a rotation matrix out of the vectors 
       float3x3 rotation = float3x3(tangent, binormal, normal); 
        
       // Transform the light vector according to this matrix 
       lightDir = (mul(rotation, lightDir)); 
       eyeDir = (mul(rotation, eyeDir)); 
       oNormal = (mul(rotation, normal)); 

       oLightDir = lightDir; 
       oEyeDir = eyeDir; 
     
        // Compute the ray direction for intersecting the height field profile with 
        // current view ray. See the above paper for derivation of this computation.
             
        // Compute initial parallax displacement direction:
        float2 vParallaxDirection = normalize(  oEyeDir.xy );
           
        // The length of this vector determines the furthest amount of displacement:
        float fLength         = length( oEyeDir );
        float fParallaxLength = sqrt( fLength * fLength - oEyeDir.z * oEyeDir.z ) / oEyeDir.z; 
           
        // Compute the actual reverse parallax displacement vector:
        oParallaxOffsetTS = vParallaxDirection * fParallaxLength;
           
        // Need to scale the amount of displacement to account for different height ranges
        // in height maps. This is controlled by an artist-editable parameter:
        oParallaxOffsetTS *= fHeightMapScale;  
    }

    void POM_Frag(
            float2 uv   : TEXCOORD0,
            float3 lightVec : TEXCOORD1,
            float3 eyeDir : TEXCOORD2,
            float3 iNormal: TEXCOORD3,
            float Attenuation: TEXCOORD4,
            float2 vParallaxOffsetTS : TEXCOORD5,

            out float4 oColor   : COLOR, 

            uniform float4 lightDiffuse,
            uniform float4 lightAmbient,
            uniform float4 lightSpecular,
            uniform float spec_exponent,
            uniform float spec_factor,
            uniform float fHeightMapScale,

          uniform sampler2D normalHeightMap : register(s0),
          uniform sampler2D diffuseMap : register(s1)
          )
    {
       eyeDir = normalize(eyeDir);
       lightVec = normalize(lightVec);
       float3 halfAngle = normalize(eyeDir + lightVec); 
       //nMinSamples = 12
       //nMaxSamples = 60
       float nMinSamples = 30;
       float nMaxSamples = 60;
       float3 N = normalize( iNormal );   
       int nNumSamples = (int)lerp( nMinSamples, nMaxSamples, dot( eyeDir, N ) );
       float fStepSize = 1.0 / (float)nNumSamples;
       float2 dx, dy;
       dx = ddx( uv );
       dy = ddy( uv );
       
          float fCurrHeight = 0.0;
          float fPrevHeight = 1.0;
          float fNextHeight = 0.0;

          int    nStepIndex = 0;

          float2 vTexOffsetPerStep = fStepSize * vParallaxOffsetTS;
          float2 vTexCurrentOffset = uv;
          float  fCurrentBound     = 1.0;
          float  fParallaxAmount   = 0.0;

          float2 pt1 = 0;
          float2 pt2 = 0;
           
          float2 texOffset2 = 0;   
          while ( nStepIndex < nNumSamples ) 
          {
             vTexCurrentOffset -= vTexOffsetPerStep;

             // Sample height map which in this case is stored in the alpha channel of the normal map:
             fCurrHeight = tex2Dgrad( normalHeightMap, vTexCurrentOffset, dx, dy ).a;

             fCurrentBound -= fStepSize;

             if ( fCurrHeight > fCurrentBound ) 
             {   
                pt1 = float2( fCurrentBound, fCurrHeight );
                pt2 = float2( fCurrentBound + fStepSize, fPrevHeight );

                texOffset2 = vTexCurrentOffset - vTexOffsetPerStep;

                nStepIndex = nNumSamples + 1;
                fPrevHeight = fCurrHeight;
             }
             else
             {
                nStepIndex++;
                fPrevHeight = fCurrHeight;
             }
          } 
          float fDelta2 = pt2.x - pt2.y;
          float fDelta1 = pt1.x - pt1.y;
          
          float fDenominator = fDelta2 - fDelta1;
          
          // SM 3.0 requires a check for divide by zero, since that operation will generate
          // an 'Inf' number instead of 0, as previous models (conveniently) did:
          if ( fDenominator == 0.0f )
          {
             fParallaxAmount = 0.0f;
          }
          else
          {
             fParallaxAmount = (pt1.x * fDelta2 - pt2.x * fDelta1 ) / fDenominator;
          }
          
          float2 vParallaxOffset = vParallaxOffsetTS * (1 - fParallaxAmount );

          // The computed texture offset for the displaced point on the pseudo-extruded surface:
          float2 newTexCoord = uv - vParallaxOffset;           
              
       float3 PixelNormal = expand(tex2D(normalHeightMap, newTexCoord).xyz);
       PixelNormal = normalize(PixelNormal);
       float3 diffuse = tex2D(diffuseMap, newTexCoord).xyz;

       float NdotL = dot(normalize(lightVec), PixelNormal);
       float NdotH = dot(normalize(halfAngle), PixelNormal); 
       float4 Lit = lit(NdotL,NdotH,spec_exponent);   
       //oColor = float4(diffuse, 1);
       float3 col = lightAmbient * diffuse + ((diffuse * Lit.y * lightDiffuse + lightSpecular * Lit.z * spec_factor) * Attenuation);
          
       oColor = float4(col, 1);
    }


