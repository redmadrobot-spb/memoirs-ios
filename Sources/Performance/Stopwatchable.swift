//
// Stopwatchable
// Robologs
//
// Created by Alex Babaev on 30 April 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

enum StopwatchableError: Error {
    case cantFindMonitor(label: String)
}

/// Performance timing of code blocks.
/// TODO: Add an example.
public protocol Stopwatchable {
    /// Marks start of timing period for the label.
    @discardableResult
    func tick(_ label: String) -> PerfMonitor
    /// Marks end of the measurement period. Simultaneously it marks start of the next period.
    /// So it is not needed to call `tick` after `tock`.
    @discardableResult
    func tock(_ label: String) throws -> PerfMonitor
}

public extension Stopwatchable {
    func measure(label: String, _ closure: () -> Void) -> PerfMonitor {
        var monitor = tick(label)
        closure()
        monitor.tock()
        return monitor
    }
}
