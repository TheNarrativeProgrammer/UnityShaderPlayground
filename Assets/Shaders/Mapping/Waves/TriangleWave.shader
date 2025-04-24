Shader "Unlit/TriangleWave"
{
    //TRIANGLE WAVE
    //start with y = x. This produces linear line starting 0, with the y intercept at 0. 

    //y = abs(x). this produces triangle starting at 0. Y values to the left and right of the y axis are positive, but x is negative to the left and positive to the right

    // to make a trianlge wave that is repeating over some range
    //multiply x --> changes the slop
    //-/+ x --> change y intercept (equals the value you're adding or subtracting by). x - 1 --> y intercept of - 1.    Meaning it starts at - 1 

    //abs(x * 2) - 1 --> y intercept without abs is -1. With -1, then y intercept is 1 AND x = 1 when y = 1 on one end of the triangle.
    //this creates a TRIANGLE wave inside the 0 to 1 range.



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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
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
                //OPTION 1
                //make the coordinates into a wave trianlge.
                    //1. multiply by some value and do frac of that. This makes # of repeating sections of 0 to 1.
                //float t = frac (i.uv.x * 5);
                // return t; //testing
                    //2. multiply that by 2 and subtract 1. Then so abs of that.

                float t = abs(frac(i.uv.x * 5) * 2 - 1);
                return t;

                //OPTION 2
                //this can also be accomplished with trig since the patterns repeat.
                //this is implemented in the CosWave shader
                //float t = cos(i.uv.x * 25);
                //return t; 
                

            }
            ENDCG
        }
    }
}
