//
//  common.h
//  Example
//
//  Created by Colin Duffy on 11/5/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

#ifndef three_common
#define three_common

#include <simd/simd.h>

// chunk = common
#define PI 3.14159265359
#define PI2 6.28318530718
#define PI_HALF 1.5707963267949
#define RECIPROCAL_PI 0.31830988618
#define RECIPROCAL_PI2 0.15915494
#define LOG2 1.442695
#define EPSILON 1e-6

#ifndef saturate
// <tonemapping_pars_fragment> may have defined saturate() already
#define saturate(a) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement(a) ( 1.0 - saturate( a ) )

struct ThreeCommon {
    static float pow2( float x ) { return x*x; }
    static float pow3( float x ) { return x*x*x; }
    static float pow4( float x ) { float x2 = x*x; return x2*x2; }
    static float average( float3 color ) { return dot( color, float3( 0.3333 ) ); }
    // expects values in the range of [0,1]x[0,1], returns values in the [0,1] range.
    // do not collapse into a single function per: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
    static float rand( float2 uv ) {
        float a = 12.9898, b = 78.233, c = 43758.5453;
        float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
        return fract(sin(sn) * c);
    }

    static float precisionSafeLength( float3 v ) { return length( v ); }

    static float3 transformDirection( float3 dir, matrix_float4x4 matrix ) {
        return normalize( ( matrix * float4( dir, 0.0 ) ).xyz );
    }

    // http://en.wikibooks.org/wiki/GLSL_Programming/Applying_Matrix_Transformations
    static float3 inverseTransformDirection( float3 dir, matrix_float4x4 matrix ) {
        return normalize( ( float4( dir, 0.0 ) * matrix ).xyz );
    }

    static float3 projectOnPlane(float3 point, float3 pointOnPlane, float3 planeNormal ) {
        float distance = dot( planeNormal, point - pointOnPlane );
        return - distance * planeNormal + point;
    }

    static float sideOfPlane( float3 point, float3 pointOnPlane, float3 planeNormal ) {
        return sign( dot( point - pointOnPlane, planeNormal ) );
    }

    static float3 linePlaneIntersect( float3 pointOnLine, float3 lineDirection, float3 pointOnPlane, float3 planeNormal ) {
        return lineDirection * ( dot( planeNormal, pointOnPlane - pointOnLine ) / dot( planeNormal, lineDirection ) ) + pointOnLine;
    }

    static matrix_float3x3 transposeMat3( matrix_float3x3 m ) {
        matrix_float3x3 tmp;
        tmp[ 0 ] = float3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
        tmp[ 1 ] = float3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
        tmp[ 2 ] = float3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
        return tmp;
    }

    // https://en.wikipedia.org/wiki/Relative_luminance
    static float linearToRelativeLuminance( float3 color ) {
        float3 weights = float3( 0.2126, 0.7152, 0.0722 );
        return dot( weights, color.rgb );
    }

    static bool isPerspectiveMatrix( matrix_float4x4 m ) {
      return m[ 2 ][ 3 ] == - 1.0;
    }
};

#endif
