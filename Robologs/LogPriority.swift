//
//  LogLevel.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Log-level priority
public enum LogPriority: CaseIterable, Comparable {
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

    var naturalIntegralValue: UInt {
        switch self {
            case .verbose: return 0
            case .debug: return 1
            case .info: return 2
            case .warning: return 3
            case .error: return 4
            case .critical: return 5
        }
    }

    public static func < (lhs: LogPriority, rhs: LogPriority) -> Bool {
        return lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}
