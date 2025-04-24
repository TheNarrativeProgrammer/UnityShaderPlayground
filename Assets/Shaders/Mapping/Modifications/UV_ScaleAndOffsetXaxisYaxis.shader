Shader "Unlit/UV_ScaleAndOffsetXaxisYaxis"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("ColorA", Color) = (1,1,1,1)
        _ColorB("ColorB", Color) = (1,1,1,1)
        _Scale ("UV Scale", Range(1,10)) = 1
        _Offset("UV Offset", Range(-10,10)) = 0
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
            float4 _Color;
            float _Scale;
            float _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //convert local space to clip space

                //PASSTHROUGH
                //Offset --> added (not multiplied). Whether the offset is before or after the Scale depends on use case.
                //This offsets the UV's diagonally'
                o.uv = (v.uv + _Offset) * _Scale;           

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4 (i.uv, 0, 1);
            }
            ENDCG
        }
    }
}
