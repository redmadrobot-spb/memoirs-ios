//
//  RemoteLogger.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Intermidiate structure used in transport and buffering to store
/// log message parameters.
public struct LogRecord {
    let timestamp: TimeInterval
    let label: String
    let level: Level
    let message: LogString
    let meta: [String: LogString]?
    let file: String
    let function: String
    let line: UInt
}

/// Responsible for buffering log records while transport is not available.
public protocol RemoteLoggerBuffering {
    /// Should return `true` if contains any not sended records.
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

/// Responsible for sending log records to remote logs storage.
public protocol RemoteLoggerTransport {
    /// Should return `false` if transport is not available.
    var isAvailable: Bool { get }

    /// Remote logger call this method to send log records to remote storage.
    /// - Parameters:
    ///   - records: Sending records
    ///   - completion: Completion called when transport finish sending.
    func send(_ records: [LogRecord], completion: @escaping (Result<Void, Error>) -> Void)

    /// Switch transport behaviour to live mode
    /// - Parameter liveSessionToken: Token received from live session page.
    func startLiveSession(_ liveSessionToken: String)

    /// Switch logger back to default mode.
    func finishLiveSession()
}

/// Logger that sends log messages to remote storage.
public class RemoteLogger: Logger {
    private let buffering: RemoteLoggerBuffering
    private let transport: RemoteLoggerTransport

    /// Creates new instance of remote logger.
    /// - Parameters:
    ///   - buffering: Buffering policy used to keep log records while transport is not available.
    ///   - transport: Transport describing how and where to log message will be sent.
    public init(buffering: RemoteLoggerBuffering, transport: RemoteLoggerTransport) {
        self.buffering = buffering
        self.transport = transport
    }

    public func log(
        level: Level,
        label: String,
        message: @autoclosure () -> LogString,
        meta: @autoclosure () -> [String: LogString]?,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let record = LogRecord(
            timestamp: Date().timeIntervalSince1970,
            label: label,
            level: level,
            message: message(),
            meta: meta(),
            file: file,
            function: function,
            line: line
        )

        if transport.isAvailable {
            buffering.retrieve { records, finish in
                self.transport.send(records + [ record ]) { result in
                    switch result {
                        case .success:
                            finish(true)
                        case .failure:
                            self.buffering.append(record: record)
                            finish(false)
                    }
                }
            }
        } else {
            buffering.append(record: record)
        }
    }

    /// Switch logger to live mode.
    /// - Parameter liveSessionToken: Token received from live session page.
    public func startLiveSession(_ liveSessionToken: String) {
        transport.startLiveSession(liveSessionToken)
    }

    /// Switch logger back to default mode.
    public func finishLiveSession() {
        transport.finishLiveSession()
    }
}
