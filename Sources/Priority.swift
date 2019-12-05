//
//  Priority.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Log-level priority
public enum Priority: CaseIterable, Comparable, CustomStringConvertible {
    /// Describes the same events as in the debug-level but in more detail.
    case verbose
    /// Describes messages that contain information typically used only when debugging a program.
    case debug
    /// Describes informational messages.
    case info
    /// Describes conditions that are not erroneous, but may require special processing.
    case warning
    /// Describes a non-critical application error.
    case error
    /// Describes a critical error, after which the application will be terminated.
    case critical

    private var naturalIntegralValue: Int {
        switch self {
            case .verbose:
                return 0
            case .debug:
                return 1
            case .info:
                return 2
            case .warning:
                return 3
            case .error:
                return 4
            case .critical:
                return 5
        }
    }

    public var description: String {
        switch self {
            case .verbose:
                return "🟣 VERBOSE"
            case .debug:
                return "🔵 DEBUG"
            case .info:
                return "🟢 INFO"
            case .warning:
                return "🟡 WARNING"
            case .error:
                return "🟠 ERROR"
            case .critical:
                return "🔴 CRITICAL"
        }
    }

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }

    public static func <= (lhs: Priority, rhs: Priority) -> Bool {
        lhs.naturalIntegralValue <= rhs.naturalIntegralValue
    }

    public static func >= (lhs: Priority, rhs: Priority) -> Bool {
        lhs.naturalIntegralValue >= rhs.naturalIntegralValue
    }

    public static func > (lhs: Priority, rhs: Priority) -> Bool {
        lhs.naturalIntegralValue > rhs.naturalIntegralValue
    }
}
