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
    func logDescription(isSensitive: Bool) -> String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.enumerated().reduce(into: "") { result, child in
            guard let label = child.element.label else { return }

            result += "\(label): "
            if let sensitiveWrapper = child.element.value as? SensitiveWrapper {
                result += isSensitive ? "<private>" : "\(sensitiveWrapper.value)"
            } else if let childModel = child.element.value as? Loggable {
                result += "(\(childModel.logDescription(isSensitive: isSensitive)))"
            } else {
                result += "\(child.element.value)"
            }

            if child.offset != mirror.children.count - 1 {
                result += ", "
            }
        }
    }
}
