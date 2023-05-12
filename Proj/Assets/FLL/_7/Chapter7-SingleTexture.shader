Shader "Custom/Chapter7-SingleTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4    _Color;
            sampler2D _MainTex;
            float4    _MainTex_ST;
            fixed4    _Specular;
            float     _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                // 将顶点坐标从模型空间变换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                // 将法线从模型空间变换到世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 将顶点坐标从模型空间变换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                //对纹理坐标顶点变换，先xy缩放，然后zw偏移
                // o.uv = v.texcoored.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 对纹理进行采样
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

                // 计算漫反射光
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}