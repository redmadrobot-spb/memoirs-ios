//
// LiveRemoteLogger
// RobologsTest
//
// Created by Vladislav Maltsev on 04.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

class LiveRemoteLogger: Logger {
    public let isSensitive: Bool

    private let loggerToInject: Logger
    private let applicationInfo: ApplicationInfo
    private let workingQueue = DispatchQueue(label: "com.redmadrobot.robologs.RemoteLogger")
    private var sendBuffer: RemoteLoggerBuffer
    private var transport: RemoteLoggerTransport?
    private var logger: LabeledLogger!

    private var bonjourServer: BonjourServer?

    init(
        applicationInfo: ApplicationInfo,
        isSensitive: Bool,
        publishServerInLocalWeb: Bool,
        bufferSize: Int = 1000,
        logger: Logger = NullLogger()
    ) {
        sendBuffer = InMemoryRemoteLoggerBuffer(maxRecordsCount: bufferSize)
        self.applicationInfo = applicationInfo
        self.loggerToInject = logger
        self.isSensitive = isSensitive
        self.logger = LabeledLogger(object: self, logger: logger)

        if publishServerInLocalWeb {
            bonjourServer = BonjourServer(logger: logger)
        }
    }

    func configure(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = ValidateSSLChallengePolicy(),
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

    func log(message: CachedLogMessage) {
        workingQueue.async {
            self.sendBuffer.add(message: message)
            self.sendLogMessages()
        }
    }

    func startLive(completion: @escaping (_ resultWithCode: Result<String, RemoteLoggerError>) -> Void) {
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

    func stopLive(completion: @escaping (Result<Void, RemoteLoggerError>) -> Void) {
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

    func getCode(completion: @escaping (_ resultWithCode: Result<String, RemoteLoggerError>) -> Void) {
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
        guard !sendingInProgress, let transport = self.transport, transport.isConnected else { return }

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

        self.logger.debug("Sending live \(batch.count) log messages")
        transport.sendLive(records: batch) { result in
            switch result {
                case .success:
                    self.logger.debug("Successfully sent live \(batch.count) log messages")
                    self.sendBuffer.removeBatch(id: batchId)
                case .failure(let error):
                    self.logger.error(error, message: "Failure sending live \(batch.count) log messages")
            }
            self.sendingInProgress = false
            self.sendLogMessages()
        }
    }
}
