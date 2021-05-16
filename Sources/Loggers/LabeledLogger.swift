//
// LabeledLogger
// Robologs
//
// Created by Dmitry Shadrin on 06.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class LabeledLogger: LabeledLoggable {
    public let label: String
    public let logger: Loggable

    public init(label: String, logger: Loggable) {
        self.label = label
        self.logger = logger
    }

    convenience public init(object: Any, logger: Loggable) {
        self.init(label: String(describing: type(of: object)), logger: logger)
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.log(
            level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }

    public func updateScope(_ scope: Scope, file: String, function: String, line: UInt) {
        logger.updateScope(scope, file: file, function: function, line: line)
    }

    public func endScope(name: String, file: String, function: String, line: UInt) {
        logger.endScope(name: name, file: file, function: function, line: line)
    }
}
