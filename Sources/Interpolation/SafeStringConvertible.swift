//
// SafeStringConvertible
// Memoirs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2020 Alex Babaev. All rights reserved.
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

    public var description: String { "\(wrappedValue)" }
}

@propertyWrapper
public struct Sensitive<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .sensitive

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String { "\(wrappedValue)" }
}

@propertyWrapper
public struct SafeToShow<T>: MemoirStringConvertibleProperty, CustomStringConvertible {
    public var wrappedValue: T
    public let safetyLevel: SafetyLevel = .safeToShow

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var description: String { "\(wrappedValue)" }
}

extension SafeStringConvertible {
    func logDescription(hideSensitiveValues: Bool) -> String {
        SafeString.logDescription(object: self, hideSensitiveValues: hideSensitiveValues)
    }
}
