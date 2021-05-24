//
// PrintMemoir
// Robologs
//
// Created by Dmitry Shadrin on 27.11.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Default `(Memoir)` implementation which uses `print()` to output logs.
public class PrintMemoir: Memoir {
    @usableFromInline
    let shortSource: Bool
    @usableFromInline
    let formatter: DateFormatter

    /// Creates a new instance of `PrintMemoir`.
    public init(onlyTime: Bool = false, shortSource: Bool = false) {
        self.shortSource = shortSource
        formatter = DateFormatter()
        formatter.dateFormat = onlyTime ? "HH:mm:ss.SSS" : "yyyy-MM-dd HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let time = formatter.string(from: date)
        let codePosition = codePosition(file: file, function: function, line: line)
        let description: String
        switch item {
            case .log(let level, let message):
                description = Output.logString(
                    time: time, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .event(let name):
                description = Output.eventString(
                    time: time, name: name, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, false):
                description = Output.tracerString(
                    time: time, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, true):
                description = Output.tracerEndString(
                    time: time, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .measurement(let name, let value):
                description = Output.measurementString(
                    time: time, name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
        }
        print(description)
        Output.logInterceptor?(self, item, description)
    }

    @usableFromInline
    func codePosition(file: String, function: String, line: UInt) -> String {
        Output.codePosition(file: file, function: shortSource ? "" : function, line: line)
    }
}
