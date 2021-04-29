//
// LiveRemoteLogger
// RobologsTest
//
// Created by Vladislav Maltsev on 04.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs

public class LiveLogSender: LogSender {
    public let isSensitive: Bool

    private let loggerToInject: Logger
    private let applicationInfo: ApplicationInfo
    private let workingQueue = DispatchQueue(label: "com.redmadrobot.robologs.RemoteLogger")
    private var sendBuffer: RemoteLoggerBuffer
    private var transport: RemoteLoggerTransport?
    private var logger: LabeledLogger!

    public init(applicationInfo: ApplicationInfo, isSensitive: Bool, bufferSize: Int = 1000, logger: Logger = NullLogger()) {
        sendBuffer = InMemoryRemoteLoggerBuffer(maxRecordsCount: bufferSize)
        loggerToInject = logger
        self.applicationInfo = applicationInfo
        self.isSensitive = isSensitive
        self.logger = LabeledLogger(object: self, logger: logger)
    }

    public func send(senderId: String, message: SerializedLogMessage) {
        workingQueue.async {
            self.sendBuffer.add(message: message)
            self.sendLogMessages()
        }
    }

    public func configure(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = ValidateSSLChallengePolicy(),
        completion: @escaping () -> Void
    ) {
        let updateTransport = {
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

    public func startLive(completion: @escaping (_ resultWithCode: Result<String, RemoteLoggerError>) -> Void) {
        guard let transport = transport else { return completion(.failure(.transportIsNotConfigured)) }

        transport.startLive { liveResult in
            switch liveResult {
                case nil:
                    transport.liveConnectionCode { codeResult in
                        switch codeResult {
                            case .success(let code):
                                completion(.success(code))
                            case .failure(let error):
                                completion(.failure(.transport(error)))
                        }
                    }
                case let error?:
                    completion(.failure(.transport(error)))
            }
        }
    }

    public func stopLive(completion: @escaping (Result<Void, RemoteLoggerError>) -> Void) {
        guard let transport = transport else { return completion(.failure(.transportIsNotConfigured)) }

        transport.invalidateConnectionCode { _ in
            transport.stopLive { _ in
                completion(.success(Void()))
            }
        }
    }

    public func getCode(completion: @escaping (_ resultWithCode: Result<String, RemoteLoggerError>) -> Void) {
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

    // MARK: - Sending logs from buffers to the backend

    private var sendingInProgress: Bool = false

    private func sendLogMessages() {
        guard !sendingInProgress, let transport = transport, transport.isConnected else { return }

        sendingInProgress = true

        guard let (batchId, batch) = sendBuffer.getNextBatch() else {
            sendingInProgress = false
            return
        }
        guard !batch.isEmpty else {
            sendBuffer.removeBatch(id: batchId)
            sendingInProgress = false
            return
        }

        logger.debug("Sending live \(batch.count) log messages")
        transport.sendLive(records: batch) { result in
            switch result {
                case nil:
                    self.logger.debug("Successfully sent live \(batch.count) log messages")
                    self.sendBuffer.removeBatch(id: batchId)
                case let error?:
                    self.logger.error(error, message: "Failure sending live \(batch.count) log messages")
            }
            self.sendingInProgress = false
            self.sendLogMessages()
        }
    }
}
