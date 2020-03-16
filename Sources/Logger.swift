//
//  Logger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 26.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Protocol describing requirements for work with `Robolog` logging system.
public protocol Logger {
    /// Required method that reports the log event.
    /// - Parameters:
    ///   - level: Logging level.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    func log(
        level: Level,
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    )
}

extension Logger {
    /// Method that reports the log event with `verbose` logging level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func verbose(
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func debug(
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func info(
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .info, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func warning(
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .warning, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func error(
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event. Can be privacy managed.
    ///   - meta: Additional log information in key-value format. Values can be privacy managed.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func critical(
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .critical, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }
}
