//
// LogLevel
// Memoirs
//
// Created by Dmitry Shadrin on 27 December 2019. Updated by Alex Babaev
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

/// Logging level.
@frozen
public enum LogLevel: Hashable, Comparable, Sendable {
    /// Extremely detailed log events. This is the only level that can spam output instantly.
    case verbose
    /// Events that can be useful for understanding steps that program does. Makes it easier to debug.
    case debug
    /// General log events. Like "something happened in a program". Can be useful even in non-debug mode.
    case info
    /// Warnings are "recoverable flow errors". Like double-calling something or like that.
    case warning
    /// Errors are "non-recoverable flow errors" or "recoverable application errors".
    case error
    /// Fatal errors that result in application termination.
    case critical

    var integralValue: Int {
        switch self {
            case .verbose: return 0
            case .debug: return 1
            case .info: return 2
            case .warning: return 3
            case .error: return 4
            case .critical: return 5
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.integralValue < rhs.integralValue
    }
}
