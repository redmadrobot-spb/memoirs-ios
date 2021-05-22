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
    public let loggers: [Loggable]

    /// Creates a new instance of `MultiplexingLogger`.
    /// - Parameter loggers: An array of loggers to which all log events will be redirected.
    public init(loggers: [Loggable]) {
        self.loggers = loggers
    }

    @inlinable
    public func add(
        _ item: Log.Item,
        meta: @autoclosure () -> [String: Log.String]?,
        tracers: [Log.Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        loggers.forEach { $0.add(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line) }
    }
}
