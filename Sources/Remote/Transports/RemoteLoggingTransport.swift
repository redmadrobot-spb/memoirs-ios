//
// RemoteLoggingTransport
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

enum RemoteLoggerTransportError: Error {
    /// Transport was failed to authenticate or authentication is expired.
    case notAuthorized
    case methodIsAbsent
    case network(Error?)
    case http(code: Int, Error?)
    case serialization(Error?)

    case liveIsInactive
}

protocol RemoteLoggerTransport {
    func liveConnectionCode(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void)
    func startLive(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void)
    func stopLive(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void)

    func sendLive(records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void)
}
