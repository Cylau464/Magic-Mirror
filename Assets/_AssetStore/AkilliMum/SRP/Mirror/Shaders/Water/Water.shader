Shader "AkilliMum/URP/Mirrors/Water"
{
	Properties
	{
		[HideInInspector] _BumpScale("Detail Wave Amount", Range(0, 2)) = 0.2//fine detail multiplier
		[HideInInspector] _DitherPattern ("Dithering Pattern", 2D) = "bump" {}
		[HideInInspector] [Toggle(_STATIC_SHADER)] _Static ("Static", Float) = 0

        //new values
        [HideInInspector]_ReflectionTex("Reflection", 2D) = "white" { } //left or all
        [HideInInspector]_ReflectionTexOther("ReflectionOther", 2D) = "white" { } //right
		[HideInInspector]_OpaqueTex("Opaque Tex", 2D) = "white" { } //left or all
		[HideInInspector]_OpaqueTexOther("Opaque Tex Other", 2D) = "white" { } //right
		[HideInInspector]_ReflectionTexDepth("Reflection Tex Depth", 2D) = "white" { } //left or all
		[HideInInspector]_ReflectionTexOtherDepth("Reflection Tex Other Depth", 2D) = "white" { } //right
		
        [HideInInspector]_ReflectionIntensity("Reflection Intensity", Float) = 0.5
        [HideInInspector]_WaveRefraction("Wave Refraction", Float) = 1.
        [HideInInspector]_WorkType("Work Type", Float) = 1.
        [HideInInspector]_DeviceType("Device Type", Float) = 1.
        [HideInInspector]_ManualDistanceSurface("ManualDistance for Surface", Float) = 1.
        [HideInInspector]_ManualDistanceDepth("Manual Distance for Surface", Float) = 1.
		[HideInInspector]_NearClip("Near Clip", Float) = 0.3
		[HideInInspector]_FarClip("Far Clip", Float) = 1000
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent-100" "RenderPipeline" = "UniversalPipeline" }
        //Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On

		Pass
		{
			Name "WaterShading"
			Tags{"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			// Required to compile gles 2.0 with standard SRP library
			// All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			/////////////////SHADER FEATURES//////////////////
			//#pragma shader_feature _REFLECTION_CUBEMAP _REFLECTION_PROBES _REFLECTION_PLANARREFLECTION
			#pragma shader_feature _ DO_NOT_USE_DEPTH
			#pragma multi_compile _ USE_STRUCTURED_BUFFER
			#pragma shader_feature _ _STATIC_SHADER
						
			// -------------------------------------
			// Universal Pipeline keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _RECEIVE_SHADOWS_OFF

			//--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile_fog

			////////////////////INCLUDES//////////////////////
			#include "WaterCommon.hlsl"

			//non-tess
			#pragma vertex WaterVertex
			#pragma fragment WaterFragment

			ENDHLSL
		}
	}
	FallBack "Hidden/InternalErrorShader"
}
