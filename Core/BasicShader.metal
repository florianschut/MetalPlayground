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
} Vertex;

typedef struct
{
    float4 position [[position]];
    float4 fragWorldPos;
    float3 normal;
    float2 texCoord;
} ColorInOut;



vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant SharedUniforms & uniforms [[buffer(BufferIndexUniforms)]])
{
    ColorInOut out;
    
    float4 position = float4(in.position, 1.0);
    //out.position = (uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix) * position;
    //out.fragWorldPos = uniforms.modelMatrix * position;
    //out.normal = normalize((uniforms.modelMatrix * float4(in.normal, 1.0f)).xyz);
    out.texCoord = float2(in.texCoord.x, -in.texCoord.y + 1);
    
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                              constant SharedUniforms & uniforms [[buffer(BufferIndexUniforms)]],
                              texture2d<half> colorMap [[texture(TextureIndexColor)]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                        mag_filter::linear,
                                        min_filter::linear);
    float4 colorSample = float4(colorMap.sample(colorSampler, in.texCoord.xy));
    float3 lightDir = normalize(uniforms.lights.position - in.fragWorldPos).xyz;
    float4 viewDir = normalize((-uniforms.viewMatrix[3]) - in.fragWorldPos);
    
    float3 specularCol =  uniforms.lights.color.xyz * pow(max(dot(viewDir.xyz, reflect(-lightDir, in.normal)), 0.0), 12);
    float3 ambientCol = colorSample.xyz * 0.135;
    float3 diffuseCol = colorSample.xyz * max(dot(lightDir, in.normal), 0.0f);
    float3 outCol = diffuseCol + ambientCol + specularCol;

    return float4(outCol, 1.0f);
}
