Shader "Unlit/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (0.5, 0.65, 1, 1)
        _AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)
        _SpecularColor("Specular Color", Color) = (0.0, 0.9, 0.9, 1)
        _Glossiness("Glossiness", Float) = 32
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimThreshold("Rim threshhold", Range(0,1)) = 0.1
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineThreshold("Outline threshhold", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags 
        {
            //try to capture all the light, and try to do everything in a single pass (a single forward pass)
            //use this for simple calculations that only require 1 pass
            "LightMode" = "ForwardBase"
            //"OnlyDirectional" --> Shader can only interact with directional light. In cartoon, we don't care about multiple lights. It's a simple calc with 1 main light
            "PassFlags" = "OnlyDirectional"
            
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //pass normals to appdata
                float3 normal : NORMAL;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                //normals
                float3 worldNormal : NORMAL;
                //Specular is dependant on view direction of camera. This a currently empty, but is open for us to assign coords later
                float3 viewDir: TEXCOORD1; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _AmbientColor;
            float _Glossiness;
            float4 _SpecularColor;
            float4 _RimColor;
            float _RimThreshold;
            float4 _OutlineColor;
            float _OutlineThreshold;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //take normals from appdata, convert to world, and store in v2f
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                //assign the coordinates of the direction of light.
                o.viewDir = WorldSpaceViewDir(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //normalize normals
                float3 normal = normalize(i.worldNormal);
                //position of directional light in relation to object. Normals pointing away from directional light are 0, normals pointing at DL are 1.
                float nl = dot(_WorldSpaceLightPos0, normal);


                //cut the shadow, but grabbing nl and applying threshhold
                //float lightIntensity = nl > 0 ? 1 : 0;
                //the code above is a clear drastic line. The code below make is slighly smoothed out.
                //0, 0.01 --> range for smoothing. Anything outside range is either 0 or 1
                float lightIntensity = smoothstep(0, 0.03, nl);


                //LightColor0 is color of directional light
                float4 light = lightIntensity * _LightColor0;

                float3 viewDir = normalize(i.viewDir);

                //HALF VECTOR - less expensive than doing reflection.
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float NdotH = dot(normal, halfVector);  
                //calc Specular intensity. Multuiply by intensitty so shadows don't have Specularity.
                // Glossiness --> exponental drop off
                float specularIntensity = pow(NdotH * lightIntensity, _Glossiness);
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _SpecularColor;

                //OUTLINE RIM get reverse of view dir and Normals
                float rimDot = 1 - max(dot(viewDir, normal), 0);
                float rimIntentsity = smoothstep(_RimThreshold - 0.05, _RimThreshold + 0.05, rimDot);
                float4 rim = rimIntentsity * _RimColor;

                //Outline
                float outlineDot = dot(viewDir, normal);
                float outlineIntensity = smoothstep(_OutlineThreshold - 0.05, _OutlineThreshold + 0.05, outlineDot);
                float4 outlineV1 = outlineIntensity * _OutlineThreshold;

                //Outline
                float outlinedotV2 =  1 - max(dot(viewDir, normal), 0);
                float outlineintensity = smoothstep(_OutlineThreshold - 0.2, _OutlineThreshold, outlinedotV2);
                float4 outlineV2 = outlineintensity * (1 - _OutlineColor);
                


                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return col * _Color * nl;
                //when we add something, we put a color on top of the other color. We're adding Grey
                //when we multiply a color with another color, they are combined together.
                //return col * _Color * (lightIntensity + _AmbientColor);
                //Factor in directional light color and intensity
                //return col * _Color * (light + _AmbientColor + specularIntensity);
                //pass smoothstep to get circle instead of gradient. Also, get a specular Color.
                //return col * _Color * (light + _AmbientColor + specular + rimIntentsity);
                //return col * _Color * (light + _AmbientColor + specular + rim) * outlineV1;

                
                return col * _Color * (light + _AmbientColor + specular + rim) * (1 - outlineV2);
            }
            ENDCG
        }
    }
}
