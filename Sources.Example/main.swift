//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

let lowLevelLogger = PrintLogger(onlyTime: true, shortSource: true) // Usually its Filtering/Multiplexing logger
//    let stopwatch = Stopwatch()
//
//    let applicationScope = Scope(name: "Application")
//
//    let logger = Logger(label: "ExampleLabel", scopes: [ applicationScope ], logger: lowLevelLogger)
//
//    logger.debug("Application debug string one")
//
//    let measurement = stopwatch.measure(label: "ExampleMeasurement") {
//        let measurementScope = applicationScope.subScope(name: "Measurement")
//        let logger = Logger(label: "ExampleLabel", scopes: [ measurementScope ], logger: lowLevelLogger)
//
//        logger.debug("Debug string one")
//        logger.info("Info string two")
//    }


// -----------------------------------------------------------------------------------------------------------------------------------------

let appLogger = ThreadQueueLogger(logger: AppLogger(bundleId: "com.smth.myGreatApp", version: "0.1", logger: lowLevelLogger))
var installLogger = InstallLogger(deviceInfo: .init(os: .macOS(version: "11.something")), logger: appLogger)

func session() {
    let sessionLogger = SessionLogger(userId: UUID().uuidString, isGuest: true, logger: installLogger)
    sessionLogger.debug("Session level log", label: "SessionLabel")
}

session()
session()
session()
installLogger.debug("Install level log", label: "MainLabel")

installLogger = InstallLogger(deviceInfo: .init(os: .macOS(version: "11.something")), logger: appLogger)
installLogger.debug("Another install level log", label: "MainLabel")
