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
    let tracersFilter: (Tracer) -> Bool
    @usableFromInline
    let formatter: DateFormatter

    public static let defaultTracerFilter: (Tracer) -> Bool = { tracer in
        switch tracer {
            case .instance, .app, .queue, .thread: return false
            case .session, .request, .label, .custom: return true
        }
    }

    /// Creates a new instance of `PrintMemoir`.
    public init(
        onlyTime: Bool = false, shortSource: Bool = false, tracersFilter: @escaping (Tracer) -> Bool = PrintMemoir.defaultTracerFilter
    ) {
        self.shortSource = shortSource
        self.tracersFilter = tracersFilter
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
                    time: time, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition,
                    isSensitive: false, tracersFilter: tracersFilter
                )
            case .event(let name):
                description = Output.eventString(
                    time: time, name: name, tracers: tracers, meta: meta, codePosition: codePosition,
                    isSensitive: false, tracersFilter: tracersFilter
                )
            case .tracer(let tracer, false):
                description = Output.tracerString(
                    time: time, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition,
                    isSensitive: false, tracersFilter: tracersFilter
                )
            case .tracer(let tracer, true):
                description = Output.tracerEndString(
                    time: time, tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition,
                    isSensitive: false, tracersFilter: tracersFilter
                )
            case .measurement(let name, let value):
                description = Output.measurementString(
                    time: time, name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition,
                    isSensitive: false, tracersFilter: tracersFilter
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
