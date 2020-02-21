#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

//////////////////////////////////////////////////
// VertexCommon.metal
//////////////////////////////////////////////////

// VertexIn.metal
typedef struct {
    vector_float4 position;
    vector_float2 uv;
    vector_float3 normal;
} VertexIn;

// VertexData.metal
typedef struct {
    vector_float4 position [[position]];
    vector_float2 uv;
    vector_float3 normal;
    vector_float3 viewPosition;
} VertexData;

// VertexUniforms.metal
typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} VertexUniforms;

//////////////////////////////////////////////////
// BasicVertex.metal
//////////////////////////////////////////////////

vertex VertexData ColorPass_vertex(uint vertexID [[vertex_id]],
                                   constant VertexIn *vertices [[buffer(0)]],
                                   constant VertexUniforms &uniforms [[buffer(1)]]) {
    VertexData out;
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * vertices[vertexID].position;
    out.uv = vertices[vertexID].uv;
    out.normal = vertices[vertexID].normal;
    out.viewPosition = out.position.xyz / out.position.w;
    return out;
}

//////////////////////////////////////////////////
// Fragment.metal
//////////////////////////////////////////////////

constexpr sampler nearestSampler(mip_filter::nearest,
                                 mag_filter::nearest,
                                 min_filter::nearest,
                                 s_address::repeat,
                                 t_address::repeat,
                                 r_address::repeat);

fragment float4 ColorPass_fragment(VertexData in [[stage_in]],
                                   texture2d<float, access::sample> inTexture [[texture(0)]]) {
    float2 uv = in.uv;
    float4 image = inTexture.sample(nearestSampler, uv);
    image.rgb += float3(0.1);
    return image;
}
