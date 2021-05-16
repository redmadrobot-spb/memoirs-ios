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
    public let newScopes: [Scope]
    public let logger: Loggable

    public init(scopes: [Scope], logger: Loggable, file: String = #file, function: String = #function, line: UInt = #line) {
        self.scopes = ((logger as? ScopedLogger).map { $0.scopes } ?? []) + scopes
        self.logger = logger
        newScopes = scopes
        newScopes
            .filter { $0.parentName != nil || !$0.meta.isEmpty }
            .forEach {
                updateScope($0, file: file, function: function, line: line)
            }
    }

    deinit {
        newScopes.forEach { endScope(name: $0.name) }
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
