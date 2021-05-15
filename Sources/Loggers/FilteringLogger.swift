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

        public static func < (rhs: FilteringLogger.ConfigurationLevel, lhs: Level) -> Bool {
            lhs.integralValue >= rhs.integralValue
        }
    }

    @usableFromInline
    let logger: Loggable
    /// Logging levels associated with registered label.
    /// If your label is not registered here, then the default log level will be used.
    public let loggingLevelForLabels: [String: ConfigurationLevel]
    /// Default minimal log level.
    public let defaultLevel: ConfigurationLevel

    /// Creates a new instance of `FilteringLogger`.
    /// - Parameters:
    ///  - logger: The logger for which log events will be filtered.
    ///  - loggingLevelForLabels: Logging levels associated with registered label.
    ///  - defaultLevel: Default minimal log level.
    public init(logger: Loggable, loggingLevelForLabels: [String: ConfigurationLevel], defaultLevel: ConfigurationLevel) {
        self.logger = logger
        self.loggingLevelForLabels = loggingLevelForLabels
        self.defaultLevel = defaultLevel
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let labelLevel = loggingLevelForLabels[label] ?? defaultLevel
        guard labelLevel < level else { return }

        logger.log(
            level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    public func update(scope: Scope, file: String = #file, function: String = #function, line: UInt = #line) {
        logger.update(scope: scope, file: file, function: function, line: line)
    }
}
