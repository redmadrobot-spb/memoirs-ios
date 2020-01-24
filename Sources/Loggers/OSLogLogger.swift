//
//  OSLogLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 03.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import os.log

/// `(Logger)` - implementation which use `os.log` logging system.
@available(iOS 12.0, *)
public struct OSLogLogger: Logger {
    /// An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    /// For example, `com.your_company.your_subsystem_name`.
    /// The subsystem is used for categorization and filtering of related log messages, as well as for grouping related logging settings.
    public let subsystem: String
    private let isSensitive: Bool
    private var loggers: SynchronizedDictionary<String, OSLog>

    /// Creates a new instance of `OSLogLogger`.
    /// - Parameter subsystem: An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    public init(subsystem: String, isSensitive: Bool = true) {
        self.subsystem = subsystem
        self.isSensitive = isSensitive
        self.loggers = [:]
    }

    public func log(
        level: Level,
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let context = [ file, function, (line == 0 ? "" : "\(line)") ].filter { !$0.isEmpty }.joined(separator: ":")
        let metaDescription = meta().map { $0.isEmpty ? "" : "\($0.mapValues { $0.privateExcluded(isSensitive) })" }
        let description = [ context, message().privateExcluded(isSensitive), metaDescription ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        os_log(logType(from: level), log: logger(with: label), "%{public}@", description)
    }

    private func logType(from level: Level) -> OSLogType {
        switch level {
            case .verbose:
                return .debug
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            case .critical:
                return .fault
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
