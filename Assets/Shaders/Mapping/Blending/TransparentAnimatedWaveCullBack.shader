Shader "Unlit/TransparentAnimatedWaveCullOffRenderBothSide"
{
    //SRC --> color you get out of the fragment shader

    //DST --> background (the destination you're rendering to'). Whatever is already behind the object

    //Blending in shaders is

    //SRC * a  +  DST * b           or subtraction              SRC * a  -  DST * b 

   
    //when you change the blending, as in how things blend with the background, then things you can modify are...
        //a --> 
        //b -->
        //operator + or -

    //you set a, b and the operator to get the effect you want.

    //ADDATIVE BLENDING --> makes things brighter by taking background and adding to it. It doens't darken anything.
        //go for light effects, fire, anything bright.

        //goal is to get: SRC + DST
        //therefore, make a = 1 and b = 1, and make operator +

        //SRC * 1 + DST * 1

    //MULTIPICITVIVE BLENDING --> multiply 2 or more colors together. 
        //goal is to get: SRC * DST
        //therefore, a = DST and b = 0

        //SRX * dst + DST * 0


    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" } //renders shader fully Opaque.
        LOD 100

        Pass
        {
            //BLEND MODE
            Blend One One //ADDATIVE
            // Blend DstColor Zero //multiply

            Cull Off
            ZWrite Off


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
                float t = cos(i.uv.y * TAU - _Time.y * periodOfY_numberofLines * reduceTimeFactor) * 0.5 + 0.5;
                return t;

            }
            ENDCG
        }
    }
}
