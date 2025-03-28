Shader "Unlit/TelaportShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TelaportLocation1 ("TelaportLocation1", Vector) = (0,0,0,0)
        _ColorEven ("ColorEven", 2D) = "red" {}
        _ColorOdd("ColorBlue", 2D) = "black" {}
        _ColorTintEven("ColorTintEven", Color) = (0,0,0,1)
        _ColorTintOdd("ColorTintOdd", Color) = (0,0,0,1)
        _TelaportPerSecond("TelaportPerSecond", float) = 0.1
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
            float3 _TelaportLocation1;

            //Time
            float1 _TelaportPerSecond;

            //colors
            sampler2D _ColorEven;
            sampler2D _ColorOdd;
            float4 _ColorTintEven;
            float4 _ColorTintOdd;

            bool IsTimeAtNextInterval()
            {
                return (int(_Time.y * (1/_TelaportPerSecond) % 2) == 0);
            }

            bool isTimeEven()
            {
                return (int(_Time.y % 2) == 0);
            }
          

            v2f vert (appdata v)
            {
                v2f o;
                bool isTimeAtNextInterval = IsTimeAtNextInterval();

                if(isTimeAtNextInterval)
                {
                    v.vertex.x += 0.1;
                }
                else
                {
                    //v.vertex.y += 2;
                    //v.vertex.xyz = v.vertex.yxz;
                    v.vertex.x -= 0.1;
                    
                }
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                bool isEven = isTimeEven();

                if(isEven)
                {
                    col *= _ColorTintEven;
                    //col = tex2D(_ColorEven, i.uv);
                }
                else
                {
                    col *= _ColorTintOdd;
                    //col = tex2D(_ColorOdd, i.uv);
                }

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
