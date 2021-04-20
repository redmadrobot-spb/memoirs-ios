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

var webSocket: WebSocketServer = WebSocketServer(port: 9999, logger: PrintLogger(onlyTime: true, shortSource: true))

DispatchQueue.global().async {
    do {
        try webSocket.start()
    } catch {
        print("\(error)")
    }
}

while true {
    let message = SerializedLogMessage(
        position: UInt64.random(in: 0 ... UInt64.max),
        timestamp: Date().timeIntervalSince1970,
        level: .debug,
        message: "Test message",
        label: "Label",
        meta: nil,
        file: "FILE",
        function: "FUNCTION",
        line: 0
    )

    Thread.sleep(forTimeInterval: 3)

    print("... ")
    do {
        try webSocket.send(log: message)
    } catch {
        print("\(error)")
    }
}
