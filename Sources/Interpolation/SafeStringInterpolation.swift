//
// SafeStringInterpolation
// Memoirs
//
// Created by Dmitry Shadrin on 23 January 2020. Updated by Alex Babaev
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public struct SafeStringInterpolation: StringInterpolationProtocol {
    enum Kind: @unchecked Sendable {
        case open(Any)
        case sensitive(Any)
        case select(open: Any, sensitive: Any)
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

    public mutating func appendInterpolation(interpolation: Any, sensitive: Any) {
        interpolations.append(.select(open: interpolation, sensitive: sensitive))
    }
}
