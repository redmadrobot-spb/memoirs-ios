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

    /// Creates a new instance of `LabeledLoggerAdapter`.
    /// - Parameters:
    ///   - label: Label which describing log category.
    ///   - adaptee: Adaptable `Logger`.
    public init(label: String, adaptee: Logger) {
        self.label = label
        self.adaptee = adaptee
    }

    public func log(
        level: Level,
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        adaptee.log(level: level, label: label, message: message, meta: meta, file: file, function: function, line: line)
    }
}
