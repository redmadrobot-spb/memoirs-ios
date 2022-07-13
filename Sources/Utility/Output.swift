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
    public enum Marker {
        static var verbose: String = "👻"
        static var debug: String = "👣"
        static var info: String = "🌵"
        static var warning: String = "🖖"
        static var error: String = "⛑"
        static var critical: String = "👿"

        @usableFromInline
        static var event: String = "💥"
        @usableFromInline
        static var tracer: String = "🕶"
        @usableFromInline
        static var measurement: String = "📈"

        public static func printString(for level: LogLevel) -> String {
            switch level {
                case .verbose: return Self.verbose
                case .debug: return Self.debug
                case .info: return Self.info
                case .warning: return Self.warning
                case .error: return Self.error
                case .critical: return Self.critical
            }
        }
    }

    @usableFromInline
    let isSensitive: Bool
    @usableFromInline
    let codePositionType: PrintMemoir.CodePosition
    @usableFromInline
    let shortTracers: Bool
    @usableFromInline
    let separateTracers: Bool
    @usableFromInline
    let tracerFilter: @Sendable (Tracer) -> Bool

    public init(
        isSensitive: Bool,
        codePositionType: PrintMemoir.CodePosition,
        shortTracers: Bool,
        separateTracers: Bool,
        tracerFilter: @escaping @Sendable (Tracer) -> Bool
    ) {
        self.isSensitive = isSensitive
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
            "\(level.map { "\(Marker.printString(for: $0))" } ?? "")",
            tracers.labelString(isShort: shortTracers, isSensitive: isSensitive),
            message().string(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: isSensitive)
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
            Marker.event,
            tracers.labelString(isShort: shortTracers, isSensitive: isSensitive),
            isSensitive ? "???" : name,
            meta()?.commaJoined(isSensitive: isSensitive),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: isSensitive)
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
            Marker.measurement,
            tracers.labelString(isShort: shortTracers, isSensitive: isSensitive),
        ]
        switch value {
            case .double(let value):
                prefix.append(contentsOf: [
                    isSensitive ? "???" : "\(name) -> \(value)",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ])
            case .int(let value):
                prefix.append(contentsOf: [
                    isSensitive ? "???" : "\(name) -> \(value)",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ])
            case .meta:
                prefix.append(contentsOf: [
                    isSensitive ? "???" : "\(name)",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ])
            case .histogram(let value):
                let values = value
                    .map { bucket in
                        "\(bucket.range.lowerBound)..\(bucket.range.upperBound): \(bucket.count)"
                    }
                    .joined(separator: "; ")
                prefix.append(contentsOf: [
                    isSensitive ? "???" : "\(name) -> [ \(values) ]",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ])
        }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: isSensitive)
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
            Marker.tracer,
            "Tracer: \(isSensitive ? "???" : (shortTracers ? tracer.stringShort : tracer.string))",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: isSensitive)
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
            Marker.tracer,
            "End Tracer: \(isSensitive ? "???" : (shortTracers ? tracer.stringShort : tracer.string))",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].compactMap { $0 }
        let suffix = tracers.filter(tracerFilter).allJoined(showFirst: false, isShort: shortTracers, isSensitive: isSensitive)
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
            : "[\(map { "\($0): \($1.string(isSensitive: isSensitive))" }.joined(separator: ", "))]"
    }
}
