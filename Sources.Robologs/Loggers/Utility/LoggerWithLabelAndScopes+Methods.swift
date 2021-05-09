//
// Logger.Convenience
// Robologs
//
// Created by Alex Babaev on 09.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public extension Loggable where Self: ScopedLoggable, Self: LabeledLoggable {
    @inlinable
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func verbose(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .verbose, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func debug(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .debug, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func info(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .info, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func warning(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .warning, message(), label: label, meta: meta(), date: date, file: file, function: function, line: line)
    }

    func error(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .error, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }

    @inlinable
    func error(
        _ error: Error,
        message: LogString? = nil,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(
            level: .error,
            message.map { "\($0): \(error)" } ?? "\(error)",
            label: label,
            scopes: scopes,
            meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    @inlinable
    func critical(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        log(level: .critical, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
    }
}
