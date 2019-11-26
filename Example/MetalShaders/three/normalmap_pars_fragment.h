//
//  normalmap_pars_fragment.h
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_normalmap_pars_fragment
#define three_normalmap_pars_fragment

#include <metal_stdlib>
#include <simd/simd.h>
#include "./common.h"
#include "./lights.h"
#include "./materials.h"

#ifdef USE_NORMALMAP
//    uniform sampler2D normalMap;
//    uniform float2 normalScale;
#endif
#ifdef OBJECTSPACE_NORMALMAP
//    uniform mat3 normalMatrix;
#endif

#if ! defined ( USE_TANGENT ) && ( defined ( TANGENTSPACE_NORMALMAP ) || defined ( USE_CLEARCOAT_NORMALMAP ) )
//    vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm, vec2 normalScale, in sampler2D normalMap ) {
    float3 perturbNormal2Arb(
                             float3 eye_pos,
                             float3 surf_norm,
                             float2 normalScale,
                             texture2d<float, access::sample> normalMap,
                             sampler sampler2D,
                             float2 vUv,
                             bool front_facing
                             ) {
        float3 q0 = float3( dfdx( eye_pos.x ), dfdx( eye_pos.y ), dfdx( eye_pos.z ) );
        float3 q1 = float3( dfdy( eye_pos.x ), dfdy( eye_pos.y ), dfdy( eye_pos.z ) );
        float2 st0 = dfdx( vUv );
        float2 st1 = dfdy( vUv );
        float scale = sign( st1.y * st0.x - st0.y * st1.x );
        float3 S = normalize( ( q0 * st1.y - q1 * st0.y ) * scale );
        float3 T = normalize( ( - q0 * st1.x + q1 * st0.x ) * scale );
        float3 N = normalize( surf_norm );
        float3 mapN = normalMap.sample(sampler2D, vUv).xyz * 2.0 - 1.0;
        mapN.xy *= normalScale;
        #ifdef DOUBLE_SIDED
            float3 NfromST = cross( S, T );
            if( dot( NfromST, N ) > 0.0 ) {
                S *= -1.0;
                T *= -1.0;
            }
        #else
            mapN.xy *= ( float( front_facing ) * 2.0 - 1.0 );
        #endif
        matrix_float3x3 tsn = matrix_float3x3(S, T, N);
        return normalize( tsn * mapN );
    }
#endif

#endif /* three_normalmap_pars_fragment */
