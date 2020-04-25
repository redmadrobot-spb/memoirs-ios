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

    private(set) var logger: RemoteLogger
    private(set) var type: RemoteLoggerType

    private init() {
        logger = RemoteLogger(mockingToLogger: PrintLogger())
        type = .mock
    }

    class var shared: RemoteLoggerService { sharedRemoteLoggerService }

    func configureRemoteLogger(with type: RemoteLoggerType) {
        self.type = type
        switch type {
            case .mock:
                logger = RemoteLogger(mockingToLogger: PrintLogger())
            case .remote(let url, let secret):
                logger = RemoteLogger(
                    endpoint: url,
                    secret: secret,
                    challengePolicy: AllowSelfSignedChallengePolicy(),
                    applicationInfo: UIKitApplicationInfo.current
                )
        }
    }
}
