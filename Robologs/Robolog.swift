//
//  Robolog.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 26.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

public protocol Logger {
    typealias Key = Int

    @inlinable
    func log(
        priority: LogPriority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: @autoclosure () -> String?,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]?
    )
}

public enum LogPriority: UInt, CaseIterable {
    case verbose = 0
    case debug
    case info
    case warning
    case error
    case assert
}

extension LogPriority: Comparable {
    public static func < (lhs: LogPriority, rhs: LogPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

@usableFromInline
struct AnyLogger {
    let uuidHash: Int = UUID().hashValue
    @usableFromInline
    let rawLogger: Logger
}

extension AnyLogger: Hashable, Equatable {

    @usableFromInline
    static func == (lhs: AnyLogger, rhs: AnyLogger) -> Bool {
        return lhs.uuidHash == rhs.uuidHash
    }

    @usableFromInline
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuidHash)
    }
}

public enum Robolog {
    @usableFromInline
    static var logQueue: DispatchQueue!
    @usableFromInline
    static var loggers: Dictionary<Logger.Key, AnyLogger> = [ : ]

    public static func add(logger: Logger) -> Logger.Key {
        logQueue.sync {
            let typeErased = AnyLogger(rawLogger: logger)
            Self.loggers[typeErased.uuidHash] = typeErased
            return typeErased.uuidHash
        }
    }

    public static func add(loggers: [Logger]) -> Set<Logger.Key> {
        logQueue.sync {
            let typeErasedPairs = loggers.reduce(into: [Logger.Key: AnyLogger]()) { (dictionary, logger) in
                let typeErased = AnyLogger(rawLogger: logger)
                dictionary[typeErased.uuidHash] = typeErased
            }
            Self.loggers.merge(typeErasedPairs) { (current, _) in current }
            return Set(typeErasedPairs.keys)
        }
    }

    public static func removeLogger(by key: Logger.Key) {
        logQueue.sync {
            Self.loggers[key] = nil
        }
    }
}

public extension Robolog {
    @inlinable
    static func verbose(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.log(priority: .verbose, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    @inlinable
    static func debug(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.log(priority: .debug, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    @inlinable
    static func info(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.log(priority: .info, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    @inlinable
    static func warning(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.log(priority: .warning, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    @inlinable
    static func error(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.log(priority: .error, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    @inlinable
    static func assert(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.log(priority: .assert, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
    }

    @inlinable
    static func log(
        priority: LogPriority,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        Self.logQueue.sync {
            Self.loggers.values.forEach { anyLogger in
                anyLogger.rawLogger
                    .log(priority: priority, file: file, function: function, line: line, label: label(), message: message(), meta: meta())
            }
        }
    }
}

public struct DefaultPrintLogger: Logger {
    public func log(
        priority: LogPriority,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {

    }
}
