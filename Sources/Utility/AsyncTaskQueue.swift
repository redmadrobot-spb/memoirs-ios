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
    public init() {
    }

    private let queue: DispatchQueue = .init(label: "AsyncTaskQueue")

    private var actions: [@Sendable () async -> Void] = []

    public func add(closure: @escaping @Sendable () async -> Void) {
        queue.async {
            self.actions.append(closure)
            self.startNext(semaphore: nil)
        }
    }

    private var isExecuting: Bool = false

    private func startNext(semaphore: DispatchSemaphore?) {
        guard !isExecuting && !actions.isEmpty else {
            semaphore?.signal()
            return
        }

        isExecuting = true
        let closures: [@Sendable () async -> Void] = [ actions.removeFirst() ]
        Task {
            for closure in closures {
                await closure()
            }
            isExecuting = false
            queue.async {
                self.startNext(semaphore: semaphore)
            }
        }
    }
}
