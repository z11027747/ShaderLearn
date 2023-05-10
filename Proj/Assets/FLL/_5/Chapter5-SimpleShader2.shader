// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader2"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //a: Application
            //v: Vertex Shader
            struct a2v
            {
                //用模型空间的顶点坐标填充 vertex变量
                float4 vertex : POSITION;
                //用模型空间的法线方向
                float3 normal : NORMAL;
                //用模型的第一套纹理坐标
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                // pos里面包含了顶点在裁剪空间中的位置信息
                float4 pos : SV_POSITION;
                //COLOR0语义可以存储颜色信息
                fixed3 color : COLOR0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线方向范围在(-1,1)之间   * 0.5 + fixed3(0.5, 0.5, 0.5) 是为了吧范围转变成(0,1)
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            //告诉渲染器 把用户的输出颜色存储到一个渲染目标（RT）中，这里将输出到默认的帧缓存中
            fixed4 frag(v2f i) : SV_Target
            {
                //吧插值后的  color 显示到屏幕上
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
}