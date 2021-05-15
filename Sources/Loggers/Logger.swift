//
// Loggable
// Robologs
//
// Created by Dmitry Shadrin on 26.11.2019.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Default logger.
public class Logger: Loggable {
    @usableFromInline
    let proxyLog: (
        _ level: Level,
        _ message: @autoclosure () -> LogString,
        _ meta: @autoclosure () -> [String: LogString]?,
        _ date: Date,
        _ file: String, _ function: String, _ line: UInt
    ) -> Void
    @usableFromInline
    let proxyBeginScopes: (_ scopes: [Scope]) -> Void
    @usableFromInline
    let proxyEndScopes: (_ scopes: [Scope]) -> Void

    public init(label: String, scopes: [Scope], logger: Loggable) {
        proxyLog = { level, message, meta, date, file, function, line in
            let scopes = ((logger as? ScopedLogger).map { $0.scopes } ?? []) + scopes
            logger.log(level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
        }
        proxyBeginScopes = { logger.begin(scopes: $0) }
        proxyEndScopes = { logger.begin(scopes: $0) }
    }

    convenience public init(object: Any, scopes: [Scope], logger: Loggable) {
        self.init(label: String(describing: type(of: object)), scopes: scopes, logger: logger)
    }

    // MARK: - Composing Loggers

    public init(label: String, logger: Loggable) {
        if let logger = logger as? ScopedLoggable {
            proxyLog = { level, message, meta, date, file, function, line in
                logger.log(level: level, message(), label: label, meta: meta(), date: date, file: file, function: function, line: line)
            }
        } else {
            proxyLog = { level, message, meta, date, file, function, line in
                logger.log(level: level, message(), label: label, scopes: [], meta: meta(), date: date, file: file, function: function, line: line)
            }
        }
        proxyBeginScopes = { logger.begin(scopes: $0) }
        proxyEndScopes = { logger.begin(scopes: $0) }
    }

    public init(scopes: [Scope], logger: Loggable) {
        if let logger = logger as? LabeledLoggable {
            proxyLog = { level, message, meta, date, file, function, line in
                logger.log(level: level, message(), scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
            }
        } else {
            proxyLog = { level, message, meta, date, file, function, line in
                let scopes = ((logger as? ScopedLogger).map { $0.scopes } ?? []) + scopes
                logger.log(level: level, message(), label: "???", scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line)
            }
        }
        proxyBeginScopes = { logger.begin(scopes: $0) }
        proxyEndScopes = { logger.begin(scopes: $0) }
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
        meta: @autoclosure () -> [String: LogString]?,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        proxyLog(level, message(), meta(), date, file, function, line)
    }

    public func begin(scopes: [Scope]) {
        proxyBeginScopes(scopes)
    }

    public func end(scopes: [Scope]) {
        proxyEndScopes(scopes)
    }
}
