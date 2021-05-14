//
// LogStringInterpolation
// Robologs
//
// Created by Dmitry Shadrin on 23.01.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

public struct LogStringInterpolation: StringInterpolationProtocol {
    enum Kind {
        case open(Any)
        case sensitive(Any)
    }

    var interpolations: [Kind] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
        interpolations.reserveCapacity(literalCapacity * 2)
    }

    public mutating func appendLiteral(_ literal: String) {
        interpolations.append(.open(literal))
    }

    public mutating func appendInterpolation(_ interpolation: Any) {
        interpolations.append(.sensitive(interpolation))
    }

    public mutating func appendInterpolation(safe interpolation: Any) {
        interpolations.append(.open(interpolation))
    }
}
