//
//  StringParameter.swift
//  Satin
//
//  Created by Colin Duffy on 3/16/20.
//

import Foundation

open class StringParameter: NSObject, Parameter {
    public static var type = ParameterType.string
    public let label: String
    @objc dynamic public var value: String
    
    public init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }
}
