Shader "Unlit/CircularVerticalPulseForceField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _XOffSet ("X Offset", Float) = 1
        _TimeScale ("Time Scale", Float) = 0.1
        _PeriodToRepeat ("Periods to Repeat", Float) = 2
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Cull Off
        ZWrite Off
        Blend One One

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
                float3 normals : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };


            //Variables
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _XOffSet;
            float _TimeScale;
            float _PeriodToRepeat;

            float4 _ColorA;
            float4 _ColorB;



            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.y += cos(_Time.y +  v.vertex.y * _PeriodToRepeat);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal (v.normals);
                
                return o;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                float t = cos( (i.uv.y + _XOffSet - _Time.y * _TimeScale) * TAU * _PeriodToRepeat) * 0.5 + 0.5;
                t *= 1 - i.uv.y;                                                                                    //reverse the direction

                float topBottomRemover = (abs(i.normal.y) < 0.999);                                                 //remove top by making greater than 0.999 = 0.
                float waves = t * topBottomRemover;                                                                 //apply removeal. Dirrectly down is 0 and now directly up is 0

                 float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                 return gradient * waves;


            }
            ENDCG
        }
    }
}