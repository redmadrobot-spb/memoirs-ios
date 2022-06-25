//
// FilteringMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 05 December 2019. Updated by Alex Babaev
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Memoir that filter items by level and redirects them to the target memoir.
public final class FilteringMemoir: Memoir {
    public struct Configuration: Sendable {
        @frozen
        public enum Level: Sendable {
            case all

            case verbose
            case debug
            case info
            case warning
            case error
            case critical

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

        public let minLevelShown: Level

        public let applyToNestedByTrace: Bool

        public let showEvents: Bool
        public let showTracers: Bool
        public let showMeasurements: Bool

        public init(
            minLevelShown: Level,
            applyToNestedByTrace: Bool = false,
            showEvents: Bool = true,
            showTracers: Bool = true,
            showMeasurements: Bool = true
        ) {
            self.minLevelShown = minLevelShown
            self.applyToNestedByTrace = applyToNestedByTrace
            self.showEvents = showEvents
            self.showTracers = showTracers
            self.showMeasurements = showMeasurements
        }
    }

    public let configurationsByTracer: [Tracer: Configuration]
    public let defaultConfiguration: Configuration

    @usableFromInline
    let memoir: Memoir

    /// Creates a new instance of `FilteringMemoir`.
    /// - Parameters:
    ///  - memoir: The memoir for which items will be filtered.
    ///  - defaultConfiguration: Default configuration.
    ///  - configurationsByTracer: Configurations for specific labels.
    public init(
        memoir: Memoir,
        defaultConfiguration: Configuration,
        configurationsByTracer: [Tracer: Configuration] = [:]
    ) {
        self.memoir = memoir
        self.configurationsByTracer = configurationsByTracer
        self.defaultConfiguration = defaultConfiguration
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) {
        let allowances: [Bool] = configurationsByTracer
            .lazy
            .filter { tracer, configuration in
                tracers.contains(tracer) && (tracers.first == tracer || (tracers.first != tracer && configuration.applyToNestedByTrace))
            }
            .map { tracer, configuration in
                switch item {
                    case .log(let level, _):
                        return configuration.minLevelShown.allows(level)
                    case .event:
                        return configuration.showEvents
                    case .tracer:
                        return configuration.showTracers
                    case .measurement:
                        return configuration.showMeasurements
                }
            }
        var allowed = allowances.contains { $0 }
        if allowances.isEmpty {
            switch item {
                case .log(let level, _):
                    allowed = defaultConfiguration.minLevelShown.allows(level)
                case .event:
                    allowed = defaultConfiguration.showEvents
                case .tracer:
                    allowed = defaultConfiguration.showTracers
                case .measurement:
                    allowed = defaultConfiguration.showMeasurements
            }
        }

        if allowed {
            memoir.append(
                item, meta: meta(), tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate,
                file: file, function: function, line: line
            )
        }
    }
}
