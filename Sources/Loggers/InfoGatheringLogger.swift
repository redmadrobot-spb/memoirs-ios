//
// SystemInfoGatheringLogger
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

// TODO: This should be replaced with scoped logger
public class InfoGatheringLogger: Loggable {
    public let logger: Loggable
    public let meta: [String: LogString]

    public init(meta: [String: LogString], logger: Loggable) {
        self.meta = meta
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
        // TODO: Replace these with scopes
        var updatedMeta = self.meta
        if let threadName = currentThreadName, !threadName.isEmpty {
            updatedMeta["_thread"] = LogString(threadName)
        }
        if let queueName = currentQueueName, !queueName.isEmpty {
            updatedMeta["_queue"] = LogString(queueName)
        }
        meta()?.forEach { key, value in
            updatedMeta[key] = value
        }

        logger.log(
            level: level, message(), label: label, scopes: scopes, meta: updatedMeta, date: date, file: file, function: function, line: line
        )
    }

    public func begin(scopes: [Scope]) {
        // TODO:
    }

    public func end(scopes: [Scope]) {
        // TODO:
    }
}