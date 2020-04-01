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

    private init() {
        logger = RemoteLogger(
            buffering: InMemoryBuffering(),
            transport: MockRemoteLoggerTransport(logger: PrintLogger())
        )

        type = .mock
    }

    class var shared: RemoteLoggerService { sharedRemoteLoggerService }

    func configureRemoteLogger(with type: RemoteLoggerType) {
        self.type = type
        switch type {
            case .mock:
                logger = RemoteLogger(
                    buffering: InMemoryBuffering(),
                    transport: MockRemoteLoggerTransport(logger: PrintLogger())
            )
            case .remote(let url, let secret):
                let transport = ProtoHttpRemoteLoggerTransport(endpoint: url, secret: secret)

                transport.authorize { result in
                    switch result {
                        case .failure(let error):
                            self.onError?(error)
                            self.configureRemoteLogger(with: .mock)
                        case .success:
                            self.connectionCodeSubscription = transport.subscribeLiveConnectionCode { connectionCode in
                                DispatchQueue.main.async {
                                    self.onConnectionCodeChanged?(connectionCode)
                                }
                            }
                    }
                }
                logger = RemoteLogger(buffering: InMemoryBuffering(), transport: transport)
        }
    }
}
