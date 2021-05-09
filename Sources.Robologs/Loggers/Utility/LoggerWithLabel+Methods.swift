//
// Logger.Convenience
// Robologs
//
// Created by Alex Babaev on 09.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public extension LabeledLoggable {
    @inlinable
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]?,
        date: Date,
        file: String, function: String, line: UInt
    ) {
        log(level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func verbose(
        _ message: @autoclosure () -> LogString,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .verbose, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func debug(
        _ message: @autoclosure () -> LogString,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .debug, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func info(
        _ message: @autoclosure () -> LogString,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .info, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func warning(
        _ message: @autoclosure () -> LogString,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .warning, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func error(
        _ message: @autoclosure () -> LogString,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .error, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func error(
        _ error: Error,
        message: LogString? = nil,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]?,
        date: Date,
        file: String, function: String, line: UInt
    ) {
        self.error(
            error, message: message, label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    @inlinable
    func critical(
        _ message: @autoclosure () -> LogString,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .critical, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }
}
