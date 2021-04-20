//
// SimpleUpgradingHTTPHandler
// Robologs.Server
//
// Created by Alex Babaev on 19 April 2021.
// Copyright (c) 2021 Redmadrobot. All rights reserved.
//

import NIO
import NIOHTTP1
import NIOWebSocket
import Robologs

final class UpgradingHTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
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

    private let responseHeaders: HTTPHeaders = [
        "Connection": "close",
        "Content-Length": "0",
    ]

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        logger.info("Reading...")

        // We're not interested in request bodies here: we're just serving up GET responses
        // to get the client to initiate a websocket request.
        guard case .head(let head) = unwrapInboundIn(data) else { return }
        guard case .GET = head.method else { return respondEmpty(context: context, status: .methodNotAllowed) }

        respondEmpty(context: context, status: .ok)
    }

    private func respondEmpty(context: ChannelHandlerContext, status: HTTPResponseStatus) {
        logger.info("Responding (status: \(status))...")

        let headers = HTTPResponseHead(version: .http1_1, status: status, headers: responseHeaders)
        context.write(wrapOutboundOut(.head(headers)), promise: nil)
        context
            .write(wrapOutboundOut(.end(nil)))
            .whenComplete { _ in
                context.close(promise: nil)
            }
        context.flush()
    }
}
