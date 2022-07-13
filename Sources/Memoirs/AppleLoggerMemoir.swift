//
// AppleLoggerMemoir
// memoirs-ios
//
// Created by Alex Babaev on 15 May 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation
import os

@available(iOS 14.0, *)
public final class AppleLoggerMemoir: Memoir {
    @usableFromInline
    actor Loggers {
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

    @usableFromInline
    let output: Output
    @usableFromInline
    let loggers: Loggers

    @usableFromInline
    let interceptor: (@Sendable (String) -> Void)?

    public init(
        isSensitive: Bool, subsystem: String, tracerFilter: @escaping @Sendable (Tracer) -> Bool = { _ in false },
        interceptor: (@Sendable (String) -> Void)? = nil
    ) {
        self.interceptor = interceptor
        loggers = .init(subsystem: subsystem)
        output = Output(
            isSensitive: isSensitive,
            codePositionType: .full, shortTracers: false, separateTracers: false,
            tracerFilter: tracerFilter
        )
    }

    @inlinable
    func tracerString(for tracers: [Tracer]) -> String {
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
        return label
    }

    @usableFromInline
    let asyncTaskQueue: AsyncTaskQueue = .init()

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String

        let traceString = tracerString(for: tracers)
        let logAction: @Sendable () async -> Void

        switch item {
            case .log(let level, let message):
                description = output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                logAction = { [self] in
                    switch level {
                        case .critical: await loggers.logger(for: traceString) { $0.fault("\(description)") }
                        case .error: await loggers.logger(for: traceString) { $0.error("\(description)") }
                        case .warning: await loggers.logger(for: traceString) { $0.warning("\(description)") }
                        case .info: await loggers.logger(for: traceString) { $0.info("\(description)") }
                        case .debug: await loggers.logger(for: traceString) { $0.debug("\(description)") }
                        case .verbose: await loggers.logger(for: traceString) { $0.trace("\(description)") }
                    }
                }
            case .event(let name):
                description = output.eventString(
                    date: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                logAction = { [self] in
                    await loggers.logger(for: traceString) { $0.notice("\(description)") }
                }
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                logAction = { [self] in
                    await loggers.logger(for: traceString) { $0.notice("\(description)") }
                }
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                logAction = { [self] in
                    await loggers.logger(for: traceString) { $0.notice("\(description)") }
                }
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                logAction = { [self] in
                    await loggers.logger(for: traceString) { $0.notice("\(description)") }
                }
        }
        asyncTaskQueue.add {
            await logAction()
        }
        interceptor?(description)
    }
}
