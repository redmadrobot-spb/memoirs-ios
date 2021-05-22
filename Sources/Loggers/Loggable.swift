//
// Loggable
// Robologs
//
// Created by Alex Babaev on 09 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public enum Log {}

/// Loggable is an interface to log events sending. Usually you don't use the base method
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
    func add(
        _ item: Log.Item,
        meta: @autoclosure () -> [String: Log.String]?,
        tracers: [Log.Tracer],
        date: Date,
        file: String, function: String, line: UInt
    )
}

/// Protocol that adds a tracer to every log.
public protocol Traceable {
    var tracer: Log.Tracer { get }
}
