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
        case remote
    }

    private static var sharedRemoteLoggerService: RemoteLoggerService = {
        RemoteLoggerService()
    }()

    private(set) var logger: Logger
    private(set) var type: RemoteLoggerType

    private init() {
        logger = RemoteLogger(
            buffering: InMemoryBuffering(),
            transport: MockRemoteLoggerTransport(logger: PrintLogger())
        )

        type = .mock
    }

    class var shared: RemoteLoggerService { sharedRemoteLoggerService }

    func configureRemoteLogger(transport: RemoteLoggerTransport) {
        if transport is MockRemoteLoggerTransport {
            self.type = .mock
            let buffering = InMemoryBuffering()
            let remoteLogger = RemoteLogger(buffering: buffering, transport: transport)
            self.logger = remoteLogger
        } else if transport is ProtoHttpRemoteLoggerTransport {
            self.type = .remote
            let buffering = InMemoryBuffering()
            let remoteLogger = RemoteLogger(buffering: buffering, transport: transport)
            self.logger = remoteLogger
        }
    }
}
