//
// SafeStringConvertible
// Memoirs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Marker protocol
public protocol SafeStringConvertible {}

public enum SafetyLevel {
    case safeToShow
    case sensitive
    case never
}

public protocol MemoirStringConvertibleProperty {
    var safetyLevel: SafetyLevel { get }
}

@propertyWrapper
public struct TopSecret<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .never

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String {
        "\(wrappedValue)"
    }
}

@propertyWrapper
public struct Sensitive<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .sensitive

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String {
        "\(wrappedValue)"
    }
}

@propertyWrapper
public struct SafeToShow<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .safeToShow

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String {
        "\(wrappedValue)"
    }
}

extension SafeStringConvertible {
    func logDescription(isSensitive: Bool) -> String {
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
            .map { child in
                guard let label = child.label else { return "" }

                switch child.value {
                    case let property as MemoirStringConvertibleProperty:
                        switch property.safetyLevel {
                            case .safeToShow:
                                return "\(label.dropFirst()): \(property)"
                            case .sensitive:
                                return isSensitive
                                    ? "\(label.dropFirst()): \(SafeString.secretReplacement)"
                                    : "\(label.dropFirst()): \(property)"
                            case .never:
                                return "\(label.dropFirst()): \(SafeString.secretReplacement))"
                        }
                    case let loggable as SafeStringConvertible:
                        return "\(label): \(loggable.logDescription(isSensitive: isSensitive))"
                    default:
                        return isSensitive ? "\(label): \(SafeString.secretReplacement)" : "\(label): \(child.value)"
                }
            }
            .joined(separator: ", ")

        return "\(String(describing: self))(\(children))"
    }
}
