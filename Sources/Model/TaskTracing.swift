//
// Context
// Memoirs
//
// Created by Alex Babaev on 18 November 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

@available(iOS 15, *)
public enum Tracing {
    @TaskLocal
    public static var localValue: TracedMemoir?

    static let `default`: TracedMemoir = .init(label: "TaskLocalDefaultUnset", memoir: PrintMemoir())

    public static func memoir(file: StaticString = #file, line: UInt = #line) -> TracedMemoir {
        #if DEBUG
        if let localValue {
            localValue
        } else {
            fatalError("TaskLocal memoir is not set, wrap your call in the `Tracing.with` or `Tracing.detached`", file: file, line: line)
        }
        #else
        localValue ?? `default`
        #endif
    }

    public static func memoir(_ tracer: Tracer) -> Memoir {
        memoir().with(tracer: tracer)
    }

    /// For injecting child TracedMemoir over current one in the context.
    @inlinable
    public static func with<Value: Sendable>(
        _ memoir: TracedMemoir,
        file: String = #file, line: UInt = #line,
        operation: @Sendable (_ localMemoir: Memoir) async throws -> Value
    ) async rethrows -> Value {
        return try await $localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
    }

    /// For injecting child TracedMemoir over current one in the context.
    @inlinable
    public static func with<Value: Sendable>(
        _ tracer: Tracer,
        file: String = #file, line: UInt = #line,
        operation: @Sendable (_ localMemoir: Memoir) async throws -> Value
    ) async rethrows -> Value {
        let memoir = memoir().with(tracer: tracer)
        return try await $localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
    }

    /// For injecting root TracedMemoir into context.
    @inlinable
    public static func with<Value: Sendable>(
        root memoir: TracedMemoir,
        file: String = #file, line: UInt = #line,
        operation: @Sendable (_ localMemoir: Memoir) async throws -> Value
    ) async rethrows -> Value {
        try await $localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
    }

    /// For injecting child TracedMemoir over current one in the context.
    @inlinable
    public static func withDetached(
        _ tracer: Tracer,
        file: String = #file, line: UInt = #line,
        operation: @escaping @Sendable (_ localMemoir: Memoir) async throws -> Void
    ) {
        let memoir = memoir().with(tracer: tracer)
        Task.detached {
            try await $localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
        }
    }

    /// For injecting root TracedMemoir.
    @inlinable
    public static func withDetached(
        root memoir: TracedMemoir,
        file: String = #file, line: UInt = #line,
        operation: @escaping @Sendable (_ localMemoir: Memoir) async throws -> Void
    ) {
        Task.detached {
            try await $localValue.withValue(memoir, operation: { try await operation(memoir) }, file: file, line: line)
        }
    }
}
