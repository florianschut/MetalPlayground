//
//  BasicShader.metal
//  MetalPlaygroundMac
//
//  Created by Florian Schut on 11/09/2019.
//

#include <metal_stdlib>
#include <simd/simd.h>

#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
    float4 tangent [[attribute(VertexAttributeTangent)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float4 fragWorldPos;
    float3 normal;
    float2 texCoord;
    float3 tangent;
    float3 biTangent;
} ColorInOut;


float DistributionGGX(float NdotH, float rougness)
{
    float alpha = rougness * rougness;
    float alpha2 = alpha * alpha;
    float denom = NdotH * NdotH * (alpha2 - 1.0f) + 1.0f;
    return alpha2 / (M_PI_F * denom * denom);
}

float GeometrySchlickSmithGGX(float NdotL, float NdotV, float roughness)
{
    float r = roughness + 1.0f;
    float k = (r * r) / 8.0f;
    float GL = NdotL / (NdotL * (1.0f - k) + k);
    float GV = NdotV / (NdotV * (1.0f - k) + k);
    
    return GL * GV;
}

float3 FresnelSchlick(float cosTetha, float metallic, float3 material_color)
{
    float3 F0 = mix(float3(0.04f), material_color, metallic);
    float3 F = F0 + (1.0f - F0) * pow(1.0f - cosTetha, 5.0);
    return F;
}

float3 BRDF(float3 L, float3 V, float3 N, float metallic, float roughness, float3 albedo, float3 radiance)
{
    float3 H = normalize( V + L);
    float dotNV = max(dot(N, V), 0.0f);
    float dotNL = max(dot(N, L), 0.0f);
    float dotNH = max(dot(N, H), 0.0f);
    
    float3 color = float3(0.f);
    
    if (dotNL > 0.0f)
    {
        float D = DistributionGGX(dotNH, roughness);
        float G = GeometrySchlickSmithGGX(dotNL, dotNV, roughness);
        float3 F = FresnelSchlick(dotNH, metallic, albedo);
        
        float3 spec = (D * G * F) / (4.0 * dotNL * dotNV + 0.001f);
        float3 kD = (float3(1.f) - F) * (1.f - metallic);
        
        color += (kD * albedo / M_PI_F + spec) * radiance * dotNL;
    }
    
    return color;
}

vertex ColorInOut vertexShader
(Vertex in [[stage_in]],
 constant SharedUniforms & sharedUniforms [[buffer(BufferIndexSharedUniforms)]],
 constant ObjectUniforms & objectUniforms [[buffer(BufferIndexObjectUniforms)]])
{
    ColorInOut out;
    
    float4 position = float4(in.position, 1.0);
    out.position = (sharedUniforms.projectionMatrix * sharedUniforms.viewMatrix * objectUniforms.modelMatrix) * position;
    out.fragWorldPos = objectUniforms.modelMatrix * position;
    out.normal = normalize((objectUniforms.modelMatrix * float4(in.normal, 1.0f)).xyz);
    out.texCoord = float2(in.texCoord.x, -in.texCoord.y + 1);
    out.tangent = in.tangent.xyz;
    out.biTangent = cross(in.normal, in.tangent.xyz) * in.tangent.w;
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant SharedUniforms & sharedUniforms [[buffer(BufferIndexSharedUniforms)]],
                               texture2d<half> colorMap [[texture(TextureIndexColor)]],
                               texture2d<half> normalMap [[texture(TextureIndexNormal)]],
                               texture2d<half> metallicMap [[texture(TextureIndexMetallic)]],
                               texture2d<half> roughnessMap [[texture(TextureIndexRoughness)]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    float4 colorSample = float4(colorMap.sample(colorSampler, in.texCoord.xy));
    float3 lightDir = normalize(sharedUniforms.lights.position - in.fragWorldPos).xyz;
    float3 viewDir = normalize(((-sharedUniforms.viewMatrix[3]) - in.fragWorldPos).xyz);
    float3x3 tbn = float3x3(in.tangent.x, in.biTangent.x, in.normal.x,
                            in.tangent.y, in.biTangent.y, in.normal.y,
                            in.tangent.z, in.biTangent.z, in.normal.z);
    
    //Sample textures
    float3 normal = normalize(float3(normalMap.sample(colorSampler, in.texCoord.xy).xyz) * tbn);
    float roughness = float(roughnessMap.sample(colorSampler, in.texCoord).x);
    float metallic = float(metallicMap.sample(colorSampler, in.texCoord).x);
    
    float3 outCol = BRDF(lightDir, viewDir, normal, metallic, roughness, colorSample.xyz, float3(1,1,1));
    outCol += float3(0.03) * colorSample.xyz;
    
    return float4(outCol, 1.0f);
}
