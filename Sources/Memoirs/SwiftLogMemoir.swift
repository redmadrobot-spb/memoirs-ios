//
// SwiftLogMemoir
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

#if canImport(Logging)

import Logging

public final class SwiftLogMemoir: Memoir {
    private let swiftLoggerMapper: ([Tracer]) -> Logging.Logger?
    private let defaultLogger: Logging.Logger = .init(label: "default")

    private let hideSensitiveValues: Bool
    private let interceptor: (@Sendable (String) -> Void)?
    private let output: Output

    init(
        hideSensitiveValues: Bool,
        markers: Output.Markers = .init(),
        interceptor: (@Sendable (String) -> Void)? = nil,
        swiftLoggerMapper: @escaping ([Tracer]) -> Logging.Logger?
    ) {
        self.hideSensitiveValues = hideSensitiveValues
        self.loggerMapper = swiftLoggerMapper
        self.interceptor = interceptor
        output = Output(
            markers: markers,
            hideSensitiveValues: hideSensitiveValues,
            codePositionType: .full, shortTracers: false, separateTracers: false,
            tracerFilter: tracerFilter
        )
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        message: @autoclosure () throws -> SafeString,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) rethrows {
        let loggingType: Logging.Logger.Level
        switch item {
            case .log(let level):
                description = try output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                switch level {
                    case .critical: loggingType = .critical
                    case .error: loggingType = .error
                    case .warning: loggingType = .warning
                    case .info: loggingType = .info
                    case .debug: loggingType = .debug
                    case .verbose: loggingType = .trace
                }
            case .event(let name):
                description = output.eventString(
                    date: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingType = .info
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingType = .info
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingType = .info
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingType = .info
        }

        let logger = swiftLoggerMapper(tracers) ?? defaultLogger
        logger.log(
            level: loggingLevel,
            message: description,
            metadata: meta().mapValues { $0.string(hideSensitiveValues: hideSensitiveValues) },
            source: nil, // TODO:
            file: file, function: function, line: line
        )
    }
}

#endif
