//
//  ProtoHttpRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 05.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Foundation
import UIKit

/// Remote logger transport that uses HTTP + Protubuf.
public class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
    // TODO: Remove when server will switch to proper certificate
    private class URLSessionDelegateObject: NSObject, URLSessionDelegate {
        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
        ) -> Void) {
            if let trust = challenge.protectionSpace.serverTrust {
                completionHandler(.useCredential, URLCredential(trust: trust))
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
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

    public var isAuthorized: Bool {
        authToken != nil
    }

    /// Creates new instance of `ProtoHttpRemoteLoggerTransport`.
    /// - Parameter endpoint: URL to server endpoint supporting this kind of transport.
    /// - Parameter secret: Secret key received from Robologs admin panel.
    public init(endpoint: URL, secret: String) {
        let configuration = URLSessionConfiguration.default
        self.endpoint = endpoint.appendingPathComponent(apiPath)
        self.secret = secret
        delegateObject = URLSessionDelegateObject()
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)
    }

    private let liveConnectionCodeSubscribers = Subscribers<String?>()
    private var currentLiveConnectionCode: String? = nil {
        didSet {
            liveConnectionCodeSubscribers.fire(currentLiveConnectionCode)
        }
    }

    /// Subscribe to live connection code.
    /// Display this code anywhere in your app, for example in About page.
    /// User can enter this code in Robologs web page to instantly see logs from current device.
    /// This code can change anytime so update it in UI at every `onChange` call.
    /// - Parameter onChange: Callback calling right after subscription and every time code change.
    /// - Returns: Subscription token.
    ///   Store this token in object with same live time as objects interested in code updates (for example some AboutViewController).
    ///   If this token is disposed `onChange` will not be called anymore.
    public func subscribeLiveConnectionCode(_ onChange: @escaping (String?) -> Void) -> Subscription {
        onChange(currentLiveConnectionCode)
        return liveConnectionCodeSubscribers.subscribe(action: onChange)
    }

    /// Authorize transport with provided secret.
    /// - Parameter completion: Completion called when authorization is finished.
    public func authorize(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        let completion = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("auth"))
            request.httpMethod = "POST"
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")

            let sourceRequest = JournalTokenRequest.with { request in
                request.secret = secret
                request.sender = JournalTokenRequest.Sender.with { sender in
                    let enviromentInfo = EnviromentInfo.current
                    sender.id = UIDevice.current.identifierForVendor?.uuidString ?? ""
                    sender.appID = enviromentInfo.appId ?? ""
                    sender.appName = enviromentInfo.appName ?? ""
                    sender.appVersion = enviromentInfo.appVersion ?? ""
                    sender.appBuildVersion = enviromentInfo.appBuild ?? ""
                    sender.operationSystem = enviromentInfo.operationSystem ?? ""
                    sender.operationSystemVersion = enviromentInfo.operationSystemVersion ?? ""
                    sender.deviceModel = enviromentInfo.deviceModel ?? ""
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
                            self.authToken = response.journalToken
                            self.currentLiveConnectionCode = response.liveConnectionCode
                            completion(.success(()))
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

    public func send(_ records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        guard let authToken = authToken else {
            return completion(.failure(.notAuthorized))
        }

        let completion = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("send"))
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
                        logMessage.message = record.message.string(withoutSensitive: shouldRemoveSensitive)
                        logMessage.source = "\(record.file):\(record.line)"
                        logMessage.timestampMs = Int64(record.timestamp * 1000)
                        logMessage.meta = record.meta?.mapValues {
                            $0.string(withoutSensitive: shouldRemoveSensitive)
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
