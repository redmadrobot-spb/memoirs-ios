//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28 April 2020.
//  Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs

let lowLevelMemoir = PrintMemoir(onlyTime: true, shortCodePosition: true) { tracer in
    switch tracer {
        case .app, .instance, .session: return false
        case .queue, .thread: return false
        case .request, .label, .custom: return true
    }
}

let appMemoir = AppMemoir(bundleId: "com.smth.myGreatApp", version: "0.1", memoir: lowLevelMemoir)
appMemoir.info("AppLog")

let stopwatch = Stopwatch(memoir: appMemoir)
var mark = stopwatch.mark

var instanceMemoir = InstanceMemoir(deviceInfo: .init(osInfo: .macOS(version: "11.something")), memoir: appMemoir)
instanceMemoir.error("instance level log")

var addedLabelMemoir = TracedMemoir(label: "SomeLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.error("Install+LabelLog")

mark = stopwatch.measureTime(from: mark, name: "Initialization")

func session() {
    stopwatch.measure(name: "Session") {
        let sessionMemoir = SessionMemoir(userId: UUID().uuidString, isGuest: true, memoir: addedLabelMemoir)
        let tracers: [Tracer] = [
            .request(id: UUID().uuidString),
            .thread(name: "main-thread-or-else"),
            .instance(id: UUID().uuidString)
        ]
        sessionMemoir.debug("SessionLog", tracers: tracers)
        sessionMemoir.info("Session Info Log", tracers: tracers)
        sessionMemoir.critical("Session Critical Log", tracers: tracers)
        sessionMemoir.event(name: "Some Event", meta: [ "parameter": "value" ], tracers: tracers)
        sessionMemoir.update(tracer: .custom("Some Event"), meta: [ "parameter": "value" ], tracers: tracers)
        sessionMemoir.finish(tracer: .custom("Some Event"), tracers: tracers)
        sessionMemoir.measurement(name: "Some Request time", value: 2.39, tracers: tracers)
    }
}

session()
addedLabelMemoir.debug("AnotherInstallLog")

addedLabelMemoir.event(name: "EventLog", meta: [:])

addedLabelMemoir = TracedMemoir(label: "AnotherLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.debug("Another instance level log")
