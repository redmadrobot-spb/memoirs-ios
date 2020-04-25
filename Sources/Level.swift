//
//  Level.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Logging level.
public enum Level: CaseIterable, Comparable, CustomDebugStringConvertible {
    /// Extremely detailed log events. This is the only level that can spam output in a second.
    case verbose
    /// Events that can be useful for understanding steps that program makes, that make it easy to debug.
    case debug
    /// General log events. Like "something happened in a program". Can be useful even in non-debug mode.
    case info
    /// Warnings are "recoverable flow errors". Like double-calling something or like that.
    case warning
    /// Errors are "non-recoverable flow errors" or "recoverable application errors".
    case error
    /// Fatal errors that result in application termination.
    case critical

    private var naturalIntegralValue: Int {
        switch self {
            case .verbose: return 0
            case .debug: return 1
            case .info: return 2
            case .warning: return 3
            case .error: return 4
            case .critical: return 5
        }
    }

    public var debugDescription: String {
        switch self {
            case .verbose: return "🟣 VERBOSE"
            case .debug: return "🔵 DEBUG"
            case .info: return "🟢 INFO"
            case .warning: return "🟡 WARNING"
            case .error: return "🟠 ERROR"
            case .critical: return "🔴 CRITICAL"
        }
    }

    public static func < (lhs: Level, rhs: Level) -> Bool {
        lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}
