//
//  LogString.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 23.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

public struct LogString: ExpressibleByStringLiteral, ExpressibleByStringInterpolation,
CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable, CustomLeafReflectable {
    private let interpolations: [LogStringInterpolation.Kind]

    public var description: String { privateIncluded(false) }
    public var debugDescription: String { privateIncluded(false) }
    public var customMirror: Mirror { Mirror(reflecting: privateIncluded(false)) }

    public init(stringLiteral value: String) {
        interpolations = [ .literal(value) ]
    }

    public init(stringInterpolation: LogStringInterpolation) {
        interpolations = stringInterpolation.interpolations
    }

    func privateIncluded(_ isIncluded: Bool) -> String {
        interpolations.map { interpolation in
            switch interpolation {
                case .literal(let string):
                    return string
                case .public(let value):
                    return "\(value)"
                case .private(let value):
                    return isIncluded ? "\(value)" : "<private>"
            }
        }
        .joined()
    }
}
