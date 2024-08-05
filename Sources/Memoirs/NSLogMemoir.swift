//
// NSLogMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 05 December 2019. Updated by Alex Babaev
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Memoir which encapsulate NSLog logging system.
public final class NSLogMemoir: Memoir {
    @usableFromInline
    let output: Output

    @usableFromInline
    let interceptor: (@Sendable (String) async -> Void)?

    public init(
        isSensitive: Bool, tracerFilter: @escaping @Sendable (Tracer) -> Bool = { _ in false },
        markers: Output.Markers = .init(),
        interceptor: (@Sendable (String) async -> Void)? = nil
    ) {
        self.interceptor = interceptor
        output = Output(
            markers: markers,
            hideSensitiveValues: isSensitive,
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
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String
        switch item {
            case .log(let level):
                description = try output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .event(let name):
                description = output.eventString(
                    date: nil, name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: nil, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: nil, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: nil, name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
        }
        NSLog("%@", description)
        Task {
            await interceptor?(description)
        }
    }
}
