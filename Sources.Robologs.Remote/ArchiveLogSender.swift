//
// ArchiveRemoteLogger
// RobologsTest
//
// Created by Alex Babaev on 27.05.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs

public class ArchiveLogSender: LogSender {
    public let isSensitive: Bool

    private let loggerToInject: Logger
    private let applicationInfo: ApplicationInfo
    private let workingQueue = DispatchQueue(label: "com.redmadrobot.robologs.RemoteLogger")
    private var sendBuffer: RemoteLoggerBuffer
    private var transport: RemoteLoggerTransport?
    private var logger: LabeledLogger!

    public init(
        applicationInfo: ApplicationInfo,
        isSensitive: Bool,
        cacheDirectoryUrl: URL,
        maxBatchSize: Int,
        maxBatchesCount: Int,
        logger: Logger = NullLogger()
    ) {
        sendBuffer = PersistingLoggingBuffer(
            cachePath: cacheDirectoryUrl,
            maxBatchSize: maxBatchSize,
            maxBatchesCount: maxBatchesCount,
            logger: logger
        )

        loggerToInject = logger
        self.applicationInfo = applicationInfo
        self.isSensitive = isSensitive
        self.logger = LabeledLogger(object: self, logger: logger)
    }

    public func send(message: SerializedLogMessage) {
        workingQueue.async {
            self.sendBuffer.add(message: message)
            self.sendLogMessages()
        }
    }

    public func configure(endpoint: URL, secret: String, challengePolicy: AuthenticationChallengePolicy) {
        transport = ProtoHttpRemoteLoggerTransport(
            endpoint: endpoint,
            secret: secret,
            challengePolicy: challengePolicy,
            applicationInfo: applicationInfo,
            logger: loggerToInject
        )
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

        logger.debug("Sending archive \(batch.count) log messages")
        transport.sendArchive(records: batch) { error in
            switch error {
                case nil:
                    self.logger.debug("Successfully sent archive \(batch.count) log messages")
                    self.sendBuffer.removeBatch(id: batchId)
                case let error?:
                    self.logger.error(error, message: "Failure sending archive \(batch.count) log messages")
            }
            self.sendingInProgress = false
            self.sendLogMessages()
        }
    }
}
