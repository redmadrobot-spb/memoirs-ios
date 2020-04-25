//
//  LabeledLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 06.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

public struct LabeledLogger: Logger {
    public let label: String
    private let logger: Logger

    public init(label: String, logger: Logger) {
        self.label = label
        self.logger = logger
    }

    public init(object: Any, logger: Logger) {
        self.init(label: String(describing: type(of: object)), logger: logger)
    }

    public func log(
        level: Level,
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        logger.log(level: level, message: message, label: label, meta: meta, file: file, function: function, line: line)
    }

    @inlinable
    public func log(
        level: Level,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        log(level: level, message: message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    public func verbose(
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .verbose, message: message(), meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    public func debug(
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug, message: message(), meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    public func info(
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .info, message: message(), meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    public func warning(
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .warning, message: message(), meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    public func error(
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error, message: message(), meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    public func critical(
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .critical, message: message(), meta: meta(), file: file, function: function, line: line)
    }
}
