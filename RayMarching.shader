Shader "Custom/RayMarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _s1Pos ("S1 pos", Vector) = (1,1,1)
        _s2Pos ("S1 pos", Vector) = (1,1,1)
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

            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


            ////////////////////////////
                
            #define MAX_MARCHING_STEPS 255
            #define MIN_DIST           0.0
            #define MAX_DIST           100.0
            #define EPSILON            0.00001

            float3 _s1Pos;
            float3 _s2Pos;
            
            float sphereSDF(float3 samplePoint, float3 spherePos) {
                return length(samplePoint - spherePos) - 0.5;
            }

            float smoothMin(float a, float b, float k){
                float h = max(k - abs(a - b), 0) / k;
                return min(a, b) - h*h*h*k * 1/6.0;
            }
            
            float sceneSDF(float3 samplePoint) {
                return smoothMin(sphereSDF(samplePoint, _s1Pos),
                                 sphereSDF(samplePoint, _s2Pos), 0.9);
            }

            float shortestDistanceToSurface(float3 eye, float3 marchingDirection, float start, float end) {
                float depth = start;
                for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
                    float dist = sceneSDF(eye + depth * marchingDirection);
                    if (dist < EPSILON) {
                        return depth;
                    }
                    depth += dist;
                    if (depth >= end) {
                        return end;
                    }
                }
                return end;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 eye = float3(0.0, 0.0, 0.0);
                float2 uv = float2(i.uv.x, i.uv.y) - 0.5;
                float3 dir = normalize(float3(uv.x, uv.y, 1.0) - eye);
                float dist = shortestDistanceToSurface(eye, dir, MIN_DIST, MAX_DIST);

                if (dist > MAX_DIST - EPSILON) {
                    // Didn't hit anything
                    fixed4 col = fixed4(0.0, 0.0, 0.0, 0.0);
                    //fixed4 col = i.uv.yyyy;
                    return col;
                }

                
                fixed4 col = fixed4(1.0, 0.0, 0.0, 0.0);
                return col;
            }
            ENDCG
        }
    }
}
