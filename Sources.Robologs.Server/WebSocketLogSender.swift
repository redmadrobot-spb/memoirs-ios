//
// WebSocketServer
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
import RobologsRemote

public class WebSocketLogSender: LogSender {
    enum Problem: Error {
        case cantBind
    }

    private let port: Int32
    private let senderId: String

    private let originalLogger: Logger
    private var logger: LabeledLogger!

    public init(port: Int32, senderId: String, logger: Logger) {
        self.senderId = senderId
        self.port = port
        originalLogger = logger
        self.logger = LabeledLogger(object: self, logger: logger)

        prepare()
    }

    private let encoder: JSONEncoder = { JSONEncoder() }()

    private struct WSMessage: Encodable {
        struct Payload: Encodable {
            let senderId: String
            let messages: [WSLogMessage]
        }

        let type: String = "v0/logMessageBatch"
        let payload: Payload
    }

    public func send(message: SerializedLogMessage) {
        do {
            channels = channels.filter { _, channel in
                channel.isActive && channel.isWritable
            }
            logger.info("Channels: \(channels.count)")
            let data = try encoder.encode(WSMessage(payload: .init(senderId: senderId, messages: [ message.wsMessage ])))
            channels.values.forEach { channel in
                guard channel.isActive && channel.isWritable else { return }

                let buffer = channel.allocator.buffer(bytes: data)
                let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
                channel
                    .writeAndFlush(NIOAny(frame))
                    .whenFailure { error in
                        self.logger.error(error)
                        channel.close(promise: nil)
                    }
            }
        } catch {
            logger.error(error)
        }
    }

    private var channels: [String: Channel] = [:]

    private var group: EventLoopGroup!
    private var bootstrap: ServerBootstrap!

    public func prepare() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let upgrader = NIOWebSocketServerUpgrader(
            shouldUpgrade: { (channel: Channel, _: HTTPRequestHead) in
                channel.eventLoop.makeSucceededFuture(HTTPHeaders())
            },
            upgradePipelineHandler: { (channel: Channel, _: HTTPRequestHead) in
                let handler = WebSocketSendingLogsHandler(logger: self.originalLogger)
                self.channels[UUID().uuidString] = channel
                return channel.pipeline.addHandler(handler)
            }
        )

        bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256) // Specify backlog for the server itself
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1) // Enable SO_REUSEADDR for the server itself
            .childChannelInitializer { channel in // Set the handlers that are applied to the accepted Channels
                let httpHandler = WebSocketHTTPHandler(logger: self.originalLogger)
                let config: NIOHTTPServerUpgradeConfiguration = (
                    upgraders: [ upgrader ],
                    completionHandler: { _ in
                        channel.pipeline.removeHandler(httpHandler, promise: nil)
                    }
                )

                return channel.pipeline
                    .configureHTTPServerPipeline(withServerUpgrade: config)
                    .flatMap {
                        channel.pipeline.addHandler(httpHandler)
                    }
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1) // Enable SO_REUSEADDR for the accepted Channels
    }

    private var boundChannel: Channel?

    public func start() throws {
        defer {
            logger.info("Shutting down")

            do {
                try group.syncShutdownGracefully()
            } catch {
                logger.error(error)
            }
        }

        let channel: Channel = try bootstrap.bind(host: "0.0.0.0", port: Int(port)).wait()
        guard let localAddress = channel.localAddress else {
            logger.error("Could not bind on 0.0.0.0:\(port)")
            throw Problem.cantBind
        }

        logger.info("Server started and listening on \(localAddress)")

        boundChannel = channel
        try channel.closeFuture.wait()
        logger.info("Server closed")
    }

    public func stop() {
        boundChannel?.close(mode: .all, promise: nil)
    }
}
