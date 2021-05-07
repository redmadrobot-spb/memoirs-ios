//
// ScopedLabeledLogger
// Robologs
//
// Created by Alex Babaev on 07.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class ScopedLabeledLogger: Logger {
    @usableFromInline
    let label: String
    @usableFromInline
    let scopes: [Scope]
    @usableFromInline
    let logger: Logger

    public init(label: String, scopes: [Scope], logger: Logger) {
        self.label = label
        self.scopes = scopes
        self.logger = logger
    }

    convenience public init(object: Any, scopes: [Scope], logger: Logger) {
        self.init(label: String(describing: type(of: object)), scopes: scopes, logger: logger)
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.log(
            level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]?,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.log(
            level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    /// Method that reports the log event with `verbose` logging level.
    @inlinable
    public func verbose(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.verbose(message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `debug` logging level.
    @inlinable
    public func debug(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.debug(message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `info` logging level.
    @inlinable
    public func info(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.info(message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `warning` logging level.
    @inlinable
    public func warning(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.warning(message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    /// Method that reports the log event with `error` logging level.
    @inlinable
    public func error(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.error(message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    public func error(
        _ error: Error,
        message: LogString? = nil,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.error(
            error, message: message, label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    /// Method that reports the log event with `assert` logging level.
    @inlinable
    public func critical(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.critical(message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }
}
