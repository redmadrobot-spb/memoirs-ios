//
//  LogString.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 23.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

public struct LogString: ExpressibleByStringLiteral, ExpressibleByStringInterpolation,
CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable, CustomLeafReflectable {
    private let interpolations: [String]

    public var description: String { interpolations.joined() }
    public var debugDescription: String { interpolations.joined() }
    public var customMirror: Mirror { Mirror(reflecting: interpolations.joined()) }

    public init(stringLiteral value: String) {
        interpolations = [ value ]
    }

    public init(stringInterpolation: LogStringInterpolation) {
        interpolations = stringInterpolation.interpolations
    }
}
