//
// Scope
// Robologs
//
// Created by Alex Babaev on 30 April 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public struct Scope {
    public enum Standard {
        case app
        case install(id: String)
        case session(userId: String, isGuest: Bool)

        case thread(name: String)
        case queue(name: String)

        case request(id: String)

        var string: String {
            switch self {
                case .app: return "app"
                case .install(let id): return "install.\(id)"
                case .session(let userId, let isGuest): return "session.\(userId).\(isGuest ? "g" : "u")"
                case .thread(let name): return "thread.\(name)"
                case .queue(let name): return "queue.\(name)"
                case .request(let id): return "request.\(id)"
            }
        }
    }

    public let name: String
    public let parentName: String?
    public let meta: [String: LogString]

    public init(name: String, parentName: String? = nil, meta: [String: LogString] = [:]) {
        self.parentName = parentName
        self.name = name
        self.meta = meta
    }

    public init(_ type: Standard, parent: Standard, meta: [String: LogString] = [:]) {
        self.init(name: type.string, parentName: parent.string, meta: meta)
    }

    public init(_ type: Standard, parentName: String? = nil, meta: [String: LogString] = [:]) {
        self.init(name: type.string, parentName: parentName, meta: meta)
    }

    public func subScope(name: String, meta: [String: LogString] = [:]) -> Scope {
        Scope(name: name, parentName: name, meta: meta)
    }

    public func equalKey(with scope: Scope) -> Bool {
        name == scope.name && parentName == scope.parentName
    }
}
