//
// PrintMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 27 December 2019. Updated by Alex Babaev
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Default `(Memoir)` implementation which uses `print()` to output logs.
public final class PrintMemoir: Memoir {
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

    public enum Time: @unchecked Sendable {
        case disabled
        case fastAndNonAccurate
        case formatter(DateFormatter)

        public func string(from timeSinceReferenceDate: TimeInterval) -> String? {
            switch self {
                case .disabled:
                    return nil
                case .fastAndNonAccurate:
                    return withUnsafePointer(to: Int(timeSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate)) { pointer in
                        var time = String(cString: ctime(pointer))
                        if let firstColon = time.firstIndex(of: ":"), let lastSpace = time.lastIndex(of: " ") {
                            time = String(time[time.index(firstColon, offsetBy: -2) ..< lastSpace])
                        }
                        return time
                    }
                case .formatter(let formatter):
                    return formatter.string(from: Date(timeIntervalSinceReferenceDate: timeSinceReferenceDate))
            }
        }
    }

    public enum CodePosition: Sendable {
        case full
        case short
        case none
    }

    public static let defaultTracerFilter: @Sendable (Tracer) -> Bool = { tracer in
        switch tracer {
            case .app, .instance, .session: return false
            case .request, .label, .type: return true
        }
    }

    @usableFromInline
    let time: Time
    @usableFromInline
    let output: Output

    @usableFromInline
    let interceptor: (@Sendable (String) -> Void)?

    /// Creates a new instance of `PrintMemoir`.
    public init(
        time: Time = .formatter(timeOnlyDateFormatter), codePosition: CodePosition = .short, shortTracers: Bool = true,
        tracerFilter: @escaping @Sendable (Tracer) -> Bool = PrintMemoir.defaultTracerFilter,
        interceptor: (@Sendable (String) -> Void)? = nil
    ) {
        output = Output(
            isSensitive: false,
            codePositionType: codePosition,
            shortTracers: shortTracers, separateTracers: true,
            tracerFilter: tracerFilter
        )
        self.time = time
        self.interceptor = interceptor
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let parts: [String]
        switch item {
            case .log(let level, let message):
                parts = output.logString(
                    date: time.string(from: timeIntervalSinceReferenceDate), level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .event(let name):
                parts = output.eventString(
                    date: time.string(from: timeIntervalSinceReferenceDate), name: name, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, false):
                parts = output.tracerString(
                    date: time.string(from: timeIntervalSinceReferenceDate), tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .tracer(let tracer, true):
                parts = output.tracerEndString(
                    date: time.string(from: timeIntervalSinceReferenceDate), tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                )
            case .measurement(let name, let value):
                parts = output.measurementString(
                    date: time.string(from: timeIntervalSinceReferenceDate), name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                )
        }

        let toOutput = parts.joined(separator: " ")
        print(toOutput)
        interceptor?(toOutput)
    }
}
