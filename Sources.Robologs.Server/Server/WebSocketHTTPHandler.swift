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

    private var logger: LabeledLogger!

    init(logger: Logger) {
        self.logger = LabeledLogger(object: self, logger: logger)
    }

    func handlerAdded(context: ChannelHandlerContext) {
        logger.info("Added: \(context.name)")
    }

    func handlerRemoved(context: ChannelHandlerContext) {
        logger.info("Removed: \(context.name)")
    }

    private let emptyResponseHeaders: HTTPHeaders = [
        "Connection": "close",
        "Content-Length": "0",
    ]

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        logger.info("Reading...")

        // We're not interested in request bodies here: we're just serving up GET responses
        // to get the client to initiate a websocket request.
        guard case .head(let head) = unwrapInboundIn(data) else { return }

        switch (head.method, head.uri) {
            case (.GET, _):
                respondEmpty(context: context, status: .ok)
            case (.POST, let uri) where uri.hasSuffix("/auth/sign-in"):
                respondWithFakeToken(context: context)
            default:
                return respondEmpty(context: context, status: .badRequest)
        }
    }

    private func respondEmpty(context: ChannelHandlerContext, status: HTTPResponseStatus) {
        logger.info("Responding (status: \(status))...")

        let headers = HTTPResponseHead(version: .http1_1, status: status, headers: emptyResponseHeaders)
        context.write(wrapOutboundOut(.head(headers)), promise: nil)
        context
            .write(wrapOutboundOut(.end(nil)))
            .whenComplete { _ in
                context.close(promise: nil)
            }
        context.flush()
    }

    private func respondWithFakeToken(context: ChannelHandlerContext) {
        logger.info("Responding with fake token...")

        let tokenResponse = ByteBuffer(string: "{ \"token\"=\"fake_token_hello_guys\" }")
        let headers: HTTPHeaders = [
            "Connection": "close",
            "Content-Length": "\(tokenResponse.writableBytes)",
        ]

        let head = OutboundOut.head(HTTPResponseHead(version: .http1_1, status: .ok, headers: headers))
        let body = OutboundOut.body(.byteBuffer(tokenResponse))
        context.write(wrapOutboundOut(head), promise: nil)
        context.write(wrapOutboundOut(body), promise: nil)
        context
            .write(wrapOutboundOut(.end(nil)))
            .whenComplete { _ in
                context.close(promise: nil)
            }
        context.flush()
    }
}
