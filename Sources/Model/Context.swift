//
// Context
// Memoirs
//
// Created by Alex Babaev on 18 November 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

@available(iOS 15, *)
public struct TaskLocalMemoir {
    @TaskLocal
    public static var localValue: TracedMemoir?
}

public extension Tracer {
    static func request() -> String {
        let traceId = (0 ..< 16)
            .map { _ in UInt8.random(in: UInt8.min ... UInt8.max) }
            .map { String(format: "%02hhx", $0) }
            .joined()
        let parentId = (0 ..< 8)
            .map { _ in UInt8.random(in: UInt8.min ... UInt8.max) }
            .map { String(format: "%02hhx", $0) }
            .joined()
        return "00-\(traceId)-\(parentId)-00"
    }
}

@available(iOS 15, *)
public enum Tracing {
    // TODO: I wish there was a function wrapper for this case
    public static func with<Value: Sendable>(
        _ tracer: Tracer,
        file: String = #file, line: UInt = #line,
        operation: @Sendable (_ localMemoir: Memoir) async throws -> Value
    ) async rethrows -> Value {
        guard let memoir = TaskLocalMemoir.localValue?.with(tracer: tracer) else { fatalError("Can't no memoir in TaskContext") }

        return try await TaskLocalMemoir.$localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
    }

    // TODO: I wish there was a function wrapper for this case
    public static func withDetached(
        _ tracer: Tracer,
        file: String = #file, line: UInt = #line,
        operation: @escaping @Sendable (_ localMemoir: Memoir) async throws -> Void
    ) {
        guard let memoir = TaskLocalMemoir.localValue?.with(tracer: tracer) else { fatalError("Can't no memoir in TaskContext") }

        TaskLocalMemoir.$localValue.withValue(memoir, operation: { Task.detached { try await operation(memoir) } }, file: file, line: line)
    }
}
