//
// Tracer
// Memoirs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public enum Tracer: Equatable {
    case app(id: String)
    case instance(id: String)
    case session(userId: String) // Yes, even for guests

    case label(String)

    case request(id: String)
    case type(name: String, module: String)

    public var string: String {
        switch self {
            case .app(let id): return "app:\(id)"
            case .instance(let id): return "instance:\(id)"
            case .session(let userId): return "session:\(userId)"
            case .request(let id): return "request:\(id)"
            case .type(let name, let module): return "\(module).\(name)"
            case .label(let label): return label
        }
    }

    public var stringShort: String {
        switch self {
            case .app: return "app:↑"
            case .instance: return "instance:↑"
            case .session: return "session:↑"
            case .request(let id): return id
            case .type(let name, _): return name
            case .label(let label): return label
        }
    }
}

extension Array where Element == Tracer {
    public var label: Tracer? { labelTracer }

    @usableFromInline
    var labelTracer: Tracer? {
        first {
            if case .label = $0 {
                return true
            } else if case .type = $0 {
                return true
            } else {
                return false
            }
        }
    }
}
