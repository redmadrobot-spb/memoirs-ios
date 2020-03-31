//
//  MockRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Mock remote logger transport. Simply redirects log records to specified logger (for example PrintLogger).
public class MockRemoteLoggerTransport: RemoteLoggerTransport {
    private let logger: LabeledLoggerAdapter
    private var sendsBeforeLogOut: Int = 0

    /// Create instance of MockRemoteLoggerTransport.
    /// - Parameter logger: Logger used to log events in mock logger.
    public init(logger: Logger) {
        self.logger = LabeledLoggerAdapter(label: "Robologs.MockRemoteLogger", adaptee: logger)
    }

    private(set) public var isAuthorized = true

    public func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        logger.info(message: "Authorize")
        isAuthorized = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.logger.info(message: "Authorized")
            self.isAuthorized = true
            self.sendsBeforeLogOut = 8
            completion(.success(()))
        }
    }

    public func send(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard isAuthorized else { return completion(.failure(.notAuthorized)) }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.sendsBeforeLogOut > 0 {
                self.sendsBeforeLogOut -= 1
                self.logRecords(records)
                completion(.success(()))
            } else {
                self.isAuthorized = false
                completion(.failure(.notAuthorized))
            }
        }
    }

    private func logRecords(_ records: [LogRecord]) {
        logger.info(message: "Log \(public: records.count) records")
    }
}
