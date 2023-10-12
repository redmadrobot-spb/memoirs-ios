//
// AppleLoggerMemoir
// memoirs-ios
//
// Created by Alex Babaev on 15 May 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

#if canImport(os)

import Foundation
import os

@available(iOS 14.0, *)
public final class AppleLoggerMemoir: Memoir {
    private actor Loggers {
        private var loggers: [String: Logger] = [:]
        private let subsystem: String

        init(subsystem: String) {
            self.subsystem = subsystem
        }

        public func logger(for tracerString: String, operation: @Sendable (Logger) -> Void) {
            if let logger = loggers[tracerString] {
                operation(logger)
            } else {
                let logger = Logger(subsystem: subsystem, category: tracerString)
                loggers[tracerString] = logger
                operation(logger)
            }
        }
    }

    private let output: Output
    private let loggers: Loggers

    private let interceptor: (@Sendable (String) -> Void)?
    private let asyncTaskQueue: AsyncTaskQueue

    public init(
        hideSensitiveValues: Bool, subsystem: String, tracerFilter: @escaping @Sendable (Tracer) -> Bool = { _ in false },
        markers: Output.Markers = .init(),
        interceptor: (@Sendable (String) -> Void)? = nil,
        useSyncOutput: Bool = false
    ) {
        self.interceptor = interceptor
        asyncTaskQueue = .init(memoir: PrintMemoir())
        loggers = .init(subsystem: subsystem)
        output = Output(
            markers: markers,
            hideSensitiveValues: hideSensitiveValues,
            codePositionType: .full, shortTracers: false, separateTracers: false,
            tracerFilter: tracerFilter
        )
    }

    func tracerString(for tracers: [Tracer]) -> String {
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
        return label
    }

    public func append(
        _ item: MemoirItem,
        message: @autoclosure () throws -> SafeString,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) rethrows {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String

        let traceString = tracerString(for: tracers)
        let osLogType: OSLogType

        switch item {
            case .log(let level):
                description = try output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                switch level {
                    case .critical: osLogType = .fault
                    case .error: osLogType = .error
                    case .warning: osLogType = .error
                    case .info: osLogType = .info
                    case .debug: osLogType = .debug
                    case .verbose: osLogType = .debug
                }
            case .event(let name):
                description = output.eventString(
                    date: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                osLogType = .info
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                osLogType = .info
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                osLogType = .info
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                osLogType = .info
        }
        asyncTaskQueue.add {
            await self.loggers.logger(for: traceString) { $0.log(level: osLogType, "\(description, privacy: .public)") }
        }
        interceptor?(description)
    }
}

#endif
