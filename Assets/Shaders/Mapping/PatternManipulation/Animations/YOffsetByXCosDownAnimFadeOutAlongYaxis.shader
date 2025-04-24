Shader "Unlit/YOffsetByXCosDownAnimFadeOutAlongYaxis"
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
                
                float minimizeWaveFactor = 0.01;
                float periodOfOffset_numberOfPeaks = 5;
                float yOffset = cos(i.uv.x * TAU * periodOfOffset_numberOfPeaks) * minimizeWaveFactor;


                //To get the animation to go UP, negate the Time.
                float periodOfY_numberofLines = 8;
                float reduceTimeFactor = 0.1;
                float t = cos((i.uv.y + yOffset - _Time.y * reduceTimeFactor) * TAU * 5) * 0.5 + 0.5;

                //FADE OUT
                //uv's of x or y are a range of 0 to 1. A fade out can be done by multiplying by the UV. 
                        //At 0, the return will be 0, making it invisible.
                        //At 1, the return will be 1, makging the value unchanged.

                //FADE OUT - BOTTOM
                //t *= i.uv.y;

                //FADE OUT - TOP
                //minus one reverses the result of normalized range equations.
                t *= 1 - i.uv.y;

                return t;

            }
            ENDCG
        }
    }
}
