//
// NSLogLogger
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Logger which encapsulate NSLog logging system.
public class NSLogLogger: Loggable {
    public let isSensitive: Bool

    public init(isSensitive: Bool) {
        self.isSensitive = isSensitive
    }

    @inlinable
    public func add(
        _ item: Log.Item,
        meta: @autoclosure () -> [String: Log.String]?,
        tracers: [Log.Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let codePosition = Output.codePosition(file: file, function: function, line: line)
        let description: String
        switch item {
            case .log(let level, let message):
                description = Output.logString(
                    time: "", level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .event(let name):
                description = Output.eventString(
                    time: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, false):
                description = Output.tracerString(
                    time: "", name: tracer.string, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, true):
                description = Output.tracerEndString(
                    time: "", name: tracer.string, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .measurement(let name, let value):
                description = Output.measurementString(
                    time: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
        }
        NSLog("%@", description)
        Output.logInterceptor?(self, description)
    }
}
