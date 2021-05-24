//
// NSLogMemoir
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Memoir which encapsulate NSLog logging system.
public class NSLogMemoir: Memoir {
    @usableFromInline
    let isSensitive: Bool

    public init(isSensitive: Bool) {
        self.isSensitive = isSensitive
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let codePosition = Output.codePosition(file: file, function: function, line: line)
        let description: String
        switch item {
            case .log(let level, let message):
                description = Output.logString(
                    time: "", level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition,
                    isSensitive: isSensitive
                )
            case .event(let name):
                description = Output.eventString(
                    time: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: isSensitive
                )
            case .tracer(let tracer, false):
                description = Output.tracerString(
                    time: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: isSensitive
                )
            case .tracer(let tracer, true):
                description = Output.tracerEndString(
                    time: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: isSensitive
                )
            case .measurement(let name, let value):
                description = Output.measurementString(
                    time: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: isSensitive
                )
        }
        NSLog("%@", description)
        Output.logInterceptor?(self, item, description)
    }
}
