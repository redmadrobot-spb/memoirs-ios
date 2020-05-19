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

    private var bonjourServer: BonjourServer?

    public init(
        applicationInfo: ApplicationInfo,
        isSensitive: Bool,
        publishServerInLocalWeb: Bool,
        logger: Logger = NullLogger()
    ) {
        buffer = InMemoryRemoteLoggerBuffer()
        self.applicationInfo = applicationInfo
        self.logger = logger
        self.isSensitive = isSensitive

        if publishServerInLocalWeb {
            bonjourServer = BonjourServer(logger: logger)
        }
    }

    public func configure(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = DefaultChallengePolicy(),
        completion: @escaping () -> Void
    ) {
        let updateTransport = {
            if let bonjourServer = self.bonjourServer {
                bonjourServer.stopPublishing()
                bonjourServer.publish(endpoint: endpoint.absoluteString, senderId: self.applicationInfo.deviceId)
            }
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

    private let positionKey: String = "robologs.remoteLogger.position"
    private var cachedPosition: UInt64!
    private var position: UInt64 {
        get {
            if cachedPosition == nil {
                cachedPosition = UserDefaults.standard.object(forKey: positionKey) as? UInt64 ?? 0
            }

            return cachedPosition
        }
        set {
            cachedPosition = newValue
            UserDefaults.standard.set(cachedPosition, forKey: positionKey)
        }
    }
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
        if let bonjourServer = bonjourServer {
            bonjourServer.stopPublishing()
        }

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
        guard let transport = self.transport, transport.isConnected else { return }
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
