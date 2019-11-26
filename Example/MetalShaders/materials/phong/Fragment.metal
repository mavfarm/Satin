float lambert(float3 n, float3 d)
{
    // n : surface view normalized
    // d : direction of the light normalized
    return dot(n, d);
}

float phong(float3 light, float3 normal, float3 eyeDirection, float shininess)
{
    // light        : normalized light direction
    // normal       : surface view normal
    // eyeDirection : normalized vPosition
    // shininess    : self explanatory =)

    return pow(max(dot(reflect(light, normal), eyeDirection), 0.0), shininess);
}

float3 faceNormals(float3 pos) {
  float3 fdx = dfdx(pos);
  float3 fdy = dfdy(pos);
  return normalize(cross(fdx, fdy));
}

fragment float4 phongFragment(VertexOut in [[stage_in]],
                              constant PhongFragmentUniforms &uniforms [[buffer( FragmentBufferMaterialUniforms )]],
                              constant LightUniforms &lights [[buffer( FragmentBufferCustom0 )]])
{
    float3 normal = in.normal;
    normal = faceNormals(in.position.xyz);

    float2 uv = in.uv;

    float3 diffuse = uniforms.diffuse;
    
//    diffuse = float3(lights.ambientLightColor);
    diffuse = lights.ambientLightColor;
    
    if(lights.POINT_LIGHTS > 0) {
        diffuse = float3(1.0);
//        diffuse = lights.pointLights[0].color;
//        if(lights.pointLights[0].shadow > 3) {
//            diffuse = float3(1.0, 1.0, 1.0);
//        } else {
//            diffuse = float3(1.0, 1.0, 0.0);
//        }
    }
    
    /*
    if(lights.POINT_LIGHTS > 0) {
//        diffuse = float3(0.0, 0.0, 1.0);
        //
        float3 vPosition = in.position.xyz;
        float3 vLight = normalize(float3(0.0, 250.0, 500.0) - vPosition);
        float3 ambient = float3(0.0);
        float specular = 0.85;
        float shininess = 0.85;
        
        float3 eyeDirection = normalize(vPosition);
        float3 light = ambient +
                diffuse * lambert(normal, vLight) +
                specular * phong(
                    vLight,
                    normal,
                    eyeDirection,
                    shininess
                );
//        float3 lightPos = lights.pointLights[0].position;
//        float3 eyeDirection = normalize(in.position.xyz);
//        float3 light = lights.ambientLightColor +
//                diffuse * lambert(normal, lightPos) +
//                uniforms.specular.x * phong(
//                    lightPos,
//                    normal,
//                    eyeDirection,
//                    uniforms.shininess
//                );
        diffuse = light;
        //
    }
    */
    
    return float4(diffuse, uniforms.opacity);
}
