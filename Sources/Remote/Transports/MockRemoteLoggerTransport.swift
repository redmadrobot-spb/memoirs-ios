//
//  MockRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

/// Mock remote logger transport. Simply redirects log records to specified logger (for example PrintLogger).
class MockRemoteLoggerTransport: RemoteLoggerTransport {
    private let localLogger: Logger

    init(localLogger: Logger) {
        self.localLogger = localLogger
    }

    let isReadyToSend = true

    func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        completion(.success(()))
    }

    func send(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        records.forEach { record in
            localLogger.log(
                level: record.level,
                label: record.label,
                message: { record.message },
                meta: { record.meta },
                file: record.file,
                function: record.function,
                line: record.line
            )
        }
        completion(.success(()))
    }
}
