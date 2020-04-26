//
//  RemoteLogger.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Logger that sends log messages to remote storage.
public class RemoteLogger: Logger {
    public let isSensitive: Bool

    private let workingQueue = DispatchQueue(label: "com.redmadrobot.robologs.RemoteLogger")
    private let buffer: RemoteLoggerBuffer
    private let transport: RemoteLoggerTransport

    public init(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = DefaultChallengePolicy(),
        applicationInfo: ApplicationInfo,
        isSensitive: Bool,
        logger: Logger
    ) {
        buffer = InMemoryRemoteLoggerBuffer()
        transport = ProtoHttpRemoteLoggerTransport(
            endpoint: endpoint,
            secret: secret,
            challengePolicy: challengePolicy,
            applicationInfo: applicationInfo,
            logger: logger
        )
        self.isSensitive = isSensitive
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
                message: message.string(isSensitive: self.isSensitive),
                label: label,
                meta: meta?.mapValues { $0.string(isSensitive: self.isSensitive) },
                file: self.isSensitive ? "" : file,
                function: self.isSensitive ? "" : function,
                line: self.isSensitive ? 0 : line
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
