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

        public static func printString(for level: Robologs.Level) -> String {
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

    public static var codePosition: (_ file: String, _ function: String, _ line: UInt) -> String = defaultCodePosition
    public static var censuredString: (_ string: LogString, _ isSensitive: Bool) -> String = defaultCensureString
    public static var logString: (
        _ time: String,
        _ level: Robologs.Level,
        _ message: () -> LogString,
        _ label: String,
        _ scopes: [Scope],
        _ meta: () -> [String: LogString]?,
        _ codePosition: String,
        _ isSensitive: Bool
    ) -> String = defaultLogString
    /// Should be called in every "basic" logger. Intended for test usage and, maybe, intercepting all the logs
    public static var logInterceptor: ((
        _ logger: Loggable, // Logger that called interceptor
        _ logString: String // String, containing parts that were sent to output
    ) -> Void)?

    @inlinable
    public static func defaultCensureString(string: LogString, isSensitive: Bool) -> String {
        string.string(isSensitive: isSensitive)
    }

    @inlinable
    public static func defaultCodePosition(file: String, function: String, line: UInt) -> String {
        // TODO: Remove this hack after Swift Evolution #0274 will be implemented
        let file = file.components(separatedBy: "/").last ?? "?"
        let context = [ file, line == 0 ? "" : "\(line)", function ]
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ":")

        return context
    }

    @inlinable
    public static func defaultLogString(
        time: String,
        level: Robologs.Level?,
        message: () -> LogString,
        label: String,
        scopes: [Scope],
        meta: () -> [String: LogString]?,
        codePosition: String,
        isSensitive: Bool
    ) -> String {
        let meta = meta()?
            .sorted { $0.key < $1.key }
            .map { "\($0): \(censuredString($1, isSensitive))" }
            .joined(separator: ", ")
        let parts = [
            time,
            "\(level.map { "\(Level.printString(for: $0))" } ?? "")",
            "\(label)",
            codePosition,
            meta.map { "[ \($0) ]" } ?? "",
            censuredString(message(), isSensitive),
        ]
        return parts
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
