//
//  LogStringInterpolation.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 23.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

public struct LogStringInterpolation: StringInterpolationProtocol {
    var interpolations: [String] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
        interpolations.reserveCapacity(literalCapacity * 2)
    }

    public mutating func appendLiteral(_ literal: String) {
        interpolations.append(literal)
    }

    public mutating func appendInterpolation(_ interpolation: Sensitive) {
        interpolations.append("<private>")
    }
    public mutating func appendInterpolation(_ interpolation: Any) {
        interpolations.append("\(interpolation)")
    }
}
