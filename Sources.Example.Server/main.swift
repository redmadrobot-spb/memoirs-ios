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

var server: WebSocketServer = WebSocketServer(port: 9999, logger: PrintLogger(onlyTime: true, shortSource: true))

DispatchQueue.global().async {
    do {
        try server.start()
    } catch {
        print("\(error)")
    }
}

let logger = LocalWebSocketLogger(server: server, isSensitive: false)

while true {
    Thread.sleep(forTimeInterval: 3)
    print("...")
    logger.debug("Test Message", label: "TestLabel")
}
