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

    @usableFromInline
    var currentQueueName: String? { String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) }
    @usableFromInline
    var currentThreadName: String? { Thread.current.name ?? String(describing: Thread.current) }

    @inlinable
    public func add(
        _ item: Log.Item, meta: @autoclosure () -> [String: Log.String]?, tracers: [Log.Tracer], date: Date,
        file: String, function: String, line: UInt
    ) {
        var tracers = tracers
        if let threadName = currentThreadName, !threadName.isEmpty {
            tracers.insert(.thread(name: threadName), at: 0)
        }
        if let queueName = currentQueueName, !queueName.isEmpty {
            tracers.insert(.queue(name: queueName), at: 0)
        }
        logger.add(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line)
    }
}
