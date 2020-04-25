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
        message: () -> LogString,
        label: String,
        meta: () -> [String: LogString]?,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.log(level: level, message: message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    @inlinable
    public func log(
        level: Level,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]?,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: level, message: message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    public func verbose(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        verbose(message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    public func debug(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        debug(message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    public func info(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        info(message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    public func warning(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        warning(message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    public func error(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        error(message(), label: label, meta: meta(), file: file, function: function, line: line)
    }

    @inlinable
    public func error(
        _ error: Error,
        message: LogString? = nil,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        self.error(error, message: message, label: label, meta: meta(), file: file, function: function, line: line)
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    public func critical(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        critical(message(), label: label, meta: meta(), file: file, function: function, line: line)
    }
}
