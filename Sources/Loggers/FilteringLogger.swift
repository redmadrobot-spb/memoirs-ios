//
//  FilteringLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Logger that filter log events by level and redirects them to the target logger.
public struct FilteringLogger: Logger {
    @usableFromInline
    let logger: Logger
    /// Logging levels associated with registered label.
    /// If your label is not registered here, then the default log level will be used.
    public let loggingLevelForLabels: [String: Level]
    /// Default minimal log level.
    public let defaultLevel: Level

    /// Creates a new instance of `FilteringLogger`.
    /// - Parameters:
    ///   - logger: The logger for which log events will be filtered.
    ///   - loggingLevelForLabels: Logging levels associated with registered label.
    ///   - defaultLevel: Default minimal log level.
    public init(logger: Logger, loggingLevelForLabels: [String: Level], defaultLevel: Level) {
        self.logger = logger
        self.loggingLevelForLabels = loggingLevelForLabels
        self.defaultLevel = defaultLevel
    }

    @inlinable
    public func log(
        level: Level,
        message: () -> LogString,
        label: String,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        guard level <= loggingLevelForLabels[label] ?? defaultLevel else { return }

        logger.log(level: level, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }
}
