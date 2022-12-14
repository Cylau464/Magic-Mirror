Shader "Custom/Lit Overlay Dissolve"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Main Tex", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
        Vector1_77711255d41f43e9b8a5a0745f8683af("Metallic", Float) = 0
        [NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}
        Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26("Occlusion", Float) = 1
        Vector1_629186e6e7ef4df9b804b1dd9aa8e014("Smoothness", Float) = 0.5
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]Color_ce9951c4597b4b04b77b4fefcb5307bf("Emission Color", Color) = (0, 0, 0, 0)
        _DissolveValue("Dissolve Value", Float) = 0
        Vector1_8c47456d68694025a2bd91bd49ca97a9("Noise Amount", Float) = 50
        [HDR]Color_5b7afd5a030749f38f5def93d23959c3("Dissolve Color", Color) = (6.494119, 0.54401, 3.80807, 1)
        Vector1_f49d66496972419cb40cee6fdfec00fd("Emission Offset", Float) = 0.05
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            UnityTexture2D _Property_ac3f090880cd45658f55503b717991d4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ac3f090880cd45658f55503b717991d4_Out_0.tex, _Property_ac3f090880cd45658f55503b717991d4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0);
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_R_4 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.r;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_G_5 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.g;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_B_6 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.b;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_A_7 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            UnityTexture2D _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.tex, _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_R_4 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.r;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_G_5 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.g;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_B_6 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.b;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_A_7 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.a;
            float4 _Property_0d3f176ca1e5493caefa93f760597f00_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_ce9951c4597b4b04b77b4fefcb5307bf) : Color_ce9951c4597b4b04b77b4fefcb5307bf;
            float4 _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2;
            Unity_Multiply_float(_SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0, _Property_0d3f176ca1e5493caefa93f760597f00_Out_0, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2);
            float4 _Add_e755e84cb5894a9497b89125b3111ad5_Out_2;
            Unity_Add_float4(_Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2, _Add_e755e84cb5894a9497b89125b3111ad5_Out_2);
            UnityTexture2D _Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0 = UnityBuildTexture2DStructNoScale(_MetallicGlossMap);
            float4 _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0.tex, _Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.r;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_G_5 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.g;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_B_6 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.b;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_A_7 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.a;
            float _Property_6c971ccf19c847f9aef4e49311a53d5b_Out_0 = Vector1_77711255d41f43e9b8a5a0745f8683af;
            float _Multiply_5241d29c8e414becb818ab191c877b51_Out_2;
            Unity_Multiply_float(_SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4, _Property_6c971ccf19c847f9aef4e49311a53d5b_Out_0, _Multiply_5241d29c8e414becb818ab191c877b51_Out_2);
            float _Property_f853924a423f4611b3e2821a79b716f6_Out_0 = Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
            float _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2;
            Unity_Multiply_float(_SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4, _Property_f853924a423f4611b3e2821a79b716f6_Out_0, _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2);
            UnityTexture2D _Property_206c0280c0c14d92ad82179a4da7742e_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_206c0280c0c14d92ad82179a4da7742e_Out_0.tex, _Property_206c0280c0c14d92ad82179a4da7742e_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_R_4 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.r;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_G_5 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.g;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_B_6 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.b;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_A_7 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.a;
            float _Property_03788129566f4582bfaa7763fd1cdb6b_Out_0 = Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
            float _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2;
            Unity_Multiply_float(_SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_G_5, _Property_03788129566f4582bfaa7763fd1cdb6b_Out_0, _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.NormalTS = (_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.xyz);
            surface.Emission = (_Add_e755e84cb5894a9497b89125b3111ad5_Out_2.xyz);
            surface.Metallic = _Multiply_5241d29c8e414becb818ab191c877b51_Out_2;
            surface.Smoothness = _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2;
            surface.Occlusion = _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2;
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            UnityTexture2D _Property_ac3f090880cd45658f55503b717991d4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ac3f090880cd45658f55503b717991d4_Out_0.tex, _Property_ac3f090880cd45658f55503b717991d4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0);
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_R_4 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.r;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_G_5 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.g;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_B_6 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.b;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_A_7 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            UnityTexture2D _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.tex, _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_R_4 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.r;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_G_5 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.g;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_B_6 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.b;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_A_7 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.a;
            float4 _Property_0d3f176ca1e5493caefa93f760597f00_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_ce9951c4597b4b04b77b4fefcb5307bf) : Color_ce9951c4597b4b04b77b4fefcb5307bf;
            float4 _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2;
            Unity_Multiply_float(_SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0, _Property_0d3f176ca1e5493caefa93f760597f00_Out_0, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2);
            float4 _Add_e755e84cb5894a9497b89125b3111ad5_Out_2;
            Unity_Add_float4(_Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2, _Add_e755e84cb5894a9497b89125b3111ad5_Out_2);
            UnityTexture2D _Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0 = UnityBuildTexture2DStructNoScale(_MetallicGlossMap);
            float4 _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0.tex, _Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.r;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_G_5 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.g;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_B_6 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.b;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_A_7 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.a;
            float _Property_6c971ccf19c847f9aef4e49311a53d5b_Out_0 = Vector1_77711255d41f43e9b8a5a0745f8683af;
            float _Multiply_5241d29c8e414becb818ab191c877b51_Out_2;
            Unity_Multiply_float(_SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4, _Property_6c971ccf19c847f9aef4e49311a53d5b_Out_0, _Multiply_5241d29c8e414becb818ab191c877b51_Out_2);
            float _Property_f853924a423f4611b3e2821a79b716f6_Out_0 = Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
            float _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2;
            Unity_Multiply_float(_SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4, _Property_f853924a423f4611b3e2821a79b716f6_Out_0, _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2);
            UnityTexture2D _Property_206c0280c0c14d92ad82179a4da7742e_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_206c0280c0c14d92ad82179a4da7742e_Out_0.tex, _Property_206c0280c0c14d92ad82179a4da7742e_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_R_4 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.r;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_G_5 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.g;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_B_6 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.b;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_A_7 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.a;
            float _Property_03788129566f4582bfaa7763fd1cdb6b_Out_0 = Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
            float _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2;
            Unity_Multiply_float(_SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_G_5, _Property_03788129566f4582bfaa7763fd1cdb6b_Out_0, _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.NormalTS = (_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.xyz);
            surface.Emission = (_Add_e755e84cb5894a9497b89125b3111ad5_Out_2.xyz);
            surface.Metallic = _Multiply_5241d29c8e414becb818ab191c877b51_Out_2;
            surface.Smoothness = _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2;
            surface.Occlusion = _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2;
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            

        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            

        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            

        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_ac3f090880cd45658f55503b717991d4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ac3f090880cd45658f55503b717991d4_Out_0.tex, _Property_ac3f090880cd45658f55503b717991d4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0);
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_R_4 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.r;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_G_5 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.g;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_B_6 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.b;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_A_7 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.a;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.NormalTS = (_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.xyz);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            UnityTexture2D _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.tex, _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_R_4 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.r;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_G_5 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.g;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_B_6 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.b;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_A_7 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.a;
            float4 _Property_0d3f176ca1e5493caefa93f760597f00_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_ce9951c4597b4b04b77b4fefcb5307bf) : Color_ce9951c4597b4b04b77b4fefcb5307bf;
            float4 _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2;
            Unity_Multiply_float(_SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0, _Property_0d3f176ca1e5493caefa93f760597f00_Out_0, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2);
            float4 _Add_e755e84cb5894a9497b89125b3111ad5_Out_2;
            Unity_Add_float4(_Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2, _Add_e755e84cb5894a9497b89125b3111ad5_Out_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.Emission = (_Add_e755e84cb5894a9497b89125b3111ad5_Out_2.xyz);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            UnityTexture2D _Property_ac3f090880cd45658f55503b717991d4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ac3f090880cd45658f55503b717991d4_Out_0.tex, _Property_ac3f090880cd45658f55503b717991d4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0);
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_R_4 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.r;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_G_5 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.g;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_B_6 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.b;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_A_7 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            UnityTexture2D _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.tex, _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_R_4 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.r;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_G_5 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.g;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_B_6 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.b;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_A_7 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.a;
            float4 _Property_0d3f176ca1e5493caefa93f760597f00_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_ce9951c4597b4b04b77b4fefcb5307bf) : Color_ce9951c4597b4b04b77b4fefcb5307bf;
            float4 _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2;
            Unity_Multiply_float(_SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0, _Property_0d3f176ca1e5493caefa93f760597f00_Out_0, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2);
            float4 _Add_e755e84cb5894a9497b89125b3111ad5_Out_2;
            Unity_Add_float4(_Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2, _Add_e755e84cb5894a9497b89125b3111ad5_Out_2);
            UnityTexture2D _Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0 = UnityBuildTexture2DStructNoScale(_MetallicGlossMap);
            float4 _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0.tex, _Property_b775b4e8ab624caa8e25e50ca4ce2c1b_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.r;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_G_5 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.g;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_B_6 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.b;
            float _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_A_7 = _SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_RGBA_0.a;
            float _Property_6c971ccf19c847f9aef4e49311a53d5b_Out_0 = Vector1_77711255d41f43e9b8a5a0745f8683af;
            float _Multiply_5241d29c8e414becb818ab191c877b51_Out_2;
            Unity_Multiply_float(_SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4, _Property_6c971ccf19c847f9aef4e49311a53d5b_Out_0, _Multiply_5241d29c8e414becb818ab191c877b51_Out_2);
            float _Property_f853924a423f4611b3e2821a79b716f6_Out_0 = Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
            float _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2;
            Unity_Multiply_float(_SampleTexture2D_a2c83e9578dd4160b3187a309fe309c0_R_4, _Property_f853924a423f4611b3e2821a79b716f6_Out_0, _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2);
            UnityTexture2D _Property_206c0280c0c14d92ad82179a4da7742e_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_206c0280c0c14d92ad82179a4da7742e_Out_0.tex, _Property_206c0280c0c14d92ad82179a4da7742e_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_R_4 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.r;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_G_5 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.g;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_B_6 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.b;
            float _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_A_7 = _SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_RGBA_0.a;
            float _Property_03788129566f4582bfaa7763fd1cdb6b_Out_0 = Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
            float _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2;
            Unity_Multiply_float(_SampleTexture2D_b8ea711935644e61a70b469b0416dc8b_G_5, _Property_03788129566f4582bfaa7763fd1cdb6b_Out_0, _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.NormalTS = (_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.xyz);
            surface.Emission = (_Add_e755e84cb5894a9497b89125b3111ad5_Out_2.xyz);
            surface.Metallic = _Multiply_5241d29c8e414becb818ab191c877b51_Out_2;
            surface.Smoothness = _Multiply_7681fa8dd88b4536869a89b50326d830_Out_2;
            surface.Occlusion = _Multiply_c571fc0f7a8b4d65836bf9f3d63d0f74_Out_2;
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            

        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            

        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            

        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_ac3f090880cd45658f55503b717991d4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ac3f090880cd45658f55503b717991d4_Out_0.tex, _Property_ac3f090880cd45658f55503b717991d4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0);
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_R_4 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.r;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_G_5 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.g;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_B_6 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.b;
            float _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_A_7 = _SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.a;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.NormalTS = (_SampleTexture2D_147a97afb3be4e318c67d6066fbaa114_RGBA_0.xyz);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            UnityTexture2D _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.tex, _Property_c09ed9f1e5404cf88967f688441d9f55_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_R_4 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.r;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_G_5 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.g;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_B_6 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.b;
            float _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_A_7 = _SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0.a;
            float4 _Property_0d3f176ca1e5493caefa93f760597f00_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_ce9951c4597b4b04b77b4fefcb5307bf) : Color_ce9951c4597b4b04b77b4fefcb5307bf;
            float4 _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2;
            Unity_Multiply_float(_SampleTexture2D_8bc39b4d2c28420eb4786cce147edb08_RGBA_0, _Property_0d3f176ca1e5493caefa93f760597f00_Out_0, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2);
            float4 _Add_e755e84cb5894a9497b89125b3111ad5_Out_2;
            Unity_Add_float4(_Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2, _Multiply_cffc04d828e34d77ba6bd23a76e2c14d_Out_2, _Add_e755e84cb5894a9497b89125b3111ad5_Out_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.Emission = (_Add_e755e84cb5894a9497b89125b3111ad5_Out_2.xyz);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest Greater
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _TintColor;
        float4 _BumpMap_TexelSize;
        float4 _MetallicGlossMap_TexelSize;
        float Vector1_77711255d41f43e9b8a5a0745f8683af;
        float4 _OcclusionMap_TexelSize;
        float Vector1_fa6ff3edc9cb4a3cb021eb327f4c8b26;
        float Vector1_629186e6e7ef4df9b804b1dd9aa8e014;
        float4 _EmissionMap_TexelSize;
        float4 Color_ce9951c4597b4b04b77b4fefcb5307bf;
        float _DissolveValue;
        float Vector1_8c47456d68694025a2bd91bd49ca97a9;
        float4 Color_5b7afd5a030749f38f5def93d23959c3;
        float Vector1_f49d66496972419cb40cee6fdfec00fd;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_MetallicGlossMap);
        SAMPLER(sampler_MetallicGlossMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        struct Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5
        {
            half4 uv0;
        };

        void SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(float Vector1_d96ae79805804c2ea010f93368371a10, float Vector1_9b4f24d7a1c74861bc2bdab73103b781, float Vector1_080769c9b8a54589bfc3454ee444b8c3, float4 Vector4_e208be4467234dd3beda8352faaafd77, Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 IN, out float OutVector1_1, out float4 OutVector4_2)
        {
            float _Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0 = Vector1_9b4f24d7a1c74861bc2bdab73103b781;
            float _Property_a21a77ef3d98493d94134345a465e86d_Out_0 = Vector1_d96ae79805804c2ea010f93368371a10;
            float _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2;
            Unity_SimpleNoise_float(IN.uv0.xy, _Property_a21a77ef3d98493d94134345a465e86d_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2);
            float _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            Unity_Step_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2);
            float4 _Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0 = Vector4_e208be4467234dd3beda8352faaafd77;
            float _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0 = Vector1_080769c9b8a54589bfc3454ee444b8c3;
            float _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2;
            Unity_Add_float(_Property_a6d76222d5a641f9a0bc89e6ae3c0d5e_Out_0, _Property_83a1b5261fae4e8b9bbd6ef10b5f1002_Out_0, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2);
            float _Step_bf982280248243c0b016fee9cc9cde93_Out_2;
            Unity_Step_float(_SimpleNoise_1b368de2b52c446095dfa01bd3c0b797_Out_2, _Add_a1ad935ff9c54d78b409b920e18da35b_Out_2, _Step_bf982280248243c0b016fee9cc9cde93_Out_2);
            float4 _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
            Unity_Multiply_float(_Property_02c06806f3fd4ef89dcd13d7b76b9c64_Out_0, (_Step_bf982280248243c0b016fee9cc9cde93_Out_2.xxxx), _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2);
            OutVector1_1 = _Step_b96b8a5a6db048838d32e16cc1b5497e_Out_2;
            OutVector4_2 = _Multiply_037851d29ff34a5f96b626556fc0cb85_Out_2;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0 = _TintColor;
            UnityTexture2D _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.tex, _Property_d6afffae10744dba9d92c8c9bbf4fcff_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_R_4 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.r;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_G_5 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.g;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_B_6 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.b;
            float _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7 = _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0.a;
            float4 _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2;
            Unity_Multiply_float(_Property_2cebb84c3b9f41e5b936ea0911031ca6_Out_0, _SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_RGBA_0, _Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2);
            float _Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0 = Vector1_8c47456d68694025a2bd91bd49ca97a9;
            float _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0 = _DissolveValue;
            float _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0 = Vector1_f49d66496972419cb40cee6fdfec00fd;
            float4 _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_5b7afd5a030749f38f5def93d23959c3) : Color_5b7afd5a030749f38f5def93d23959c3;
            Bindings_Dissolve_db09325aa4c0bc648a5087c19c8bdec5 _Dissolve_43b173f66b6749d19a20a1c0d2da9911;
            _Dissolve_43b173f66b6749d19a20a1c0d2da9911.uv0 = IN.uv0;
            float _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1;
            float4 _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2;
            SG_Dissolve_db09325aa4c0bc648a5087c19c8bdec5(_Property_87ba2e3dbade4579b94e5ef8df8995bd_Out_0, _Property_8680cdf85c7d4698aec36eb5b906a981_Out_0, _Property_3be9485d419c4e2cb919a4b07d719f5b_Out_0, _Property_a2e1515e35154b71bcf6b6d128f7399c_Out_0, _Dissolve_43b173f66b6749d19a20a1c0d2da9911, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector4_2);
            float _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_af3df9aa9e3e464db6a07b526480cb35_A_7, _Dissolve_43b173f66b6749d19a20a1c0d2da9911_OutVector1_1, _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2);
            surface.BaseColor = (_Multiply_37d01e1fcd074075a8cb9e51f3d06d87_Out_2.xyz);
            surface.Alpha = _Multiply_66d95e14f067459394c5e8abd3889f8f_Out_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}