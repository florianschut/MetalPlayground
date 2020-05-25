//
//  SkyboxShader.metal
//  MetalPlayground
//
//  Created by Florian Schut on 21/11/2019.
//

#include <metal_stdlib>
#include <simd/simd.h>

#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
} SkyboxVertex;

typedef struct
{
    float4 position[[position]];
    float3 UV;
}SkyboxInOut;

vertex SkyboxInOut skyboxVertexShader (SkyboxVertex in [[stage_in]], constant SharedUniforms & uniforms [[buffer(BufferIndexSharedUniforms)]])
{
    SkyboxInOut out;
    float4x4 skyboxView = uniforms.viewMatrix;
    skyboxView.columns[3] = float4(0);
    
    out.UV = -in.position;
    out.UV.x = -out.UV.x;
    out.position = uniforms.projectionMatrix * skyboxView * float4(in.position, 1.0f);
    out.position = out.position.xyww;
    return out;
}

fragment half4 skyboxFragmentShader(SkyboxInOut in [[stage_in]],
                                    constant SharedUniforms & uniforms [[buffer(BufferIndexSharedUniforms)]],
                                    texturecube<float> skybox_texture [[texture(TextureIndexSkybox)]])
{
    constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
    
    float4 retVal = skybox_texture.sample(colorSampler, in.UV);
    return half4(retVal);
}
