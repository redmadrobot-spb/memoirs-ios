//
// RemoteLogger
// Robologs
//
// Created by Alex Babaev on 27 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

public class RemoteLogger: Logger {
    public enum LiveMode {
        case disabled
        case enabled(allowAutoConnectViaBonjour: Bool, bufferSize: Int = 1000)
    }
    public enum ArchiveMode {
        case disabled
        case enabled(cacheDirectoryUrl: URL, maxBatchSize: Int, maxBatchesCount: Int)
    }

    private var liveLogger: LiveRemoteLogger?
    private var archiveLogger: ArchiveRemoteLogger?
    private var isSensitive: Bool

    public init(applicationInfo: ApplicationInfo, isSensitive: Bool, live: LiveMode, archive: ArchiveMode, logger: Logger) {
        self.isSensitive = isSensitive

        switch live {
            case .disabled:
                liveLogger = nil
            case .enabled(let allowAutoConnectViaBonjour, let bufferSize):
                liveLogger = LiveRemoteLogger(
                    applicationInfo: applicationInfo,
                    isSensitive: isSensitive,
                    publishServerInLocalWeb: allowAutoConnectViaBonjour,
                    bufferSize: bufferSize,
                    logger: logger
                )
        }

        switch archive {
            case .disabled:
                archiveLogger = nil
            case .enabled(let cacheDirectoryUrl, let maxBatchSize, let maxBatchesCount):
                archiveLogger = ArchiveRemoteLogger(
                    applicationInfo: applicationInfo,
                    isSensitive: isSensitive,
                    cacheDirectoryUrl: cacheDirectoryUrl,
                    maxBatchSize: maxBatchSize,
                    maxBatchesCount: maxBatchesCount,
                    logger: logger
                )
        }
    }

    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]?,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let timestamp = Date().timeIntervalSince1970
        let position = nextPosition
        let cachedMessage = CachedLogMessage(
            position: position,
            timestamp: timestamp,
            level: level,
            message: message().string(isSensitive: isSensitive),
            label: label,
            meta: meta()?.mapValues { $0.string(isSensitive: isSensitive) },
            file: isSensitive ? "" : file,
            function: isSensitive ? "" : function,
            line: isSensitive ? 0 : line
        )

        liveLogger?.log(message: cachedMessage)
        archiveLogger?.log(message: cachedMessage)
    }

    public func configure(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = ValidateSSLChallengePolicy(),
        completion: @escaping () -> Void
    ) {
        liveLogger?.configure(endpoint: endpoint, secret: secret, challengePolicy: challengePolicy, completion: completion)
        archiveLogger?.configure(endpoint: endpoint, secret: secret, challengePolicy: challengePolicy)
    }

    public func startLive(completion: @escaping (_ resultWithCode: Result<String, RemoteLoggerError>) -> Void) {
        liveLogger?.startLive(completion: completion)
    }

    public func stopLive(completion: @escaping (Result<Void, RemoteLoggerError>) -> Void) {
        liveLogger?.stopLive(completion: completion)
    }

    public func getCode(completion: @escaping (_ resultWithCode: Result<String, RemoteLoggerError>) -> Void) {
        liveLogger?.getCode(completion: completion)
    }

    // MARK: - Log Position (part of identifier)

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

    private let positionIncrementQueue: DispatchQueue = .init(label: "RemoteLogger.positionIncrementingQueue")
    private var nextPosition: UInt64 {
        positionIncrementQueue.sync {
            if position == UInt64.max {
                position = 0
            } else {
                position += 1
            }
            return position
        }
    }
}
