//
// OSLogMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 03 December 2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

#if canImport(os)

import Foundation
import os.log

/// `(Memoir)` - implementation which use `os.log` logging system.
@available(iOS 12.0, *)
public class OSLogMemoir: Memoir {
    /// An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    /// For example, `com.your_company.your_subsystem_name`.
    /// The subsystem is used for categorization and filtering of related log messages, as well as for grouping related logging settings.
    private let subsystem: String
    private var osLogs: SynchronizedDictionary<String, OSLog> = [:]

    @usableFromInline
    let output: Output

    /// Creates a new instance of `OSLogMemoir`.
    /// - Parameter subsystem: An identifier string, in reverse DNS notation, representing the subsystem that’s performing logging.
    public init(subsystem: String, isSensitive: Bool, tracersFilter: @escaping (Tracer) -> Bool = { _ in false }) {
        self.subsystem = subsystem
        output = Output(
            isSensitive: isSensitive,
            codePositionType: .full, shortTracers: false, separateTracers: true,
            tracersFilter: tracersFilter
        )
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        let codePosition = output.codePosition(file: file, function: function, line: line)
        let description: String
        var osLogType: OSLogType = .debug
        let label: OSLog = osLog(with: tracers.labelTracer.map { output.isSensitive ? "???" : $0.string } ?? "NoLabel")
        switch item {
            case .log(let level, let message):
                description = output.logString(
                    date: nil, level: level, message: message, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
                osLogType = logType(from: level)
            case .event(let name):
                description = output.eventString(
                    date: "", name: name, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .tracer(let tracer, false):
                description = output.tracerString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .tracer(let tracer, true):
                description = output.tracerEndString(
                    date: "", tracer: tracer, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
            case .measurement(let name, let value):
                description = output.measurementString(
                    date: "", name: name, value: value, tracers: tracers, meta: meta, codePosition: codePosition
                ).joined(separator: " ")
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
    private let queue: DispatchQueue = DispatchQueue(label: "memoirs.synchronizedDictionary", attributes: .concurrent)

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

#endif
