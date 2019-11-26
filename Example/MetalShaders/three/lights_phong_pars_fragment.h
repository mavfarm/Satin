//
//  lights_phong_pars_fragment.h
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_lights_phong_pars_fragment
#define three_lights_phong_pars_fragment

#include <simd/simd.h>
#include "./common.h"
#include "./lights.h"
#include "./materials.h"

struct ThreePhongPars {
    // chunk = lights_phong_pars_fragment

    //varying float3 vViewPosition;
    //#ifndef FLAT_SHADED
    //    varying float3 vNormal;
    //#endif

    static ReflectedLight RE_Direct_BlinnPhong( IncidentLight directLight, GeometricContext geometry, BlinnPhongMaterial material, ReflectedLight reflectedLight ) {
        ReflectedLight newLight;
        newLight.directDiffuse = reflectedLight.directDiffuse;
        newLight.directSpecular = reflectedLight.directSpecular;
        newLight.indirectDiffuse = reflectedLight.indirectDiffuse;
        newLight.indirectSpecular = reflectedLight.indirectSpecular;
        
        #ifdef TOON
            float3 irradiance = getGradientIrradiance( geometry.normal, directLight.direction ) * directLight.color;
        #else
            float dotNL = saturate( dot( geometry.normal, directLight.direction ) );
            float3 irradiance = dotNL * directLight.color;
        #endif
        #ifndef PHYSICALLY_CORRECT_LIGHTS
            irradiance *= PI;
        #endif
        newLight.directDiffuse += irradiance * ThreeBSDFS::BRDF_Diffuse_Lambert( material.diffuseColor );
        newLight.directSpecular += irradiance * ThreeBSDFS::BRDF_Specular_BlinnPhong( directLight, geometry, material.specularColor, material.specularShininess ) * material.specularStrength;
        
        return newLight;
    }

    static ReflectedLight RE_IndirectDiffuse_BlinnPhong( float3 irradiance, GeometricContext geometry, BlinnPhongMaterial material, ReflectedLight reflectedLight ) {
        ReflectedLight newLight;
        newLight.directDiffuse = reflectedLight.directDiffuse;
        newLight.directSpecular = reflectedLight.directSpecular;
        newLight.indirectDiffuse = reflectedLight.indirectDiffuse;
        newLight.indirectSpecular = reflectedLight.indirectSpecular;
        
        newLight.indirectDiffuse += irradiance * ThreeBSDFS::BRDF_Diffuse_Lambert( material.diffuseColor );
        
        return newLight;
    }
    
};

#define RE_Direct               ThreePhongPars::RE_Direct_BlinnPhong
#define RE_IndirectDiffuse      ThreePhongPars::RE_IndirectDiffuse_BlinnPhong
#define Material_LightProbeLOD( material )    (0)

#endif /* three_lights_phong_pars_fragment */
