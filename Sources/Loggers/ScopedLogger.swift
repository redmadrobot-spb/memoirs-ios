//
// ScopedLogger
// Robologs
//
// Created by Alex Babaev on 07 April 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class ScopedLogger: ScopedLoggable {
    public let scopes: [Scope]
    public let beganScopes: [Scope]
    public let logger: Loggable

    public init(scopes: [Scope], logger: Loggable) {
        self.scopes = ((logger as? ScopedLogger).map { $0.scopes } ?? []) + scopes
        self.logger = logger
        beganScopes = scopes
        begin(scopes: beganScopes)
    }

    deinit {
        end(scopes: beganScopes)
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

    public func begin(scopes: [Scope]) {
        logger.begin(scopes: scopes)
    }

    public func end(scopes: [Scope]) {
        logger.end(scopes: scopes)
    }
}
