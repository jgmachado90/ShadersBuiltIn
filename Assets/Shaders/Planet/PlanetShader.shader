Shader "Unlit/PlanetShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NightLights("_NightLights", 2D) = "white" {}
        [HDR]
        _NightColor("NightColor", Color) = (1,1,1,1)
        [HDR]
        _RimColor("Rim Color", Color) = (1,1,1,1)
         [HDR]
        _AtmosphereColor("_AtmosphereColor", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.716
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
        _NightLightValue("NightLightValue", Range(0, 1)) = 0.1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
                float2 lightsUV : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NightLights;
            float4 _NightLights_ST;
            float4 _NightColor;

            float4 _RimColor;
            float _RimAmount;
            float _RimThreshold;
            float4 _AtmosphereColor;

            float _NightLightValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.lightsUV = TRANSFORM_TEX(v.uv, _NightLights);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
               fixed4 col = tex2D(_MainTex, i.uv);
    
                float nightLightSample = tex2D(_NightLights, i.lightsUV).r;
                float4 clampedNightLight = nightLightSample > _NightLightValue ? _NightColor : float4(0,0,0,0);

                float3 normal = normalize(i.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0, normal);

                float4 clampedWithLightNightLight = NdotL < 0 ? clampedNightLight : float4(0,0,0,0);
                float lightIntensity = smoothstep(0, 0.2, NdotL);

                float3 viewDir = normalize(i.viewDir);
                float4 rimDot = 1 - dot(viewDir, normal);

                float4 clampedMainTex = rimDot > _RimThreshold ? _RimColor : col;
                float atmosphere = _AtmosphereColor * lightIntensity * NdotL;

                return clampedMainTex * lightIntensity + atmosphere + clampedWithLightNightLight;
            }
            ENDCG
        }
    }
}
