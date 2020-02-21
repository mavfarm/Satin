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

vertex VertexData BlurPass_vertex(uint vertexID [[vertex_id]],
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

float4 blur13(texture2d<float, access::sample> image,
              sampler sampler2D,
              float2 uv,
              float2 resolution,
              float2 direction) {
    float4 color = float4(0.0);
    float2 off1 = float2(1.4117647058823530) * direction;
    float2 off2 = float2(3.2941176470588234) * direction;
    float2 off3 = float2(5.1764705882352940) * direction;
    
    color += image.sample(sampler2D, uv) * 0.1964825501511404;
    color += image.sample(sampler2D, uv + (off1 / resolution)) * 0.2969069646728344;
    color += image.sample(sampler2D, uv - (off1 / resolution)) * 0.2969069646728344;
    color += image.sample(sampler2D, uv + (off2 / resolution)) * 0.09447039785044732;
    color += image.sample(sampler2D, uv - (off2 / resolution)) * 0.09447039785044732;
    color += image.sample(sampler2D, uv + (off3 / resolution)) * 0.010381362401148057;
    color += image.sample(sampler2D, uv - (off3 / resolution)) * 0.010381362401148057;
    
    return color;
}

fragment float4 BlurPass_fragment(VertexData in [[stage_in]],
                                   texture2d<float, access::sample> inTexture [[texture(0)]]) {
    float2 uv = in.uv;
    float4 image = blur13(inTexture, nearestSampler, uv, float2(375.0, 812.0), float2(5.0, 0.0));
    return image;
}
