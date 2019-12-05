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
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    func log(
        priority: Priority,
        label: String,
        message: () -> String,
        meta: () -> [String: Any]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    )
}

extension Logger {
    /// Method that reports the log event with `verbose` log-level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func verbose(
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` log-level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func debug(
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` log-level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func info(
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` log-level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func warning(
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` log-level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func error(
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` log-level.
    /// - Parameters:
    ///   - label: Label describing log category.
    ///   - message: Message describing log event.
    ///   - meta: Additional log information in key-value format.
    ///   - file: The path to the file from which the method was called.
    ///   - function: The function name from which the method was called.
    ///   - line: The line of code from which the method was called.
    @inlinable
    public func critical(
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(priority: .verbose, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }

    func prepareMessage(_ parts: Any?...) -> String {
        parts.compactMap { $0.map(String.init(describing:)) }.joined(separator: " | ")
    }
}
