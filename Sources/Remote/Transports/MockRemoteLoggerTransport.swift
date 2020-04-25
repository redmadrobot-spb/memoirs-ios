//
//  MockRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Mock remote logger transport. Emulate behaviour of transport for offline testing.
public class MockRemoteLoggerTransport: RemoteLoggerTransport {
    private let logger: LabeledLogger
    private var sendsBeforeLogOut = 0

    /// Create instance of MockRemoteLoggerTransport.
    /// - Parameter logger: Logger used to log events in mock logger.
    public init(logger: Logger) {
        self.logger = LabeledLogger(label: "Robologs.MockRemoteLogger", logger: logger)
    }

    private(set) public var isAuthorized = true

    func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        logger.info("Authorize.")
        isAuthorized = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.logger.info("Authorized.")
            self.isAuthorized = true
            self.sendsBeforeLogOut = 8
            completion(.success(()))
        }
    }

    func liveSend(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard isAuthorized else { return completion(.failure(.notAuthorized)) }

        logger.info("Send \(public: records.count) records.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.sendsBeforeLogOut > 0 {
                self.sendsBeforeLogOut -= 1
                self.logger.info("Sent \(public: records.count) records.")
                self.logger.verbose("\(records)")
                completion(.success(()))
            } else {
                self.logger.info("Logging out.")
                self.isAuthorized = false
                completion(.failure(.notAuthorized))
            }
        }
    }

    func subscribeLiveConnectionCode(_ onChange: @escaping (String?) -> Void) -> Subscription {
        onChange("M0CKC0D3")
        return Subscription {}
    }
}
