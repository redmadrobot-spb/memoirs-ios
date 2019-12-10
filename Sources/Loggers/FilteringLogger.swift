//
//  FilteringLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Logger that filter log events by priority and redirects them to the target logger.
public struct FilteringLogger: Logger {
    /// The logger for which log events will be filtered.
    public let logger: Logger
    /// Logging levels associated with registered label.
    /// If your label is not registered here, then the default log level will be used.
    public let loggingLevelForLabels: [String: Priority]
    /// Default minimal log priority.
    public let defaultPriority: Priority

    @inlinable
    public func log(
        priority: Priority,
        label: String,
        message: () -> String,
        meta: () -> [String: Any]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        guard priority <= loggingLevelForLabels[label] ?? defaultPriority else { return }

        logger.log(priority: priority, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }
}
