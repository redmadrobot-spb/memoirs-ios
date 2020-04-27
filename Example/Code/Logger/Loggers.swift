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

    private let bufferLogger: BufferLogger = BufferLogger()
    private let remoteLogger: RemoteLogger = RemoteLogger(
        applicationInfo: UIKitApplicationInfo.current,
        isSensitive: false,
        logger: PrintLogger(onlyTime: true)
    )
    private(set) lazy var logger = MultiplexingLogger(loggers: [ self.bufferLogger, self.remoteLogger ])

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

    func connectAndGetCode(url: URL, secret: String, completion: @escaping (Result<String, RemoteLogger.Error>) -> Void) {
        remoteLogger.configure(endpoint: url, secret: secret) {
            self.remoteLogger.startLive(completion: completion)
        }
    }

    func getCode(completion: @escaping (Result<String, RemoteLogger.Error>) -> Void) {
        remoteLogger.getCode(completion: completion)
    }
}
