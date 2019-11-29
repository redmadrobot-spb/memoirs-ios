//
//  Logger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Protocol describing requirements for work with `Robolog` logging system.
public protocol Logger {
    /// Required method that reports the log event.
    /// - Parameters:
    ///   - priority: Log-level
    ///   - file: The path to the file from which the method was called
    ///   - function: The function name from which the method was called
    ///   - line: The line of code from which the method was called
    ///   - label: Label describing log catergory
    ///   - message: Message describing log event
    ///   - meta: Additional log information in key-value format
    @inlinable
    func log(
        priority: LogPriority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: @autoclosure () -> String?,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]?
    )
}
