//
//  ProtoHttpRemoteLoggerTransport.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 05.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Foundation

class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
    private class URLSessionDelegateObject: NSObject, URLSessionDelegate {
        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
        ) -> Void) {
            guard let trust = challenge.protectionSpace.serverTrust else {
                return completionHandler(.performDefaultHandling, nil)
            }

            completionHandler(.useCredential, URLCredential(trust: trust))
        }
    }

    private let endpoint: URL
    private let delegateObject: URLSessionDelegateObject
    private let session: URLSession

    init(endpoint: URL) {
        let configuration = URLSessionConfiguration.default
        self.endpoint = endpoint
        delegateObject = URLSessionDelegateObject()
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)
    }

    var isAvailable: Bool {
        true
    }

    func send(_ records: [LogRecord], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let record = records.first else {
            return
        }

        do {
            var request = URLRequest(url: endpoint.appendingPathComponent("http/saveProto"))
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")

            let message = TestLogMessage.with { message in
                message.priority = .error
                message.label = record.label
                message.message = record.message
                message.timestampMs = Int64(record.timestamp * 1000)
            }

            let data = try message.serializedData()
            request.httpMethod = "POST"
            request.httpBody = data

            let task = session.dataTask(with: request) { _, response, error in
                print(response as Any)
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
