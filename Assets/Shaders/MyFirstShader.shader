Shader "Unlit/MyFirstShader"
{
    //PROPERTIES --> all things we can pass to the unity inspector and expose.
    //UPPER SIDE IS WRAPPER --> PRORPERTIES and first part of SUBSHADER (tags and LOG) (everything before PASS)is the wrapper
    //LOWER SIDER --> actual HLS code (starts at PASS)
    Properties
    {
        //_NameOfVariableInHSLCode ("NameExposedInUnity", propertyType) = "initialValue" {}
        _MainTex ("Texture", 2D) = "white" {}
        //1. create property
        _Period ("Period", Range(0.0, 100.0)) = 1.0
    }
    //SUBSHADER --> here we only have 1 pass, but after ENDCG at bottom, you can add another pass.
    //All of the code within this file is considered part of the shader (properties included). The subshader divides code into separate pass. 
    SubShader
    {
        //Tags --> pre made things we're telling Unity to care about. Here, the tag is defining the RenderType="Opaque", but it could be changed to "transpart"
        //this tell unity, that before we write the shader, apply this high level property to the shader and add them to pipeline.
        Tags { "RenderType"="Opaque" }
        //LOD --> level of detail. We define what this number means and how it will apply to the different properties. 
        //changing this number has no effect on the shader. It's for future reference, and defines a range that swaps between different shaders, each with different details.
        //LOD --> this is a tag type. 
        //The LOD is is then chosen in editor.
        //Based on the LOD selected in editor, a different pass with a matching LOD will be applied.
        LOD 100

        //PASS-->start of the pipeline.
        Pass
        {
            //CGPROGRAM --> after this point, we're writing HLSL code'
            CGPROGRAM

            //a. PREPROCESSING 

            //DIRECTIVES
            //#pragma--> high level definitions that tell system what things you're going to access
            //#pragma vertex vert --> we're accessing the vertex shader and it's name "vert"
            //#pragma fragment frag --> accessing fragment part of pipeline and name 'frag'
            #pragma vertex vert
            #pragma fragment frag

            // if you have fog system, this is how you control and render it
            #pragma multi_compile_fog


            //IMPORT LIBRARY --> different type of directive. Like normal include in unity. Here, we're importing library for compute graphics.
            //import libraries you need for code below.
            #include "UnityCG.cginc"


            //b. STRUCT DEFINITION
            //structs are info that is passed into the shader for a SINGLE FRAGMENT
            struct appdata
            {
                //type variableName : ThingPassedFromCPUThatMustBeNamedInSpecificWay;
                //POSITION --> tells unity, when you pass into to shader, pass POSITION of verticies and store in 'vertex'
                //float4 --> vertor of 4 values. W is the perspective value. (x,y,z,w)
                float4 vertex : POSITION;
                //TEXCOORD0 --> UV, image, texture info
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
            //2. crewate variable to link to property
            float _Period;

            //fixed --> single byte of info. Used for very small numbers. 0 to 226. used to colors

            //half --> in between fixed and float

            //int --> 32 byte negative and positive numbers

            //uint --> 32 bit but only positive numbers

            //float4 --> Vector. This is Vector4.


            //d. VERTEX SHADER --> shade that modifies geometry.
            //appdata -> struct defined above. This is info we're passing along'
            v2f vert (appdata v)
            {
                v2f o;
                //used to move vertixes around

                //get x values ov vertixes and add 5
                //v.vertex.x += 5;


                //v.vertex.x += sin(v.vertex.y * 3); --> 3 changes the period of sin wave
                //v.vertex.x += sin(v.vertex.y * 3);

                //3. use variable in script. You can then click on the Material and manipulate the value of the variable
                //v.vertex.x += sin(v.vertex.y * _Period);

                //change face of sin wave, use addition
                //_Time.y --> stored at float4. This is how time is stored and y has nothing to do with vertixes. _Time.x is divide by 20, _Time.z is multiply by 2 
                v.vertex.x += sin(_Time.y +  v.vertex.y * _Period);

                //3 ways to access variables once we create them
                //x, y, z used for coordinates. w is perspective.
                //v.vertex.x
                //v.vertex.w
                
                //r, g, b, used for color. a is alpha. This is the same data as x,y,z,w. X is same as r, y is same as g.
                //v.vertex.r 
                //v.vertex.a

                //swizzling --> mixing up the order that you're getting the data. xyz is a different order than yzx and it returns a different float3 (vector3)
                //v.vertex.xyz;
               // v.vertex.yzx;


                //e. FRAGMENT SHADER --> takes where verticies are and modifies them to give us pixels.
                //MATRIX
                float4x4 matrixof4;
                //[0] row 0
                //[1] column 1
                //matrixof4[0][1]

                //matrix swizzle --> use dot underscore ._
                //_m01 --> row 0 column 1
                //_m12 --> row 1 column2
                //this results in float2 b/c it's returning 2 values, pulling the specific value at row 0 column 1, and the specific value at row 1 column 2.
                //matrixof4._m01_m12


                //UnityObjectToClipPos --> converts world/local transform to clip space. Translate the final result of the vertex shade to clip space
                //before the next stage, which is the fragment shader.
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //now that space has been converted to screenshape, the fragment shader knows where things are on screenshape. It can determine what color each pixel is

                //_MainTex --> get the main image for the texture, 
                // i.uv --> get uv info
                //tex2D --> use texture info and uv info to determine where colors should be in shader
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                //once the color has been determined, and then applied to the pixel, return the color "col" info
                return col;
            }
            ENDCG
        }
    }
}
