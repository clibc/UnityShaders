Shader "Gamepons/Phong"
{
    Properties
    {
        _AmbientColor("Ambient Color", Color) = (1,1,1,1)
        _AmbientCoefficient("Ambient Coefficient", Range(0.0, 2.0)) = 1.0

        _DiffuseColor("Diffuse Color", Color) = (1,1,1,1)
        _DiffuseCoefficient("Diffuse Light", Range(0.0, 1.0)) = 1.0

        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        _SpecularCoefficient("Specular Coefficient", Range(0.0, 1.0)) = 1.0
        _SpecularTreshold("Specular Treshold", Range(0.0, 1.0)) = 1.0
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
                float4 uv     : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex      : SV_POSITION;
                float4 uv          : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldVertex : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o; 
                o.uv  = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldVertex = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 _AmbientColor;
            float  _AmbientCoefficient;
            fixed4 _DiffuseColor;
            float  _DiffuseCoefficient;
            fixed4 _SpecularColor;
            float  _SpecularCoefficient;
            float  _SpecularTreshold;
            
            fixed4 frag (v2f i) : SV_Target
            {
                //float3 specular_reflection_vector = (2 * dot(_WorldSpaceLightPos0, normalize(i.worldNormal)) * normalize(i.worldNormal) - _WorldSpaceLightPos0);
                float3 specular_reflection_vector = reflect(-normalize(_WorldSpaceLightPos0), normalize(i.worldNormal));
                float3 specular_view_vector = normalize(_WorldSpaceCameraPos - i.worldVertex);

                float specular_strogness = dot(normalize(specular_reflection_vector), specular_view_vector);

                if(specular_strogness >= 1 - _SpecularTreshold) specular_strogness = 1.0;
                else specular_strogness = 0.0;
                 
                
                
                float4 color = _AmbientColor * _AmbientCoefficient +
                    _DiffuseColor * _DiffuseCoefficient * dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0)) +
                    _SpecularColor * _SpecularCoefficient * specular_strogness;
                    

                //return _SpecularColor * _SpecularCoefficient * specular_strogness;
                return color;
            }
            ENDCG
        }
    }
}
