//
// Logger.Convenience
// Robologs
//
// Created by Alex Babaev on 09.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

public extension Loggable {
    /// Common log method.
    @inlinable
    func log(level: Log.Level, _ message: Log.String, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.log(level: level, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    func verbose(_ message: Log.String, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.log(level: .verbose, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    func debug(_ message: Log.String, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.log(level: .debug, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    func info(_ message: Log.String, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.log(level: .info, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    func warning(_ message: Log.String, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.log(level: .warning, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    func error(_ error: Error? = nil, message: Log.String? = nil, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        let message: Log.String = error.map { error in message.map { message in "\(message): \(error)" } ?? "\(error)" } ?? message.map { "\($0)" } ?? "Unknown Error"
        add(.log(level: .error, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    func critical(_ message: Log.String, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.log(level: .critical, message: message), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

public extension Loggable {
    /// Logs an event.
    @inlinable
    func event(name: String, meta: [String: Log.String], tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.event(name: name), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

public extension Loggable {
    /// Logs tracer parameters update.
    @inlinable
    func update(tracer: Log.Tracer, meta: [String: Log.String], tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.tracer(tracer, isFinished: false), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }

    /// Logs end of the tracer. It may not be called for each tracer.
    @inlinable
    func finish(tracer: Log.Tracer, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.tracer(tracer, isFinished: true), meta: nil, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

public extension Loggable {
    /// Logs measurement that was calculated somehow.
    @inlinable
    func measurement(name: String, value: Double, meta: [String: Log.String]? = nil, tracers: [Log.Tracer] = [], date: Date = Date(), file: String = #file, function: String = #function, line: UInt = #line) {
        add(.measurement(name: name, value: value), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

// swiftlint:enable line_length
