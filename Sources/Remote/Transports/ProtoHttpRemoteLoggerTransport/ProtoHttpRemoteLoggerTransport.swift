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
    private let delegateObject: URLSessionDelegateObject
    private let session: URLSession

    /// Creates new instance of `ProtoHttpRemoteLoggerTransport`.
    /// - Parameter endpoint: URL to server endpoint supporting this kind of transport.
    public init(endpoint: URL) {
        let configuration = URLSessionConfiguration.default
        self.endpoint = endpoint
        delegateObject = URLSessionDelegateObject()
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)
    }

    public let isAvailable = true
    public var shouldRemoveSensitive = true

    public func send(_ records: [LogRecord], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let record = records.first else {
            return
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("http/saveProto"))
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")

            let message = TestLogMessage.with { message in
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

            let data = try message.serializedData()
            request.httpMethod = "POST"
            request.httpBody = data

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
}
