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

@available(iOS 15, *)
public enum Tracing {
    // TODO: I wish there was a function wrapper for this case
    public static func with<Value: Sendable>(
        _ tracer: Tracer,
        memoir: TracedMemoir? = nil,
        file: String = #file, line: UInt = #line,
        operation: @Sendable (_ localMemoir: Memoir) async throws -> Value
    ) async rethrows -> Value {
        let memoir = TaskLocalMemoir.localValue?.with(tracer: tracer) ?? memoir
        guard let memoir else { fatalError("No memoir in task context, please provide one in the call") }

        return try await TaskLocalMemoir.$localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
    }

    // TODO: I wish there was a function wrapper for this case
    public static func withDetached(
        _ tracer: Tracer,
        memoir: TracedMemoir? = nil,
        file: String = #file, line: UInt = #line,
        operation: @escaping @Sendable (_ localMemoir: Memoir) async throws -> Void
    ) {
        let memoir = TaskLocalMemoir.localValue?.with(tracer: tracer) ?? memoir
        guard let memoir else { fatalError("No memoir in task context, please provide one in the call") }

        TaskLocalMemoir.$localValue.withValue(memoir, operation: { Task.detached { try await operation(memoir) } }, file: file, line: line)
    }
}
