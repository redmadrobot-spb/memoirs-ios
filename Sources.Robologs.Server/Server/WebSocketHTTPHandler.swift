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

    private let senderId: String
    private var logger: LabeledLogger!

    init(senderId: String, logger: Logger) {
        self.senderId = senderId
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
                respondWithText(context: context, response: "{ \"token\": \"fake_token_hello_guys\" }")
            case (.POST, let uri) where uri.hasSuffix("/v0/sender/get-by-code"):
                respondWithText(context: context, response: "{ \"sender\": { \"id\": \"\(senderId)\" } }")
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

    private func respondWithText(context: ChannelHandlerContext, response: String) {
        logger.info("Responding with fake token...")

        let data = response.data(using: .utf8) ?? Data()
        let tokenResponse: ByteBuffer = ByteBuffer(bytes: data)
        let headers: HTTPHeaders = [
            "Connection": "close",
            "Content-Type": "application/json",
            "Content-Length": "\(data.count)",
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
