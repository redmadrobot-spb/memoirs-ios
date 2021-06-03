//
// Memoir+Methods
// Memoirs
//
// Created by Alex Babaev on 09 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

public extension Memoir {
    /// Common log method.
    @inlinable
    func log(level: LogLevel, _ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.log(level: level, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    func verbose(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.log(level: .verbose, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    func debug(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.log(level: .debug, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    func info(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.log(level: .info, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    func warning(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.log(level: .warning, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    func error(_ message: SafeString? = nil, error: Error? = nil, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        let message: SafeString = error.map { error in message.map { message in "\(message): \(error)" } ?? "\(error)" } ?? message.map { "\($0)" } ?? "Unknown Error"
        append(.log(level: .error, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    func error(_ error: Error? = nil, message: SafeString? = nil, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.error(message, error: error, meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    func critical(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.log(level: .critical, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

public extension Memoir {
    /// Logs an event.
    @inlinable
    func event(name: String, meta: [String: SafeString], tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.event(name: name), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

public extension Memoir {
    /// Logs tracer parameters update.
    @inlinable
    func update(tracer: Tracer, meta: [String: SafeString], tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.tracer(tracer, isFinished: false), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Logs end of the tracer. It may not be called for each tracer.
    @inlinable
    func finish(tracer: Tracer, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.tracer(tracer, isFinished: true), meta: nil, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

public extension Memoir {
    /// Logs measurement that was calculated somehow.
    @inlinable
    func measurement(name: String, value: Double, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(), file: String = #fileID, function: String = #function, line: UInt = #line) {
        append(.measurement(name: name, value: value), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

// swiftlint:enable line_length
