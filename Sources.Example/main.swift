//
//  main.swift
//  Memoir
//
//  Created by Alex Babaev on 28 April 2020.
//  Copyright © 2020 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation
import Memoirs

// https://github.com/minimaxir/big-list-of-naughty-strings
private let naughtyStrings: [String] = {
    guard let currentDirectory = ProcessInfo.processInfo.environment["PWD"] else { return [ "Not found..." ] }

    let url = URL(fileURLWithPath: currentDirectory)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Tests/BigListOfNaughtyStringsBase64.json")
    guard
        let data = try? Data(contentsOf: url),
            let strings = try? JSONDecoder().decode([String].self, from: data)
    else { return [ ":-<" ] }

    return strings
}()

let lowLevelMemoir = PrintMemoir { tracer in
    switch tracer {
        case .app, .instance, .session: return false
        case .request, .label, .type: return true
    }
}

let appMemoir = TracedMemoir(appWithBundleId: "com.smth.myGreatApp", version: "0.1", memoir: lowLevelMemoir)
appMemoir.infoLater("AppLog")

let stopwatch = Stopwatch(memoir: appMemoir)
var mark = stopwatch.mark

var instanceMemoir = TracedMemoir(instanceWithDeviceInfo: .init(osInfo: .macOS(version: "11.something")), memoir: appMemoir)
instanceMemoir.errorLater("instance level log")

var addedLabelMemoir = TracedMemoir(label: "SomeLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.errorLater("Install+LabelLog")

mark = stopwatch.measureTime(from: mark, name: "Initialization")

func session() {
    stopwatch.measure(name: "Session") {
        let sessionMemoir = TracedMemoir(sessionWithUserId: UUID().uuidString, isGuest: true, memoir: addedLabelMemoir)
        let tracers: [Tracer] = [
            .request(trace: UUID().uuidString),
            .instance(id: UUID().uuidString)
        ]
        sessionMemoir.debugLater("SessionLog", tracers: tracers)
        sessionMemoir.infoLater("Session Info Log", tracers: tracers)
        sessionMemoir.criticalLater("Session Critical Log", tracers: tracers)
        sessionMemoir.eventLater(name: "Some Event", meta: [ "parameter": "value" ], tracers: tracers)
        sessionMemoir.measurementLater(name: "Some Request time", value: .double(2.39), tracers: tracers)
    }
}

session()
addedLabelMemoir.debugLater("AnotherInstallLog")

addedLabelMemoir.eventLater(name: "EventLog", meta: [:])

addedLabelMemoir = TracedMemoir(label: "AnotherLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.debugLater("Another instance level log")

DispatchQueue.main.async {
    let statistics = CPUMemoryMeasurements(memoir: appMemoir)
    statistics.start(period: 2)

    var naughtyStringIndex = -1
    while (true) {
        autoreleasepool {
            naughtyStringIndex += 1
            if naughtyStringIndex >= naughtyStrings.count {
                naughtyStringIndex = 0
            }

            let string = naughtyStrings[naughtyStringIndex]
            addedLabelMemoir.debugLater("Another instance level log \(string)")
            addedLabelMemoir.updateLater(
                tracer: .label("Some Tracer \(naughtyStringIndex)"),
                meta: [ "meta1": "value1", "meta2": "value2", "meta3": "value3", ]
            )
            addedLabelMemoir.measurementLater(name: "Measurement \(naughtyStringIndex)", value: .double(23.9))
        }
    }
}

RunLoop.main.run()
