//
// Memoir+Methods
// Memoirs
//
// Created by Alex Babaev on 09 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

// swiftlint:disable line_length

public extension Memoir {
    /// Common log method.
    @inlinable
    nonmutating func log(level: LogLevel, _ message: @escaping @autoclosure () throws -> SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        try append(.log(level: level), message: try message(), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    nonmutating func verbose(_ message: @escaping @autoclosure () throws -> SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        try append(.log(level: .verbose), message: try message(), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    nonmutating func debug(_ message: @escaping @autoclosure () throws -> SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        try append(.log(level: .debug), message: try message(), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    nonmutating func info(_ message: @escaping @autoclosure () throws -> SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        try append(.log(level: .info), message: try message(), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    nonmutating func warning(_ message: @escaping @autoclosure () throws -> SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        try append(.log(level: .warning), message: try message(), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    nonmutating func error(_ message: @escaping @autoclosure () throws -> SafeString? = nil, error: Error? = nil, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        if let error {
            try append(.log(level: .error), message: "\(try message().map { message in "\(message): \(error)" } ?? "\(error)")", meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        } else {
            try append(.log(level: .error), message: "\(try message() ?? "Unknown Error")", meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    nonmutating func error(_ error: Error? = nil, message: SafeString? = nil, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.error(message, error: error, meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    nonmutating func critical(_ message: @escaping @autoclosure () throws -> SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) rethrows {
        try append(.log(level: .critical), message: try message(), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }
}

public extension Memoir {
    /// Logs an event.
    @inlinable
    nonmutating func event(name: String, meta: [String: SafeString], tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.event(name: name), message: "", meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }
}

public extension Memoir {
    /// Logs tracer parameters update.
    @inlinable
    nonmutating func update(tracer: Tracer, meta: [String: SafeString], tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.tracer(tracer, isFinished: false), message: "", meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }

    /// Logs end of the tracer. It may not be called for each tracer.
    @inlinable
    nonmutating func finish(tracer: Tracer, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.tracer(tracer, isFinished: true), message: "", meta: nil, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }
}

public extension Memoir {
    /// Logs measurement that was calculated somehow.
    @inlinable
    nonmutating func measurement(name: String, value: MeasurementValue, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.measurement(name: name, value: value), message: "", meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
    }
}

// swiftlint:enable line_length
