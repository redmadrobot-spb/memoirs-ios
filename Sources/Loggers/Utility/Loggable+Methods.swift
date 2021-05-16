//
// Logger.Convenience
// Robologs
//
// Created by Alex Babaev on 09.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public extension Loggable {
    @inlinable
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    func verbose(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .verbose, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    func debug(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .debug, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    func info(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .info, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    func warning(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .warning, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    func error(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .error, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func error(
        _ error: Error,
        message: LogString? = nil,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let message: LogString = message.map { "\($0): \(error)" } ?? "\(error)"
        log(level: .error, message, label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    func critical(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .critical, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func updateScope(_ scope: Scope, file: String = #file, function: String = #function, line: UInt = #line) {
        updateScope(scope, file: file, function: function, line: line)
    }

    @inlinable
    func endScope(name: String, file: String = #file, function: String = #function, line: UInt = #line) {
        endScope(name: name, file: file, function: function, line: line)
    }
}
