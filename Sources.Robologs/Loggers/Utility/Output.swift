//
// HelperFunctions
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

// TODO: This is a wrong place for this kind of customization.
public extension Level {
    /// You can redefine these to display other symbols in PrintLogger
    static var stringVerbose: String = "VERBOSE"
    /// You can redefine these to display other symbols in PrintLogger
    static var stringDebug: String = "DEBUG"
    /// You can redefine these to display other symbols in PrintLogger
    static var stringInfo: String = "INFO"
    /// You can redefine these to display other symbols in PrintLogger
    static var stringWarning: String = "WARNING"
    /// You can redefine these to display other symbols in PrintLogger
    static var stringError: String = "ERROR"
    /// You can redefine these to display other symbols in PrintLogger
    static var stringCritical: String = "CRITICAL"

    var printString: String {
        switch self {
            case .verbose: return Self.stringVerbose
            case .debug: return Self.stringDebug
            case .info: return Self.stringInfo
            case .warning: return Self.stringWarning
            case .error: return Self.stringError
            case .critical: return Self.stringCritical
        }
    }
}

public final class Output {
    public static var codePosition: (_ file: String, _ function: String, _ line: UInt) -> String = defaultCodePosition
    public static var censuredString: (_ string: LogString, _ isSensitive: Bool) -> String = defaultCensureString
    public static var logString: (
        _ time: String,
        _ level: Level,
        _ message: () -> LogString,
        _ label: String,
        _ scopes: [Scope],
        _ meta: () -> [String: LogString]?,
        _ codePosition: String,
        _ isSensitive: Bool
    ) -> String = defaultLogString
    /// Should be called in every "basic" logger. Intended for test usage and, maybe, intercepting all the logs
    public static var logInterceptor: ((
        _ logger: Logger, // Logger that called interceptor
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
        level: Level?,
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
            "\(level.map { "\($0.printString)" } ?? "")",
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
