//
// SwiftLogMemoir
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

import Foundation

#if canImport(Logging)

import Logging

public final class SwiftLogMemoir: Memoir, @unchecked Sendable {
    private let swiftLoggerMapper: ([Tracer]) -> Logging.Logger?
    private let defaultLogger: Logging.Logger = .init(label: "default")

    private let hideSensitiveValues: Bool
    private let interceptor: (@Sendable (String) -> Void)?
    private let output: Output

    init(
        hideSensitiveValues: Bool,
        markers: Output.Markers = .init(),
        interceptor: (@Sendable (String) -> Void)? = nil,
        swiftLoggerMapper: @escaping ([Tracer]) -> Logging.Logger?,
        tracerFilter: @escaping @Sendable (Tracer) -> Bool = PrintMemoir.defaultTracerFilter,
    ) {
        self.hideSensitiveValues = hideSensitiveValues
        self.swiftLoggerMapper = swiftLoggerMapper
        self.interceptor = interceptor
        output = Output(
            markers: markers,
            hideSensitiveValues: hideSensitiveValues,
            codePositionType: .full, shortTracers: false, separateTracers: false,
            tracerFilter: tracerFilter
        )
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

        let loggingLevel: Logging.Logger.Level
        switch item {
            case .log(let level):
                description = try output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                switch level {
                    case .critical: loggingLevel = .critical
                    case .error: loggingLevel = .error
                    case .warning: loggingLevel = .warning
                    case .info: loggingLevel = .info
                    case .debug: loggingLevel = .debug
                    case .verbose: loggingLevel = .trace
                }
            case .event(let name):
                description = output.eventString(
                    date: nil, name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingLevel = .info
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: nil, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingLevel = .info
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: nil, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingLevel = .info
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: nil, name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                loggingLevel = .info
        }

        let logger = swiftLoggerMapper(tracers) ?? defaultLogger
        logger.log(
            level: loggingLevel,
            "\(description)",
            metadata: meta()?.mapValues { .stringConvertible($0.string(hideSensitiveValues: hideSensitiveValues)) },
            source: nil, // TODO:
            file: file, function: function, line: line
        )
    }
}

#endif
