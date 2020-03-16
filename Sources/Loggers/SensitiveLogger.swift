//
//  SensitiveLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 21.02.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Dispatch

/// Logger which incapsulate some logger to which will redirect log events that have already been cleared of sensitive data.
public class SensitiveLogger: Logger {
    private let logger: Logger
    private let queue = DispatchQueue(label: "com.redmadrobot.robologs.SensitiveLogger", attributes: .concurrent)
    private var excludeSensitive: Bool = true

    /// Creates a new instance of `SensitiveLogger`.
    /// - Parameter logger: Logger to which will redirect log events that have already been cleared of sensitive data.
    public init(logger: Logger) {
        self.logger = logger
    }

    public func log(
        level: Level,
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        queue.sync {
            logger.log(
                level: level,
                label: label,
                message: { "\(excludeSensitive ? message().string(withoutSensitive: true) : message())" },
                meta: { meta()?.mapValues { "\(excludeSensitive ? $0.string(withoutSensitive: true) : $0)" } },
                file: file,
                function: function,
                line: line
            )
        }
    }

    /// Sets the need to erase all sensitive data. Thread-safe.
    func excludeSensitive(_ isExcluded: Bool) {
        queue.async(flags: .barrier) {
            self.excludeSensitive = isExcluded
        }
    }
}

/// Marker protocol
public protocol Loggable {}

protocol SensitiveWrapper: Loggable {
    var value: Any { get }
}

@propertyWrapper
public struct Sensitive<T>: SensitiveWrapper {
    var value: Any
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        value = wrappedValue
    }
}

extension Loggable {
    func logDescription(withoutSensitive isSensitiveExcluded: Bool) -> String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.enumerated().reduce(into: "") { result, child in
            guard let label = child.element.label else { return }

            result += "\(label): "
            if let sensitiveWrapper = child.element.value as? SensitiveWrapper {
                result += isSensitiveExcluded ? "<private>" : "\(sensitiveWrapper.value)"
            } else if let childModel = child.element.value as? Loggable {
                result += "(\(childModel.logDescription(withoutSensitive: isSensitiveExcluded)))"
            } else {
                result += "\(child.element.value)"
            }

            if child.offset != mirror.children.count - 1 {
                result += ", "
            }
        }
    }
}
