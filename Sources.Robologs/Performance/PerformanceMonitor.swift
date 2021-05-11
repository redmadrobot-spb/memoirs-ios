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
    public let label: String
    public var uptimes: [TimeInterval] = []

    public init(label: String) {
        uptimes.append(ProcessInfo.processInfo.systemUptime)
        self.label = label
    }

    @discardableResult
    public mutating func tock() -> TimeInterval {
        let timestamp = Date.timeIntervalSinceReferenceDate
        uptimes.append(ProcessInfo.processInfo.systemUptime)
        return timestamp
    }

    // MARK: - Aggregating functions

    // Yup, must crash if no values present. Can't be used in init.
    public var firstTick: TimeInterval {
        uptimes[0]
    }
    // Yup, must crash if no values present. Can't be used in init.
    public var lastTick: TimeInterval {
        uptimes[uptimes.count - 1] + Date.timeIntervalBetween1970AndReferenceDate
    }

    public var tickTocks: [TimeInterval] {
        zip(uptimes.dropLast(), uptimes.dropFirst()).map { $0.1 - $0.0 }
    }
    public var firstTickTock: TimeInterval { tickTocks.first ?? 0 }
    public var lastTickTock: TimeInterval { tickTocks.last ?? 0 }
    public var minTickTock: TimeInterval { tickTocks.min() ?? 0 }
    public var maxTickTock: TimeInterval { tickTocks.max() ?? 0 }
    public var averageTickTock: TimeInterval { tickTocks.isEmpty ? 0.0 : tickTocks.reduce(0.0, +) / TimeInterval(tickTocks.count) }
}
