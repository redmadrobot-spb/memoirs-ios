//
// Level
// Robologs
//
// Created by Dmitry Shadrin on 27.11.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

/// Logging level.
@frozen
public enum Level: Comparable, CustomDebugStringConvertible {
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

    public static var stringVerbose: String = "VERBOSE"
    public static var stringDebug: String = "DEBUG"
    public static var stringInfo: String = "INFO"
    public static var stringWarning: String = "WARNING"
    public static var stringError: String = "ERROR"
    public static var stringCritical: String = "CRITICAL"

    public var debugDescription: String {
        switch self {
            case .verbose: return Self.stringVerbose
            case .debug: return Self.stringDebug
            case .info: return Self.stringInfo
            case .warning: return Self.stringWarning
            case .error: return Self.stringError
            case .critical: return Self.stringCritical
        }
    }

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

    public static func < (lhs: Level, rhs: Level) -> Bool {
        lhs.integralValue < rhs.integralValue
    }
}
