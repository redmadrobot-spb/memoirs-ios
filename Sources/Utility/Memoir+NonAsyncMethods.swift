//
// Memoir+Methods
// Memoirs
//
// Created by Alex Babaev on 09 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

// swiftlint:disable line_length

public extension Memoir {
    /// Common log method.
    @inlinable
    func logLater(level: LogLevel, _ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.log(level: level, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    func verboseLater(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.log(level: .verbose, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    func debugLater(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.log(level: .debug, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    func infoLater(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.log(level: .info, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    func warningLater(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.log(level: .warning, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    func errorLater(_ message: SafeString? = nil, error: Error? = nil, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        let message: SafeString = error.map { error in message.map { message in "\(message): \(error)" } ?? "\(error)" } ?? message.map { "\($0)" } ?? "Unknown Error"
        Task {
            await append(.log(level: .error, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    func errorLater(_ error: Error? = nil, message: SafeString? = nil, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await self.error(message, error: error, meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    func criticalLater(_ message: SafeString, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.log(level: .critical, message: message), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }
}

public extension Memoir {
    /// Logs an event.
    @inlinable
    func eventLater(name: String, meta: [String: SafeString], tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.event(name: name), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }
}

public extension Memoir {
    /// Logs tracer parameters update.
    @inlinable
    func updateLater(tracer: Tracer, meta: [String: SafeString], tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.tracer(tracer, isFinished: false), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }

    /// Logs end of the tracer. It may not be called for each tracer.
    @inlinable
    func finishLater(tracer: Tracer, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.tracer(tracer, isFinished: true), meta: nil, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }
}

public extension Memoir {
    /// Logs measurement that was calculated somehow.
    @inlinable
    func measurementLater(name: String, value: MeasurementValue, meta: [String: SafeString]? = nil, tracers: [Tracer] = [], timeIntervalSinceReferenceDate: TimeInterval = Date.timeIntervalSinceReferenceDate, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Task {
            await append(.measurement(name: name, value: value), meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }
}

// swiftlint:enable line_length
