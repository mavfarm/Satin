//
//  LightData.metal
//  Example
//
//  Created by Colin Duffy on 10/30/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
#include "../three/lights.h"

struct LightUniforms {
    uint POINT_LIGHTS;
//    int DIR_LIGHTS;
//    int SPOT_LIGHTS;
//    int RECT_AREA_LIGHTS;
//    int HEMI_LIGHTS;
    
    vector_float3 ambientLightColor;
//    packed_float3 lightProbe[ 9 ];

    PointLight pointLights[MAX_LIGHTS];
    
//    DirectionalLight directionalLights[MAX_LIGHTS];
//    SpotLight spotLights[MAX_LIGHTS];
//    RectAreaLight rectAreaLights[MAX_LIGHTS];
//    HemisphereLight hemisphereLights[MAX_LIGHTS];
};
