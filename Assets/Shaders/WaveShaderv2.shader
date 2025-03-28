Shader "Unlit/WaveShaderV2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (1,1,1,1)
        _DiffuseMapSamplerTex("Diffuse Map Sampler", 2D) = "white" {}
        _SomeValue("some value", Float) = 1.0
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
        _Scale ("UV scale", Float) = 1
        _Offset("UV Offset", Float) = 0
        _ColorGradStart("Color Gradient Start", Range(0,1)) = 0
        _ColorGradEnd("Color Gradient End", Range(0,1)) = 1
    }
    SubShader
    {
        //SUBSHADER --> render pipeline related options. 

        //Quene --> if it renders before or after some other shader.
        //Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Tags{ "RenderType" = "Opaque"}
        LOD 100
        // SrcAlpha OneMinusSrcAlpha

        Pass
        {
            //PASS --> Graphics related options for this specific render pass. It's 'etails of this render pass itself
                //blending mode
                //stem cell properies
            CGPROGRAM
            //CGPROGRAM --> where shader code starts

            //define the name of the vertex function (vert) and fragment function (frag)
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            //INPUT STRUCT
            //different input Stuct - like appdate it's data 'from application to shader - contains all vertex sata we're into shader from CPU (short for application to vertex)'
            //POSITION --> data coming in from CPU. Data is binded/assigned to variable
            //posiion --> variable storing incoming data
            //colon --> binding. Binding variable position to object space POSITION (which is incoming data from CPU)
            struct a2v
            {
                float4 position : POSITION;
                float2 texCoords : TEXCOORD0;
                float3 tangent :   TANGENT;
                float3 binormal: BINORMAL;
                float3 nomral : NORMAL;

            };

            //Appdate --> per vertex mesh data
            struct appdata
            {
                float4 vertex : POSITION; //vertex position
                float2 uv : TEXCOORD0; //uv coordinates --> used for mapping 2D textures onto 3D objects. Uses uv map.
                                        //but can be used for other things like
                                        //TEXCOORD0 --> UV channel 0. 
                float3 normals : NORMAL; //normal of this specific Vertex
                float4 color : COLOR;
                float4 tangent : TANGENT;
            };


            //OUTPUT STRUCT 
            //unlike input struct (whict tells compute what data to assign to variables), the output struct tells computes which REGISTERS to assign the values to
            //POSITION --> register to assign value to. It's a chanel that holds data when data is passed from vertex shader to pixel shader
            //position --> variable holding data
            //there are limited number of chanels that can hold data. When data is passed from vertex shader to pixel shader, it must go in one of predefined registers.
            //data fill order reverses
                //Vertex shader --> CPU passes info from POSITION, which is then assigned to variable position in vertex Shader
                //pixel shader --> vertex shader passes info from appdata.position to v2f.position (after changine to WorldSpace), 
                    //and then v2f.position assigns that data to register POSITION

            //you only have access to INTERPOLATED data passed from vertex shader. You DON't have info of a single vertex. Therefore, the color of a fragment at the half
            //point of a vertex colored red on the right, and a vertex colored blue on the left will be purple. The colors will get more red for each fragment that is
            //closer to the red vertex, and more blue for those closer to the blue. 
                //Same applies for normal info. A fragment normal is an inbetween of the normals of the vertexes on either side. It LERPS (INTERPOLATES) between the Vertex
                //normals
            //you get INPTERPOLATED VALUE of pixel, of whatever is defined in vertex shader for this specific fragment
            struct v2f
            {
                //float4 position : POSITION;
                float2 uv : TEXCOORD0;      //TEXCOORD0 --> doesn't necessarily refer to UV chanel. It's the Uv coordinates from vertex shader stored in register TEXCOORD0
                float3 normal : TEXCOORD1;
                float3 lightVec : TEXCOORD2;
                float3 worldNormal : TEXCOORD3; //Note: Vertex normal data is part of vertex (the point in space). It's not part of line connecting vertexes'
                                                //in fragment shader, there are fragments/pixels inbetween two vertexes. The normal of the inbetween fragment is 
                                                    //an interpolation of the normals of the vertexes on either side. The normals smoothly blend between the vertex normals
                float3 worldTangent : TEXCOORD4;
                float3 worldBinormal : TEXCOORD5;

                float4 vertex : SV_POSITION; //CLIP SPACE --> clip space position of this vertex
            };

            sampler2D _MainTex;//texture
            float4 _MainTex_ST;
            float4 _BaseColor;
            sampler2D _DiffuseMapSamplerTex;
            float _SomeValue;
            float4 _ColorA;
            float4 _ColorB;
            float _Scale;
            float _Offset;
            float _ColorGradStart;
            float _ColorGradEnd;

            v2f vert (appdata v)
            {
                v2f o;
                //CLIP SPACE --> -1 to 1, inside of render target.
                //converts local space of vertex and transform to clip space with MVP-matrix (mode view projection).
                //This conversion makes shader follow mesh it's applied to. Without this, the shader is slapped on top of the camera and doesn't move
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                //POST PROCESSING SHADERS --> cover the entire screen and don't move based on camera position. The mesh is rendered directly in clip space
                //the position of the object doens't matter because we're not using converstion matrix. Shader doesn't have position, it covers whole screen'
                //o.vertex = v.vertex;

                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //o.uv = (v.uv + _Offset)  * _Scale; //pass through without modification to space. Scale the UV by factor _Scale (multiply), and change position with _offset (add)
                //fade from one color to another across x axis.
                o.uv = v.uv; //

                //assign normal value to the v2f strcut to pass to frag
                //o.normal = v.normals;
                //convert from object space to world space. --> doesn't change normal direction if you rotate object. Normals corespond to WorldSpace normals'
                o.normal = UnityObjectToWorldNormal (v.normals); 
                return o;
            }

            float InverseLerp(float start, float end, float t)
            {
                return (t - start) / (end - start);
            }


            //fixed4 --> lower percision that float4
            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);

                //ColorTexture Map
                //tex2D(nameOfSampler, textureCoordinates) --> samples Color texture to determine color at this pixel
                //float4 ColorTexture = tex2D(_DiffuseMapSamplerTex, i.uv);
                
                //Detail TextureMap

                //col *= _BaseColor;

                //FADE IN AND OUT OVER TIME
                //col.w = max(sin(_Time.y),0);

                //SWIZZLE
                float4 valueA = float4(1,0,0,1);
                float2 valueB = valueA.zy;
                float4 valueC = valueA.yxzw;
                float4 valueD = float4(0.4, 0.5, 0.9, 1);

                //ColorTexture = valueD;

                //ColorTexture = valueD.xxxx; //grey scale of this color

                //output normals
                //return float4 (i.normal, 1);

                //output uv - x (red) and y (green) added together and product yellow in middle. 
                 //return float4 (i.uv, 0, 1);
                //output uv grey scale to see x coordinate only. It's horizontal grey scale'
                //return float4 (i.uv.xxx, 1);
                //output uv grey scale to see y coordinate only. It's vertical grey scale'
                // return float4 (i.uv.yyy, 1);

                //LERP --> fade between 2 values based on 3rd value (usually between 0 to 1).
                //float4 (i.uv.xxx, 1); --> x uv coordinate is 0 on left side and 1 on right side. This can be used as 't' param of lerp function
                //float4 outColor = lerp(_ColorA, _ColorB, i.uv.x);

                //Remap the x-coordinate of uv to another range, changing where x starts and where it ends.
                //return i.uv.x; //this is used for debugging to visualize the current gradient.
                //float t = InverseLerp(_ColorGradStart, _ColorGradEnd, i.uv.x);
                //return t; //this shows a gradient that can be adjusted based on start and end values. Use to visulaize the InverseLerp function


                //t can return values less than 0 and or greater than 1. We check if t is outside range of 0 to 1 using 'frac'
                //FRAC --> same as  value - floor(value). floor returns largest integer that's smaller to equal to input'.   - 0.2 - floor(-0.2) = -0.2 - (-1) = 0.8
                //if values are outside range of 0 to 1, then grey shaded part repeats multiple times instead of being completely balck or white.
                //if it's clamped, then we would not see a repeating pattern. Here the pattern repeats
                // float t = InverseLerp(_ColorGradStart, _ColorGradEnd, i.uv.x);
                // t = frac(t);
                

                //We don't want the pattern to repeat, therefore, we clamp the values'
                //SATURATE --> clamps values within a range of 0 to 1. Same as clamp01 fun in c#
                //float t = saturate(InverseLerp(_ColorGradStart, _ColorGradEnd, i.uv.x) );


                //make 5 repeating sections with each section having range of 0 to 1.
                //float t = frac(i.uv.x * 5);

                //triangle wave-->repeating pattern clamped fro 0 to 1
                //abs(frac(i.uv.x * 5) * 2 - 1) --> this is 'x' in graph y = x. 
                // - 1 --> makes y-intersect -1. The abs of this is 1, since - 1 becomes 1. This forms a triangle with points at 1, 1 and 0.
                //float t = abs(frac(i.uv.x * 5) * 2 - 1);

                //repeating pattern with cos - between -1 to 1.
                //multiplying my TAU (6.28) means it repeats perfectly, starting and ending on the same value. Guarentees you go through entire period
                //float t = cos(i.uv.x * TAU * 5);

                 //repeating pattern with cos - between 0 to 1.
                 //apply shift to move range between 0 to 1.
                 //float t = cos(i.uv.x * TAU * 2) * 0.5 + 0.5;


                 //wave and distortion
                //a wave is a type of distortion. DISTORTIONS are created by applying an Offset
                
                //diagonal offset --> as y gets bigger, the offest increases. Along the x axis when y = 0, there is no offset, but it's shifted more and more closer to top
                //float xOffset = i.uv.y;

                //wave pattern
                //float xOffset = cos (i.uv.y * TAU * 8) * 0.05f;
                //float t = cos( (i.uv.x + xOffset) * TAU * 2) * 0.5 + 0.5;

                //animate --> add current time in seconds. Moves pattern horizontally
                //float xOffset = cos (i.uv.y * TAU * 8) * 0.05f;
                //float t = cos( (i.uv.x + xOffset + _Time.y * 0.1) * TAU * 2) * 0.5 + 0.5;

                 //animate --> moves pattern vertically and reverse the direction by negating time, changing from adding time to subtracting
                // float xOffset = cos (i.uv.x * TAU * 8) * 0.05f;
                //  float t = cos( (i.uv.y + xOffset - _Time.y * 0.1) * TAU * 2) * 0.5 + 0.5;

                //animate --> moves pattern vertically and rerverse direction with fade out effect.
                //return i.uv.y //DEBUG ->use to check values in grey scale. Here black is at the bottom (0) & white is at the top (1), so these can be used for the fade
                //FADE OUT --> multiply by low value to make color darker. 
                float xOffset = cos (i.uv.x * TAU * 8) * 0.05f;
                float t = cos( (i.uv.y + xOffset - _Time.y * 0.1) * TAU * 2) * 0.5 + 0.5;
                //we're reversing the direction of the fade by using minus 1. This makes it fade out at top where y = 1'
                t *= 1 - i.uv.y;


                float4 outColor = lerp(_ColorA, _ColorB, t);
                return outColor;


                //return outColor;
                
            }
            ENDCG
        }
    }

   

    
}
