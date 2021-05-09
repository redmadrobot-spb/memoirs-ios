//
// MultiplexingLogger
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// A logger that stores several loggers in itself and redirects all log events to them. It has no side effects.
public class MultiplexingLogger: Loggable {
    public var loggers: [Loggable]

    /// Creates a new instance of `MultiplexingLogger`.
    /// - Parameter loggers: An array of loggers to which all log events will be redirected.
    public init(loggers: [Loggable]) {
        self.loggers = loggers
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let loggers = self.loggers
        loggers.forEach {
            $0.log(
                level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
            )
        }
    }
}
