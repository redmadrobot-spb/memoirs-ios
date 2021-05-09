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
let stopwatch = SimpleStopwatch()

let applicationScope = Scope(name: "Application")

let logger = Logger(label: "ExampleLabel", scopes: [ applicationScope ], logger: printLogger)

logger.debug("Application debug string one")

let measurement = stopwatch.measure(label: "ExampleMeasurement") {
    let measurementScope = applicationScope.subScope(name: "Measurement")
    let logger = Logger(label: "ExampleLabel", scopes: [ measurementScope ], logger: printLogger)

    logger.debug("Debug string one")
    logger.info("Info string two")
}
