//
// FilteringMemoir
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Memoir that filter items by level and redirects them to the target memoir.
public class FilteringMemoir: Memoir {
    public struct Configuration {
        @frozen
        public enum Level {
            case verbose
            case debug
            case info
            case warning
            case error
            case critical

            case all
            case disabled

            var integralValue: Int {
                switch self {
                    case .all: return -1
                    case .verbose: return 0
                    case .debug: return 1
                    case .info: return 2
                    case .warning: return 3
                    case .error: return 4
                    case .critical: return 5
                    case .disabled: return Int.max
                }
            }

            @usableFromInline
            func allows(_ level: LogLevel) -> Bool {
                integralValue <= level.integralValue
            }
        }

        public let level: Level
        public let events: Bool
        public let tracers: Bool
        public let measurements: Bool

        public init(level: Level, events: Bool = true, tracers: Bool = true, measurements: Bool = true) {
            self.level = level
            self.events = events
            self.tracers = tracers
            self.measurements = measurements
        }
    }

    public let configurationsByLabel: [String: Configuration]
    public let defaultConfiguration: Configuration

    @usableFromInline
    let memoir: Memoir

    /// Creates a new instance of `FilteringMemoir`.
    /// - Parameters:
    ///  - memoir: The memoir for which items will be filtered.
    ///  - defaultConfiguration: Default configuration.
    ///  - configurationsByLabel: Configurations for specific labels.
    public init(
        memoir: Memoir,
        defaultConfiguration: Configuration,
        configurationsByLabel: [String: Configuration] = [:]
    ) {
        self.memoir = memoir
        self.configurationsByLabel = configurationsByLabel
        self.defaultConfiguration = defaultConfiguration
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let label = tracers.labelTracer.map { $0.string }
        let configuration = label.flatMap { configurationsByLabel[$0] } ?? defaultConfiguration

        var ok = false
        switch item {
            case .log(let level, _):
                ok = configuration.level.allows(level)
            case .event:
                ok = configuration.events
            case .tracer:
                ok = configuration.tracers
            case .measurement:
                ok = configuration.measurements
        }

        if ok {
            memoir.append(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line)
        }
    }
}
