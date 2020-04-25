//
//  ProtoHttpRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 05.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Foundation

/// Remote logger transport that uses HTTP + Protubuf.
class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
    // TODO: Remove when server will switch to proper certificate
    private class URLSessionDelegateObject: NSObject, URLSessionDelegate {
        let challengePolicy: AuthenticationChallengePolicy

        init(challengePolicy: AuthenticationChallengePolicy) {
            self.challengePolicy = challengePolicy
        }

        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
        ) -> Void) {
            challengePolicy.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
        }
    }

    private let apiPath = "api/v1"
    private let endpoint: URL
    private let secret: String
    private let delegateObject: URLSessionDelegateObject
    private let session: URLSession
    private var authToken: String?
    private var isLoading = false
    private let shouldRemoveSensitive = true

    private let applicationInfo: ApplicationInfo

    var isAuthorized: Bool {
        authToken != nil
    }

    /// Creates new instance of `ProtoHttpRemoteLoggerTransport`.
    /// - Parameter endpoint: URL to server endpoint supporting this kind of transport.
    /// - Parameter secret: Secret key received from Robologs admin panel.
    /// - Parameter challengePolicy: Policy determining how URLAuthentificationChallange will be mannaged.
    ///       If you using self-signing certificate use `AllowSelfSignedChallengePolicy`
    init(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = DefaultChallengePolicy(),
        applicationInfo: ApplicationInfo
    ) {
        self.applicationInfo = applicationInfo

        let configuration = URLSessionConfiguration.default
        self.endpoint = endpoint.appendingPathComponent(apiPath)
        self.secret = secret
        delegateObject = URLSessionDelegateObject(challengePolicy: challengePolicy)
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)
    }

    private let liveConnectionCodeSubscribers = Subscribers<String?>()
    private var currentLiveConnectionCode: String? = nil {
        didSet {
            liveConnectionCodeSubscribers.fire(currentLiveConnectionCode)
        }
    }

    func subscribeLiveConnectionCode(_ onChange: @escaping (String?) -> Void) -> Subscription {
        onChange(currentLiveConnectionCode)
        return liveConnectionCodeSubscribers.subscribe(action: onChange)
    }

    func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("auth"))
            request.httpMethod = "POST"
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")

            let sourceRequest = JournalTokenRequest.with { request in
                request.secret = secret
                request.sender = JournalTokenRequest.Sender.with { sender in
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
            request.httpBody = try sourceRequest.serializedData()
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.network(error)))
                } else {
                    if let data = data {
                        do {
                            let response = try JournalTokenResponse(serializedData: data)
                            self.authToken = response.token
                            self.getCode { result in
                                switch result {
                                    case .success:
                                        completion(.success(()))
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                            }
                        } catch {
                            completion(.failure(.serialization(error)))
                        }
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(.serialization(error)))
        }
    }

    func getCode(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard let authToken = authToken else {
            completion(.failure(.notAuthorized))
            return
        }

        var request = URLRequest(url: endpoint.appendingPathComponent("code"))
        request.httpMethod = "POST"
        request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue(authToken, forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.network(error)))
            } else {
                if let data = data {
                    do {
                        let response = try ConnectionCodeResponse(serializedData: data)
                        self.currentLiveConnectionCode = response.code
                        self.liveStart { result in
                            switch result {
                                case .success:
                                    completion(.success(()))
                                case .failure(let error):
                                    completion(.failure(error))
                            }
                        }
                    } catch {
                        completion(.failure(.serialization(error)))
                    }
                }
            }
        }
        task.resume()
    }

    func liveStart(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard let authToken = authToken else {
            completion(.failure(.notAuthorized))
            return
        }

        var request = URLRequest(url: endpoint.appendingPathComponent("live/start"))
        request.httpMethod = "POST"
        request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue(authToken, forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(.network(error)))
            } else {
                completion(.success(()))
            }
        }
        task.resume()
    }

    func liveSend(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard let authToken = authToken else {
            completion(.failure(.notAuthorized))
            return
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("live/send"))
            request.httpMethod = "POST"
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
            request.setValue(authToken, forHTTPHeaderField: "Authorization")

            let logMessages = LogMessageBatch.with { logMessages in
                logMessages.messages = records.map { record in
                    LogMessage.with { logMessage in
                        logMessage.priority = {
                            switch record.level {
                                case .critical, .error:
                                    return .error
                                case .warning:
                                    return .warn
                                case .info:
                                    return .info
                                case .debug, .verbose:
                                    return .debug
                            }
                        }()
                        logMessage.label = record.label
                        logMessage.message = record.message.string(isSensitive: shouldRemoveSensitive)
                        logMessage.source = "\(record.file):\(record.line)"
                        logMessage.timestampMs = Int64(record.timestamp * 1000)
                        logMessage.meta = record.meta?.mapValues {
                            $0.string(isSensitive: shouldRemoveSensitive)
                        } ?? [:]
                    }
                }
            }

            request.httpBody = try logMessages.serializedData()

            let task = session.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(.network(error)))
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    completion(.failure(.notAuthorized))
                } else {
                    completion(.success(()))
                }
            }
            task.resume()
        } catch {
            completion(.failure(.serialization(error)))
        }
    }
}
