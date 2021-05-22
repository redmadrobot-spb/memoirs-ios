//
// OSLogLogger
// Robologs
//
// Created by Dmitry Shadrin on 03.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import os.log

/// `(Logger)` - implementation which use `os.log` logging system.
@available(iOS 12.0, *)
public class OSLogLogger: Loggable {
    public let isSensitive: Bool

    /// An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    /// For example, `com.your_company.your_subsystem_name`.
    /// The subsystem is used for categorization and filtering of related log messages, as well as for grouping related logging settings.
    public let subsystem: String
    private var loggers: SynchronizedDictionary<String, OSLog> = [:]

    /// Creates a new instance of `OSLogLogger`.
    /// - Parameter subsystem: An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    public init(subsystem: String, isSensitive: Bool) {
        self.isSensitive = isSensitive
        self.subsystem = subsystem
    }

    @inlinable
    public func add(
        _ item: Log.Item,
        meta: @autoclosure () -> [String: Log.String]?,
        tracers: [Log.Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let codePosition = Output.codePosition(file: file, function: function, line: line)
        let description: String
        var osLogType: OSLogType = .debug
        let label: OSLog = logger(with: tracers.label ?? "NoLabel")
        switch item {
            case .log(let level, let message):
                description = Output.logString(
                    time: "", level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
                osLogType = logType(from: level)
            case .event(let name):
                description = Output.eventString(
                    time: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, false):
                description = Output.tracerString(
                    time: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, true):
                description = Output.tracerEndString(
                    time: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .measurement(let name, let value):
                description = Output.measurementString(
                    time: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
        }
        os_log(osLogType, log: label, "%{public}@", description)
        Output.logInterceptor?(self, description)
    }

    @usableFromInline
    func logType(from level: Log.Level) -> OSLogType {
        switch level {
            case .verbose: return .debug
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
        }
    }

    @usableFromInline
    func logger(with label: String) -> OSLog {
        if let logger = loggers[label] {
            return logger
        } else {
            let logger = OSLog(subsystem: subsystem, category: label)
            loggers[label] = logger
            return logger
        }
    }
}
