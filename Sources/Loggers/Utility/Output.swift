//
// HelperFunctions
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public enum Output {
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

    public static var logInterceptor: ((
        _ memoir: Memoir, // Memoir that called interceptor
        _ item: MemoirItem, // Item that is being appended
        _ logString: String // String, containing parts that were sent to output
    ) -> Void)?

    @inlinable
    public static func codePosition(file: String, function: String, line: UInt) -> String {
        // TODO: Remove this hack after Swift Evolution #0274 will be implemented
        let file = file.components(separatedBy: "/").last ?? "?"
        let context = [ file, line == 0 ? "" : "\(line)", function ]
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ":")

        return context
    }

    @inlinable
    public static func logString(
        time: String,
        level: LogLevel?,
        message: () -> SafeString,
        tracers: [Tracer],
        meta: () -> [String: SafeString]?,
        codePosition: String,
        isSensitive: Bool,
        tracersFilter: (Tracer) -> Bool
    ) -> String {
        let prefix = [
            time,
        ].spaceMerged
        let message = [
            codePosition,
            "\(level.map { "\(Marker.printString(for: $0))" } ?? "")",
            tracers.labelString(isSensitive: isSensitive),
            message().string(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix)
    }

    @inlinable
    public static func eventString(
        time: String, name: String, tracers: [Tracer], meta: () -> [String: SafeString]?, codePosition: String,
        isSensitive: Bool, tracersFilter: (Tracer) -> Bool
    ) -> String {
        let prefix = [
            time,
        ].spaceMerged
        let message = [
            codePosition,
            Marker.event,
            tracers.labelString(isSensitive: isSensitive),
            isSensitive ? "???" : name,
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix)
    }

    @inlinable
    public static func measurementString(
        time: String, name: String, value: Double, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String, isSensitive: Bool, tracersFilter: (Tracer) -> Bool
    ) -> String {
        let prefix = [
            time,
        ].spaceMerged
        let message = [
            codePosition,
            Marker.measurement,
            tracers.labelString(isSensitive: isSensitive),
            isSensitive ? "???" : "\(name)->\(value)",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix)
    }

    @inlinable
    public static func tracerString(
        time: String, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?, codePosition: String,
        isSensitive: Bool, tracersFilter: (Tracer) -> Bool
    ) -> String {
        let prefix = [
            time,
        ].spaceMerged
        let message = [
            codePosition,
            Marker.tracer,
            tracers.labelString(isSensitive: isSensitive),
            "Tracer: \(isSensitive ? "???" : tracer.output)",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix)
    }

    @inlinable
    public static func tracerEndString(
        time: String, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?, codePosition: String,
        isSensitive: Bool, tracersFilter: (Tracer) -> Bool
    ) -> String {
        let prefix = [
            time,
        ].spaceMerged
        let message = [
            codePosition,
            Marker.tracer,
            tracers.labelString(isSensitive: isSensitive),
            "End Tracer: \(isSensitive ? "???" : tracer.output)",
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
        let suffix = tracers.filter(tracersFilter).allJoined(showLabel: false, isSensitive: isSensitive)
        return format(prefix: prefix, message: message, suffix: suffix)
    }

    @inlinable
    static func format(prefix: String, message: String, suffix: String) -> String {
        if suffix.isEmpty {
            return "\(prefix) \(message)"
        } else {
            let suffixPadding: String = [String](repeating: " ", count: prefix.count + 1).joined()
            return "\(prefix) \(message)\n\(suffixPadding)\(suffix)"
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
    func allJoined(showLabel: Bool, isSensitive: Bool) -> String {
        let list = showLabel
            ? self
            : filter { $0 != label }
        return list.isEmpty ? "" : isSensitive ? "???" : list.map { $0.string }.joined(separator: ", ")
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
