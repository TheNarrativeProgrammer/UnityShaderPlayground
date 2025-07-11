Shader "Unlit/DiagonalOffset"
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
                //DIALOGAL LINE
                //As we go higher on Y-axis, we add more in a specific direction
                //each value along X axis has the height of Y added to it. 
                float xOffset = i.uv.y;

                float t = cos ( (i.uv.x + xOffset) * TAU * 5) * 0.5 + 0.5;
                return t;
      
            }
            ENDCG
        }
    }
}
