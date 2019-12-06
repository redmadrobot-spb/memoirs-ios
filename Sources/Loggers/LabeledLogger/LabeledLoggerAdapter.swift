//
//  LabeledLoggerAdapter.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 06.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Wrapper which adapts the incapsulated `Logger` object to the`LabeledLogger` protocol .
public struct LabeledLoggerAdapter: LabeledLogger {
    public let label: String
    private let adaptee: Logger

    public init(label: String, adaptee: Logger) {
        self.label = label
        self.adaptee = adaptee
    }

    public func log(
        priority: Priority,
        message: () -> String,
        meta: () -> [String: Any]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        adaptee.log(priority: priority, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }
}
