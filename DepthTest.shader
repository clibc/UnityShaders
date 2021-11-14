Shader "Render Depth" {
    Properties {
        _WaterColor("Water Color" , Color) = (1,1,1,1)
        _FoamColor("Foam Color" , Color) = (1,1,1,1)
        _WaterDepth("Water Depth" , Float) = 0
    }

    SubShader {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float4 sp : TEXCOORD0;
            };

            v2f vert ( appdata_base v ) {
                v2f o;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.sp = ComputeScreenPos(o.pos);
                return o;
            }

            sampler2D _CameraDepthTexture;
            float4 _WaterColor;
            float4 _FoamColor;
            float _WaterDepth;

            float4 frag( v2f i ) : SV_Target {
                float sceneRawDepth = tex2Dproj(_CameraDepthTexture, i.sp);
                float sceneEyeDepth = LinearEyeDepth(sceneRawDepth);

                float c = (sceneEyeDepth - i.sp.w) / _WaterDepth;
                c = saturate(c);
                return _WaterColor * c + (1-c) * _FoamColor;
            }
            ENDCG
        }
    }
}