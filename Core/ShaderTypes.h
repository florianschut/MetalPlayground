//
//  ShaderTypes.h
//  CrossPlatformGameRef Shared
//
//  Created by Florian Schut on 10/09/2019.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions    = 0,
    BufferIndexMeshNormals      = 1,
    BufferIndexMeshGenerics     = 2,
    BufferIndexSharedUniforms   = 3,
    BufferIndexObjectUniforms   = 4,
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeNormal    = 1,
    VertexAttributeTexcoord  = 2,
    VertexAttributeTangent   = 3,
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor       = 0,
    TextureIndexNormal      = 1,
    TextureIndexMetallic    = 2,
    TextureIndexRoughness   = 3,
    TextureIndexSkybox      = 4,
};

typedef struct{
    vector_float4 position;
    vector_float4 color;
} Light;

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    Light lights;
} SharedUniforms;

typedef struct
{
    matrix_float4x4 modelMatrix;
    matrix_float4x4 allignment[3];
} ObjectUniforms;

#endif /* ShaderTypes_h */

