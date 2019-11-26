//
//  Math.swift
//
//  Created by Colin Duffy on 10/11/19.
//  Copyright © 2019 Mav Farm. All rights reserved.
//

import Foundation

///
/// Doubles
///

func toRad(value:Double) -> Double {
    return value * (Double.pi / 180.0)
}

func clamp(value:Double, minimum:Double, maximum:Double) -> Double {
    return min(maximum, max(minimum, value))
}

func lerp(value:Double, minimum:Double, maximum:Double) -> Double {
    return minimum * (1.0 - value) + maximum * value;
}

func normalize(value:Double, minimum:Double, maximum:Double) -> Double {
    return(value - minimum) / (maximum - minimum);
}

func map(value:Double, minimum1:Double, maximum1:Double, minimum2:Double, maximum2:Double) -> Double {
    return lerp(
        value: normalize(value: value, minimum: minimum1, maximum: maximum1),
        minimum: minimum2,
        maximum: maximum2
    )
}

func cosRange(value:Double, range:Double, minValue:Double) -> Double {
    return (((1.0 + cos(toRad(value: value))) * 0.5) * range) + minValue;
}

///
/// Floats
///

func toRad(value:Float) -> Float {
    return value * (Float.pi / 180.0)
}

func clamp(value:Float, minimum:Float, maximum:Float) -> Float {
    return min(maximum, max(minimum, value))
}

func lerp(value:Float, minimum:Float, maximum:Float) -> Float {
    return minimum * (1.0 - value) + maximum * value;
}

func normalize(value:Float, minimum:Float, maximum:Float) -> Float {
    return(value - minimum) / (maximum - minimum);
}

func map(value:Float, minimum1:Float, maximum1:Float, minimum2:Float, maximum2:Float) -> Float {
    return lerp(
        value: normalize(value: value, minimum: minimum1, maximum: maximum1),
        minimum: minimum2,
        maximum: maximum2
    )
}

func cosRange(value:Float, range:Float, minValue:Float) -> Float {
    return (((1.0 + cos(toRad(value: value))) * 0.5) * range) + minValue;
}
