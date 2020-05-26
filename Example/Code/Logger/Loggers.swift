//
// Loggers
// Robologs
//
// Created by Alex Babaev on 27 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Robologs
import Foundation

class Loggers {
    static let instance: Loggers = .init()

    #if DEBUG
    private static let publishServerInLocalWeb: Bool = true
    #else
    private static let publishServerInLocalWeb: Bool = false
    #endif

    private lazy var cacheDirectoryUrl: URL = {
        Storage.documentsDirectory.appendingPathComponent("archiveLogsCache")
    }()

    private let bufferLogger: BufferLogger = BufferLogger()
    private lazy var remoteLogger: RemoteLogger = RemoteLogger(
        applicationInfo: UIKitApplicationInfo.current,
        isSensitive: false,
        publishServerInLocalWeb: Loggers.publishServerInLocalWeb,
        liveMode: .enabled(bufferSize: 1000),
        archiveMode: .enabled(cacheDirectoryUrl: cacheDirectoryUrl, batchSize: 100),
        logger: PrintLogger(onlyTime: true)
    )

    private(set) lazy var logger = InfoGatheringLogger(
        meta: [:],
        logger: MultiplexingLogger(
            loggers: [ self.bufferLogger, remoteLogger ]
        )
    )

    private(set) var liveConnectionId: String?

    var bufferLoggerHandler: ([String]) -> Void {
        get { bufferLogger.changeHandler }
        set { bufferLogger.changeHandler = newValue }
    }

    func disconnect(completion: @escaping () -> Void) {
        remoteLogger.stopLive { _ in
            completion()
        }
    }

    func connectAndGetCode(
        url: URL,
        secret: String,
        disableSSLCheck: Bool,
        completion: @escaping (Result<String, RemoteLogger.Error>
    ) -> Void) {
        let challengePolicy: AuthenticationChallengePolicy = disableSSLCheck
            ? AllowSelfSignedChallengePolicy()
            : DefaultChallengePolicy()
        remoteLogger.configure(endpoint: url, secret: secret, challengePolicy: challengePolicy) {
            self.remoteLogger.startLive(completion: completion)
        }
    }

    func getCode(completion: @escaping (Result<String, RemoteLogger.Error>) -> Void) {
        remoteLogger.getCode(completion: completion)
    }
}
