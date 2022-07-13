Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _HealthyColor ("HealthyColor", Color) = (1,1,1,1)
        _UnhealthyColor ("UnhealthyColor", Color) = (1,1,1,1)
        _HealthValue ("Health Value", Range(0.0,1.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            zWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _HealthyColor;
            float4 _UnhealthyColor;
            float _HealthValue;
            
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }
            
            float4 frag (Interpolators i) : SV_Target
            {
                float healthbarMask = _HealthValue > i.uv.x;
                
                float3 healthbarColor = tex2D(_MainTex, float2( _HealthValue, i.uv.y));
                return float4(healthbarColor * healthbarMask, 1);
            }
            ENDCG
        }
    }
}
