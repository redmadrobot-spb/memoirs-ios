//
// PerformanceMonitor
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Tocks here are using `ProcessInfo.processInfo.systemUptime`. They will be wrong in absolute time if computer is asleep because of that.
public struct PerformanceMonitor {
    public let name: String
    public var measurements: [TimeInterval] = []

    public init(name: String) {
        measurements.append(ProcessInfo.processInfo.systemUptime)
        self.name = name
    }

    @discardableResult
    public mutating func tock() -> TimeInterval {
        let timestamp = Date.timeIntervalSinceReferenceDate
        measurements.append(ProcessInfo.processInfo.systemUptime)
        return timestamp
    }

    // MARK: - Aggregating functions

    // Yup, must crash if no values present. Can't be used in init.
    public var firstTick: TimeInterval {
        measurements[0]
    }
    // Yup, must crash if no values present. Can't be used in init.
    public var lastTick: TimeInterval {
        measurements[measurements.count - 1] + Date.timeIntervalBetween1970AndReferenceDate
    }

    public var tickTocks: [TimeInterval] {
        zip(measurements.dropLast(), measurements.dropFirst()).map { $0.1 - $0.0 }
    }
    public var firstTickTock: TimeInterval { tickTocks.first ?? 0 }
    public var lastTickTock: TimeInterval { tickTocks.last ?? 0 }
    public var minTickTock: TimeInterval { tickTocks.min() ?? 0 }
    public var maxTickTock: TimeInterval { tickTocks.max() ?? 0 }
    public var averageTickTock: TimeInterval { tickTocks.isEmpty ? 0.0 : tickTocks.reduce(0.0, +) / TimeInterval(tickTocks.count) }
}
