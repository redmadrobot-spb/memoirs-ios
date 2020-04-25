//
//  Logger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 26.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Logger is an interface to log events sending. Usually you don't use the base method (with "level" parameter), but specific ones.
public protocol Logger {
    /// Required method that reports the log event.
    /// - Parameters:
    ///   - level: Logging level.
    ///   - label: Specifies in what part log event was recorded.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called. Usually you should use the #file literal for this.
    ///   - function: The function name from which the method was called. Usually you should use the #function literal for this.
    ///   - line: The line of code from which the method was called. Usually you should use the #line literal for this.
    @inlinable
    func log(
        level: Level,
        message: () -> LogString,
        label: String,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    )
}

extension Logger {
    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    public func verbose(
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .verbose, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    public func debug(
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    public func info(
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .info, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    public func warning(
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .warning, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    public func error(
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    public func critical(
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .critical, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    @inlinable
    public func log(
        level: Level,
        message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: level, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }
}
