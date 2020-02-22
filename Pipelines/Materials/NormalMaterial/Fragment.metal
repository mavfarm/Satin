fragment float4 NormalFragment(VertexData in [[stage_in]]) {
    return float4(in.normal, 1.0);
}
