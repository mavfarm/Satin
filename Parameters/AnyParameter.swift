//
//  AnyParameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

open class AnyParameter: Codable {
    public var base: Parameter

    public init(_ base: Parameter) {
        self.base = base
    }

    private enum CodingKeys: CodingKey {
        case type, base
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ParameterType.self, forKey: .type)
        self.base = try type.metatype.init(from: container.superDecoder(forKey: .base))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type(of: base).type, forKey: .type)
        try base.encode(to: container.superEncoder(forKey: .base))
    }
}
