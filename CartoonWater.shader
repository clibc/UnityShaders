Shader "Custom/Water_modified"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _WiggleTex ("Base (RGB)", 2D) = "white" {}
        _WiggleStrength ("Wiggle Strength", Range (0.01, 0.1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _WiggleTex;
            fixed4 _Color;
            float _WiggleStrength;

            float4 _MainTex_ST;
            float4 _WiggleTex_ST;

            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv_main : TEXCOORD0;
                float2 uv_wiggle : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_main = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_wiggle = TRANSFORM_TEX(v.uv, _WiggleTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 tc2 = i.uv_wiggle;
                tc2.x -= _SinTime;
                tc2.y += _CosTime;
                float4 wiggle = tex2D(_WiggleTex, tc2);
                i.uv_main.x -= wiggle.r * _WiggleStrength;
                i.uv_main.y += wiggle.b * _WiggleStrength*1.5;

                fixed4 c = tex2D(_MainTex, i.uv_main) * _Color;

                return c;
            }
            ENDCG
        }
    }
}
