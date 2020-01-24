//
//  LogStringInterpolation.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 23.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

public struct LogStringInterpolation: StringInterpolationProtocol {
    enum Kind {
        case literal(String)
        case `public`(Any)
        case `private`(Any)
    }

    var interpolations: [Kind] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
        interpolations.reserveCapacity(literalCapacity * 2)
    }

    public mutating func appendLiteral(_ literal: String) {
        interpolations.append(.literal(literal))
    }

    public mutating func appendInterpolation(_ interpolation: Any) {
        interpolations.append(.private(interpolation))
    }

    public mutating func appendInterpolation(public interpolation: Any) {
        interpolations.append(.public(interpolation))
    }
}
