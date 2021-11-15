//
// Tracer
// Memoirs
//
// Created by Alex Babaev on 21 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

public enum Tracer: Equatable, Hashable {
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

public func tracer<T>(forObject object: T) -> Tracer {
    (Mirror(reflecting: object).subjectType as? T.Type).map { tracer(forType: $0) } ?? .label("—")
}

public func tracer<T>(forType type: T.Type) -> Tracer {
    var label = String(reflecting: type)
    // Here we can have these options:
    // <[Module].[Class] [Address]> for Objective-C classes
    // [Module].[Class] for Swift Types
    // I want to cut [Address] and angle brackets from ObjC classes.
    if label.hasPrefix("<") && label.hasSuffix(">") && label.contains(": 0x") {
        let start = label.index(after: label.startIndex)
        let end = label.index(before: label.endIndex)
        label = String(label[start ..< end])
        label = label.components(separatedBy: ": 0x").first ?? label
    }
    // First part of every String(describing: ...) is module name. Let's separate it for possibility of shorter output in the console
    if let index = label.firstIndex(of: ".") {
        return .type(name: String(label[label.index(after: index)...]), module: String(label[..<index]))
    } else {
        return .type(name: label, module: "")
    }
}
