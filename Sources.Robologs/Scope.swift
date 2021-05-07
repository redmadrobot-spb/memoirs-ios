//
// Scope
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public struct Scope {
    public let id: UUID
    public let parentId: UUID?

    public let name: String
    public var meta: [String: LogString]

    public init(parentId: UUID? = nil, name: String, meta: [String: LogString] = [:]) {
        id = UUID()
        self.parentId = parentId
        self.name = name
        self.meta = meta
    }

    public func subScope(name: String, meta: [String: LogString] = [:]) -> Scope {
        Scope(parentId: self.id, name: name, meta: meta)
    }
}
