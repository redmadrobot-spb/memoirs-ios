//
// FilteringLogger
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Logger that filter log events by level and redirects them to the target logger.
public class FilteringLogger: Loggable {
    @frozen
    public enum ConfigurationLevel {
        case verbose
        case debug
        case info
        case warning
        case error
        case critical

        case all
        case disabled

        var integralValue: Int {
            switch self {
                case .all: return -1
                case .verbose: return 0
                case .debug: return 1
                case .info: return 2
                case .warning: return 3
                case .error: return 4
                case .critical: return 5
                case .disabled: return Int.max
            }
        }

        public static func < (rhs: FilteringLogger.ConfigurationLevel, lhs: Log.Level) -> Bool {
            lhs.integralValue >= rhs.integralValue
        }
    }

    public struct ConfigurationForLabel {
        public let level: Log.Level
        public let events: Bool
        public let tracers: Bool
        public let measurements: Bool

        public init(level: Log.Level, events: Bool = true, tracers: Bool = true, measurements: Bool = true) {
            self.level = level
            self.events = events
            self.tracers = tracers
            self.measurements = measurements
        }
    }

    @usableFromInline
    let logger: Loggable
    /// Logging levels associated with registered label.
    /// If your label is not registered here, then the default log level will be used.
    public let labelConfigurations: [String: ConfigurationForLabel]
    /// Default minimal log level.
    public let defaultConfiguration: ConfigurationForLabel

    /// Creates a new instance of `FilteringLogger`.
    /// - Parameters:
    ///  - logger: The logger for which log events will be filtered.
    ///  - loggingLevelForLabels: Logging levels associated with registered label.
    ///  - defaultLevel: Default minimal log level.
    public init(
        logger: Loggable,
        labelConfigurations: [String: ConfigurationForLabel],
        defaultConfiguration: ConfigurationForLabel
    ) {
        self.logger = logger
        self.labelConfigurations = labelConfigurations
        self.defaultConfiguration = defaultConfiguration
    }

    @inlinable
    public func add(
        _ item: Log.Item,
        meta: @autoclosure () -> [String: Log.String]?,
        tracers: [Log.Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let label = tracers.label ?? "—"
        let configuration = labelConfigurations[label] ?? defaultConfiguration

        var filteredOut = false
        switch item {
            case .log(let level, _):
                filteredOut = configuration.level > level
            case .event:
                filteredOut = !configuration.events
            case .tracer:
                filteredOut = !configuration.tracers
            case .measurement:
                filteredOut = !configuration.measurements
        }

        if !filteredOut {
            logger.add(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line)
        }
    }
}
