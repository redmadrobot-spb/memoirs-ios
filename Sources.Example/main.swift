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
//import MemoirMacros

// https://github.com/minimaxir/big-list-of-naughty-strings
private var naughtyStrings: [String] = {
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
appMemoir.info("AppLog")

let stopwatch = Stopwatch(memoir: appMemoir)
var mark = stopwatch.mark

var instanceMemoir = TracedMemoir(instanceWithDeviceInfo: .init(osInfo: .macOS(version: "11.something")), memoir: appMemoir)
instanceMemoir.error("instance level log")

var addedLabelMemoir = TracedMemoir(label: "SomeLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.error("Install+LabelLog")

mark = stopwatch.measureTime(from: mark, name: "Initialization")

func session() {
    stopwatch.measure(name: "Session") {
        let sessionMemoir = TracedMemoir(sessionWithUserId: UUID().uuidString, isGuest: true, memoir: addedLabelMemoir)
        let tracers: [Tracer] = [
            .request(trace: UUID().uuidString),
            .instance(id: UUID().uuidString)
        ]
        sessionMemoir.debug("SessionLog", tracers: tracers)
        sessionMemoir.info("Session Info Log", tracers: tracers)
        sessionMemoir.critical("Session Critical Log", tracers: tracers)
        sessionMemoir.event(name: "Some Event", meta: [ "parameter": "value" ], tracers: tracers)
        sessionMemoir.measurement(name: "Some Request time", value: .double(2.39), tracers: tracers)
    }
}

session()
addedLabelMemoir.debug("AnotherInstallLog")

addedLabelMemoir.event(name: "EventLog", meta: [:])

addedLabelMemoir = TracedMemoir(label: "AnotherLabelALittleLonger", memoir: instanceMemoir)
addedLabelMemoir.debug("Another instance level log")

let statistics = CPUMemoryMeasurements(memoir: appMemoir)
statistics.start(period: 1)

DispatchQueue.global().async {
    var naughtyStringIndex = -1
    while naughtyStringIndex < naughtyStrings.count {
//        autoreleasepool {
            naughtyStringIndex += 1
            guard naughtyStringIndex < naughtyStrings.count else { return }

            let string = naughtyStrings[naughtyStringIndex]
            addedLabelMemoir.debug("Another instance level log \(string)")
            addedLabelMemoir.update(
                tracer: .label("Some Tracer \(naughtyStringIndex)"),
                meta: [ "meta1": "value1", "meta2": "value2", "meta3": "value3", ]
            )
            addedLabelMemoir.measurement(name: "Measurement \(naughtyStringIndex)", value: .double(23.9))
            Thread.sleep(forTimeInterval: 0.01)
//        }
    }

    naughtyStrings = []
}

RunLoop.main.run()
