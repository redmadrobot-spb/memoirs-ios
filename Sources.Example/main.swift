//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

let printLogger = PrintLogger(onlyTime: true, shortSource: true)
let stopwatch = Stopwatch()

let applicationScope = Scope(name: "Application")

let logger = Logger(label: "ExampleLabel", scopes: [ applicationScope ], logger: printLogger)

logger.debug("Application debug string one")

let measurement = stopwatch.measure(label: "ExampleMeasurement") {
    let measurementScope = applicationScope.subScope(name: "Measurement")
    let logger = Logger(label: "ExampleLabel", scopes: [ measurementScope ], logger: printLogger)

    logger.debug("Debug string one")
    logger.info("Info string two")
}


// -----------------------------------------------------------------------------------------------------------------------------------------

let lowLevelLogger = PrintLogger() // Usually its Filtering/Multiplexing logger

let appScope = Scope(name: "Application", meta: [ "bundleId": "com.smth.myGreatApp" ])
let appLogger = ScopedLogger(scopes: [ appScope ], logger: lowLevelLogger)

let installationScope = Scope(name: "Installation", parentName: "Application", meta: [
    "deviceId": "\(safe: UUID().uuidString)",
    "appVersion": "1.239",
    "os": "iOS",
    "osVersion": "14.4 beta 3",
])
var installLogger: ScopedLogger = ScopedLogger(scopes: [ installationScope ], logger: appLogger)

func session() {
    let sessionScope = Scope(name: "Session", parentName: "Installation", meta: [
        "startTimestamp": "\(safe: Int(Date().timeIntervalSince1970))"
    ])
    let sessionLogger = ScopedLogger(scopes: [ sessionScope ], logger: installLogger)
    sessionLogger.debug("Session level log", label: "session")
}

session()
appLogger.debug("Application level log", label: "main")
