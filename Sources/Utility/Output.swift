//
// Output
// Memoirs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

public final class Output: Sendable {
    public struct Markers: Sendable {
        @usableFromInline
        let verbose: String
        @usableFromInline
        let debug: String
        @usableFromInline
        let info: String
        @usableFromInline
        let warning: String
        @usableFromInline
        let error: String
        @usableFromInline
        let critical: String

        @usableFromInline
        let event: String
        @usableFromInline
        let tracer: String
        @usableFromInline
        let measurement: String

        public init(
            verbose: String = "👻",
            debug: String = "👣",
            info: String = "🌵",
            warning: String = "🖖",
            error: String = "⛑",
            critical: String = "👿",
            event: String = "💥",
            tracer: String = "🕶",
            measurement: String = "📈"
        ) {
            self.verbose = verbose
            self.debug = debug
            self.info = info
            self.warning = warning
            self.error = error
            self.critical = critical
            self.event = event
            self.tracer = tracer
            self.measurement = measurement
        }

        public func marker(for level: LogLevel) -> String {
            switch level {
                case .verbose: return verbose
                case .debug: return debug
                case .info: return info
                case .warning: return warning
                case .error: return error
                case .critical: return critical
            }
        }
    }

    @usableFromInline
    let hideSensitiveValues: Bool
    @usableFromInline
    let codePositionType: PrintMemoir.CodePosition
    @usableFromInline
    let shortTracers: Bool
    @usableFromInline
    let separateTracers: Bool
    @usableFromInline
    let tracerFilter: @Sendable (Tracer) -> Bool

    @usableFromInline
    let markers: Markers

    public init(
        markers: Markers = .init(),
        hideSensitiveValues: Bool,
        codePositionType: PrintMemoir.CodePosition,
        shortTracers: Bool,
        separateTracers: Bool,
        tracerFilter: @escaping @Sendable (Tracer) -> Bool
    ) {
        self.markers = markers
        self.hideSensitiveValues = hideSensitiveValues
        self.codePositionType = codePositionType
        self.shortTracers = shortTracers
        self.separateTracers = separateTracers
        self.tracerFilter = tracerFilter
    }

    @inlinable
    public func codePosition(file: String, function: String, line: UInt) -> String {
        guard codePositionType != .none else { return "" }

        let file = file.firstIndex(of: "/").map { String(file[file.index(after: $0) ..< file.endIndex]) } ?? file
        let context = [ file, line == 0 ? "" : "\(line)", codePositionType == .short ? "" : function ]
            .filter { !$0.isEmpty }
            .joined(separator: ":")

        return context
    }

    @inlinable
    public func logString(
        date: String?, level: LogLevel?, message: () -> SafeString, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> [String] {
        let prefix = [
            date,
            codePosition,
            "\(level.map { "\(markers.marker(for: $0))" } ?? "")",
            tracers.labelString(isShort: shortTracers, isSensitive: hideSensitiveValues),
            message().string(hideSensitiveValues: hideSensitiveValues),
            meta()?.commaJoined(isSensitive: hideSensitiveValues),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: hideSensitiveValues)
        return merge(prefix: prefix, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func eventString(
        date: String?, name: String, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> [String] {
        let prefix = [
            date,
            codePosition,
            markers.event,
            tracers.labelString(isShort: shortTracers, isSensitive: hideSensitiveValues),
            hideSensitiveValues ? "???" : name,
            meta()?.commaJoined(isSensitive: hideSensitiveValues),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: hideSensitiveValues)
        return merge(prefix: prefix, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func measurementString(
        date: String?, name: String, value: MeasurementValue, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> [String] {
        var prefix = [
            date,
            codePosition,
            markers.measurement,
            tracers.labelString(isShort: shortTracers, isSensitive: hideSensitiveValues),
        ]
        switch value {
            case .double(let value):
                prefix.append(contentsOf: [
                    hideSensitiveValues ? "???" : "\(name) -> \(value)",
                    meta()?.commaJoined(isSensitive: hideSensitiveValues),
                ])
            case .int(let value):
                prefix.append(contentsOf: [
                    hideSensitiveValues ? "???" : "\(name) -> \(value)",
                    meta()?.commaJoined(isSensitive: hideSensitiveValues),
                ])
            case .meta:
                prefix.append(contentsOf: [
                    hideSensitiveValues ? "???" : "\(name)",
                    meta()?.commaJoined(isSensitive: hideSensitiveValues),
                ])
            case .histogram(let value):
                let values = value
                    .map { bucket in
                        "\(bucket.range.lowerBound)..\(bucket.range.upperBound): \(bucket.count)"
                    }
                    .joined(separator: "; ")
                prefix.append(contentsOf: [
                    hideSensitiveValues ? "???" : "\(name) -> [ \(values) ]",
                    meta()?.commaJoined(isSensitive: hideSensitiveValues),
                ])
        }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: hideSensitiveValues)
        return merge(prefix: prefix.compactMap { $0 }, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func tracerString(
        date: String?, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> [String] {
        let prefix = [
            date,
            codePosition,
            markers.tracer,
            "Tracer: \(hideSensitiveValues ? "???" : (shortTracers ? tracer.stringShort : tracer.string))",
            meta()?.commaJoined(isSensitive: hideSensitiveValues),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: hideSensitiveValues)
        return merge(prefix: prefix, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func tracerEndString(
        date: String?, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> [String] {
        let prefix = [
            date,
            codePosition,
            markers.tracer,
            "End Tracer: \(hideSensitiveValues ? "???" : (shortTracers ? tracer.stringShort : tracer.string))",
            meta()?.commaJoined(isSensitive: hideSensitiveValues),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: hideSensitiveValues)
        return merge(prefix: prefix, suffix: suffix, separateTracers: separateTracers)
    }

    @usableFromInline
    let tracersSeparator: String = " <<- "

    @inlinable
    func merge(prefix: [String], suffix: String, separateTracers: Bool) -> [String] {
        if suffix.isEmpty {
            return prefix
        } else {
            return prefix + (separateTracers ? [ tracersSeparator, suffix ] : [ suffix ])
        }
    }
}

extension Array where Element == Tracer {
    @usableFromInline
    func labelString(isShort: Bool, isSensitive: Bool) -> String? {
        guard let first = first else { return nil }
        guard !isSensitive else { return "[???]" }

        return "[\(isShort ? first.stringShort : first.string)]"
    }
}

extension Array where Element == Tracer {
    @usableFromInline
    func allJoined(showFirst: Bool, isShort: Bool, isSensitive: Bool) -> String {
        let list = showFirst
            ? self
            : Array(dropFirst())
        return list.isEmpty ? "" : isSensitive ? "???" : list.map { isShort ? $0.stringShort : $0.string }.joined(separator: " <- ")
    }
}

extension Dictionary where Key == String, Value == SafeString {
    @usableFromInline
    func commaJoined(isSensitive: Bool) -> String? {
        isEmpty
            ? nil
            : "[\(map { "\($0): \($1.string(hideSensitiveValues: isSensitive))" }.joined(separator: ", "))]"
    }
}
