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

let appLogger = AppLogger(bundleId: "com.smth.myGreatApp", version: "0.1", logger: lowLevelLogger)
appLogger.info("AppLog")
let threadInfoLogger = ThreadQueueLogger(logger: appLogger)
threadInfoLogger.warning("ThreadInfoLog")

let stopwatch = Stopwatch()

var mark = stopwatch.mark
var installLogger = InstallLogger(deviceInfo: .init(osInfo: .macOS(version: "11.something")), logger: threadInfoLogger)
installLogger.error(message: "InstallLog")
var addedLabelLogger = Logger(label: "SomeLabelALittleLonger", logger: installLogger)
addedLabelLogger.error(message: "Install+LabelLog")
mark = stopwatch.logInterval(from: mark, label: "Initialization")

func session() {
    stopwatch.measure(label: "Session") {
        let sessionLogger = SessionLogger(userId: UUID().uuidString, isGuest: true, logger: addedLabelLogger)
        sessionLogger.debug("SessionLog")
    }
}

session()
addedLabelLogger.debug("AnotherInstallLog")

addedLabelLogger.event(name: "EventLog", meta: [:])

installLogger = InstallLogger(deviceInfo: .init(osInfo: .macOS(version: "11.something")), logger: appLogger)
installLogger.debug("Another install level log")
