//
// OSLogMemoir
// Robologs
//
// Created by Dmitry Shadrin on 03.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import os.log

/// `(Memoir)` - implementation which use `os.log` logging system.
@available(iOS 12.0, *)
public class OSLogMemoir: Memoir {
    /// An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    /// For example, `com.your_company.your_subsystem_name`.
    /// The subsystem is used for categorization and filtering of related log messages, as well as for grouping related logging settings.
    private let subsystem: String
    private let isSensitive: Bool
    private var osLogs: SynchronizedDictionary<String, OSLog> = [:]

    /// Creates a new instance of `OSLogMemoir`.
    /// - Parameter subsystem: An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    public init(subsystem: String, isSensitive: Bool) {
        self.isSensitive = isSensitive
        self.subsystem = subsystem
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let codePosition = Output.codePosition(file: file, function: function, line: line)
        let description: String
        var osLogType: OSLogType = .debug
        let label: OSLog = osLog(with: tracers.label ?? "NoLabel")
        switch item {
            case .log(let level, let message):
                description = Output.logString(
                    time: "", level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
                osLogType = logType(from: level)
            case .event(let name):
                description = Output.eventString(
                    time: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, false):
                description = Output.tracerString(
                    time: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .tracer(let tracer, true):
                description = Output.tracerEndString(
                    time: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
            case .measurement(let name, let value):
                description = Output.measurementString(
                    time: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition, isSensitive: false
                )
        }
        os_log(osLogType, log: label, "%{public}@", description)
        Output.logInterceptor?(self, item, description)
    }

    @usableFromInline
    func logType(from level: LogLevel) -> OSLogType {
        switch level {
            case .verbose: return .debug
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
        }
    }

    @usableFromInline
    func osLog(with label: String) -> OSLog {
        if let osLog = osLogs[label] {
            return osLog
        } else {
            let osLog = OSLog(subsystem: subsystem, category: label)
            osLogs[label] = osLog
            return osLog
        }
    }
}

private class SynchronizedDictionary<Key, Value>: ExpressibleByDictionaryLiteral where Key: Hashable {
    private var dictionary: [Key: Value]
    private let queue: DispatchQueue = DispatchQueue(label: "com.redmadrobot.robologs.synchronizedDictionary", attributes: .concurrent)

    required init(dictionaryLiteral elements: (Key, Value)...) {
        dictionary = Dictionary(uniqueKeysWithValues: elements)
    }

    subscript(key: Key) -> Value? {
        get {
            queue.sync {
                dictionary[key]
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key] = newValue
            }
        }
    }
}
