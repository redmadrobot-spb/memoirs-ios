//
// OSLogLogger
// Robologs
//
// Created by Dmitry Shadrin on 03.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import os.log

/// `(Logger)` - implementation which use `os.log` logging system.
@available(iOS 12.0, *)
public class OSLogLogger: Logger {
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

    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let context = Output.codePosition(file, function, line)
        let description = Output.logString("", nil, message, "", scopes, meta, context, isSensitive)
        os_log(logType(from: level), log: logger(with: label), "%{public}@", description)

        Output.logInterceptor?(self, nil, level, message, label, scopes, meta, isSensitive, file, function, line)
    }

    private func logType(from level: Level) -> OSLogType {
        switch level {
            case .verbose: return .debug
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
        }
    }

    private func logger(with label: String) -> OSLog {
        if let logger = loggers[label] {
            return logger
        } else {
            let logger = OSLog(subsystem: subsystem, category: label)
            loggers[label] = logger
            return logger
        }
    }
}
