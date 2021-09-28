//
// Stopwatch
// Memoirs
//
// Created by Alex Babaev on 30 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

public typealias Mark = TimeInterval
public typealias Measurement = TimeInterval

public class Stopwatch {
    private let memoir: Memoir

    private let maxValuesToHold: Int
    private let tooManyMeasurementNames: Int = 100000
    private var values: [String: [Measurement]] = [:]

    public init(maxValuesToHold: Int = 10, memoir: Memoir) {
        self.maxValuesToHold = maxValuesToHold
        self.memoir = memoir
    }

    @inlinable
    public var mark: Mark {
        ProcessInfo.processInfo.systemUptime
    }

    public func values(for name: String) -> [Measurement] {
        values[name] ?? []
    }

    public func removeValues(for name: String) -> [Measurement] {
        let result = values[name] ?? []
        values[name] = nil
        return result
    }

    public func removeAllValues() {
        values = [:]
    }

    private var warnedAboutLotsOfValues: Bool = false
    private var counterToSizeTests: Int = 1000

    public func measureTime(
        from mark: Mark, name: String,
        meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(),
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Mark {
        let newMark = self.mark
        let value = newMark - mark
        var values = values[name] ?? []
        values.append(value)
        counterToSizeTests -= 1
        if counterToSizeTests < 0 && values.count > maxValuesToHold {
            counterToSizeTests = 1000
            values = values.suffix(Int(Double(maxValuesToHold) * 0.8))
        }
        self.values[name] = values

        if self.values.keys.count > tooManyMeasurementNames && !warnedAboutLotsOfValues {
            warnedAboutLotsOfValues = true
            memoir.warning("You have lots of different measurements in stopwatch \(self), please be careful")
        }

        memoir.measurement(
            name: name, value: .double(value), meta: meta, tracers: tracers, date: date, file: file, function: function, line: line
        )

        return newMark
    }

    @discardableResult
    public func measure(
        name: String,
        meta: [String: SafeString]? = nil, tracers: [Tracer] = [], date: Date = Date(),
        file: String = #fileID, function: String = #function, line: UInt = #line,
        _ closure: () -> Void
    ) -> Mark {
        let mark = mark
        closure()
        return measureTime(from: mark, name: name, meta: meta, tracers: tracers, date: date, file: file, function: function, line: line)
    }
}
