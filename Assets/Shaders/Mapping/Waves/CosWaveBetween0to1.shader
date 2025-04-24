Shader "Unlit/CosWaveBetween0to1"
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
                //this code has a range of -1 to 1, which causes the start and end of the quadratic to end at inpercise spots in the cos wave.
                //float t = cos(i.uv.x * 25);

                //Use TAU to make the range between 0 to 1, which makes the start and end points of the wave the min and max of the cos or sin wave.
                //TAU --> guarentees we go through entire period

                //this is still a range of -1 to 1, but now will go through a period, which the start and end being the same value. It repeats perfectly.
                //float t = cos(i.uv.x * TAU * 2);

                //REMAP TO 0 TO 1.
                //cos so it starts at 1 and goes to 0
                //shifts the range
                float t = cos(i.uv.x * TAU * 2) * 0.5 + 0.5;

                return t;
            }
            ENDCG
        }
    }
}
