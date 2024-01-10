//
// SafeStringConvertible
// Memoirs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// Marker protocol
public protocol SafeStringConvertible {}

public enum SafetyLevel {
    case always
    case sensitive
    case never
}

public protocol MemoirStringConvertibleProperty {
    var safetyLevel: SafetyLevel { get }
}

@propertyWrapper
public struct LogAlways<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .always

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String { "\(String(describing: wrappedValue))" }
}

@propertyWrapper
public struct LogSensitive<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .sensitive

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String { "\(String(describing: wrappedValue))" }
}

@propertyWrapper
public struct LogNever<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .never

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String { "\(String(describing: wrappedValue))" }
}

extension SafeStringConvertible {
    func logDescription(hideSensitiveValues: Bool) -> String {
        SafeString.logDescription(object: self, hideSensitiveValues: hideSensitiveValues)
    }
}
