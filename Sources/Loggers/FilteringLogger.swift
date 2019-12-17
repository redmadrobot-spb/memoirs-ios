//
//  FilteringLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Logger that filter log events by priority and redirects them to the target logger.
public struct FilteringLogger: Logger {
    @usableFromInline
    let logger: Logger
    /// Logging levels associated with registered label.
    /// If your label is not registered here, then the default log level will be used.
    public let loggingLevelForLabels: [String: Priority]
    /// Default minimal log priority.
    public let defaultPriority: Priority

    /// Creates a new instance of `FilteringLogger`.
    /// - Parameters:
    ///   - logger: The logger for which log events will be filtered.
    ///   - loggingLevelForLabels: Logging levels associated with registered label.
    ///   - defaultPriority: Default minimal log priority.
    public init(logger: Logger, loggingLevelForLabels: [String: Priority], defaultPriority: Priority) {
        self.logger = logger
        self.loggingLevelForLabels = loggingLevelForLabels
        self.defaultPriority = defaultPriority
    }

    @inlinable
    public func log(
        priority: Priority,
        label: String,
        message: () -> String,
        meta: () -> [String: String]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        guard priority <= loggingLevelForLabels[label] ?? defaultPriority else { return }

        logger.log(priority: priority, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }
}
