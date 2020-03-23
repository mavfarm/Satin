//
//  BoolParameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

open class BoolParameter: NSObject, Parameter {
    public static var type = ParameterType.bool
    public let label: String
    @objc dynamic public var value: Bool

    public init(_ label: String, _ value: Bool) {
        self.label = label
        self.value = value
    }
}
