// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Chapter6-DiffusePixelLevel"
{
    Properties
    {
        //漫反射颜色
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        //LightMode 决定了可以获取哪些内置变量 
        Tags
        {
            "LightMode"="ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            //逐顶点的漫反射光照，所以都在顶点着色器里面写
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //把法线转换到世界坐标中 
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize( i.worldNormal );
                fixed3 worldLightDir = normalize( _WorldSpaceLightPos0.xyz );

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(worldNormal, worldLightDir) );
                
                fixed3 color = ambient+ diffuse;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}