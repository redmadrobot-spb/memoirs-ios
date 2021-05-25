//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28 April 2020.
//  Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs

let lowLevelMemoir = PrintMemoir(onlyTime: true, shortSource: true) // Usually its Filtering/Multiplexing memoir

let appMemoir = AppMemoir(bundleId: "com.smth.myGreatApp", version: "0.1", memoir: lowLevelMemoir)
appMemoir.info("AppLog")

let infoMemoir = ThreadQueueMemoir(memoir: appMemoir)
infoMemoir.warning("ThreadInfoLog")

let stopwatch = Stopwatch()

var mark = stopwatch.mark

var instanceMemoir = InstanceMemoir(deviceInfo: .init(osInfo: .macOS(version: "11.something")), memoir: infoMemoir)
instanceMemoir.error("instance level log")

var addedLabelMemoir = TracedMemoir(label: "SomeLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.error("Install+LabelLog")

mark = stopwatch.logInterval(from: mark, label: "Initialization")

func session() {
    stopwatch.measure(label: "Session") {
        let sessionMemoir = SessionMemoir(userId: UUID().uuidString, isGuest: true, memoir: addedLabelMemoir)
        sessionMemoir.debug("SessionLog")
    }
}

session()
addedLabelMemoir.debug("AnotherInstallLog")

addedLabelMemoir.event(name: "EventLog", meta: [:])

addedLabelMemoir = TracedMemoir(label: "AnotherLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.debug("Another instance level log")
