Shader "Unlit/PhongShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt("LightIntensity", Range(0,1)) = 1
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(1,128)) = 16
        _Ambient ("Ambient Strength", Range(0,1)) = 0.1
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2; 
                float3 normalWorld : TEXCOORD3; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _LightInt;
            float4 _LightColor0; //light from the first directional light Unity finds in game (first as in 1st in the hiearchy, but there is usually only 1 sun in game)
            fixed4 _SpecColor;
            float _Shininess;
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //get view direction (where we're looking from'). This determines specularity and defusion. 
                o.viewDir = WorldSpaceViewDir(v.vertex);

                //normal multiplication.
                //change/transform v.vertex from Object to Wrodl space.
                float4 worldPos4 = mul(unity_ObjectToWorld, v.vertex);
                //calc nomrals in world space
                float3 transformNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));


                o.worldPos = worldPos4.xyz;

                o.normalWorld = transformNormal;



                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture - find color of texture at current location
                fixed4 col = tex2D(_MainTex, i.uv);

                //LAMBERT DEFUSE
                float3 normal = normalize(i.normalWorld); //get normals
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //give us directional light and normalize. This is direction light will come from.
                
                float lambert = max(0, dot (normal, lightDir)); //calc the defuse range. anything below 0, will be 0. Use dot product from upper range.

                //SPECULAR (phong) -
                //viewDir --> where observer is in world space in relattion to object
                float3 viewDir = normalize(i.viewDir);
                //add the vector of the lightdirction with vector of viewer. This gives new vector that can be compared to nomral of object
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float ndotH = max(0, dot(normal, halfVector));
                //calc we curently have, but to power of the shiness. This exponentially changes how shiny object is depending on where obeserver is (ViewDir) in relation to light direction reflection
                float specFactor = pow(max(0,ndotH), _Shininess);


                //world light
                float3 lightColor = _LightColor0.rgb * _LightInt;
                float3 ambient = _Ambient * lightColor;

                //defuse - take color a multiply by a tint
                float3 diffuse = lambert * lightColor * col.rgb;
                float3 specular = specFactor * lightColor * _SpecColor.rgb;

                //final color
                float3 finalColor = ambient + diffuse + specular;
                //1.0 --> alpha of 1
                fixed4 color = fixed4(finalColor, 1.0);  



                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //specularity = we're adding the specFactor not multiplying b/x we're adding a color to certin areas (the white shinny part)
                //lambert, = we're changing color of whole sphere '
                //return col * lambert + specFactor;

                //return float4(1,0,0,1);

                return color;
            }
            ENDCG
        }
    }
}
