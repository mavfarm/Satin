//
//  lights_pars_begin.h
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_lights_pars_begin_h
#define three_lights_pars_begin_h

#include <simd/simd.h>
#include "./common.h"
#include "./lights.h"

struct ThreeLightPars {
    // chunk = lights_pars_begin
    //uniform float3 ambientLightColor;
    //uniform float3 lightProbe[ 9 ];

    static float3 shGetIrradianceAt( float3 normal, float3 shCoefficients[ 9 ] ) {
        float x = normal.x, y = normal.y, z = normal.z;
        float3 result = shCoefficients[ 0 ] * 0.886227;
        result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
        result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
        result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
        result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
        result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
        result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
        result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
        result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
        return result;
    }
    
    static float3 getLightProbeIrradiance( float3 lightProbe[ 9 ], GeometricContext geometry, matrix_float4x4 viewMatrix ) {
        float3 worldNormal = ThreeCommon::inverseTransformDirection( geometry.normal, viewMatrix );
        float3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
        return irradiance;
        return 0.0;
    }
    
    static float3 getAmbientLightIrradiance( float3 ambientLightColor ) {
        float3 irradiance = ambientLightColor;
        #ifndef PHYSICALLY_CORRECT_LIGHTS
            irradiance *= PI;
        #endif
        return irradiance;
    }

    //#if NUM_DIR_LIGHTS > 0
    //    uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
    static IncidentLight getDirectionalDirectLightIrradiance( DirectionalLight directionalLight, GeometricContext geometry ) {
        IncidentLight light = IncidentLight();
        light.color = directionalLight.color;
        light.direction = directionalLight.direction;
        light.visible = true;
        return light;
    }
    //#endif

    //#if NUM_POINT_LIGHTS > 0
    //    uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
    static IncidentLight getPointDirectLightIrradiance( PointLight pointLight, GeometricContext geometry ) {
        IncidentLight directLight = IncidentLight();
        
        float3 lfloattor = pointLight.position - geometry.position;
        directLight.direction = normalize( lfloattor );
        
        float lightDistance = length( lfloattor );
        directLight.color = pointLight.color;
        directLight.color *= ThreeBSDFS::punctualLightIntensityToIrradianceFactor( lightDistance, pointLight.distance, pointLight.decay );
        directLight.visible = directLight.color[0] > 0.0 && directLight.color[1] > 0.0 && directLight.color[2] > 0.0;
        
        return directLight;
    }
    //#endif


    //#if NUM_SPOT_LIGHTS > 0
    //    uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
    static IncidentLight getSpotDirectLightIrradiance( SpotLight spotLight, GeometricContext geometry  ) {
        IncidentLight directLight = IncidentLight();
        
        float3 lfloattor = spotLight.position - geometry.position;
        directLight.direction = normalize( lfloattor );
        float lightDistance = length( lfloattor );
        float angleCos = dot( directLight.direction, spotLight.direction );
        if ( angleCos > spotLight.coneCos ) {
            float spotEffect = smoothstep( spotLight.coneCos, spotLight.penumbraCos, angleCos );
            directLight.color = spotLight.color;
            directLight.color *= spotEffect * ThreeBSDFS::punctualLightIntensityToIrradianceFactor( lightDistance, spotLight.distance, spotLight.decay );
            directLight.visible = true;
        } else {
            directLight.color = float3( 0.0 );
            directLight.visible = false;
        }
        
        return directLight;
    }
    //#endif

    //#if NUM_RECT_AREA_LIGHTS > 0
    //    uniform sampler2D ltc_1;    uniform sampler2D ltc_2;
    //    uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
    //#endif

    //#if NUM_HEMI_LIGHTS > 0
    //    uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
    static float3 getHemisphereLightIrradiance( HemisphereLight hemiLight, GeometricContext geometry ) {
        float dotNL = dot( geometry.normal, hemiLight.direction );
        float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
        float3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
        #ifndef PHYSICALLY_CORRECT_LIGHTS
            irradiance *= PI;
        #endif
        return irradiance;
    }
    //#endif
};

#endif /* three_lights_pars_begin_h */
