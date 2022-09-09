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
    private let output: Output
    private let interceptor: (@Sendable (String) -> Void)?
    private let asyncTaskQueue: AsyncTaskQueue

    /// Creates a new instance of `OSLogMemoir`.
    /// - Parameter subsystem: An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    /// - Parameter isSensitive: is log sensitive
    /// - Parameter tracerFilter: filter for the tracers output
    /// - Parameter markers: markers for distinguishing between different logging levels and items
    /// - Parameter interceptor: method that catches all strings, that this logger emits
    /// - Parameter useSyncOutput: Warning. This will slow down execution. Use this for tests when you need synchronous output.
    public init(
        subsystem: String, isSensitive: Bool, tracerFilter: @escaping @Sendable (Tracer) -> Bool = { _ in false },
        markers: Output.Markers = .init(),
        interceptor: (@Sendable (String) -> Void)? = nil,
        useSyncOutput: Bool = false
    ) {
        self.interceptor = interceptor
        asyncTaskQueue = .init(syncExecution: useSyncOutput)
        osLogHolder = .init(subsystem: subsystem)
        output = Output(
            markers: markers,
            hideSensitiveValues: isSensitive,
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
    ) {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String
        var osLogType: OSLogType = .debug

        var label: String = output.hideSensitiveValues ? "???" : "NoLabel"
        if !output.hideSensitiveValues {
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
        asyncTaskQueue.add { [osLogType, label] in
            await self.osLogHolder.osLog(for: label) { os_log(osLogType, log: $0, "%{public}@", description) }
        }
        interceptor?(description)
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
