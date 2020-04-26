//
//  RemoteLogger.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Logger that sends log messages to remote storage.
/// It uses `RemoteLoggerBuffering` for storing log records before sending and `RemoteLoggerTransport` to send them.
/// After initialization `RemoteLogger` will try to authorize transport
/// and at success it will send records collected during previous request with `RemoteLoggerTransport.send` method.
/// If transport returns errors from `authorize` request `RemoteLogger` will be trying to reauthorize every `reAuthorizationInterval`.
/// `RemoteLogger` is sending only one `send` request per time, next batch will be send only after current batch is finished.
/// If during sending batch of record `RemoteLogger` received `notAuthorized` error `RemoteLogger` will try to reauthorize transport.
public class RemoteLogger: Logger {
    private let workingQueue = DispatchQueue(label: "Robologs.RemoteLogger")
    private let buffer: RemoteLoggerBuffer
    private let transport: RemoteLoggerTransport

    /// Create new instance of remote logger.
    /// - Parameter endpoint: Address of remote Robologs endpoint.
    public convenience init(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = DefaultChallengePolicy(),
        applicationInfo: ApplicationInfo
    ) {
        self.init(
            transport: ProtoHttpRemoteLoggerTransport(
                endpoint: endpoint,
                secret: secret,
                challengePolicy: challengePolicy,
                applicationInfo: applicationInfo,
                logger: PrintLogger(onlyTime: true)
            ),
            buffer: InMemoryRemoteLoggerBuffer()
        )
    }

    /// Creates mocked RemoteLogger that uses offline mock transport.
    /// This is usable mostly for mocking or this SDK development.
    /// - Parameter mockLogger: Logger using for mock transport output.
    public convenience init(mockingToLogger mockLogger: Logger) {
        self.init(
            transport: MockRemoteLoggerTransport(logger: mockLogger),
            buffer: InMemoryRemoteLoggerBuffer()
        )
    }

    /// Creates new instance of remote logger with custom transport and buffering.
    /// - Parameters:
    ///   - buffering: Buffering policy used to keep log records while transport is not available.
    ///   - transport: Transport describing how and where to log message will be sent.
    init(transport: RemoteLoggerTransport, buffer: RemoteLoggerBuffer) {
        self.buffer = buffer
        self.transport = transport
    }

    // TODO: Persist position
    private var position: UInt64 = 0
    private var nextPosition: UInt64 {
        if position == UInt64.max {
            position = 0
        } else {
            position += 1
        }
        return position
    }

    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]?,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let timestamp = Date().timeIntervalSince1970
        let message = message()
        let meta = meta()
        workingQueue.async {
            let record = LogRecord(
                position: self.nextPosition,
                timestamp: timestamp,
                level: level,
                message: message,
                label: label,
                meta: meta,
                file: file,
                function: function,
                line: line
            )

            self.buffer.append(record: record)
            if self.canSend {
                self.sendIfNeeded()
            }
        }
    }

    public func startLive(completion: @escaping (_ resultWithCode: Result<String, Error>) -> Void) {
        transport.startLive { liveResult in
            switch liveResult {
                case .success:
                    self.transport.liveConnectionCode { codeResult in
                        switch codeResult {
                            case .success(let code):
                                completion(.success(code))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    public func stopLive(completion: @escaping () -> Void) {
        transport.stopLive { _ in
            completion()
        }
    }

    private func sendIfNeeded() {
        guard buffer.haveBufferedData else { return }

        canSend = false
        buffer.retrieve { records, completion in
            guard !records.isEmpty else {
                self.canSend = true
                return completion(true)
            }

            self.send(records: records) { finished in
                self.canSend = true
                completion(finished)
            }
        }
    }

    private var canSend: Bool = true

    private func send(records: [LogRecord], completion: @escaping (Bool) -> Void) {
        transport.sendLive(records: records) { result in
            switch result {
                case .success:
                    completion(true)
                    self.sendIfNeeded()
                case .failure:
                    completion(false)
                    self.sendIfNeeded()
            }
        }
    }
}
