//
// Loggable
// Robologs
//
// Created by Dmitry Shadrin on 26.11.2019.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Logger is an interface to log events sending. Usually you don't use the base method
/// (with "level" parameter), but specific ones.
/// TODO: Add an example.
public protocol Loggable {
    /// Required method that reports the log event.
    /// - Parameters:
    ///  - level: Logging level.
    ///  - label: Specifies in what part log event was recorded.
    ///  - message: Message describing log event.
    ///  - scopes: Scopes that the log is a part of.
    ///  - meta: Additional log information in key-value format.
    ///  - date: date of the log emitting.
    ///  - file: The path to the file from which the method was called. Usually you should use the #file literal for this.
    ///  - function: The function name from which the method was called. Usually you should use the #function literal for this.
    ///  - line: The line of code from which the method was called. Usually you should use the #line literal for this.
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope],
        meta: @autoclosure () -> [String: LogString]?,
        date: Date,
        file: String,
        function: String,
        line: UInt
    )
}

public protocol LabeledLoggable: Loggable {
    var label: String { get }
}

public protocol ScopedLoggable: Loggable {
    var scopes: [Scope] { get }
}

public protocol LoggableProxy: Loggable {
    var logger: Loggable { get }
}

public class Logger: LoggableProxy, ScopedLoggable, LabeledLoggable {
    public let label: String
    public let scopes: [Scope]
    public let logger: Loggable

    public init(label: String, scopes: [Scope] = [], logger: Loggable) {
        self.label = label
        self.scopes = scopes
        self.logger = logger
    }

    convenience public init(object: Any, scopes: [Scope] = [], logger: Loggable) {
        self.init(label: String(describing: type(of: object)), scopes: scopes, logger: logger)
    }
}
