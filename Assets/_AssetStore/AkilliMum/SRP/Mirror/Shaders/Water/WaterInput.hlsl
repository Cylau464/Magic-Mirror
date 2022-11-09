#ifndef WATER_INPUT_INCLUDED
#define WATER_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)

half _BumpScale;
half4 _DitherPattern_TexelSize;

//REFLECTIONS
TEXTURE2D(_ReflectionTex);              SAMPLER(sampler_ReflectionTex);
TEXTURE2D(_ReflectionTexOther);         SAMPLER(sampler_ReflectionTexOther);
TEXTURE2D(_OpaqueTex);                  SAMPLER(sampler_OpaqueTex);
TEXTURE2D(_OpaqueTexOther);             SAMPLER(sampler_OpaqueTexOther);
TEXTURE2D(_ReflectionTexDepth);         SAMPLER(sampler_ReflectionTexDepth);
TEXTURE2D(_ReflectionTexOtherDepth);    SAMPLER(sampler_ReflectionTexOtherDepth);

half _WaveRefraction;
half _ReflectionIntensity;
float _WorkType;
float _DeviceType;
float _ManualDistanceSurface;
float _ManualDistanceDepth;
float _NearClip;
float _FarClip;

CBUFFER_END

half _MaxDepth;
half _MaxWaveHeight;
int _DebugPass;
half4 _Water_DepthCamParams;
float4x4 _InvViewProjection;

// Screen Effects textures
SAMPLER(sampler_ScreenTextures_linear_clamp);

//#if defined(_REFLECTION_PLANARREFLECTION)
//TEXTURE2D(_PlanarReflectionTexture);
//#elif defined(_REFLECTION_CUBEMAP)
//TEXTURECUBE(_CubemapTexture);
//SAMPLER(sampler_CubemapTexture);
//#endif

TEXTURE2D(_WaterFXMap);
TEXTURE2D(_CameraDepthTexture);
TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);

TEXTURE2D(_WaterDepthMap); SAMPLER(sampler_WaterDepthMap_linear_clamp);

// Surface textures
TEXTURE2D(_AbsorptionScatteringRamp); SAMPLER(sampler_AbsorptionScatteringRamp);
TEXTURE2D(_SurfaceMap); SAMPLER(sampler_SurfaceMap);
TEXTURE2D(_FoamMap); SAMPLER(sampler_FoamMap);
TEXTURE2D(_DitherPattern); SAMPLER(sampler_DitherPattern);

// Must match Lightweigth ShaderGraph master node
struct SurfaceData
{
    half3 absorption;
	half3 scattering;
    half3 normal;
    half  foam;
};

#endif // WATER_INPUT_INCLUDED