//
// Output
// Memoirs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class Output {
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
    var isSensitive: Bool
    @usableFromInline
    var shortCodePosition: Bool
    @usableFromInline
    var shortTracers: Bool
    @usableFromInline
    var separateTracers: Bool
    @usableFromInline
    var tracersFilter: (Tracer) -> Bool

    public init(
        isSensitive: Bool,
        shortCodePosition: Bool,
        shortTracers: Bool,
        separateTracers: Bool,
        tracersFilter: @escaping (Tracer) -> Bool
    ) {
        self.isSensitive = isSensitive
        self.shortCodePosition = shortCodePosition
        self.shortTracers = shortTracers
        self.separateTracers = separateTracers
        self.tracersFilter = tracersFilter
    }

    public static var logInterceptor: ((
        _ memoir: Memoir, // Memoir that called interceptor
        _ item: MemoirItem, // Item that is being appended
        _ logString: String // String, containing parts that were sent to output
    ) -> Void)?

    @inlinable
    public func codePosition(file: String, function: String, line: UInt) -> String {
        let context = [ file, line == 0 ? "" : "\(line)", shortCodePosition ? "" : function ]
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ":")

        return context
    }

    @inlinable
    public func logString(
        time: String, level: LogLevel?, message: () -> SafeString, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> String {
        let prefix = [
            time,
            codePosition,
            "\(level.map { "\(Marker.printString(for: $0))" } ?? "")",
            tracers.labelString(isSensitive: isSensitive),
        ].spaceMerged
        let message = [
            message().string(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, short: shortTracers, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func eventString(
        time: String, name: String, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> String {
        let prefix = [
            time,
            codePosition,
            Marker.event,
            tracers.labelString(isSensitive: isSensitive),
        ].spaceMerged
        let message = [
            isSensitive ? "???" : name,
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, short: shortTracers, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func measurementString(
        time: String, name: String, value: MeasurementValue, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> String {
        let prefix = [
            time,
            codePosition,
            Marker.measurement,
            tracers.labelString(isSensitive: isSensitive),
        ].spaceMerged
        let message: String
        switch value {
            case .double(let value):
                message = [
                    isSensitive ? "???" : "\(name) -> \(value)",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ].spaceMerged
            case .int(let value):
                message = [
                    isSensitive ? "???" : "\(name) -> \(value)",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ].spaceMerged
            case .meta:
                message = [
                    isSensitive ? "???" : "\(name)",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ].spaceMerged
            case .histogram(let value):
                let values = value
                    .map { bucket in
                        "\(bucket.range.lowerBound)..\(bucket.range.upperBound): \(bucket.count)"
                    }
                    .joined(separator: "; ")
                message = [
                    isSensitive ? "???" : "\(name) -> [ \(values) ]",
                    meta()?.commaJoined(isSensitive: isSensitive),
                ].spaceMerged
        }
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, short: shortTracers, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func tracerString(
        time: String, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> String {
        let prefix = [
            time,
            codePosition,
            Marker.tracer,
            tracers.labelString(isSensitive: isSensitive),
        ].spaceMerged
        let message = [
            "Tracer: \(isSensitive ? "???" : tracer.output)",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, short: shortTracers, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix, separateTracers: separateTracers)
    }

    @inlinable
    public func tracerEndString(
        time: String, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String
    ) -> String {
        let prefix = [
            time,
            codePosition,
            Marker.tracer,
            tracers.labelString(isSensitive: isSensitive),
        ].spaceMerged
        let message = [
            "End Tracer: \(isSensitive ? "???" : tracer.output)",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, short: shortTracers, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix, separateTracers: separateTracers)
    }

    @usableFromInline
    let tracersSeparator: String = "            • "

    @inlinable
    func format(prefix: String, message: String, suffix: String, separateTracers: Bool) -> String {
        if suffix.isEmpty {
            return "\(prefix) \(message)"
        } else {
            return "\(prefix) \(message)\(separateTracers ? tracersSeparator : " ")\(suffix)"
        }
    }
}

extension Array where Element == Tracer {
    @usableFromInline
    func labelString(isSensitive: Bool) -> String? {
        labelTracer.map { isSensitive ? "???" : "[\($0.string)]" }
    }
}

extension Array where Element == String? {
    @usableFromInline
    var spaceMerged: String {
        compactMap { $0 }.spaceMerged
    }
}

extension Array where Element == String {
    @usableFromInline
    var spaceMerged: String {
        filter { !$0.isEmpty }.joined(separator: " ")
    }
}

extension Array where Element == Tracer {
    @usableFromInline
    func allJoined(showLabel: Bool, short: Bool, isSensitive: Bool) -> String {
        let list = showLabel
            ? self
            : filter { $0 != label }
        return list.isEmpty ? "" : isSensitive ? "???" : list.map { short ? $0.stringShort : $0.string }.joined(separator: ", ")
    }
}

extension Dictionary where Key == String, Value == SafeString {
    @usableFromInline
    func commaJoined(isSensitive: Bool) -> String {
        isEmpty
            ? ""
            : "[\(sorted { $0.key < $1.key }.map { "\($0): \($1.string(isSensitive: isSensitive))" }.joined(separator: ", "))]"
    }
}

extension Tracer {
    @usableFromInline
    var output: String { string }
}
