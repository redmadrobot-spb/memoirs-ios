//
//  Robolog.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 26.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// The `Robolog` is a global point to call log methods.
/// The `Robolog` redirects everyone log event to all `(Logger)` - implementations.
public struct Robolog {
    /// Registered `Logger` - implementations
    @usableFromInline
    let loggers: [ Logger ]

    public init(loggers: [ Logger ]) {
        self.loggers = loggers
    }

    /// Method that reports the log event with `verbose` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func verbose(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .verbose, file: file, function: function, line: line, label: label, message: message, meta: meta)
    }

    /// Method that reports the log event with `debug` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func debug(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .debug, file: file, function: function, line: line, label: label, message: message, meta: meta)
    }

    /// Method that reports the log event with `info` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func info(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .info, file: file, function: function, line: line, label: label, message: message, meta: meta)
    }

    /// Method that reports the log event with `warning` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func warning(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .warning, file: file, function: function, line: line, label: label, message: message, meta: meta)
    }

    /// Method that reports the log event with `error` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func error(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .error, file: file, function: function, line: line, label: label, message: message, meta: meta)
    }

    /// Method that reports the log event with `assert` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func critical(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .critical, file: file, function: function, line: line, label: label, message: message, meta: meta)
    }

    /// Common method that reports the log event.
    /// - Parameters:
    ///   - priority: Log-level
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    public func log(
        priority: LogPriority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: () -> String?,
        message: () -> String,
        meta: () -> [String: Any]?
    ) {
        loggers.forEach { logger in
            logger.log(priority: priority, file: file, function: function, line: line, label: label, message: message, meta: meta)
        }
    }
}
