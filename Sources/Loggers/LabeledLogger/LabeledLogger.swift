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
    ///   - level: Logging level.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    func log(
        level: Level,
        message: () -> String,
        meta: () -> [String: String]?,
        file: String,
        function: String,
        line: UInt
    )
}

extension LabeledLogger {
    @inlinable
    public func log(
        level: Level,
        message: () -> String,
        meta: () -> [String: String]?,
        file: String,
        function: String,
        line: UInt
    ) {
        log(level: level, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func verbose(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .verbose, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func debug(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func info(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .info, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func warning(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .warning, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func error(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    /// - Parameters:
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func critical(
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .critical, message: message, meta: meta, file: file, function: function, line: line)
    }
}
