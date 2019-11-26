//
//  bsdfs.metal
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_bsdfs
#define three_bsdfs

#include <simd/simd.h>
#include "./common.h"
#include "./lights.h"

struct ThreeBSDFS {
    // chunk = bsdfs
    static float2 integrateSpecularBRDF( float dotNV, float roughness ) {
        const float4 c0 = float4( - 1, - 0.0275, - 0.572, 0.022 );
        const float4 c1 = float4( 1, 0.0425, 1.04, - 0.04 );
        float4 r = roughness * c0 + c1;
        float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
        return float2( -1.04, 1.04 ) * a004 + r.zw;
    }
        
    static float punctualLightIntensityToIrradianceFactor( float lightDistance, float cutoffDistance, float decayExponent ) {
    #if defined ( PHYSICALLY_CORRECT_LIGHTS )
        float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
        if( cutoffDistance > 0.0 ) {
            distanceFalloff *= ThreeCommon::pow2( saturate( 1.0 - ThreeCommon::pow4( lightDistance / cutoffDistance ) ) );
        }
        return distanceFalloff;
    #else
        if( cutoffDistance > 0.0 && decayExponent > 0.0 ) {
            return pow( saturate( -lightDistance / cutoffDistance + 1.0 ), decayExponent );
        }
        return 1.0;
    #endif
    }
        
    static float3 BRDF_Diffuse_Lambert( float3 diffuseColor ) {
        return RECIPROCAL_PI * diffuseColor;
    }
        
    static float3 F_Schlick( float3 specularColor, float dotLH ) {
        float fresnel = exp2( ( -5.55473 * dotLH - 6.98316 ) * dotLH );
        return ( 1.0 - specularColor ) * fresnel + specularColor;
    }
        
    static float3 F_Schlick_RoughnessDependent( float3 F0, float dotNV, float roughness ) {
        float fresnel = exp2( ( -5.55473 * dotNV - 6.98316 ) * dotNV );
        float3 Fr = max( float3( 1.0 - roughness ), F0 ) - F0;
        return Fr * fresnel + F0;
    }
        
    static float G_GGX_Smith( float alpha, float dotNL, float dotNV ) {
        float a2 = ThreeCommon::pow2( alpha );
        float gl = dotNL + sqrt( a2 + ( 1.0 - a2 ) * ThreeCommon::pow2( dotNL ) );
        float gv = dotNV + sqrt( a2 + ( 1.0 - a2 ) * ThreeCommon::pow2( dotNV ) );
        return 1.0 / ( gl * gv );
    }
        
