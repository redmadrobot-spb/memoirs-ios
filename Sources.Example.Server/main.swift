//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1
import Robologs
import RobologsRemote
import RobologsServer

let senderId = "SOME_SENDER_ID"

let jsonHeaders: HTTPHeaders = [
    "Content-Type": "application/json"
]
let serverFailResponse = ActionsHandler.Response(status: .internalServerError, headers: [:], body: Data())

var actions: [(ActionsHandler.Request) -> ActionsHandler.Response?] = []
actions.append { request in
    guard request.method == .GET else { return nil }

    return .init(status: .ok, headers: [:], body: Data())
}
actions.append { request in
    guard request.method == .POST, request.version == 0, request.path == "/sender/get-by-code" else { return nil }
    guard let body = "{ \"sender\": { \"id\": \"\(senderId)\" } }".data(using: .utf8) else { return serverFailResponse }

    return .init(status: .ok, headers: jsonHeaders, body: body)
}

let actionsHandler = ActionsHandler(actions: actions)

var logSender: WebSocketLogSender = WebSocketLogSender(
    port: 9999,
    actionsHandler: actionsHandler,
    logger: PrintLogger(onlyTime: true, shortSource: true)
)

DispatchQueue.global().async {
    do {
        try logSender.start()
    } catch {
        print("\(error)")
    }
}

let logger = RemoteLogger(isSensitive: false, senderId: senderId, senders: [ logSender ])

while true {
    Thread.sleep(forTimeInterval: 3)
    print("...")
    logger.debug("Test Message", label: "TestLabel")
}
