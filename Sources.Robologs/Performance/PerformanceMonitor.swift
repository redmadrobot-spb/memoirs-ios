//
// PerformanceMonitor
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public struct PerformanceMonitor {
    public let id: UUID
    public let label: String
    public let startTimestamp: TimeInterval
    public var lapTimestamps: [TimeInterval] = []

    init(label: String) {
        id = UUID()
        startTimestamp = PerformanceMonitor.currentTimestamp()
        self.label = label
    }

    private static func currentTimestamp() -> TimeInterval {
        Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate
    }

    mutating func lap() {
        lapTimestamps.append(PerformanceMonitor.currentTimestamp())
    }

    mutating func finish() {
        lap()
    }
}
