//
//  ProtoHttpRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 05.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Foundation
import UIKit

/// Remote logger transport that uses HTTP2 + Protubuf.
public class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
    /// Errors that can be happend in ProtoHttpRemoteLoggerTransport.
    public enum Error: Swift.Error {
        /// Transport was failed to make handshake with secret or doesn't have code6 for live session.
        case notAuthorized
        /// Network error occured.
        case network(Swift.Error)
        /// Serialization error occured.
        case serialization(Swift.Error)
    }

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
    private var liveSessionToken: String?
    private var sourceToken: String?
    private var authToken: String?

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

    public let isAvailable = true
    private let shouldRemoveSensitive = true

    /// Authorize transport with provided secret.
    /// - Parameter completion: Completion called when authorization is finished.
    public func authorize(_ completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        let completion = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("source"))
            request.httpMethod = "POST"
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")

            let sourceRequest = SenderTokenRequest.with { request in
                request.secret = secret
                request.sender = SenderTokenRequest.Sender.with { sender in
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
                    completion(.failure(Error.network(error)))
                } else {
                    if let data = data {
                        do {
                            let response = try SenderTokenResponse(serializedData: data)
                            let authToken = response.senderToken
                            self.authToken = authToken
                            completion(.success(()))
                        } catch let error {
                            completion(.failure(Error.serialization(error)))
                        }
                    }
                }
            }
            task.resume()
        } catch let error {
            completion(.failure(Error.serialization(error)))
        }
    }

    public func send(_ records: [LogRecord], completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        guard let authToken = authToken, let liveSessionToken = liveSessionToken else {
            return completion(.failure(Error.notAuthorized))
        }
        guard let record = records.first else {
            return
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
            request.setValue(liveSessionToken, forHTTPHeaderField: "X-C6-Marker")

            let message = LogMessage.with { message in
                message.priority = {
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
                message.label = record.label
                message.message = record.message.string(withoutSensitive: shouldRemoveSensitive)
                message.source = "\(record.file):\(record.line)"
                message.timestampMs = Int64(record.timestamp * 1000)
                message.meta = record.meta?.mapValues { $0.string(withoutSensitive: shouldRemoveSensitive) } ?? [:]
            }

            request.httpBody = try message.serializedData()

            let task = session.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            task.resume()
        } catch let error {
            completion(.failure(Error.serialization(error)))
        }
    }

    public func startLiveSession(_ liveSessionToken: String) {
        self.liveSessionToken = liveSessionToken
    }

    public func finishLiveSession() {
        liveSessionToken = nil
    }
}
