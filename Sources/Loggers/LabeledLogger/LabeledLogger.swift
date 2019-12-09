//
//  LabeledLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 06.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

public protocol LabeledLogger: Logger {
    /// Label which describing log category, like `Network` or `Repository`.
    var label: String { get }

    /// Required method that reports the log event.
    /// - Parameters:
    ///   - priority: Log-level.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    func log(
        priority: Priority,
        message: () -> String,
        meta: () -> [String: Any]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    )
}

extension LabeledLogger {
    @inlinable
    public func log(
        priority: Priority,
        message: () -> String,
        meta: () -> [String: Any]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        log(priority: priority, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` log-level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func verbose(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` log-level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func debug(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .debug, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` log-level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func info(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .info, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` log-level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func warning(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .warning, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` log-level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func error(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .error, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` log-level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func critical(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .critical, message: message, meta: meta, file: file, function: function, line: line)
    }
}
