//
// LogString
// Robologs
//
// Created by Dmitry Shadrin on 23.01.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

/// String with additional functionality used inside the logging system.
/// Allows you to conveniently manage data privacy.
/// Data privacy is controlled by interpolation. The default interpolation is used to mark the parameter as private.
/// In order to be able to transfer a parameter that is not sensitive to privacy,
/// it is necessary to indicate the label `public:` inside the interpolation.
///
/// Usage:
///
///    let logString: LogString = "Username: \(public: user.name), cardNumber: \(user.cardNumber)"
///
public struct LogString: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public static var isSensitive: Bool = true

    private let interpolations: [LogStringInterpolation.Kind]
    private let isSensitive: Bool = LogString.isSensitive

    public init(stringLiteral value: String) {
        interpolations = [ .open(value) ]
    }

    public init(stringInterpolation: LogStringInterpolation) {
        interpolations = stringInterpolation.interpolations
    }

    public init(_ any: Any) {
        interpolations = [ isSensitive ? .sensitive(any) : .open(any) ]
    }

    public var description: String {
        string(isSensitive: isSensitive)
    }

    public func string(isSensitive: Bool) -> String {
        interpolations.map { interpolation in
            switch interpolation {
                case .open(let value as Loggable):
                    return "\(value.logDescription(isSensitive: false))"
                case .open(let value):
                    return "\(value)"
                case .sensitive(let value as Loggable):
                    return "\(value.logDescription(isSensitive: isSensitive))"
                case .sensitive(let value):
                    return isSensitive ? "<private>" : "\(value)"
            }
        }
        .joined()
    }
}
