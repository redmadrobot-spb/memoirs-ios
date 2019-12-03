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
    ///   - priority: Log-level.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    func log(
        priority: Priority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]?
    )
}

extension Logger {
    /// Method that reports the log event with `verbose` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    public func verbose(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]? = nil
    ) {
        log(priority: .verbose, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    /// Method that reports the log event with `debug` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    public func debug(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]? = nil
    ) {
        log(priority: .debug, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    /// Method that reports the log event with `info` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    public func info(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]? = nil
    ) {
        log(priority: .info, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    /// Method that reports the log event with `warning` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    public func warning(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]? = nil
    ) {
        log(priority: .warning, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    /// Method that reports the log event with `error` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    public func error(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]? = nil
    ) {
        log(priority: .error, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    /// Method that reports the log event with `assert` log-level.
    /// - Parameters:
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    @inlinable
    public func critical(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [ String: Any ]? = nil
    ) {
        log(priority: .critical, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    func prepareMessage(_ parts: CustomStringConvertible?...) -> String {
        return parts
            .compactMap { $0?.description }
            .joined(separator: " | ")
    }
}
