//
// Loggable
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

/// Marker protocol
public protocol Loggable {}

public enum LoggingSafetyLevel {
    case safe
    case sensitive
    case never
}

public protocol LoggableProperty {
    var safetyLevel: LoggingSafetyLevel { get }
}

@propertyWrapper
public struct NeverLog<T>: LoggableProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: LoggingSafetyLevel = .never

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String {
        "\(wrappedValue)"
    }
}

@propertyWrapper
public struct Sensitive<T>: LoggableProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: LoggingSafetyLevel = .sensitive

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String {
        "\(wrappedValue)"
    }
}

@propertyWrapper
public struct SafeToLog<T>: LoggableProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: LoggingSafetyLevel = .safe

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String {
        "\(wrappedValue)"
    }
}

extension Loggable {
    func logDescription(isSensitive: Bool) -> String {
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
            .map { child in
                guard let label = child.label else { return "" }

                switch child.value {
                    case let property as LoggableProperty:
                        switch property.safetyLevel {
                            case .safe:
                                return "\(label.dropFirst()): \(property)"
                            case .sensitive:
                                return isSensitive ? "\(label.dropFirst()): <private>" : "\(label.dropFirst()): \(property)"
                            case .never:
                                return "\(label.dropFirst()): <private>"
                        }
                    case let loggable as Loggable:
                        return "\(label): \(loggable.logDescription(isSensitive: isSensitive))"
                    default:
                        return isSensitive ? "\(label): <private>" : "\(label): \(child.value)"
                }
            }
            .joined(separator: ", ")

        return "\(String(describing: type(of: self)))(\(children))"
    }
}
