//
// Created by Alex Babaev on 29.04.2021.
//

import Foundation
import NIO
import NIOHTTP1

public class ActionsHandler {
    public struct Request {
        public let method: HTTPMethod
        public let version: Int?
        public let path: String
        public let body: ByteBuffer

        public init(header: HTTPRequestHead, body: ByteBuffer) {
            method = header.method
            let pathComponents = header.uri.components(separatedBy: "/")
            if let versionIndex = pathComponents.firstIndex(of: "v0") {
                version = 0
                path = "/\(pathComponents[(versionIndex + 1) ..< pathComponents.endIndex].joined(separator: "/"))"
            } else {
                version = nil
                path = "/\(pathComponents.joined(separator: "/"))"
            }
            self.body = body
        }
    }

    public struct Response {
        public let status: HTTPResponseStatus
        public let headers: HTTPHeaders
        public let body: Data

        public init(status: HTTPResponseStatus, headers: HTTPHeaders, body: Data) {
            self.status = status
            self.headers = headers
            self.body = body
        }
    }

    // TODO: Extract
    private var actions: [(Request) -> Response?] = []

    public init(actions: [(Request) -> Response?]) {
        self.actions = actions
    }

    func response(for request: Request) -> Response? {
        actions.lazy.compactMap({ $0(request) }).first
    }
}
