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

let senderId = "SOME_FAKE_SENDER_ID"
let actionsHandler = RobologsActions(senderId: senderId)

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
    logger.debug("Test Message", label: "TestLabel", scopes: [])
}
