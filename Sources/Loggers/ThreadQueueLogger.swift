//
// ThreadQueueLogger
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class ThreadQueueLogger: Loggable {
    public let logger: Loggable

    public init(logger: Loggable) {
        self.logger = logger
    }

    @inlinable
    public var currentQueueName: String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }

    @inlinable
    public var currentThreadName: String? {
        Thread.current.name ?? String(describing: Thread.current)
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
        var scopes = scopes
        if let threadName = currentThreadName, !threadName.isEmpty {
            let scope = Scope(.thread(name: threadName), parent: .app)
            scopes.append(scope)
        }
        if let queueName = currentQueueName, !queueName.isEmpty {
            let scope = Scope(.queue(name: queueName), parent: .app)
            scopes.append(scope)
        }

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
