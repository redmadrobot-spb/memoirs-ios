//
// Scope
// Robologs
//
// Created by Alex Babaev on 30.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public struct Scope {
    public enum Kind {
        case application
        case installation
        case run
        case user
        case flow
        case presentation
        case custom(String)
    }

    public let id: UUID
    public let parentId: UUID?
    public let name: String
    public let kind: String
    public var meta: [String: String] = [:]
}
