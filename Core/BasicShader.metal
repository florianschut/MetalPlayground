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
    float3 normal;
    float2 texCoord;
} ColorInOut;


vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[buffer(BufferIndexUniforms)]])
{
    ColorInOut out;
    
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.normal = in.normal;
    out.texCoord = float2(in.texCoord.x, -in.texCoord.y);
    
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                              constant Uniforms & uniforms [[buffer(BufferIndexUniforms)]],
                              texture2d<half> colorMap [[texture(TextureIndexColor)]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    
    half4 colorSamle = colorMap.sample(colorSampler, in.texCoord.xy);
    return float4(colorSamle);
}
