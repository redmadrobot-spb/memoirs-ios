//
// Stopwatchable
// Robologs
//
// Created by Alex Babaev on 30 April 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public typealias Mark = TimeInterval
public typealias Measurement = TimeInterval

/// Performance timing of code blocks.
/// TODO: Add an example.
public protocol Stopwatchable {
    /// Returns current time (abstract value, not directly connected with Date time intervals).
    var mark: Mark { get }

    /// Returns values stored for the label.
    func values(for label: String) -> [Measurement]

    /// Logs value for the label.
    func logValue(_ value: Double, label: String, file: String, function: String, line: UInt)
}

public extension Stopwatchable {
    @discardableResult
    func logInterval(
        from mark: TimeInterval, label: String, file: String = #file, function: String = #function, line: UInt = #line
    ) -> Mark {
        let newMark = self.mark
        logValue(newMark - mark, label: label, file: file, function: function, line: line)
        return newMark
    }

    @discardableResult
    func measure(label: String, file: String = #file, function: String = #function, line: UInt = #line, _ closure: () -> Void) -> Mark {
        let mark = mark
        closure()
        return logInterval(from: mark, label: label)
    }
}
