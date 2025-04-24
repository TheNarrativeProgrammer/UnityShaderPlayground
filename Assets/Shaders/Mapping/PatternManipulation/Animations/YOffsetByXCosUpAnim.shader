Shader "Unlit/YOffsetByXCosUpAnim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #define TAU 6.28318530718

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float yOffset = cos(i.uv.x * TAU * 5) * 0.01;
                float reduceTimeFactor = 0.1;

                //To get the animation to go UP, negate the Time.
                float t = cos((i.uv.y + yOffset - _Time.y * reduceTimeFactor) * TAU * 5) * 0.5 + 0.5;
                return t;
            }
            ENDCG
        }
    }
}
