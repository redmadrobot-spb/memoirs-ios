//
// HelperFunctions
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public enum Output {
    public enum Level {
        static var verbose: String = "👻"
        static var debug: String = "👣"
        static var info: String = "🌵"
        static var warning: String = "🖖"
        static var error: String = "⛑"
        static var critical: String = "👿"

        public static func printString(for level: Log.Level) -> String {
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
        _ logger: Loggable, // Logger that called interceptor
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
        level: Log.Level?,
        message: () -> Log.String,
        tracers: [Log.Tracer],
        meta: () -> [String: Log.String]?,
        codePosition: String,
        isSensitive: Bool
    ) -> String {
        [
            time,
            "\(level.map { "\(Level.printString(for: $0))" } ?? "")",
            codePosition,
            tracers.label(isSensitive: isSensitive),
            message().string(isSensitive: isSensitive),
            tracers.nonLabelJoined(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func eventString(
        time: String, name: String, tracers: [Log.Tracer], meta: () -> [String: Log.String]?, codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            "💥",
            codePosition,
            tracers.label(isSensitive: isSensitive),
            isSensitive ? "???" : name,
            tracers.nonLabelJoined(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func measurementString(
        time: String, name: String, value: Double, tracers: [Log.Tracer], meta: () -> [String: Log.String]?,
        codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            "📈",
            codePosition,
            isSensitive ? "???" : "\(name)->\(value)",
            tracers.label(isSensitive: isSensitive),
            tracers.nonLabelJoined(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func tracerString(
        time: String, tracer: Log.Tracer, tracers: [Log.Tracer], meta: () -> [String: Log.String]?, codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            "🕶",
            codePosition,
            tracers.label(isSensitive: isSensitive),
            "Updated: \(isSensitive ? "???" : tracer.output)",
            tracers.nonLabelJoined(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
        ].spaceMerged
    }

    @inlinable
    public static func tracerEndString(
        time: String, tracer: Log.Tracer, tracers: [Log.Tracer], meta: () -> [String: Log.String]?, codePosition: String, isSensitive: Bool
    ) -> String {
        [
            time,
            "🕶",
            codePosition,
            tracers.label(isSensitive: isSensitive),
            "Ended: \(isSensitive ? "???" : tracer.output)",
            tracers.nonLabelJoined(isSensitive: isSensitive),
            meta()?.commaJoined(isSensitive: isSensitive),
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

extension Array where Element == Log.Tracer {
    @usableFromInline
    func label(isSensitive: Bool) -> String? {
        first {
            if case .label = $0 {
                return true
            } else {
                return false
            }
        }.map { isSensitive ? "???" : $0.string }
    }

    @usableFromInline
    func nonLabelJoined(isSensitive: Bool) -> String {
        let tracers = filter {
            if case .label = $0 {
                return false
            } else {
                return true
            }
        }
        return tracers.isEmpty ? "" : isSensitive ? "???" : "{\(tracers.map { $0.string }.joined(separator: ", "))}"
    }
}

extension Dictionary where Key == String, Value == Log.String {
    @usableFromInline
    func commaJoined(isSensitive: Bool) -> String {
        isEmpty
            ? ""
            : "[\(sorted { $0.key < $1.key }.map { "\($0): \($1.string(isSensitive: isSensitive))" }.joined(separator: ", "))]"
    }
}

extension Log.Tracer {
    @usableFromInline
    var output: Swift.String { string }
}
