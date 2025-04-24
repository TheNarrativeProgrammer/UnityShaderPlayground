Shader "Unlit/UV_SliderLerpTwoColorClamp"
{
        Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("ColorA", Color) = (1,1,1,1)
        _ColorB("ColorB", Color) = (1,1,1,1)
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1

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
            // make fog work
            #pragma multi_compile_fog

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

            //variables
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            float InverseLerp (float a, float b, float v)
            {
                //Note: you need to acount for divisions by zero. 
                //t --> normalized valeu between 0 to 1
                //value --> between a and b

                //LERP (a, b, t) = value            // v = result of lerp          --> between a and b.      if a = 10 and b = 20, then the result is between 10 and 20
                //IVERSE LERP (a, b, value) = t     // t = result of InverseLerp    --> between 0 and 1       always between 0 to 1

                //USE CASE 1. If volume at 20 meters away is 0 (min) and at 10 meters away it's 1 (max), then between 20 meters to 10 meters the volume will increase.
                //at 10 meters the volume is a consistent flat line at 1
                //at 20 meters the volume is a consistent flat line at 0

                //  1 ----------------10
                //                      \
                //                       \
                //                        \
                //                         \
                //                          \
                //  0                        20 _____________

                //NOTE: unity built in InverseLerp Clamps, but the InverseLerp here does NOT CLAMP with the formula below.
                //This will result in 't' possibly being outside the range of 0 to 1.
                //USE FRAC --> checks range and clamps
                //float result = (v - a) / (b - a);
                
                //USE CASE 2 - We have a gradient along the x axis with a = 0.3 and b = 0.6. 
                //The value produces a grey scale along the Xaxis.
                //INVERSE LERP (a, b, v) = t        //t = result of lerp        --> t = between 1 to 0
                //                                  //                          --> v = between 0.3 and 0.6 
                //the result is a REMAP with the gradient
                    //start (all black)             usual gradient -> start at 0              remapped -> start at 0.3         Now it's black from 0 all the way to 0.3
                    //end (all white)               usual gradient -> start at 1              remapped -> start at 0.6         now it's white from 0.6 all the way to 1'

                    //value = 0.3 and less          --> output 't' = 0
                    //value = 0.6 and greater       --> output 't' = 1

                //INVERSE LERP --> modifies input range 't'
                //LERP --> modifies the output range 'v'
                float result = (v - a) / (b - a);   
                return result;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //convert local space to clip space

                //PASSTHROUGH
                //Offset --> added (not multiplied). Whether the offset is before or after the Scale depends on use case.
                //This offsets the UV's diagonally'
                //o.uv = (v.uv + _Offset) * _Scale;
                //We just want to apply the Offset and scale lerp across the Xaxis, so we passthrough the uv values unchanged and ignore scale and offset in vertex
                //
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //BLEND BETWEEN 2 COLORS BASED ON X UV COORDINATE
                //we want to blend between to colors. Lerp blends between 2 values based on a 3rd value (which is usually betwen 0 to 1). 3rd value is 't'
                //i.uv.xxx -> x uv coordinate is 0 on left and 1 on right, so it can be used as 't'
                //this produces a gradient from left at 0 to right at 1. The next section adjust the start and end points.

                // float4 outColor_StartZeroEndOne = lerp(_ColorA, _ColorB, i.uv.x);
                // return outColor_StartZeroEndOne;

                //CHANGE/REMAP THE X COORDINATE START AND END OF UV'S TO SOME OTHER RANGE -- Greyscale
                //testing 
                //--> first output greyscale of x uv coordinates. Black on left to white on right.
                //--> We want to change where this gradient starts and where this gradient ends
                //return i.uv.x;
                //IVERSE LERP --> similar to smooth-step (but smoothstep has smoothing). REMAPs range of 0 and 1, taking in v (value) which is between a & b, and returnnig t
                //          -->change where gradient starts and ends.
                // v = gradient input. This is the current range that the _ColorStart and _ColorEnd are mapped to. Here, it's i.uv.x meaning start is 0 and end is 1
                //this produces a grey scale where the start and end can be adjsuted.
                // float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x);
                // return t;

                //CHANGE/REMAP THE X COORDINATE START AND END OF UV'S TO SOME OTHER RANGE -- Colors
                // inverse lerp --> modifies input range 't'
                //float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x);
                // lerp --> modifies the output range 'v'
                //now that 't' has been modified, it can be fed into lerp to apply the colors.
                //float4 outColor = lerp(_ColorA, _ColorB, t);

                //'T' IS OUTSIDE RANGE OF 0 TO 1. OPTIONS FOR KEEPING 'T' IN RANGE

                //1. FRAC
                //frac = value - floor(value) 
                //floor = returns the largest integer that is less than or equal to value. If value = 5.5, then floor returns 5
                // 5.5 - 5 = 0.5
                // this means the values will repeat within the 0 to 1 interval in both directions.
                    //if values are above 1 --> graident repeats
                    //if values are below 0 --> gradient repeats
                //frac vs clamp 
                    //frac --> gives repeating pattern
                    //clamp --> no repeating pattern. Values below 0 become 0, and values above 1 become 1.

                //2. SATURATE --> this clamps the 't' returned from inverse lerp. It's clamped between 0 to 1
                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                
                t = frac(t);

                float4 outColor = lerp(_ColorA, _ColorB, t);
                return outColor;

            }
            ENDCG
        }
    }
}
