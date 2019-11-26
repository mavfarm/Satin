//
//  materials.h
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_materials
#define three_materials

#include <simd/simd.h>
#include "./common.h"

struct BlinnPhongMaterial {
    float3    diffuseColor;
    float3    specularColor;
    float    specularShininess;
    float    specularStrength;
};

#endif /* three_materials */
