//
// SimpleTiming
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class SimpleTiming: Timing {
    private var timers: [UUID: PerformanceMonitor] = [:]

    public func start(label: String) -> PerformanceMonitor {
        let timer = PerformanceMonitor(label: label)
        timers[timer.id] = timer
        return timer
    }

    @discardableResult
    public func lap(_ monitor: PerformanceMonitor) -> PerformanceMonitor {
        var timer = timers[monitor.id] ?? monitor
        timer.lap()
        timers[timer.id] = timer
        return timer
    }

    @discardableResult
    public func finish(_ monitor: PerformanceMonitor) -> PerformanceMonitor {
        var timer = timers[monitor.id] ?? monitor
        timer.finish()
        timers[timer.id] = timer
        return timer
    }
}
