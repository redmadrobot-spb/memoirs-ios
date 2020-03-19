//
//  ProtoHttpRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 05.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Foundation

/// Remote logger transport that uses HTTP2 + Protubuf.
public class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
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
        self.endpoint = endpoint
        self.secret = secret
        delegateObject = URLSessionDelegateObject()
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)
    }

    public let isAvailable = true
    private let shouldRemoveSensitive = true

    private func getAuthToken(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let completion = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("api/v1/source"))
            let sourceRequest = SenderTokenRequest.with { request in
                request.secret = secret
                request.sender = SenderTokenRequest.Sender.with { sender in
                    let enviromentInfo = EnviromentInfo.current
                    sender.appID = enviromentInfo.appId ?? ""
                    sender.appName = enviromentInfo.appName ?? ""
                    sender.appVersion = enviromentInfo.appVersion ?? ""
                    sender.appBuildVersion = enviromentInfo.appBuild ?? ""
                    sender.operationSystem = enviromentInfo.operationSystem ?? ""
                    sender.operationSystemVersion = enviromentInfo.operationSystemVersion ?? ""
                    sender.deviceModel = enviromentInfo.deviceModel ?? ""
                }
            }

            request.httpMethod = "POST"
            request.httpBody = try sourceRequest.serializedData()

            let task = session.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            task.resume()
        } catch let error {
            completion(.failure(error))
        }
    }

    public func send(_ records: [LogRecord], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let record = records.first else {
            return
        }

        let completion = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("api/v1/send"))
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
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

            request.httpMethod = "POST"
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
            completion(.failure(error))
        }
    }

    public func startLiveSession(_ liveSessionToken: String) {
        self.liveSessionToken = liveSessionToken
    }

    public func finishLiveSession() {
        liveSessionToken = nil
    }
}
