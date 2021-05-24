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
        isSensitive: Bool
    ) -> String {
        [
            time,
            "\(level.map { "\(Marker.printString(for: $0))" } ?? "")",
            codePosition,
            tracers.labelTracer.map { isSensitive ? "???" : $0.string },
            message().string(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
            tracers.allJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func eventString(
        time: String, name: String, tracers: [Tracer], meta: () -> [String: SafeString]?, codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            Marker.event,
            codePosition,
            tracers.labelTracer.map { isSensitive ? "???" : $0.string },
            isSensitive ? "???" : name,
            meta()?.commaJoined(isSensitive: isSensitive),
            tracers.allJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func measurementString(
        time: String, name: String, value: Double, tracers: [Tracer], meta: () -> [String: SafeString]?,
        codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            Marker.measurement,
            codePosition,
            isSensitive ? "???" : "\(name)->\(value)",
            tracers.labelTracer.map { isSensitive ? "???" : $0.string },
            meta()?.commaJoined(isSensitive: isSensitive),
            tracers.allJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func tracerString(
        time: String, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?, codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            Marker.tracer,
            codePosition,
            tracers.labelTracer.map { isSensitive ? "???" : $0.string },
            "Tracer: \(isSensitive ? "???" : tracer.output)",
            meta()?.commaJoined(isSensitive: isSensitive),
            tracers.allJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func tracerEndString(
        time: String, tracer: Tracer, tracers: [Tracer], meta: () -> [String: SafeString]?, codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            Marker.tracer,
            codePosition,
            tracers.labelTracer.map { isSensitive ? "???" : $0.string },
            "End Tracer: \(isSensitive ? "???" : tracer.output)",
            meta()?.commaJoined(isSensitive: isSensitive),
            tracers.allJoined(isSensitive: isSensitive),
        ].spaceMerged
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
    func allJoined(isSensitive: Bool) -> String {
        isEmpty ? "" : isSensitive ? "???" : "{\(map { $0.string }.joined(separator: ", "))}"
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
