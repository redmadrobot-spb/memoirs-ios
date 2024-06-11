//
// AsyncTaskQueue
// memoirs-ios
//
// Created by Alex Babaev on 25 June 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation

extension DispatchSemaphore: @unchecked Sendable {}

public final class AsyncTaskQueue: @unchecked Sendable {
    private let memoir: Memoir

    public init(memoir: Memoir) {
        self.memoir = memoir
    }

    private let queue: DispatchQueue = .init(label: "AsyncTaskQueue")

    private var actions: [@Sendable () async throws -> Void] = []

    public func add(closure: @escaping @Sendable () async throws-> Void) {
        queue.async {
            self.actions.append(closure)
            self.startNext()
        }
    }

    private var isExecuting: Bool = false

    private func startNext() {
        guard !isExecuting && !actions.isEmpty else { return }

        isExecuting = true
        let closures: [@Sendable () async throws -> Void] = [ actions.removeFirst() ]
        Task {
            for closure in closures {
                do {
                    try await closure()
                } catch {
                    memoir.error("Problem while executing queue task: \(error)")
                }
            }
            queue.async {
                self.isExecuting = false
                self.startNext()
            }
        }
    }
}
