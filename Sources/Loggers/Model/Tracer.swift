//
// Tracer
// Robologs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

public enum Tracer {
    case app
    case install(id: Swift.String)
    case session(userId: Swift.String, isGuest: Bool)

    case thread(name: Swift.String)
    case queue(name: Swift.String)

    case request(id: Swift.String)

    case label(Swift.String)

    public var string: Swift.String {
        switch self {
            case .app: return "app"
            case .install(let id): return "install.\(id)"
            case .session(let userId, let isGuest): return "session.\(userId).\(isGuest ? "g" : "u")"
            case .thread(let name): return "thread.\(name)"
            case .queue(let name): return "queue.\(name)"
            case .request(let id): return "request.\(id)"
            case .label(let label): return label
        }
    }
}

extension Array where Element == Tracer {
    @usableFromInline
    var label: String? {
        first {
            switch $0 {
                case .label: return true
                default: return false
            }
        }
        .map { $0.string }
    }
}
