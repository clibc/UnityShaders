Shader "Gamepons/Wave"
{
    Properties
    {
        _Color("Wave Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv  : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv  : TEXCOORD0;
            };

            float get_wave(float2 uv)
            {
                float2 uvCentered = uv * 2 - 1;
                float radialDistance = length(uvCentered);
                float wave = cos((radialDistance + _Time.y * 0.4) * 3.14 * 2 * 5) * 0.5 + 0.5;
                wave *= 1 - radialDistance;
                return wave;
            }
            
            v2f vert (appdata v)
            {
                v2f o; 
                o.uv  = v.uv;

                float2 uvCentered = v.uv * 2 - 1;
                float radialDistance = length(uvCentered);
                
                v.vertex.y = get_wave(o.uv) * 50 * (radialDistance * 3);

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            fixed4 _Color;
            
            fixed4 frag (v2f i) : SV_Target
            {
                return get_wave(i.uv) * _Color;
            }
            ENDCG
        }
    }
}
