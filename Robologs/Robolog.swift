//
//  Robolog.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 26.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// The `Robolog` is a global point to call log methods.
/// The `Robolog` redirects everyone log event to all `(Logger)` - implementations.
public enum Robolog {
    private static var logQueue: DispatchQueue?
    private static var loggers: Set<AnyLogger> = []

    /// `configure` is a one-time configuration function which globally setup logging system
    /// `configure` can be called at maximum once, calling it more than once will
    /// lead to undefined behaviour, most likely a crash.
    /// - Parameter label: Unique label
    public static func configure(label: String) {
        precondition(logQueue == nil, "Robolog can only be configured once")
        logQueue = DispatchQueue(label: label, attributes: .concurrent)
    }

    /// Adding `(Logger)` - implementation which will handle everyone log event
    /// - Parameter logger: `(Logger)` - implementation which should be added
    public static func add(logger: Logger) {
        checkReadiness()
        logQueue?.async(flags: .barrier) {
            let wrapped = AnyLogger(base: logger)
            loggers.insert(wrapped)
        }
    }

    /// Adding several `(Logger)` - implementations which will handle everyone log event
    /// - Parameter loggers: Array of `(Logger)` - implementations which should be added
    public static func add(loggers: [Logger]) {
        checkReadiness()
        logQueue?.async(flags: .barrier) {
            let wrapped = loggers.reduce(into: Set<AnyLogger>()) { $0.insert(AnyLogger(base: $1)) }
            Self.loggers.formUnion(wrapped)
        }
    }

    /// Removing concrete `(Logger)` - implementation
    /// - Parameter logger: `Logger` which should be removed
    public static func remove(logger: Logger) {
        checkReadiness()
        logQueue?.async(flags: .barrier) {
            let wrapped = AnyLogger(base: logger)
            loggers.remove(wrapped)
        }
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
    public static func verbose(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .verbose, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
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
    public static func debug(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .debug, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
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
    public static func info(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .info, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
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
    public static func warning(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .warning, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
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
    public static func error(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .error, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
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
    public static func assert(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        log(priority: .assert, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
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
    public static func log(
        priority: LogPriority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: @autoclosure () -> String?,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]?
    ) {
        checkReadiness()
        logQueue?.sync {
            loggers.forEach { anyLogger in
                anyLogger.base
                    .log(priority: priority, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
            }
        }
    }

    private static func checkReadiness() {
        precondition(logQueue != nil, "Robolog must be configured")
    }
}
