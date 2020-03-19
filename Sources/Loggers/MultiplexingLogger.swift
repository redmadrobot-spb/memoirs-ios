//
//  MultiplexingLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// A logger that stores several loggers in itself and redirects all log events to them. It has no side effects.
public struct MultiplexingLogger: Logger {
    @usableFromInline
    let loggers: [Logger]

    /// Creates a new instance of `MultiplexingLogger`.
    /// - Parameter loggers: An array of loggers to which all log events will be redirected.
    public init(loggers: [Logger]) {
        self.loggers = loggers
    }

    @inlinable
    public func log(
        level: Level,
        label: String,
        message: () -> String,
        meta: () -> [String: String]?,
        file: String,
        function: String,
        line: UInt
    ) {
        loggers.forEach {
            $0.log(level: level, label: label, message: message, meta: meta, file: file, function: function, line: line)
        }
    }
}
