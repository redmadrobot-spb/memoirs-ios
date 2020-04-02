//
//  RemoteLogger.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Intermediate structure used in transport and buffering to store
/// log message parameters.
struct LogRecord {
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
protocol RemoteLoggerBuffering {
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

/// Errors that can happen in RemoteLoggerTransport
enum RemoteLoggerTransportError: Error {
    /// Transport was failed to authenficate or authentification is expired.
    case notAuthorized
    /// Network error occured.
    case network(Error)
    /// Serialization error occured.
    case serialization(Error)
}

/// Responsible for sending log records to remote logs storage.
protocol RemoteLoggerTransport {
    /// Should return `false` if transport is not authorized.
    var isAuthorized: Bool { get }

    /// Authorize transport.
    /// - Parameter completion: Completion called when transport authorized.
    func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void)

    /// Remote logger call this method to send log records to remote storage.
    /// - Parameters:
    ///   - records: Sending records
    ///   - completion: Completion called when transport finish sending.
    ///   If returned RemoteLoggerTransportError.notAuthorized logger should reauthorize transport.
    func send(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void)

    /// Subscribe to live connection code for this transport.
    /// - Parameter onChange: Callback calling right after subscription and every time code change.
    ///     Could be called from background queue.
    /// - Returns: Subscription token.
    ///     Store this token in object with same live time as objects
    ///     interested in code updates (for example some AboutViewController).
    ///     If this token is disposed `onChange` will not be called anymore.
    func subscribeLiveConnectionCode(_ onChange: @escaping (String?) -> Void) -> Subscription
}

/// Logger that sends log messages to remote storage.
/// It uses `RemoteLoggerBuffering` for storing log records before sending and `RemoteLoggerTransport` to send them.
/// At the receiving of first log record `RemoteLogger` will try to authorize transport
/// and at success it will send records collected during previous request with `RemoteLoggerTransport.send` method.
/// If transport returns errors from `authorize` request `RemoteLogger` will be trying to reauthorize every `reauthorizationInterval`.
/// `RemoteLogger` is sending only one `send` request per time, next batch will be send only after current batch is finished.
/// If during sending batch of record `RemoteLogger` received `notAuthorized` error `RemoteLogger` will try to reauthorize transport.
public class RemoteLogger: Logger {
    private let workingQueue = DispatchQueue(label: "Robologs.RemoteLogger")
    private let buffering: RemoteLoggerBuffering
    private let transport: RemoteLoggerTransport

    /// Create new instance of remote logger.
    /// - Parameter endpoint: Address of remote Robologs enpoint.
    public convenience init(endpoint: URL, secret: String) {
        self.init(
            transport: ProtoHttpRemoteLoggerTransport(endpoint: endpoint, secret: secret),
            buffering: InMemoryBuffering()
        )
    }

    /// Creates mocked RemoteLogger that uses offline mock transport.
    /// This is usable mostly for mocking or this SDK development.
    /// - Parameter mockLogger: Logger using for mock transport output.
    public convenience init(mockingToLogger mockLogger: Logger) {
        self.init(
            transport: MockRemoteLoggerTransport(logger: mockLogger),
            buffering: InMemoryBuffering()
        )
    }

    /// Creates new instance of remote logger with custom transport and buffering.
    /// - Parameters:
    ///   - buffering: Buffering policy used to keep log records while transport is not available.
    ///   - transport: Transport describing how and where to log message will be sent.
    init(transport: RemoteLoggerTransport, buffering: RemoteLoggerBuffering) {
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
        let timestamp = Date().timeIntervalSince1970
        let message = message()
        let meta = meta()
        workingQueue.async {
            let record = LogRecord(
                timestamp: timestamp,
                label: label,
                level: level,
                message: message,
                meta: meta,
                file: file,
                function: function,
                line: line
            )

            self.buffering.append(record: record)
            if self.canSend {
                self.sendIfNeeded()
            }
        }
    }

    /// Subscribe to live connection code.
    /// Display this code anywhere in your app, for example in About page.
    /// User can enter this code in Robologs web page to instantly see logs from current device.
    /// This code can change anytime so update it in UI at every `onChange` call.
    /// - Parameter onChange: Callback calling right after subscription and every time code change.
    ///     Could be called from background queue.
    /// - Returns: Subscription token.
    ///     Store this token in object with same live time as objects
    ///     interested in code updates (for example some AboutViewController).
    ///     If this token is disposed `onChange` will not be called anymore.
    public func subscribeLiveConnectionCode(_ onChange: @escaping (String?) -> Void) -> Subscription {
        transport.subscribeLiveConnectionCode(onChange)
    }

    private func sendIfNeeded() {
        guard buffering.haveBufferedData else { return }

        canSend = false
        buffering.retrieve { records, finish in
            guard !records.isEmpty else {
                self.canSend = true
                return finish(true)
            }

            self.send(records: records) { finished in
                self.canSend = true
                finish(finished)
            }
        }
    }

    private var canSend: Bool = true

    private func send(records: [LogRecord], finish: @escaping (Bool) -> Void) {
        transport.send(records) { result in
            switch result {
                case .success:
                    finish(true)
                    self.sendIfNeeded()
                case .failure(.notAuthorized):
                    self.authorize {
                        self.send(records: records, finish: finish)
                    }
                case .failure:
                    finish(false)
                    self.sendIfNeeded()
            }
        }
    }

    private let reauthorizationInterval: TimeInterval = 10

    private func authorize(completion: @escaping () -> Void) {
        transport.authorize { result in
            switch result {
                case .success:
                    completion()
                case .failure:
                    self.workingQueue.asyncAfter(deadline: .now() + self.reauthorizationInterval) {
                        self.authorize(completion: completion)
                    }
            }
        }
    }
}
