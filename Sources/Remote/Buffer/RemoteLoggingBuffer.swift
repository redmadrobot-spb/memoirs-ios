//
// RemoteLoggingBuffer
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

/// Intermediate structure used in transport and buffering to store
/// log message parameters.
struct LogRecord {
    let position: UInt64
    let timestamp: TimeInterval
    let level: Level
    let message: LogString
    let label: String
    let meta: [String: LogString]?
    let file: String
    let function: String
    let line: UInt
}

/// Responsible for buffering log records while transport is not available.
protocol RemoteLoggerBuffer {
    /// Should return `true` if contains any not sent records.
    var haveBufferedData: Bool { get }

    /// Add record to the buffer. Remote logger should use this method
    /// to store log records while transport is not available.
    /// - Parameter record: Buffering record
    func append(record: LogRecord)

    /// Remote logger call this method to fetch buffered records when transport become available.
    /// `finished` callback should be called with `true` if retrieved records was sent successfully and
    /// then remove this records from buffering storage.
    /// - Parameter completion: Completion block in which remote logger should try to send buffered messages.
    func retrieve(_ completion: @escaping (_ records: [LogRecord], _ finished: @escaping (Bool) -> Void) -> Void)
}
