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
                               texture2d<half> glossMap [[texture(TextureIndexGloss)]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    float4 colorSample = float4(colorMap.sample(colorSampler, in.texCoord.xy));
    float3 lightDir = normalize(sharedUniforms.lights.position - in.fragWorldPos).xyz;
    float4 viewDir = normalize((-sharedUniforms.viewMatrix[3]) - in.fragWorldPos);
    float3x3 tbn = float3x3(in.tangent.x, in.biTangent.x, in.normal.x,
                            in.tangent.y, in.biTangent.y, in.normal.y,
                            in.tangent.z, in.biTangent.z, in.normal.z);
    float3 normal = normalize(float3(normalMap.sample(colorSampler, in.texCoord.xy).xyz) * tbn);
    float3 halfWay = normalize(viewDir.xyz + lightDir);
    float3 specularCol =  (float(glossMap.sample(colorSampler, in.texCoord).x) * sharedUniforms.lights.color.xyz) * pow(max(dot(normal, halfWay), 0.0), 32);
    float3 ambientCol = colorSample.xyz * 0.135;
    float3 diffuseCol = colorSample.xyz * max(dot(lightDir, normal), 0.0f);
    float3 outCol = diffuseCol + ambientCol + specularCol;
    return float4(outCol, 1.0f);
}
