//
//  Parameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

public protocol Parameter: Codable {
    static var type: ParameterType { get }
    var label: String { get }
}

public enum ParameterType: String, Codable {
    case float, float2, float3, float4, bool, int, int2, int3, int4, double, string

    var metatype: Parameter.Type {
        switch self {
        case .bool:
            return BoolParameter.self
        case .int:
            return IntParameter.self
        case .int2:
            return Int2Parameter.self
        case .int3:
            return Int3Parameter.self
        case .int4:
            return Int4Parameter.self
        case .float:
            return FloatParameter.self
        case .float2:
            return Float2Parameter.self
        case .float3:
            return Float3Parameter.self
        case .float4:
            return Float4Parameter.self
        case .double:
            return DoubleParameter.self
        case .string:
            return StringParameter.self
        }
    }
}
