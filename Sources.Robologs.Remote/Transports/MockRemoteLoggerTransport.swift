//
// MockRemoteLoggerTransport
// RobologsTest
//
// Created by Vladislav Maltsev on 04.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs

/// Mock remote logger transport. Emulate behaviour of transport for offline testing.
public class MockRemoteLoggerTransport: RemoteLoggerTransport {
    let isConnected: Bool = true
    private let logger: LabeledLogger

    /// Create instance of MockRemoteLoggerTransport.
    /// - Parameter logger: Logger used to log events in mock logger.
    public init(logger: Logger) {
        self.logger = LabeledLogger(label: "Robologs.MockRemoteLogger", logger: logger)
    }

    func liveConnectionCode(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void) {
        completion(.success("M0CKC0D3"))
    }

    func invalidateConnectionCode(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        completion(.success(Void()))
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

    func sendLive(records: [CachedLogMessage], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard isLiveActive else { return completion(.failure(.liveIsInactive)) }

        logger.debug("Sending live \(safe: records.count) records...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.logger.debug("Sent live \(safe: records.count) records.")
            self.logger.verbose("\(records)")
            completion(.success(()))
        }
    }

    func sendArchive(records: [CachedLogMessage], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        logger.debug("Sending archive \(safe: records.count) records...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.logger.debug("Sent archive \(safe: records.count) records.")
            self.logger.verbose("\(records)")
            completion(.success(()))
        }
    }
}
