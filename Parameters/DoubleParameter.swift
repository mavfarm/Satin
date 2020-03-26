//
//  DoubleParameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

open class DoubleParameter: NSObject, Parameter {
    public static var type = ParameterType.double
    public let label: String
    @objc dynamic public var value: Double
    @objc dynamic public var min: Double
    @objc dynamic public var max: Double

    public init(_ label: String, _ value: Double, _ min: Double, _ max: Double) {
        self.label = label
        self.value = value
        self.min = min
        self.max = max
    }
    
    public init(_ label: String, _ value: Double) {
        self.label = label
        self.value = value
        self.min = 0.0
        self.max = 1.0
    }
}
