//
//  Icosahedron.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import simd

open class Icosahedron: Polyhedron {

    public init(_ radius: Float, _ detail: Int) {
        let t: Float = ( 1.0 + sqrt( 5.0 ) ) / 2.0
        
        let vertices = [
            simd_make_float4(-1, t, 0, 1),
            simd_make_float4(1, t, 0, 1),
            simd_make_float4(-1, -t, 0, 1),
            simd_make_float4(1, -t, 0, 1),
            simd_make_float4(0, -1, t, 1),
            simd_make_float4(0, 1, t, 1),
            simd_make_float4(0, -1, -t, 1),
            simd_make_float4(0, 1, -t, 1),
            simd_make_float4(t, 0, -1, 1),
            simd_make_float4(t, 0, 1, 1),
            simd_make_float4(-t, 0, -1, 1),
            simd_make_float4(-t, 0, 1, 1)
        ]
        
        let indices: [UInt32] = [
            0, 11, 5,
            0, 5, 1,
            0, 1, 7,
            0, 7, 10,
            0, 10, 11,
            1, 5, 9,
            5, 11, 4,
            11, 10, 2,
            10, 7, 6,
            7, 1, 8,
            3, 9, 4,
            3, 4, 2,
            3, 2, 6,
            3, 6, 8,
            3, 8, 9,
            4, 9, 5,
            2, 4, 11,
            6, 2, 10,
            8, 6, 7,
            9, 8, 1
        ]
        
        super.init(vertices, indices, radius, detail)
    }
}
