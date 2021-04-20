//
// RemoteLoggingTransport
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public enum RemoteLoggerTransportError: Error {
    /// Transport was failed to authenticate or authentication is expired.
    case notAuthorized
    case methodIsAbsent
    case network(Error?)
    case http(code: Int, Error?)
    case serialization(Error?)

    case liveIsInactive
}

protocol RemoteLoggerTransport {
    var isConnected: Bool { get }

    func liveConnectionCode(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void)
    func invalidateConnectionCode(_ completion: @escaping (RemoteLoggerTransportError?) -> Void)

    func startLive(_ completion: @escaping (RemoteLoggerTransportError?) -> Void)
    func stopLive(_ completion: @escaping (RemoteLoggerTransportError?) -> Void)

    func sendLive(records: [CachedLogMessage], completion: @escaping (RemoteLoggerTransportError?) -> Void)
    func sendArchive(records: [CachedLogMessage], completion: @escaping (RemoteLoggerTransportError?) -> Void)
}
