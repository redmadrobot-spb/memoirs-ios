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
    private let localLogger: LabeledLoggerAdapter
    private var sendsBeforeLogOut: Int = 0

    public init(localLogger: Logger) {
        self.localLogger = LabeledLoggerAdapter(label: "MockRemoteLogger", adaptee: localLogger)
    }

    private(set) public var isAuthorized = true

    public func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        localLogger.info(message: "Authorize")
        self.isAuthorized = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.localLogger.info(message: "Authorized")
            self.isAuthorized = true
            self.sendsBeforeLogOut = 8
            completion(.success(()))
        }
    }

    public func send(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard isAuthorized else { return completion(.failure(.notAuthorized)) }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.sendsBeforeLogOut > 0 {
                self.logRecords(records)
                completion(.success(()))
            } else {
                self.isAuthorized = false
                completion(.failure(.notAuthorized))
            }
        }
    }

    private func logRecords(_ records: [LogRecord]) {
        localLogger.info(message: "Log \(public: records.count) records")
    }
}
