constexpr sampler nearestSampler(mip_filter::nearest,
                                 mag_filter::nearest,
                                 min_filter::nearest,
                                 s_address::repeat,
                                 t_address::repeat,
                                 r_address::repeat);

fragment float4 ImageFragment(VertexData in [[stage_in]],
                              texture2d<float, access::sample> image) {
    float2 uv = float2(in.uv.x, 1.0 - in.uv.y);
    return image.sample(nearestSampler, uv);
}
