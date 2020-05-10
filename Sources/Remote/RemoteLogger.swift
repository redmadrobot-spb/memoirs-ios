//
// RemoteLogger
// RobologsTest
//
// Created by Vladislav Maltsev on 04.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Logger that sends log messages to remote storage.
public class RemoteLogger: Logger {
    public enum Error: Swift.Error {
        case transportIsNotConfigured
        case transport(RemoteLoggerTransportError?)
    }

    public let isSensitive: Bool

    private let logger: Logger
    private let applicationInfo: ApplicationInfo
    private let workingQueue = DispatchQueue(label: "com.redmadrobot.robologs.RemoteLogger")
    private let buffer: RemoteLoggerBuffer
    private var transport: RemoteLoggerTransport?

    #if DEBUG
    private let bonjourServer: BonjourServer
    #endif

    public init(
        applicationInfo: ApplicationInfo,
        isSensitive: Bool,
        logger: Logger = NullLogger()
    ) {
        buffer = InMemoryRemoteLoggerBuffer()
        self.applicationInfo = applicationInfo
        self.logger = logger
        self.isSensitive = isSensitive

        #if DEBUG
        bonjourServer = BonjourServer(logger: logger)
        #endif
    }

    public func configure(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = DefaultChallengePolicy(),
        completion: @escaping () -> Void
    ) {
        #if DEBUG
        bonjourServer.stopPublishing()
        bonjourServer.publish(endpoint: endpoint.absoluteString, senderId: applicationInfo.deviceId)
        #endif
        let updateTransport = {
            self.transport = ProtoHttpRemoteLoggerTransport(
                endpoint: endpoint,
                secret: secret,
                challengePolicy: challengePolicy,
                applicationInfo: self.applicationInfo,
                logger: self.logger
            )
            completion()
        }

        if transport != nil {
            stopLive { _ in
                updateTransport()
            }
        } else {
            updateTransport()
        }
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
        guard let transport = transport else { return completion(.failure(.transportIsNotConfigured)) }

        transport.startLive { liveResult in
            switch liveResult {
                case .success:
                    transport.liveConnectionCode { codeResult in
                        switch codeResult {
                            case .success(let code):
                                completion(.success(code))
                            case .failure(let error):
                                completion(.failure(.transport(error)))
                        }
                    }
                case .failure(let error):
                    completion(.failure(.transport(error)))
            }
        }
    }

    public func stopLive(completion: @escaping (Result<Void, Error>) -> Void) {
        #if DEBUG
        bonjourServer.stopPublishing()
        #endif

        guard let transport = transport else { return completion(.failure(.transportIsNotConfigured)) }

        transport.invalidateConnectionCode { _ in
            transport.stopLive { _ in
                completion(.success(Void()))
            }
        }
    }

    public func getCode(completion: @escaping (_ resultWithCode: Result<String, Error>) -> Void) {
        guard let transport = transport else { return completion(.failure(.transportIsNotConfigured)) }

        transport.liveConnectionCode { result in
            switch result {
                case .success(let code):
                    completion(.success(code))
                case .failure(let error):
                    completion(.failure(.transport(error)))
            }
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

            self.send(records: records) { result in
                self.canSend = true
                completion((try? result.get()) != nil)
            }
        }
    }

    private var canSend: Bool = true

    private func send(records: [LogRecord], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let transport = transport else { return completion(.failure(.transportIsNotConfigured)) }

        transport.sendLive(records: records) { result in
            switch result {
                case .success:
                    completion(.success(Void()))
                    self.sendIfNeeded()
                case .failure(let error):
                    completion(.failure(.transport(error)))
                    self.sendIfNeeded()
            }
        }
    }
}
