// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader1"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //译器看到我们正在返回四个浮点数的集合，但是它不知道该数据代表什么。因此，它不知道GPU应该如何处理。我们必须对程序的输出非常具体。
            //POSITION代表 把模型的顶点坐标填充到 v 中
            //SV_POSITION代表 输出的是裁剪空间中的顶点坐标
            float4 vert (float4 v : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(v);
            }

            //告诉渲染器 把用户的输出颜色存储到一个渲染目标（RT）中，这里将输出到默认的帧缓存中
            fixed4 frag () : SV_Target
            {
                return fixed4(1.0, 1.0, 1.0, 1.0);
            }
            ENDCG
        }
    }
}
