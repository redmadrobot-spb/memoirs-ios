//
// Logger
// Robologs
//
// Created by Dmitry Shadrin on 26.11.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Logger is an interface to log events sending. Usually you don't use the base method
/// (with "level" parameter), but specific ones.
/// TODO: Add an example.
public protocol Logger {
    /// Required method that reports the log event.
    /// - Parameters:
    ///  - level: Logging level.
    ///  - label: Specifies in what part log event was recorded.
    ///  - message: Message describing log event.
    ///  - scopes: Scopes that the log is a part of.
    ///  - meta: Additional log information in key-value format.
    ///  - date: date of the log emitting.
    ///  - file: The path to the file from which the method was called. Usually you should use the #file literal for this.
    ///  - function: The function name from which the method was called. Usually you should use the #function literal for this.
    ///  - line: The line of code from which the method was called. Usually you should use the #line literal for this.
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]?,
        date: Date,
        file: String,
        function: String,
        line: UInt
    )
}

extension Logger {
    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    public func verbose(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .verbose, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    public func debug(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .debug, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    public func info(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .info, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    public func warning(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .warning, message(), label: label, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    public func error(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .error, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    public func error(
        _ error: Error,
        message: LogString? = nil,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(
            level: .error,
            message.map { "\($0): \(error)" } ?? "\(error)",
            label: label,
            scopes: scopes,
            meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    public func critical(
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .critical, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }
}
