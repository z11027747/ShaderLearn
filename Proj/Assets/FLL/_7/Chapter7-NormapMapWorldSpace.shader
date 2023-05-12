Shader "Custom/Chapter7-NormalMapWorldSpace"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
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
            sampler2D _BumpMap;
            float4    _BumpMap_ST;
            float     _BumpScale;
            fixed4    _Specular;
            float     _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

                // 获得世界空间下副切线(副法线)：(法向量 x 切线向量) * w
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                // 将切线、副切线、法线按列摆放得到从切线空间到世界空间的变换矩阵
                // 把该矩阵的每一行分别存储在TtoW0、TtoW1、TtoW2中
                // 把世界空间下的顶点位置的xyz分量分别存储在这些变量的w分量中
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

                // 获得世界空间下单位光向量
                fixed3 lightDir = normalize( UnityWorldSpaceLightDir( worldPos ) );
                // 获得世界空间下单位观察向量
                fixed3 viewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );

                // 获得压缩后的法线像素
                // 若法线纹理Texture Type未设置成Normal map，
                // 要从像素映射回法线，即[0, 1]转化到[-1, 1]
                // bump.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                
                // 如果设置了Normal map类型，Unity会根据平台使用不同的压缩方法，
                // _BumpMap.rbg值不是对应的切线空间的xyz值了，要用Unity内置函数
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump.xy*= _BumpScale;
                // 因为法线都是单位矢量。所以 z = 根号下（1 - (x*x + y*y) ）
                bump.z = sqrt(1.0 -  saturate( dot(bump.xy, bump.xy) ) );

                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                // 如果设置了Normal map类型，Unity会根据平台使用不同的压缩方法，
                fixed3 tangentNormal = UnpackNormal(packedNormal);

                tangentNormal.xy *= _BumpScale;
                // 因为法线都是单位矢量。所以 z = 根号下（1 - x*x + y*y ）
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 对纹理进行采样
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

                // 计算漫反射光
                // 兰伯特公式：Id = Ip * Kd * N * L
                // IP：入射光的光颜色；
                // Kd：漫反射系数 ( 0 ≤ Kd ≤ 1)；
                // N：单位法向量，
                // L：单位光向量
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

                fixed3 halfDir = normalize(lightDir + viewDir);

                // Blinn-Phong高光反射公式：
                // Cspecular=(Clight ⋅ Mspecular)max(0,n.h)^mgloss
                // Clight：入射光颜色；
                // Mspecular：高光反射颜色；
                // n: 单位法向量；
                // h: 半角向量：光线和视线夹角一半方向上的单位向量
                // h = (V + L)/(| V + L |)
                // mgloss：反射系数；
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}