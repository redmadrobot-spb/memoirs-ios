//
//  RemoteLoggerService.swift
//  Example
//
//  Created by Roman Mazeev on 28.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Robologs
import Foundation

class RemoteLoggerService {
    enum RemoteLoggerType {
        case mock
        case remote(url: URL, secret: String)
    }

    private static var sharedRemoteLoggerService: RemoteLoggerService = {
        RemoteLoggerService()
    }()

    private(set) var logger: Logger
    private(set) var type: RemoteLoggerType
    private(set) var connectionCodeSubscription: Subscription?
    var onConnectionCodeChanged: ((String?) -> Void)?
    var onError: ((Error?) -> Void)?
    var lastConnectionCode: String?

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
                let remoteLogger = RemoteLogger(endpoint: url, secret: secret)
                self.connectionCodeSubscription = remoteLogger.subscribeLiveConnectionCode { connectionCode in
                    DispatchQueue.main.async {
                        self.onConnectionCodeChanged?(connectionCode)
                        self.lastConnectionCode = connectionCode
                    }
                }
                logger = remoteLogger
        }
    }
}
