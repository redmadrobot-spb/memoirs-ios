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
    public enum LiveMode {
        case disabled
        case enabled(bufferSize: Int = 1000)
    }
    public enum ArchiveMode {
        case disabled
        case enabled(cacheDirectoryUrl: URL, batchSize: Int)
    }

    public enum Error: Swift.Error {
        case transportIsNotConfigured
        case transport(RemoteLoggerTransportError?)
    }

    public let isSensitive: Bool

    private let loggerToInject: Logger
    private let applicationInfo: ApplicationInfo
    private let workingQueue = DispatchQueue(label: "com.redmadrobot.robologs.RemoteLogger")
    private var sendBuffers: [RemoteLoggerBuffer]
    private var transport: RemoteLoggerTransport?
    private var logger: LabeledLogger!

    private var bonjourServer: BonjourServer?

    public init(
        applicationInfo: ApplicationInfo,
        isSensitive: Bool,
        publishServerInLocalWeb: Bool,
        liveMode: LiveMode,
        archiveMode: ArchiveMode = .disabled,
        logger: Logger = NullLogger()
    ) {
        let liveBuffer: RemoteLoggerBuffer
        switch liveMode {
            case .disabled:
                liveBuffer = NullRemoteLoggerBuffer()
            case .enabled(let bufferSize):
                liveBuffer = InMemoryRemoteLoggerBuffer(maxRecordsCount: bufferSize)
        }
        let archiveBuffer: RemoteLoggerBuffer
        switch archiveMode {
            case .disabled:
                archiveBuffer = NullRemoteLoggerBuffer()
            case .enabled(let cacheDirectoryUrl, let batchSize):
                archiveBuffer = PersistingLoggingBuffer(cachePath: cacheDirectoryUrl, batchSize: batchSize, logger: logger)
        }
        sendBuffers = [ liveBuffer, archiveBuffer ]

        self.applicationInfo = applicationInfo
        self.loggerToInject = logger
        self.isSensitive = isSensitive
        self.logger = LabeledLogger(object: self, logger: logger)

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
                logger: self.loggerToInject
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
            let record = CachedLogMessage(
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

            self.sendBuffers.forEach { $0.add(record: record) }
            self.sendLogMessages()
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

    // MARK: - Sending logs to live stream

    private var buffersSendingInProgress: Int = 0

    private func sendLogMessages() {
        guard buffersSendingInProgress == 0, let transport = self.transport, transport.isConnected else { return }

        buffersSendingInProgress += 1
        defer {
            buffersSendingInProgress -= 1
        }

        for buffer in sendBuffers {
            guard buffer.kind != .unknown else { continue }

            buffersSendingInProgress += 1

            guard let (batchId, batch) = buffer.getNextBatch() else {
                buffersSendingInProgress -= 1
                return
            }
            guard !batch.isEmpty else {
                buffer.removeBatch(id: batchId)
                buffersSendingInProgress -= 1
                return
            }

            self.logger.debug("Sending \(buffer.kind) \(batch.count) log messages to \(buffer.name)")
            let sendCompletion: (Result<Void, RemoteLoggerTransportError>) -> Void = { result in
                switch result {
                    case .success:
                        self.logger.debug("Successfully sent \(buffer.kind) \(batch.count) log messages to \(buffer.name)")
                        buffer.removeBatch(id: batchId)
                    case .failure(let error):
                        self.logger.error(error, message: "Failure sending \(buffer.kind) \(batch.count) log messages to \(buffer.name)")
                }
                self.buffersSendingInProgress -= 1
                self.sendLogMessages()
            }

            switch buffer.kind {
                case .live:
                    transport.sendLive(records: batch, completion: sendCompletion)
                case .archive:
                    transport.sendArchive(records: batch, completion: sendCompletion)
                case .unknown:
                    break
            }
        }
    }
}
