Shader "Custom/BasicSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (0.2,0.8,0.3,1)
        _ColorEmission ("ColorEmission", Color) = (1.0,0.4,0.6,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Smoothness("Smoothness", Range(0,1)) = 0.0
        _Emission("Emission", Range(0,1)) = 0.0

        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("BumpMap", 2D) = "bump" {}
    }
    SubShader
    {

        Tags { "RenderType"="Opaque" }
        Cull Off

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #define TAU 6.28318530718


        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _ColorEmission;
        sampler2D _MainTex;
        sampler2D _BumpMap;
        half _Emission;
        half _Smoothness;


 

        void surf (Input IN, inout SurfaceOutputStandard o)
        {


            float numberOfLinesInOnePeriod = 5;

            //* 0.5 + 0.5 used to make full period for sin and cos. Not sure why this doesn't work for world positision?'

            //make diagonal. As x increases, so does y and this is addative along the axis.
            float xOffset = (IN.worldPos.x);
            float slowTimeFactorDiagonalLines = 0.2;
            //negate time to move from high to low
            float t = cos ((IN.worldPos.y + xOffset - _Time.y * slowTimeFactorDiagonalLines) * TAU * numberOfLinesInOnePeriod);
            
            clip (t);

            //cool looking stuff.
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
            o.Smoothness = _Smoothness;
            o.Metallic = _Metallic; 

            // //
            // //Glow 
            float slowTimeFactorEmission = 0.9;
            float glowFactor = sin(_Time.y * slowTimeFactorEmission) * 0.5 + 0.5;
            o.Emission = tex2D(_MainTex, IN.uv_MainTex).rgb * glowFactor * _Emission * _ColorEmission.rgb;


        }
        ENDCG
    }
    FallBack "Diffuse"
}
