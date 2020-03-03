//
//  LocalRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

class LocalRemoteLoggerTransport: RemoteLoggerTransport {
    private let localLogger: Logger

    init(localLogger: Logger) {
        self.localLogger = localLogger
    }

    var isAvailable: Bool {
        true
    }

    func send(_ records: [LogRecord], completion: (Result<Void, Error>) -> Void) {
        records.forEach { record in
            localLogger.log(
                level: record.level,
                label: record.label,
                message: record.message,
                meta: record.meta
            )
        }
        completion(.success(()))
    }
}
