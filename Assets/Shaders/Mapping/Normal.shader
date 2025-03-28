Shader "Unlit/Normal"
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
            // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normals: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normals; //pass normal info from vertex shader to fragment shader
                //o.normal = UnityObjectToWorldNormal(v.normals); // use to lock normals to world space. Without this, Normals adjust as you rotate object b/c
                                                                //normals are in local space.
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4 (i.normal, 1);
            }
            ENDCG
        }
    }
}
