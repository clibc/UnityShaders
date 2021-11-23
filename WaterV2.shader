Shader "Custom/WaterV2"
{
    Properties
    {
        _SurfaceNoise( "Surface Noise", 2D ) = "white" {}
        _MaxDepth( "Foam depth value ", Range(0.0, 1.0) )  = 0.5
        _DepthShallowColor( "Shallow Color", Color ) = ( 1,1,1,1 )
        _DepthDeepColor( "Deep Color", Color ) = ( 1,1,1,1 )
        _SurfaceNoiseTrashold( "Surface Noise Trashold", Range(0.0, 1.0) ) = 0.5
        _FoamDistance( "Surface Noise Trashold", Range(0.0, 1.0) ) = 0.5
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 noiseUV : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screen_pos : TEXCOORD1;
            };

            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float _MaxDepth;

            float4 _DepthShallowColor;
            float4 _DepthDeepColor;

            float _SurfaceNoiseTrashold;
            float _FoamDistance;
            
            float2 _SurfaceNoiseScroll;

            v2f vert ( appdata v )
            {
                v2f o;
                o.vertex = UnityObjectToClipPos( v.vertex );
                o.noiseUV = TRANSFORM_TEX( v.uv, _SurfaceNoise );
                o.screen_pos = ComputeScreenPos( o.vertex );
                return o;
            }

            fixed4 frag ( v2f i ) : SV_Target
            {
                float depth01 = tex2Dproj( _CameraDepthTexture, UNITY_PROJ_COORD(i.screen_pos) ).r;
                float depthLin = LinearEyeDepth( depth01 );
                float depthDiff = depthLin - i.screen_pos.w;
                float relDepth = saturate( depthDiff / _MaxDepth );

                float2 noiseUV = float2(i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x, i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y);

                float surfaceNoiseSample = tex2D( _SurfaceNoise, noiseUV ).r;
                float foamDepthDifference01 = saturate(depthDiff / _FoamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseTrashold;
                
                surfaceNoiseSample = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;

                //surfaceNoiseSample = step( _SurfaceNoiseTrashold, surfaceNoiseSample );

                float4 waterColor = lerp( _DepthShallowColor, _DepthDeepColor, relDepth );
                return waterColor + surfaceNoiseSample;
            }
            ENDCG
        }
    }
}
