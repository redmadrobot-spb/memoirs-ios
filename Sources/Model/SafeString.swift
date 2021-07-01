//
// SafeString
// Memoirs
//
// Created by Dmitry Shadrin on 23 January 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

/// String with additional functionality used inside the logging system.
/// Allows you to conveniently manage data privacy.
/// Data privacy is controlled by interpolation. The default interpolation is used to mark the parameter as private.
/// In order to be able to transfer a parameter that is not sensitive to privacy,
/// it is necessary to indicate the label `safe:` inside the interpolation.
///
/// Usage:
///
///    let logString: SafeString = "Username: \(safe: user.name), cardNumber: \(user.cardNumber)"
///
public struct SafeString: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    #if DEBUG
    public static var isSensitive: Bool = false
    #else
    public static var isSensitive: Bool = true
    #endif

    static let secretReplacement: String = "<secret>"

    private let interpolations: [SafeStringInterpolation.Kind]

    init(interpolations: [SafeStringInterpolation.Kind]) {
        self.interpolations = interpolations
    }

    public init(stringLiteral value: String) {
        interpolations = [ .open(value) ]
    }

    public init(stringInterpolation: SafeStringInterpolation) {
        interpolations = stringInterpolation.interpolations
    }

    public init(_ any: Any) {
        interpolations = [ SafeString.isSensitive ? .sensitive(any) : .open(any) ]
    }

    public var description: String {
        string(isSensitive: SafeString.isSensitive)
    }

    func appending(_ safeString: SafeString) -> SafeString {
        SafeString(interpolations: interpolations + safeString.interpolations)
    }

    public func string(isSensitive: Bool) -> String {
        interpolations.map { interpolation in
            switch interpolation {
                case .open(let value as String):
                    return value
                case .open(let value as SafeStringConvertible):
                    return value.logDescription(isSensitive: false)
                case .open(let value):
                    return "\(value)"
                case .sensitive(let value as SafeStringConvertible):
                    return value.logDescription(isSensitive: isSensitive)
                case .sensitive(let value as String):
                    return isSensitive ? SafeString.secretReplacement : value
                case .sensitive(let value):
                    return isSensitive ? SafeString.secretReplacement : "\(value)"
            }
        }
        .joined()
    }
}
