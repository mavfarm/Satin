//
//  Simd+Extensions.swift
//  Satin
//
//  Created by Reza Ali on 9/14/19.
//

import simd

extension simd_quatf: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let x = try values.decode(Float.self, forKey: .x)
        let y = try values.decode(Float.self, forKey: .y)
        let z = try values.decode(Float.self, forKey: .z)
        let w = try values.decode(Float.self, forKey: .w)
        self.init(ix: x, iy: y, iz: z, r: w)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.vector.x, forKey: .x)
        try container.encode(self.vector.y, forKey: .y)
        try container.encode(self.vector.z, forKey: .z)
        try container.encode(self.vector.w, forKey: .w)
    }
    
    public func lerp(_ end: simd_quatf, _ progress: Float) -> simd_quatf {
        return simd_slerp(self, end, progress)
    }

    private enum CodingKeys: String, CodingKey {
        case x,y,z,w
    }
}

extension simd_float2 {
    public func lerp(_ end: simd_float2, _ progress: Float) -> simd_float2 {
        return self + (end - self) * progress
    }
}

extension simd_float3 {
    public func lerp(_ end: simd_float3, _ progress: Float) -> simd_float3 {
        return self + (end - self) * progress
    }
    
    static func toHex(_ hex: Int) -> simd_float3 {
        let dividend = Float(255)
        return simd_make_float3(
            Float( hex >> 16 & 255 ) / dividend,
            Float( hex >> 8 & 255 ) / dividend,
            Float( hex & 255 ) / dividend
        )
    }
}

extension simd_float4 {
    public func lerp(_ end: simd_float4, _ progress: Float) -> simd_float4 {
        return self + (end - self) * progress
    }
    
    public func xyz() -> simd_float3 {
        return simd_make_float3(self.x, self.y, self.z)
    }
}

extension matrix_float4x4 {
    func upper_left_3x3() -> matrix_float3x3 {
        return matrix_float3x3(
            simd_make_float3(self.columns.0.x, self.columns.0.y, self.columns.0.z),
            simd_make_float3(self.columns.1.x, self.columns.1.y, self.columns.1.z),
            simd_make_float3(self.columns.2.x, self.columns.2.y, self.columns.2.z)
        )
    }
}
