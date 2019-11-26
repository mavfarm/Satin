//
//  VertexData.metal
//  Example
//
//  Created by Colin Duffy on 10/30/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct VertexIn {
    vector_float4 position;
    vector_float2 uv;
    vector_float3 normal;
};

struct VertexOut {
    vector_float4 position [[position]];
    vector_float3 fragPosition;
    vector_float2 uv;
    vector_float3 normal;
//    #ifdef VERTEX_DISPLACEMENT
//    vector_float3 extrusion;
//    #endif
};

struct VertexUniforms {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
};

typedef enum VertexBufferIndex {
    VertexBufferVertices = 0,
    VertexBufferVertexUniforms = 1,
    VertexBufferShadowUniforms = 2,
    VertexBufferCustom0 = 3,
    VertexBufferCustom1 = 4,
    VertexBufferCustom2 = 5,
    VertexBufferCustom3 = 6
} VertexBufferIndex;

typedef enum VertexTextureIndex {
    VertexTextureCustom0 = 0,
    VertexTextureCustom1 = 1,
    VertexTextureCustom2 = 2,
    VertexTextureCustom3 = 3,
    VertexTextureCustom4 = 4,
    VertexTextureCustom5 = 5,
    VertexTextureCustom6 = 6
} VertexTextureIndex;

typedef enum FragmentBufferIndex {
    FragmentBufferMaterialUniforms = 0,
    FragmentBufferCustom0 = 1,
    FragmentBufferCustom1 = 2,
    FragmentBufferCustom2 = 3,
    FragmentBufferCustom3 = 4
} FragmentBufferIndex;

typedef enum FragmentTextureIndex {
    FragmentTextureShadow = 0,
    FragmentTextureCustom0 = 1,
    FragmentTextureCustom1 = 2,
    FragmentTextureCustom2 = 3,
    FragmentTextureCustom3 = 4,
    FragmentTextureCustom4 = 5,
    FragmentTextureCustom5 = 6
} FragmentTextureIndex;
