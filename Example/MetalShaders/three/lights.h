//
//  lights.h
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_lights
#define three_lights

#include <simd/simd.h>

#define MAX_LIGHTS 1

struct IncidentLight {
    packed_float3 color;
    packed_float3 direction;
    bool visible;
};

struct ReflectedLight {
    packed_float3 directDiffuse;
    packed_float3 directSpecular;
    packed_float3 indirectDiffuse;
    packed_float3 indirectSpecular;
};

struct GeometricContext {
    packed_float3 position;
    packed_float3 normal;
    packed_float3 viewDir;
#ifdef CLEARCOAT
    packed_float3 clearcoatNormal;
#endif
};

struct DirectionalLight {
    packed_float3 direction;
    packed_float3 color;
    int shadow;
    float shadowBias;
    float shadowRadius;
    packed_float2 shadowMapSize;
};

struct PointLight {
    int shadow;
//    float shadowBias;
//    float shadowRadius;
//    
//    float distance;
//    float decay;
//    float shadowCameraNear;
//    float shadowCameraFar;
//    
//    float2 shadowMapSize;
//    float3 position;
//    float3 color;
};

struct SpotLight {
    int shadow;
    float shadowBias;
    float shadowRadius;
    
    float distance;
    float decay;
    float coneCos;
    float penumbraCos;
    
    packed_float2 shadowMapSize;
    
    packed_float3 position;
    packed_float3 direction;
    packed_float3 color;
};

struct RectAreaLight {
    packed_float3 color;
    packed_float3 position;
    packed_float3 halfWidth;
    packed_float3 halfHeight;
};

struct HemisphereLight {
    packed_float3 direction;
    packed_float3 skyColor;
    packed_float3 groundColor;
};

#endif /* three_lights */
