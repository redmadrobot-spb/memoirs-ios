//
// SafeString
// Memoirs
//
// Created by Dmitry Shadrin on 23 January 2020. Updated by Alex Babaev
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
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
public struct SafeString: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Sendable {
    static let unsafeReplacement: String = "<private>"

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

    public var description: String {
        string(hideSensitiveValues: true)
    }

    public func appending(_ safeString: SafeString) -> SafeString {
        SafeString(interpolations: interpolations + safeString.interpolations)
    }

    public func string(hideSensitiveValues: Bool) -> String {
        interpolations.map { interpolation in
            switch interpolation {
                case .open(let value as String):
                    return value
                case .open(let value as SafeStringConvertible):
                    return value.logDescription(isSensitive: false)
                case .open(let value):
                    return "\(value)"
                case .sensitive(let value as SafeStringConvertible):
                    return value.logDescription(isSensitive: hideSensitiveValues)
                case .sensitive(let value as String):
                    return hideSensitiveValues ? SafeString.unsafeReplacement : value
                case .sensitive(let value):
                    return hideSensitiveValues ? SafeString.unsafeReplacement : "\(value)"
            }
        }
        .joined()
    }
}
