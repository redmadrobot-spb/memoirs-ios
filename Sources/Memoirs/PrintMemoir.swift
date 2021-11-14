//
// PrintMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 27 December 2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Default `(Memoir)` implementation which uses `print()` to output logs.
public class PrintMemoir: Memoir {
    public static let timeOnlyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    public static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    public enum Time {
        case disabled
        case fastAndNonAccurate
        case formatter(DateFormatter)

        public func string(from date: Date) -> String? {
            switch self {
                case .disabled:
                    return nil
                case .fastAndNonAccurate:
                    return withUnsafePointer(to: Int(date.timeIntervalSince1970)) { pointer in
                        var time = String(cString: ctime(pointer))
                        if let firstColon = time.firstIndex(of: ":"), let lastSpace = time.lastIndex(of: " ") {
                            time = String(time[time.index(firstColon, offsetBy: -2) ..< lastSpace])
                        }
                        return time
                    }
                case .formatter(let formatter):
                    return formatter.string(from: date)
            }
        }
    }

    public enum CodePosition {
        case full
        case short
        case none
    }

    public static let defaultTracerFilter: (Tracer) -> Bool = { tracer in
        switch tracer {
            case .app, .instance, .session: return false
            case .request, .label, .type: return true
        }
    }

    @usableFromInline
    let time: Time
    @usableFromInline
    let output: Output

    /// Creates a new instance of `PrintMemoir`.
    public init(
        time: Time = .formatter(timeOnlyDateFormatter), codePosition: CodePosition = .short, shortTracers: Bool = true,
        tracersFilter: @escaping (Tracer) -> Bool = PrintMemoir.defaultTracerFilter
    ) {
        output = Output(
            isSensitive: false,
            codePositionType: codePosition,
            shortTracers: shortTracers, separateTracers: true,
            tracersFilter: tracersFilter
        )
        self.time = time
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
        let parts: [String]
        switch item {
            case .log(let level, let message):
                parts = output.logString(
                    date: time.string(from: date), level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .event(let name):
                parts = output.eventString(
                    date: time.string(from: date), name: name, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, false):
                parts = output.tracerString(
                    date: time.string(from: date), tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, true):
                parts = output.tracerEndString(
                    date: time.string(from: date), tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .measurement(let name, let value):
                parts = output.measurementString(
                    date: time.string(from: date), name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                )
        }

        let toOutput = parts.joined(separator: " ")
        print(toOutput)
        Output.logInterceptor?(self, item, toOutput)
    }
}
