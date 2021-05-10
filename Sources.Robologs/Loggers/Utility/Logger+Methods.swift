//
// Logger.Convenience
// Robologs
//
// Created by Alex Babaev on 09.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public extension Logger {
    @inlinable
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(level, message(), meta(), date, file, function, line)
    }

    @inlinable
    func verbose(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.verbose, message(), meta(), date, file, function, line)
    }

    @inlinable
    func debug(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.debug, message(), meta(), date, file, function, line)
    }

    @inlinable
    func info(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.info, message(), meta(), date, file, function, line)
    }

    @inlinable
    func warning(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.warning, message(), meta(), date, file, function, line)
    }

    func error(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.error, message(), meta(), date, file, function, line)
    }

    @inlinable
    func error(
        _ error: Error,
        message: LogString? = nil,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.error, message.map { "\($0): \(error)" } ?? "\(error)", meta(), date, file, function, line)
    }

    @inlinable
    func critical(
        _ message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(.critical, message(), meta(), date, file, function, line)
    }
}
