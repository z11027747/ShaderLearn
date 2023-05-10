// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-FalseColor"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                // pos里面包含了顶点在裁剪空间中的位置信息
                float4 pos : SV_POSITION;
                //COLOR0语义可以存储颜色信息
                fixed4 color : COLOR0;
            };

            //appdata_full 内置的结构体，几乎包含了所有的模型数据
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //可视化法线方向
                o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                //可视化切线方向
                o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                
                //可视化副切线方向
                fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                
                //可视化第一组纹理坐标
                o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
                
                //可视化第二组纹理坐标
                o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);

                //可视化第一组纹理坐标小数部分
                o.color = frac(v.texcoord);
                if ( any( saturate( v.texcoord ) - v.texcoord ) )
                {
                    o.color.b = 0.5;
                }
                o.color.a=1.0;

                //可视化顶点颜色
                o.color = v.color;
                
                return o;
            }

            //告诉渲染器 把用户的输出颜色存储到一个渲染目标（RT）中，这里将输出到默认的帧缓存中
            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}