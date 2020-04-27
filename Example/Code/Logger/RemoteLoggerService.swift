//
//  RemoteLoggerService.swift
//  Example
//
//  Created by Roman Mazeev on 28.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

class RemoteLoggerService {
    enum RemoteLoggerType {
        case mock
        case remote(url: URL, secret: String)
    }

    private static var sharedRemoteLoggerService: RemoteLoggerService = {
        RemoteLoggerService()
    }()

    private(set) var logger: MultiplexingLogger = MultiplexingLogger(loggers: [])
    private(set) var type: RemoteLoggerType = .mock
    private var remoteLogger: RemoteLogger?

    private init() {
        configureRemoteLogger(with: .mock)
    }

    class var shared: RemoteLoggerService { sharedRemoteLoggerService }

    func configureRemoteLogger(with type: RemoteLoggerType) {
        self.type = type
        switch type {
            case .mock:
                logger.loggers = []
//                logger.loggers = [ PrintLogger() ]
                remoteLogger?.stopLive {}
                remoteLogger = nil
            case .remote(let url, let secret):
                let remoteLogger = RemoteLogger(
                    endpoint: url,
                    secret: secret,
                    challengePolicy: AllowSelfSignedChallengePolicy(),
                    applicationInfo: UIKitApplicationInfo.current,
                    isSensitive: false,
                    logger: PrintLogger(onlyTime: true)
                )
                logger.loggers = [
                    remoteLogger
                ]
                self.remoteLogger = remoteLogger
        }
    }

    func liveCode(completion: @escaping (Result<String, Error>) -> Void) {
        remoteLogger?.startLive(completion: completion)
    }
}
