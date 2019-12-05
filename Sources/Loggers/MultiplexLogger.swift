//
//  MultiplexLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// A logger that stores several loggers in itself and redirects all log events to them. It has no side effects.
public struct MultiplexLogger: Logger {
    /// An array of loggers to which all log events will be redirected.
    public let loggers: [Logger]

    @inlinable
    public func log(
        priority: Priority,
        label: String,
        message: () -> String,
        meta: () -> [String: Any]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        loggers.forEach {
            $0.log(priority: priority, label: label, message: message, meta: meta, file: file, function: function, line: line)
        }
    }
}
