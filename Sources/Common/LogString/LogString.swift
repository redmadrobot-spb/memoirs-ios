//
//  LogString.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 23.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

/// String with additional functionality used inside the logging system.
/// Allows you to conveniently manage data privacy.
/// Data privacy is controlled by interpolation. The default interpolation is used to mark the parameter as private.
/// In order to be able to transfer a parameter that is not sensitive to privacy,
/// it is necessary to indicate the label `public:` inside the interpolation.
///
/// Usage:
///
///     let logString: LogString = "Username: \(public: user.name), cardNumber: \(user.cardNumber)"
///
public struct LogString: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    private let interpolations: [LogStringInterpolation.Kind]

    /// Converts `LogString` to `String` with erasing private data.
    public var sensitiveErased: String { privateExcluded(true) }
    public var description: String { privateExcluded(false) }

    public init(stringLiteral value: String) {
        interpolations = [ .literal(value) ]
    }

    public init(stringInterpolation: LogStringInterpolation) {
        interpolations = stringInterpolation.interpolations
    }

    private func privateExcluded(_ isExcluded: Bool) -> String {
        interpolations.map { interpolation in
            switch interpolation {
                case .literal(let string):
                    return string
                case .public(let value):
                    return "\(value)"
                case .private(let value):
                    return isExcluded ? "<private>" : "\(value)"
                case .dump(let value):
                    return "\(value.logDescription(isSensitiveExcluded: isExcluded))"
            }
        }
        .joined()
    }
}
