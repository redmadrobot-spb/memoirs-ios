//
// ProtoHttpRemoteLoggerTransport
// Robologs
//
// Created by Vladislav Maltsev on 05.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs
import SwiftProtobuf

extension Level {
    var protoBufLevel: LogMessage.Priority {
        switch self {
            case .critical:
                return .critical
            case .error:
                return .error
            case .warning:
                return .warn
            case .info:
                return .info
            case .debug:
                return .debug
            case .verbose:
                return .verbose
        }
    }
}

/// Remote logger transport that uses HTTP + Protobuf.
class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
    private let secret: String
    private var isLoading = false
    private let applicationInfo: ApplicationInfo
    private var logger: LabeledLogger!
    private let httpTransport: HttpTransport

    var isConnected: Bool { httpTransport.isAuthorized }

    /// Creates new instance of `ProtoHttpRemoteLoggerTransport`.
    /// - Parameter endpoint: URL to server endpoint supporting this kind of transport.
    /// - Parameter secret: Secret key received from Robologs admin panel.
    /// - Parameter challengePolicy: Policy determining how URLAuthenticationChallenge will be managed.
    ///      If you using self-signing certificate use `AllowSelfSignedChallengePolicy`
    init(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = ValidateSSLChallengePolicy(),
        applicationInfo: ApplicationInfo,
        logger: Logger
    ) {
        self.applicationInfo = applicationInfo
        self.secret = secret
        httpTransport = HttpTransport(endpoint: endpoint, challengePolicy: challengePolicy, logger: logger)
        httpTransport.authorizeHandler = authorize
        self.logger = LabeledLogger(object: self, logger: logger)
    }

    private var liveConnectionCode: String?

    private func authorize(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void) {
        let source = AuthRequest.with { request in
            request.secret = secret
            request.sender = AuthRequest.Sender.with { sender in
                sender.id = applicationInfo.deviceId
                sender.appID = applicationInfo.appId
                sender.appName = applicationInfo.appName ?? ""
                sender.appVersion = applicationInfo.appVersion ?? ""
                sender.appBuildVersion = applicationInfo.appBuild ?? ""
                sender.operationSystem = applicationInfo.operationSystem ?? ""
                sender.operationSystemVersion = applicationInfo.operationSystemVersion ?? ""
                sender.deviceModel = applicationInfo.deviceModel ?? ""
            }
        }

        httpTransport.request(
            path: "auth",
            needAuthorization: false,
            object: source
        ) { (result: Result<AuthResponse, RemoteLoggerTransportError>) in
            switch result {
                case .success(let response):
                    self.httpTransport.authToken = response.token
                    completion(.success(response.token))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func liveConnectionCode(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void) {
        httpTransport.request(path: "code") { (result: Result<LiveCodeResponse, RemoteLoggerTransportError>) in
            switch result {
                case .success(let response):
                    self.liveConnectionCode = response.code
                    completion(.success(response.code))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func invalidateConnectionCode(_ completion: @escaping (RemoteLoggerTransportError?) -> Void) {
        httpTransport.request(path: "code", method: "DELETE", completion: completion)
    }

    func startLive(_ completion: @escaping (RemoteLoggerTransportError?) -> Void) {
        httpTransport.request(path: "live/start", completion: completion)
    }

    func stopLive(_ completion: @escaping (RemoteLoggerTransportError?) -> Void) {
        httpTransport.request(path: "live/stop", completion: completion)
    }

    func sendLive(records: [SerializedLogMessage], completion: @escaping (RemoteLoggerTransportError?) -> Void) {
        httpTransport.request(path: "live/send", object: batch(from: records), completion: completion)
    }

    func sendArchive(records: [SerializedLogMessage], completion: @escaping (RemoteLoggerTransportError?) -> Void) {
        httpTransport.request(path: "archive/send", object: batch(from: records), completion: completion)
    }

    private func batch(from messages: [SerializedLogMessage]) -> LogMessageBatch {
        LogMessageBatch.with { logMessages in
            logMessages.messages = messages.map { $0.protobufMessage }
        }
    }
}
