//
// MeasurementTests
// Robologs
//
// Created by Alex Babaev on 05 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import XCTest
@testable import Robologs

class MeasurementTests: GenericTestCase {
    func testPerformanceMonitor() {
        let label = "test_\(Int.random(in: 0 ... 239))"
        let randomInterval = TimeInterval.random(in: 0 ... 0.5)

        var monitor = PerformanceMonitor(label: label)
        Thread.sleep(forTimeInterval: randomInterval)
        monitor.tock()
//        fputs(
//            """
//            Monitor intervals: \(monitor.intervals);
//            random time: \(randomInterval);
//            difference: \(monitor.averageInterval - randomInterval)
//
//            """,
//            stdout
//        )

        XCTAssertEqual(label, monitor.label)
        XCTAssertEqual(monitor.uptimes.count, 2)
        XCTAssertTrue(monitor.firstTick < monitor.lastTick)
        XCTAssertTrue(monitor.tickTocks.count == 1)
        XCTAssertTrue(abs(monitor.minTickTock - randomInterval) < 0.01)
        XCTAssertTrue(abs(monitor.maxTickTock - randomInterval) < 0.01)
        XCTAssertTrue(abs(monitor.averageTickTock - randomInterval) < 0.01)
        XCTAssertTrue(abs(monitor.averageTickTock - randomInterval) < 0.01)
    }

    func testTockPerformance() {
        let label = "test_\(Int.random(in: 0 ... 239))"
        let iterations = 10000

        let startTime = ProcessInfo.processInfo.systemUptime
        var monitor = PerformanceMonitor(label: label)
        for _ in 0 ..< iterations {
            monitor.tock()
        }
        let endTime = ProcessInfo.processInfo.systemUptime

        let overallTime = endTime - startTime
        let averageIterationTime = overallTime/TimeInterval(iterations)
        XCTAssertTrue(averageIterationTime < 1e-6)
    }
}
