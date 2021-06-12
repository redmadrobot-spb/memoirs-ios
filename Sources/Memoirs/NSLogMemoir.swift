//
// NSLogMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 05 December 2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Memoir which encapsulate NSLog logging system.
public class NSLogMemoir: Memoir {
    @usableFromInline
    let output: Output

    public init(isSensitive: Bool, tracersFilter: @escaping (Tracer) -> Bool = { _ in false }) {
        output = Output(
            isSensitive: isSensitive,
            shortCodePosition: false, shortTracers: false, separateTracers: false,
            tracersFilter: tracersFilter
        )
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String
        switch item {
            case .log(let level, let message):
                description = output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
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
        NSLog("%@", description)
        Output.logInterceptor?(self, item, description)
    }
}
