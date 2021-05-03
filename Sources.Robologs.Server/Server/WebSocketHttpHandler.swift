//
// SimpleUpgradingHTTPHandler
// Robologs.Server
//
// Created by Alex Babaev on 19 April 2021.
// Copyright (c) 2021 Redmadrobot. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket
import Robologs

final class WebSocketHTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private let actionsHandler: HttpActions
    private var logger: LabeledLogger!

    init(actionsHandler: HttpActions, logger: Logger) {
        self.actionsHandler = actionsHandler
        self.logger = LabeledLogger(object: self, logger: logger)
    }

    func handlerAdded(context: ChannelHandlerContext) {
        logger.info("Added: \(context.name)")
    }

    func handlerRemoved(context: ChannelHandlerContext) {
        logger.info("Removed: \(context.name)")
    }

    private var isHeaderDone: Bool = false
    private var header: HTTPRequestHead?

    private let emptyResponseHeaders: HTTPHeaders = [
        "Connection": "close",
        "Content-Length": "0",
    ]
    private lazy var badRequestResponse: HttpActions.Response = .init(status: .badRequest, headers: emptyResponseHeaders, body: Data())

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        if case .head(let header) = unwrapInboundIn(data) {
            self.header = header
        } else if case .body(let body) = unwrapInboundIn(data), let header = header {
            let request = HttpActions.Request(header: header, body: body)
            let response: HttpActions.Response = actionsHandler.response(for: request) ?? badRequestResponse

            write(context: context, response: response)
        }

//        // We're not interested in request bodies here: we're just serving up GET responses
//        // to get the client to initiate a websocket request.
//        guard case .head(let head) = unwrapInboundIn(data) else { return }
//
//        switch (head.method, head.uri) {
//            case (.GET, _):
//                respondEmpty(context: context, status: .ok)
//            case (.POST, let uri) where uri.hasSuffix("/auth/sign-in"):
//                respondWithText(context: context, response: "{ \"token\": \"fake_token_hello_guys\" }")
//            case (.POST, let uri) where uri.hasSuffix("/v0/sender/get-by-code"):
//                respondWithText(context: context, response: "{ \"sender\": { \"id\": \"\(senderId)\" } }")
//            default:
//                return respondEmpty(context: context, status: .badRequest)
//        }
    }

    private func write(context: ChannelHandlerContext, response: HttpActions.Response) {
        var headers = response.headers
        headers.replaceOrAdd(name: "Connection", value: "close")
        headers.replaceOrAdd(name: "Content-Length", value: "\(response.body.count)")
        let head = OutboundOut.head(HTTPResponseHead(version: .http1_1, status: response.status, headers: headers))
        context.write(wrapOutboundOut(head), promise: nil)

        if !response.body.isEmpty {
            let body = OutboundOut.body(.byteBuffer(ByteBuffer(bytes: response.body)))
            context.write(wrapOutboundOut(body), promise: nil)
        }

        context
            .write(wrapOutboundOut(.end(nil)))
            .whenComplete { _ in
                context.close(promise: nil)
            }
        context.flush()
    }
}
