//
// MeasurementTests
// Memoirs
//
// Created by Alex Babaev on 05 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import XCTest
@testable import Memoirs

class MeasurementTests: GenericTestCase {
    func testMeasurementPerformance() {
        let iterations = 5000
        let memoir = VoidMemoir()

        var overallTime: TimeInterval = 0
        measure {
            let startTime = ProcessInfo.processInfo.systemUptime
            let stopwatch = Stopwatch(maxValuesToHold: Int.max, memoir: memoir)
            var mark = stopwatch.mark
            for _ in 0 ..< iterations {
                mark = stopwatch.measureTime(from: mark, name: "Test Measurement")
            }
            let endTime = ProcessInfo.processInfo.systemUptime
            overallTime += endTime - startTime
        }

        let averageIterationTime = overallTime / TimeInterval(iterations * 10)
        print("Average execution time: \(averageIterationTime)")
        XCTAssertTrue(averageIterationTime < 1e-5)
    }
}
