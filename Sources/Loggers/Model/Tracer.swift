//
// Tracer
// Robologs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

public enum Tracer {
    case app(id: String)
    case instance(id: String)
    case session(userId: String) // Yes, even for guests

    case thread(name: String)
    case queue(name: String)

    case request(id: String)

    case label(String)
    case custom(String)

    public var string: String {
        switch self {
            case .app: return "app"
            case .instance(let id): return "instance.\(id)"
            case .session(let userId): return "session.\(userId)"
            case .thread(let name): return "thread.\(name)"
            case .queue(let name): return "queue.\(name)"
            case .request(let id): return "request.\(id)"
            case .label(let label): return label
            case .custom(let name): return name
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
