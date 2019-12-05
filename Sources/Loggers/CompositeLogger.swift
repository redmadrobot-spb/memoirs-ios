//
//  CompositeLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// A logger that stores several loggers in itself and redirects all log events to them. It has no side effects.
public struct CompositeLogger: Logger {
    /// An array of loggers to which all log events will be redirected.
    public let loggers: [Logger]

    @inlinable
    public func log(
        priority: Priority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: String,
        message: () -> String,
        meta: () -> [String: Any]?
    ) {
        loggers.forEach {
            $0.log(priority: priority, file: file, function: function, line: line, label: label, message: message, meta: meta)
        }
    }
}
