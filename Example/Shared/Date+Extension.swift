//
//  Date+Extension.swift
//  Example iOS
//
//  Created by Colin Duffy on 10/21/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Foundation

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
