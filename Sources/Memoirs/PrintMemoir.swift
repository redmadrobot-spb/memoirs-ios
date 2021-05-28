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
    let formatter: DateFormatter

    public static let defaultTracerFilter: (Tracer) -> Bool = { tracer in
        switch tracer {
            case .app, .instance, .session: return false
            case .queue, .thread: return false
            case .request, .label, .custom: return true
        }
    }

    @usableFromInline
    let output: Output

    /// Creates a new instance of `PrintMemoir`.
    public init(
        onlyTime: Bool = false, shortCodePosition: Bool = true, shortTracers: Bool = true,
        tracersFilter: @escaping (Tracer) -> Bool = PrintMemoir.defaultTracerFilter
    ) {
        output = Output(
            isSensitive: false,
            shortCodePosition: shortCodePosition, shortTracers: shortTracers, separateTracers: true,
            tracersFilter: tracersFilter
        )
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
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String
        switch item {
            case .log(let level, let message):
                description = output.logString(
                    time: time, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .event(let name):
                description = output.eventString(
                    time: time, name: name, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, false):
                description = output.tracerString(
                    time: time, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    time: time, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .measurement(let name, let value):
                description = output.measurementString(
                    time: time, name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                )
        }
        print(description)
        Output.logInterceptor?(self, item, description)
    }
}
