fragment float4 UVFragment(VertexData in [[stage_in]]) {
    return float4(in.uv, 0.0, 1.0);
}
