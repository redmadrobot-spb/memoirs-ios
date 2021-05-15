//
// Scope
// Robologs
//
// Created by Alex Babaev on 30 April 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public struct Scope {
    public let name: String
    public let parentName: String?
    public let meta: [String: LogString]

    public init(name: String, parentName: String? = nil, meta: [String: LogString] = [:]) {
        self.parentName = parentName
        self.name = name
        self.meta = meta
    }

    public func subScope(name: String, meta: [String: LogString] = [:]) -> Scope {
        Scope(name: name, parentName: name, meta: meta)
    }

    public func equalKey(with scope: Scope) -> Bool {
        name == scope.name && parentName == scope.parentName
    }
}
