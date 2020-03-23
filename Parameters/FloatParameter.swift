//
//  FloatParameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

open class FloatParameter: NSObject, Parameter {
    public static var type = ParameterType.float
    public let label: String
    @objc dynamic public var value: Float
    @objc dynamic public var min: Float
    @objc dynamic public var max: Float

    public init(_ label: String, _ value: Float, _ min: Float, _ max: Float) {
        self.label = label
        self.value = value
        self.min = min
        self.max = max
    }
    
    public init(_ label: String, _ value: Float) {
        self.label = label
        self.value = value
        self.min = 0.0
        self.max = 1.0
    }
}
