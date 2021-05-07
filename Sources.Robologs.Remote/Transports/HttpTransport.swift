//
// HttpTransport
// Robologs
//
// Created by Alex Babaev on 19 April 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs
import SwiftProtobuf

class HttpTransport {
    private let endpoint: URL
    private let session: URLSession
    private let httpLogger: HttpLogger
    private var logger: LabeledLogger!

    private let delegateObject: URLSessionDelegateObject

    // Should return token in `success` case, error otherwise.
    var authorizeHandler: (_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void) -> Void = { completion in
        completion(.failure(.notAuthorized))
    }
    var authToken: String?
    var isAuthorized: Bool {
        authToken != nil
    }

    /// Creates new instance of `HttpTransport`.
    /// - Parameter endpoint: URL to server endpoint supporting this kind of transport.
    /// - Parameter secret: Secret key received from Robologs admin panel.
    /// - Parameter challengePolicy: Policy determining how URLAuthenticationChallenge will be managed.
    ///      If you using self-signing certificate use `AllowSelfSignedChallengePolicy`
    init(
        endpoint: URL,
        challengePolicy: AuthenticationChallengePolicy = ValidateSSLChallengePolicy(),
        logger: Logger
    ) {
        let configuration = URLSessionConfiguration.default
        self.endpoint = endpoint

        delegateObject = URLSessionDelegateObject(challengePolicy: challengePolicy)
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)

