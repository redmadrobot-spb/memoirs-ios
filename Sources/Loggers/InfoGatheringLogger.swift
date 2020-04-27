//
// SystemInfoGatheringLogger
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

public class InfoGatheringLogger: Logger {
    public let logger: Logger
    public let meta: [String: LogString]

    public init(meta: [String: LogString], logger: Logger) {
        self.meta = meta
        self.logger = logger
    }

    @inlinable
    public var currentQueueName: String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        var updatedMeta = self.meta
        if let threadName = Thread.current.name, !threadName.isEmpty {
            updatedMeta["_thread"] = LogString(threadName)
        }
        if let queueName = currentQueueName, !queueName.isEmpty {
            updatedMeta["_queue"] = LogString(queueName)
        }
        meta()?.forEach { key, value in
            updatedMeta[key] = value
        }

        logger.log(level: level, message(), label: label, meta: updatedMeta, file: file, function: function, line: line)
    }
}
