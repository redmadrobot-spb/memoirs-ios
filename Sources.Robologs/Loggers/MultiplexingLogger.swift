//
// MultiplexingLogger
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

/// A logger that stores several loggers in itself and redirects all log events to them. It has no side effects.
public class MultiplexingLogger: Logger {
    public var loggers: [Logger]

    /// Creates a new instance of `MultiplexingLogger`.
    /// - Parameter loggers: An array of loggers to which all log events will be redirected.
    public init(loggers: [Logger]) {
        self.loggers = loggers
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let loggers = self.loggers
        loggers.forEach {
            $0.log(level: level, message(), label: label, meta: meta(), file: file, function: function, line: line)
        }

        Output.logInterceptor?(self, nil, level, message, label, scopes, meta, nil, file, function, line)
    }
}
