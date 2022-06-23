//
// OSLogMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 03 December 2019. Updated by Alex Babaev
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

#if canImport(os)

import Foundation
import os.log

/// `(Memoir)` - implementation which use `os.log` logging system.
@available(iOS 12.0, *)
public final class OSLogMemoir: Memoir {
    private actor OSLogHolder {
        /// An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
        /// For example, `com.your_company.your_subsystem_name`.
        /// The subsystem is used for categorization and filtering of related log messages, as well as for grouping related logging settings.
        private let subsystem: String
        private var osLogs: [String: OSLog] = [:]

        init(subsystem: String) {
            self.subsystem = subsystem
        }

        func osLog(for label: String, operation: @Sendable (OSLog) -> Void) {
            if let osLog = osLogs[label] {
                operation(osLog)
            } else {
                let osLog = OSLog(subsystem: subsystem, category: label)
                osLogs[label] = osLog
                operation(osLog)
            }
        }
    }

    private let osLogHolder: OSLogHolder

    @usableFromInline
    let output: Output

    /// Creates a new instance of `OSLogMemoir`.
    /// - Parameter subsystem: An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    /// - Parameter isSensitive: is log sensitive
    /// - Parameter tracerFilter: filter for the tracers output
    public init(subsystem: String, isSensitive: Bool, tracerFilter: @escaping @Sendable (Tracer) -> Bool = { _ in false }) {
        osLogHolder = .init(subsystem: subsystem)
        output = Output(
            isSensitive: isSensitive,
            codePositionType: .full, shortTracers: false, separateTracers: true,
            tracerFilter: tracerFilter
        )
    }

    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) async {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String
        var osLogType: OSLogType = .debug

        var label: String = output.isSensitive ? "???" : "NoLabel"
        if !output.isSensitive {
            switch tracers.first {
                case .label(let name): label = name
                case .type(let name, _): label = name
                case .app(let name): label = name
                case .instance(let name): label = name
                case .session: label = "session"
                case .request: label = "requests"
                case nil: label = "NoLabel"
            }
        }

        switch item {
            case .log(let level, let message):
                description = output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                osLogType = logType(from: level)
            case .event(let name):
                description = output.eventString(
                    date: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
        }
        await osLogHolder.osLog(for: label) { os_log(osLogType, log: $0, "%{public}@", description) }
        Output.logInterceptor?(self, item, description)
    }

    @usableFromInline
    func logType(from level: LogLevel) -> OSLogType {
        switch level {
            case .verbose: return .debug
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
        }
    }
}

#endif