        httpLogger = HttpLogger(logger: logger, label: "RobologsHttp")
        self.logger = LabeledLogger(object: self, logger: logger)
    }

    func request(
        path: String,
        method: String = "POST",
        needAuthorization: Bool = true,
        completion: @escaping (RemoteLoggerTransportError?) -> Void
    ) {
        request(path: path, method: method, needAuthorization: needAuthorization, object: EmptyMessage(), completion: completion)
    }

    func request<Request: Message>(
        path: String,
        method: String = "POST",
        needAuthorization: Bool = true,
        object: Request,
        completion: @escaping (RemoteLoggerTransportError?) -> Void
    ) {
        request(
            path: path,
            method: method,
            needAuthorization: needAuthorization,
            object: object
        ) { ( response: Result<EmptyMessage, RemoteLoggerTransportError>) in
            switch response {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }

    func request<Response: Message>(
        path: String,
        method: String = "POST",
        needAuthorization: Bool = true,
        completion: @escaping (Result<Response, RemoteLoggerTransportError>) -> Void
    ) {
        request(path: path, method: method, needAuthorization: needAuthorization, object: EmptyMessage(), completion: completion)
    }

    func request<Request: Message, Response: Message>(
        path: String,
        method: String = "POST",
        needAuthorization: Bool = true,
        object: Request,
        completion: @escaping (Result<Response, RemoteLoggerTransportError>) -> Void
    ) {
        let completion: (Result<Response, RemoteLoggerTransportError>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        var request = URLRequest(url: endpoint.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue("deflate, gzip", forHTTPHeaderField: "Accept-Encoding")
        if !(object is EmptyMessage) {
            do {
                logger.verbose("Sending: \((try? object.jsonString()) ?? "???")")
                let body = try object.serializedData()
                request.httpBody = body
            } catch {
                logger.error(error, message: "Serialization problem")
                completion(.failure(.serialization(error)))
            }
        }

        if needAuthorization {
            if let authToken = authToken {
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                executeRequest(urlRequest: request, retryCounter: 0, completion: completion)
            } else {
                logger.debug("Authorization required, but absent for \(path)")
                authorizeHandler { result in
                    switch result {
                        case .success(let authToken):
                            request.setValue(authToken, forHTTPHeaderField: "Authorization")
                            self.executeRequest(urlRequest: request, retryCounter: 0, completion: completion)
                        case .failure(let error):
                            self.logger.error("Authorization failed for \(path)")
                            completion(.failure(error))
                    }
                }
            }
        } else {
            executeRequest(urlRequest: request, retryCounter: 0, completion: completion)
        }
    }

    private class HttpLogger {
        private let logger: Logger
        private let label: String
        var maxBodySize: Int = 8192

        init(logger: Logger, label: String) {
            self.logger = logger
            self.label = label
        }

        func log(_ request: URLRequest, date: Date = Date()) {
            let tag = "←"
            let body = request.httpBody.flatMap { data -> String? in
                if let type = request.allHTTPHeaderFields?["Content-Type"], isText(type: type) && data.count <= maxBodySize {
                    return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
                } else {
                    return "\(data.count) bytes"
                }
            } ?? request.httpBodyStream.map { _ in "stream" }
            let string =
                """
                \n__
                \(tag) Request: \(nils(request.httpMethod)) \(nils(request.url))
                \(tag) Headers: \(nils(logHeaders(request.allHTTPHeaderFields)))
                \(tag) Body: \(nils(body))
                ‾‾
                """

            logger.log(level: .info, "\(string)", label: label, function: "")
        }

        func log(
            _ response: URLResponse?,
            _ request: URLRequest,
            _ content: String,
            _ error: NSError?,
            startDate: Date,
            date: Date
        ) {
            let duration = date.timeIntervalSince(startDate)
            let urlResponse = response as? HTTPURLResponse
            let loggingLevel: Level = (urlResponse?.statusCode ?? 1000) < 400 ? .info : .error
            let tag = "→"
            let string =
                """
                \n__
                \(tag) Request: \(nils(request.httpMethod)) \(nils(request.url))
                \(tag) Response: \(nils(urlResponse?.statusCode)), Duration: \(String(format: "%0.3f", duration)) s
                \(tag) Headers: \(nils(logHeaders(urlResponse?.allHeaderFields)))
                \(tag) \(content)
                \(tag) Error: \(nils(error))
                ‾‾
                """
            logger.log(level: loggingLevel, "\(string)", label: label, function: "")
        }

        func log(_ data: Data?, _ response: URLResponse?) -> String {
            let urlResponse = response as? HTTPURLResponse
            let body = data.flatMap { data -> String? in
                if let type = urlResponse?.allHeaderFields["Content-Type"] as? String, isText(type: type) && data.count <= maxBodySize {
                    return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
                } else {
                    return "\(data.count) bytes"
                }
            }
            return "Data: \(nils(body))"
        }

        func log(_ url: URL?) -> String {
            "URL: \(nils(url?.absoluteString))"
        }

        private func nils(_ object: Any?) -> String {
            object.map { "\($0)" } ?? "nil"
        }

        private func logHeaders(_ httpHeaders: [AnyHashable: Any]?) -> String? {
            let headers = httpHeaders?.map { key, value -> String in "\(key): \(value)" }
            return headers.map { "[\n    " + $0.joined(separator: "\n    ") + "\n  ]" }
        }

        private func isText(type: String) -> Bool {
            type.contains("json") || type.contains("xml") || type.contains("text")
        }
    }

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

    struct EmptyMessage: Message {
        static let protoMessageName: String = "__EmptyMessage"
        let isInitialized: Bool = true
        var unknownFields: UnknownStorage = UnknownStorage()

        init() {
        }

        init(serializedData: Data) {
        }

        mutating func decodeMessage<D>(decoder: inout D) throws where D: Decoder {
        }

        func traverse<V>(visitor: inout V) throws where V: Visitor {
        }

        func isEqualTo(message: Message) -> Bool {
            message is EmptyMessage
        }
    }

    private func executeRequest<Response: Message>(
        urlRequest: URLRequest,
        retryCounter: Int,
        completion: @escaping (Result<Response, RemoteLoggerTransportError>) -> Void
    ) {
        guard retryCounter < 2 else { return completion(.failure(.notAuthorized)) }

        httpLogger.log(urlRequest)
        let startDate = Date()

        let task = session.dataTask(with: urlRequest) { data, response, error in
            let endDate = Date()
            self.httpLogger.log(response, urlRequest, "", nil, startDate: startDate, date: endDate)

            guard let data = data, error == nil else {
                return completion(.failure(.network(error)))
            }
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(.network(nil)))
            }

            let url = urlRequest.url.map { "\($0)" } ?? "—"

            switch response.statusCode {
                case 200 ... 299:
                    do {
                        let result = try Response(serializedData: data)
                        completion(.success(result))
                    } catch {
                        self.logger.error(error, message: "Serialization error for \(url)")
                        completion(.failure(.serialization(error)))
                    }
                case 401:
                    self.authorizeHandler { result in
                        switch result {
                            case .success(let authToken):
                                var urlRequest = urlRequest
                                urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
                                self.executeRequest(urlRequest: urlRequest, retryCounter: retryCounter + 1, completion: completion)
                            case .failure(let error):
                                self.logger.error(error, message: "Authorization failed for \(url)")
                                completion(.failure(error))
                        }
                    }
                case 405:
                    self.logger.error("Method is absent for \(url)")
                    completion(.failure(.methodIsAbsent))
                default:
                    self.logger.error("Error code \(response.statusCode) is got for \(url)")
                    completion(.failure(.http(code: response.statusCode, error)))
            }
        }
        task.resume()
    }
}
