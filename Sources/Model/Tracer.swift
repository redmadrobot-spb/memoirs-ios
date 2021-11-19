//
// Tracer
// Memoirs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public enum Tracer: Equatable, Hashable {
    case app(id: String)
    case instance(id: String)
    case session(userId: String) // Yes, even for guests

    case label(String)

    case request(trace: String)
    case type(name: String, module: String)

    public var string: String {
        switch self {
            case .app(let id): return "app:\(id)"
            case .instance(let id): return "instance:\(id)"
            case .session(let userId): return "session:\(userId)"
            case .request(let trace): return "request:\(trace)"
            case .type(let name, let module): return "\(module).\(name)"
            case .label(let label): return label
        }
    }

    public var stringShort: String {
        switch self {
            case .app: return "app:↑"
            case .instance: return "instance:↑"
            case .session: return "session:↑"
            case .request(let trace): return trace
            case .type(let name, _): return name
            case .label(let label): return label
        }
    }
}

public func tracer<T>(for object: T) -> Tracer {
    tracerFromString(for: String(reflecting: Mirror(reflecting: object).subjectType))
}

public func tracer(for type: Any.Type) -> Tracer {
    tracerFromString(for: String(reflecting: type))
}

public func tracer<T>(for type: T.Type) -> Tracer {
    tracerFromString(for: String(reflecting: type))
}

private func tracerFromString(for string: String) -> Tracer {
    // Here we can have these options:
    // <[Module].[Class] [Address]> for Objective-C classes
    // [Module].[Class] for Swift Types
    // I want to cut [Address] and angle brackets from ObjC classes.
    var string = string
    if string.hasPrefix("<") && string.hasSuffix(">") && string.contains(": 0x") {
        let start = string.index(after: string.startIndex)
        let end = string.index(before: string.endIndex)
        string = String(string[start ..< end])
        string = string.components(separatedBy: ": 0x").first ?? string
    }
    // First part of every String(describing: ...) is module name. Let's separate it for possibility of shorter output in the console
    if let index = string.firstIndex(of: ".") {
        return .type(name: String(string[string.index(after: index)...]), module: String(string[..<index]))
    } else {
        return .type(name: string, module: "")
    }
}