    static float G_GGX_SmithCorrelated( float alpha, float dotNL, float dotNV ) {
        float a2 = ThreeCommon::pow2( alpha );
        float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * ThreeCommon::pow2( dotNV ) );
        float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * ThreeCommon::pow2( dotNL ) );
        return 0.5 / max( gv + gl, EPSILON );
    }
        
    static float D_GGX( float alpha, float dotNH ) {
        float a2 = ThreeCommon::pow2( alpha );
        float denom = ThreeCommon::pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
        return RECIPROCAL_PI * a2 / ThreeCommon::pow2( denom );
    }
        
    static float3 BRDF_Specular_GGX( IncidentLight incidentLight, float3 viewDir, float3 normal, float3 specularColor, float roughness ) {
        float alpha = ThreeCommon::pow2( roughness );
        float3 halfDir = normalize( incidentLight.direction + viewDir );
        float dotNL = saturate( dot( normal, incidentLight.direction ) );
        float dotNV = saturate( dot( normal, viewDir ) );
        float dotNH = saturate( dot( normal, halfDir ) );
        float dotLH = saturate( dot( incidentLight.direction, halfDir ) );
        float3 F = F_Schlick( specularColor, dotLH );
        float G = G_GGX_SmithCorrelated( alpha, dotNL, dotNV );
        float D = D_GGX( alpha, dotNH );
        return F * ( G * D );
    }
        
    static float2 LTC_Uv( float3 N, float3 V, float roughness ) {
        const float LUT_SIZE  = 64.0;
        const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
        const float LUT_BIAS  = 0.5 / LUT_SIZE;
        float dotNV = saturate( dot( N, V ) );
        float2 uv = float2( roughness, sqrt( 1.0 - dotNV ) );
        uv = uv * LUT_SCALE + LUT_BIAS;
        return uv;
    }
        
    static float LTC_ClippedSphereFormFactor( float3 f ) {
        float l = length( f );
        return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
    }
        
    static float3 LTC_EdgeVectorFormFactor( float3 v1, float3 v2 ) {
        float x = dot( v1, v2 );
        float y = abs( x );
        float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
        float b = 3.4175940 + ( 4.1616724 + y ) * y;
        float v = a / b;
        float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * ThreeCommon::inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
        return cross( v1, v2 ) * theta_sintheta;
    }
        
    static float3 LTC_Evaluate( float3 N, float3 V, float3 P, matrix_float3x3 mInv, float3 rectCoords[ 4 ] ) {
        float3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
        float3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
        float3 lightNormal = cross( v1, v2 );
        if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return float3( 0.0 );
        float3 T1, T2;
        T1 = normalize( V - N * dot( V, N ) );
        T2 = - cross( N, T1 );
        matrix_float3x3 mat = mInv * ThreeCommon::transposeMat3( matrix_float3x3( T1, T2, N ) );
        float3 coords[ 4 ];
        coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
        coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
        coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
        coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
        coords[ 0 ] = normalize( coords[ 0 ] );
        coords[ 1 ] = normalize( coords[ 1 ] );
        coords[ 2 ] = normalize( coords[ 2 ] );
        coords[ 3 ] = normalize( coords[ 3 ] );
        float3 vectorFormFactor = float3( 0.0 );
        vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
        vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
        vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
        vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
        float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
        return float3( result );
    }
        
    static float3 BRDF_Specular_GGX_Environment( float3 viewDir, float3 normal, float3 specularColor, float roughness ) {
        float dotNV = saturate( dot( normal, viewDir ) );
        float2 brdf = integrateSpecularBRDF( dotNV, roughness );
        return specularColor * brdf.x + brdf.y;
    }
        
    static void BRDF_Specular_Multiscattering_Environment( GeometricContext geometry, float3 specularColor, float roughness, float3 singleScatter, float3 multiScatter ) {
        float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
        float3 F = F_Schlick_RoughnessDependent( specularColor, dotNV, roughness );
        float2 brdf = integrateSpecularBRDF( dotNV, roughness );
        float3 FssEss = F * brdf.x + brdf.y;
        float Ess = brdf.x + brdf.y;
        float Ems = 1.0 - Ess;
        float3 Favg = specularColor + ( 1.0 - specularColor ) * 0.047619;    float3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
        singleScatter += FssEss;
        multiScatter += Fms * Ems;
    }
        
    static float G_BlinnPhong_Implicit( ) {
        return 0.25;
    }
        
    static float D_BlinnPhong( float shininess, float dotNH ) {
        return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
    }
        
    static float3 BRDF_Specular_BlinnPhong( IncidentLight incidentLight, GeometricContext geometry, float3 specularColor, float shininess ) {
        float3 halfDir = normalize( incidentLight.direction + geometry.viewDir );
        float dotNH = saturate( dot( geometry.normal, halfDir ) );
        float dotLH = saturate( dot( incidentLight.direction, halfDir ) );
        float3 F = F_Schlick( specularColor, dotLH );
        float G = G_BlinnPhong_Implicit( );
        float D = D_BlinnPhong( shininess, dotNH );
        return F * ( G * D );
    }
        
    static float GGXRoughnessToBlinnExponent( float ggxRoughness ) {
        return ( 2.0 / ThreeCommon::pow2( ggxRoughness + 0.0001 ) - 2.0 );
    }
        
    static float BlinnExponentToGGXRoughness( float blinnExponent ) {
        return sqrt( 2.0 / ( blinnExponent + 2.0 ) );
    }

    #if defined( USE_SHEEN )
    static float D_Charlie(float roughness, float NoH) {
        float invAlpha  = 1.0 / roughness;
        float cos2h = NoH * NoH;
        float sin2h = max(1.0 - cos2h, 0.0078125);
        return (2.0 + invAlpha) * pow(sin2h, invAlpha * 0.5) / (2.0 * PI);
    }
        
    static float V_Neubelt(float NoV, float NoL) {
        return saturate(1.0 / (4.0 * (NoL + NoV - NoL * NoV)));
    }
        
    static float3 BRDF_Specular_Sheen( float roughness, float3 L, GeometricContext geometry, float3 specularColor ) {
        float3 N = geometry.normal;
        float3 V = geometry.viewDir;
        float3 H = normalize( V + L );
        float dotNH = saturate( dot( N, H ) );
        return specularColor * D_Charlie( roughness, dotNH ) * V_Neubelt( dot(N, V), dot(N, L) );
    }
    #endif
};

#endif /* three_bsdfs */
