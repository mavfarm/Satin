//
//  IntParameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

open class IntParameter: NSObject, Parameter {
    public static var type = ParameterType.int
    public let label: String
    @objc public dynamic var value: Int
    @objc public dynamic var min: Int
    @objc public dynamic var max: Int

    public init(_ label: String, _ value: Int, _ min: Int, _ max: Int) {
        self.label = label
        self.value = value
        self.min = min
        self.max = max
    }

    public init(_ label: String, _ value: Int) {
        self.label = label
        self.value = value
        self.min = 0
        self.max = 100
    }
}
