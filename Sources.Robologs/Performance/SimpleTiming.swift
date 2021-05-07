//
// SimpleTiming
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class SimpleStopwatch: Stopwatch {
    private var monitorsByLabel: [String: PerformanceMonitor] = [:]

    public init() {
    }

    @discardableResult
    public func tick(_ label: String) -> PerformanceMonitor {
        let timer = PerformanceMonitor(label: label)
        monitorsByLabel[label] = timer
        return timer
    }

    @discardableResult
    public func tock(_ label: String) throws -> PerformanceMonitor {
        guard var timer = monitorsByLabel[label] else {
            throw StopwatchError.cantFindMonitor(label: label)
        }

        timer.tock()
        monitorsByLabel[label] = timer
        return timer
    }
}
