//
// ProtoHttpRemoteLoggerTransport
// Robologs
//
// Created by Vladislav Maltsev on 05.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
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

/// Remote logger transport that uses HTTP + Protubuf.
class ProtoHttpRemoteLoggerTransport: RemoteLoggerTransport {
    private let endpoint: URL
    private let secret: String
    private let session: URLSession
    private var authToken: String?
    private var isLoading = false

    private var logger: LabeledLogger!
    private var httpLogger: HttpLogger!

    private let applicationInfo: ApplicationInfo

    var isAuthorized: Bool {
        authToken != nil
    }

    private let delegateObject: URLSessionDelegateObject

    /// Creates new instance of `ProtoHttpRemoteLoggerTransport`.
    /// - Parameter endpoint: URL to server endpoint supporting this kind of transport.
    /// - Parameter secret: Secret key received from Robologs admin panel.
    /// - Parameter challengePolicy: Policy determining how URLAuthentificationChallange will be mannaged.
    ///      If you using self-signing certificate use `AllowSelfSignedChallengePolicy`
    init(
        endpoint: URL,
        secret: String,
        challengePolicy: AuthenticationChallengePolicy = DefaultChallengePolicy(),
        applicationInfo: ApplicationInfo,
        logger: Logger
    ) {
        self.applicationInfo = applicationInfo

        let configuration = URLSessionConfiguration.default
        self.endpoint = endpoint
        self.secret = secret

        delegateObject = URLSessionDelegateObject(challengePolicy: challengePolicy)
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)

        self.logger = LabeledLogger(object: self, logger: logger)
        self.httpLogger = HttpLogger(logger: logger, label: "RobologsAPI")
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

        request(
            path: "auth",
            needAuthorization: false,
            requestObject: source
        ) { (result: Result<AuthResponse, RemoteLoggerTransportError>) in
            switch result {
                case .success(let response):
                    self.authToken = response.token
                    completion(.success(response.token))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func liveConnectionCode(_ completion: @escaping (Result<String, RemoteLoggerTransportError>) -> Void) {
        request(path: "code") { (result: Result<LiveCodeResponse, RemoteLoggerTransportError>) in
            switch result {
                case .success(let response):
                    self.liveConnectionCode = response.code
                    completion(.success(response.code))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func invalidateConnectionCode(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        request(path: "code", method: "DELETE") { (result: Result<EmptyMessage, RemoteLoggerTransportError>) in
            completion(result.map { _ in Void() })
        }
    }

    func startLive(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        request(path: "live/start") { (result: Result<EmptyMessage, RemoteLoggerTransportError>) in
            completion(result.map { _ in Void() })
        }
    }

    func stopLive(_ completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        request(path: "live/stop") { (result: Result<EmptyMessage, RemoteLoggerTransportError>) in
            completion(result.map { _ in Void() })
        }
    }

    func sendLive(records: [LogRecord], completion: @escaping (Result<Void, RemoteLoggerTransportError>) -> Void) {
        let logMessages = LogMessageBatch.with { logMessages in
            logMessages.messages = records.map { record in
                LogMessage.with { logMessage in
                    logMessage.position = record.position
                    logMessage.priority = record.level.protoBufLevel
                    logMessage.label = record.label
                    logMessage.body = record.message
                    logMessage.source = collectContext(file: record.file, function: record.function, line: record.line)
                    logMessage.timestampMillis = UInt64(record.timestamp * 1000)
                    logMessage.meta = record.meta ?? [:]
                }
            }
        }

        request(path: "live/send", requestObject: logMessages) { (result: Result<EmptyMessage, RemoteLoggerTransportError>) in
            completion(result.map { _ in Void() })
        }
    }

    private func request<Response: Message>(
        path: String,
        method: String = "POST",
        needAuthorization: Bool = true,
        completion: @escaping (Result<Response, RemoteLoggerTransportError>) -> Void
    ) {
        request(path: path, method: method, needAuthorization: needAuthorization, requestObject: EmptyMessage(), completion: completion)
    }

    private func request<Request: Message, Response: Message>(
        path: String,
        method: String = "POST",
        needAuthorization: Bool = true,
        requestObject: Request,
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
        if !(requestObject is EmptyMessage) {
            do {
                request.httpBody = try requestObject.serializedData()
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
                authorize { result in
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

    private func executeRequest<Response: Message>(
        urlRequest: URLRequest,
        retryCounter: Int,
        completion: @escaping (Result<Response, RemoteLoggerTransportError>) -> Void
    ) {
        guard retryCounter < 2 else { return completion(.failure(.notAuthorized)) }

        httpLogger.log(urlRequest)
        let startDate = Date()

        let task = self.session.dataTask(with: urlRequest) { data, response, error in
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
                    self.authorize { result in
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

    class HttpLogger {
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

private struct EmptyMessage: Message {
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
