//
//  MockRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// Mock remote logger transport. Simply redirects log records to specified logger (for example PrintLogger).
class MockRemoteLoggerTransport: RemoteLoggerTransport {
    private let localLogger: LabeledLoggerAdapter
    private var isLoggedIn: Bool = false
    private var sendsBeforeLogOut: Int = 0

    init(localLogger: Logger) {
        self.localLogger = LabeledLoggerAdapter(label: "MockRemoteLogger", adaptee: localLogger)
    }

    private(set) var isReadyToSend = true

    func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        localLogger.info(message: "Authorize")
        self.isReadyToSend = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isReadyToSend = true
            self.localLogger.info(message: "Authorized")
            self.isLoggedIn = true
            self.sendsBeforeLogOut = 8
            completion(.success(()))
        }
    }

    func send(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard isLoggedIn else { return completion(.failure(.notAuthorized)) }

        self.isReadyToSend = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.sendsBeforeLogOut > 0 {
                self.logRecords(records)
                completion(.success(()))
            } else {
                self.isLoggedIn = false
                completion(.failure(.notAuthorized))
            }
            self.isReadyToSend = true
        }
    }

    private func logRecords(_ records: [LogRecord]) {
        localLogger.info(message: "Log \(public: records.count) records")
    }
}
