//
//  Float4Parameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation
import simd

open class Float4Parameter: NSObject, Parameter {
    public static var type = ParameterType.float4
    public let label: String
    
    @objc dynamic var x: Float
    @objc dynamic var y: Float
    @objc dynamic var z: Float
    @objc dynamic var w: Float
    
    @objc dynamic var minX: Float
    @objc dynamic var maxX: Float
    
    @objc dynamic var minY: Float
    @objc dynamic var maxY: Float
    
    @objc dynamic var minZ: Float
    @objc dynamic var maxZ: Float
    
    @objc dynamic var minW: Float
    @objc dynamic var maxW: Float
    
    public var value: simd_float4 {
        get {
            return simd_make_float4(x, y, z, w)
        }
        set(newValue) {
            x = newValue.x
            y = newValue.y
            z = newValue.z
            w = newValue.w
        }
    }
    
    public var min: simd_float4 {
        get {
            return simd_make_float4(minX, minY, minZ, minW)
        }
        set(newValue) {
            minX = newValue.x
            minY = newValue.y
            minZ = newValue.z
            minW = newValue.w
        }
    }
    
    
    public var max: simd_float4 {
        get {
            return simd_make_float4(maxX, maxY, maxZ, maxW)
        }
        set(newValue) {
            maxX = newValue.x
            maxY = newValue.y
            maxZ = newValue.z
            maxW = newValue.w
        }
    }

    public init(_ label: String, _ value: simd_float4, _ min: simd_float4, _ max: simd_float4) {
        self.label = label
        self.x = value.x
        self.y = value.y
        self.z = value.z
        self.w = value.w
        
        self.minX = min.x
        self.maxX = max.x
        
        self.minY = min.y
        self.maxY = max.y
        
        self.minZ = min.z
        self.maxZ = max.z
        
        self.minW = min.w
        self.maxW = max.w
    }
    
    public init(_ label: String, _ value: simd_float4) {
        self.label = label
        self.x = value.x
        self.y = value.y
        self.z = value.z
        self.w = value.w
        
        self.minX = 0.0
        self.maxX = 1.0
        
        self.minY = 0.0
        self.maxY = 1.0
        
        self.minZ = 0.0
        self.maxZ = 1.0
        
        self.minW = 0.0
        self.maxW = 1.0
    }
}
