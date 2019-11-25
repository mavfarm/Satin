//
//  Defines.swift
//  Satin
//
//  Created by Reza Ali on 7/23/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import simd

public let maxBuffersInFlight: Int = 3

public let worldForwardDirection = simd_make_float3(0, 0, 1)
public let worldUpDirection = simd_make_float3(0, 1, 0)
public let worldRightDirection = simd_make_float3(1, 0, 0)

public enum VertexBufferIndex: Int {
    case Vertices = 0
    case VertexUniforms = 1
    case ShadowUniforms = 2
    case Custom0 = 3
    case Custom1 = 4
    case Custom2 = 5
    case Custom3 = 6
}

public enum VertexTextureIndex: Int {
    case Custom0 = 0
    case Custom1 = 1
    case Custom2 = 2
    case Custom3 = 3
    case Custom4 = 4
    case Custom5 = 5
    case Custom6 = 6
}

public enum FragmentBufferIndex: Int {
    case MaterialUniforms = 0
    case Custom0 = 1
    case Custom1 = 2
    case Custom2 = 3
    case Custom3 = 4
}

public enum FragmentTextureIndex: Int {
    case Shadow = 0
    case Custom0 = 1
    case Custom1 = 2
    case Custom2 = 3
    case Custom3 = 4
    case Custom4 = 5
    case Custom5 = 6
}
