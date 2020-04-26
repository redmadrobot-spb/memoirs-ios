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

    /// Create instance of MockRemoteLoggerTransport.
    /// - Parameter logger: Logger used to log events in mock logger.
    public init(logger: Logger) {
        self.logger = LabeledLogger(label: "Robologs.MockRemoteLogger", logger: logger)
    }

    func liveConnectionCode(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void) {
        completion(.success("M0CKC0D3"))
    }

    private var isLiveActive: Bool = false

    func startLive(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        if isLiveActive {
            logger.warning("Live is already active")
        }

        isLiveActive = true
    }

    func stopLive(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        if !isLiveActive {
            logger.warning("Live is already inactive")
        }

        isLiveActive = false
    }

    func sendLive(records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard isLiveActive else { return completion(.failure(.liveIsInactive)) }

        logger.debug("Sending \(public: records.count) records...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.logger.debug("Sent \(public: records.count) records.")
            self.logger.verbose("\(records)")
            completion(.success(()))
        }
    }
}
