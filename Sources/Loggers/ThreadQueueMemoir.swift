//
// ThreadQueueMemoir
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class ThreadQueueMemoir: Memoir {
    public let memoir: Memoir

    public init(memoir: Memoir) {
        self.memoir = memoir
    }

    @usableFromInline
    var currentQueueName: String? { String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) }
    @usableFromInline
    var currentThreadName: String? { Thread.current.name ?? String(describing: Thread.current) }

    @inlinable
    public func append(
        _ item: MemoirItem, meta: @autoclosure () -> [String: SafeString]?, tracers: [Tracer], date: Date,
        file: String, function: String, line: UInt
    ) {
        var tracers = tracers
        if let threadName = currentThreadName, !threadName.isEmpty {
            tracers.append(.thread(name: threadName))
        }
        if let queueName = currentQueueName, !queueName.isEmpty {
            tracers.append(.queue(name: queueName))
        }
        memoir.append(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line)
    }
}
