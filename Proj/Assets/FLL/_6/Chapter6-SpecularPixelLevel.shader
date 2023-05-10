// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Chapter6-SpecularPixelLevel"
{
    Properties
    {
        //漫反射颜色
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        //高光反射颜色
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        //高光区域大小
        _Gloss("Gloss", Range(8.0, 256)) = 20
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
            fixed4 _Specular;
            float  _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            //逐顶点的漫反射光照，所以都在顶点着色器里面写
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //把法线转换到世界坐标中 
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                //将顶点坐标转换到世界坐标中
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                //表面法线反射方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                // _WorldSpaceCameraPos 世界空间中摄像机的位置，与顶点的世界坐标相减即可得到世界空间下的视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                //入射光颜色 * 高光反射系数 * 视角方向点乘反射方向（0-1） ^ 光泽度系数
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                //与环境光颜色叠加
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}