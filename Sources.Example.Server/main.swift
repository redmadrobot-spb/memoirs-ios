//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs
import RobologsRemote
import RobologsServer

var logSender: WebSocketLogSender = WebSocketLogSender(
    port: 9999,
    senderId: "SOME_SENDER",
    logger: PrintLogger(onlyTime: true, shortSource: true)
)

DispatchQueue.global().async {
    do {
        try logSender.start()
    } catch {
        print("\(error)")
    }
}

let logger = RemoteLogger(isSensitive: false, senders: [ logSender ])

while true {
    Thread.sleep(forTimeInterval: 3)
    print("...")
    logger.debug("Test Message", label: "TestLabel")
}
