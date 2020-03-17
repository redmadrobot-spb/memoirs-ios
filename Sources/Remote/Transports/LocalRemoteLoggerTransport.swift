//
//  LocalRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

/// Mock remote logger transport. Simply redirects log records to specified logger (for example PrintLogger).
public class LocalRemoteLoggerTransport: RemoteLoggerTransport {
    private let localLogger: Logger

    public init(localLogger: Logger) {
        self.localLogger = localLogger
    }

    public let isAvailable = true

    public func send(_ records: [LogRecord], completion: (Result<Void, Error>) -> Void) {
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
