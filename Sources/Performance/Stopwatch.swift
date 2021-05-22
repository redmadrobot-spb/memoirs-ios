//
// Stopwatch
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class Stopwatch: Stopwatchable {
    private var values: [String: [TimeInterval]] = [:]

    @inlinable
    public var mark: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }

    public init() {
    }

    public func values(for label: String) -> [Measurement] {
        values[label] ?? []
    }

    public func logValue(_ value: Double, label: String, file: String = #file, function: String = #function, line: UInt = #line) {
        values[label, default: []].append(value)
    }
}
