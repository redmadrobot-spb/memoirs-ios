//
// LogLevel
// Robologs
//
// Created by Dmitry Shadrin on 27.11.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

/// Logging level.
@frozen
public enum LogLevel: Hashable, Comparable {
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

    /// You can redefine these to display other symbols in PrintMemoir.
    public static func configure(
        stringForVerbose: Swift.String = "👻",
        stringForDebug: Swift.String = "👣",
        stringForInfo: Swift.String = "🌵",
        stringForWarning: Swift.String = "🖖",
        stringForError: Swift.String = "⛑",
        stringForCritical: Swift.String = "👿",
        stringForEvent: Swift.String = "💥",
        stringForTracer: Swift.String = "🕶",
        stringForMeasurement: Swift.String = "📈"
    ) {
        Output.Marker.verbose = stringForVerbose
        Output.Marker.debug = stringForDebug
        Output.Marker.info = stringForInfo
        Output.Marker.warning = stringForWarning
        Output.Marker.error = stringForError
        Output.Marker.critical = stringForCritical
        Output.Marker.event = stringForEvent
        Output.Marker.tracer = stringForTracer
        Output.Marker.measurement = stringForMeasurement
    }
}
