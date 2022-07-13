//
// AsyncTaskQueue
// memoirs-ios
//
// Created by Alex Babaev on 25 June 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation

public final actor AsyncTaskQueue {
    private var queue: [@Sendable () async -> Void] = []

    public nonisolated func add(closure: @escaping @Sendable () async -> Void) {
        Task {
            await updateQueue(add: closure)
            await startNext()
        }
    }

    private func updateQueue(add closure: @escaping @Sendable () async -> Void) {
        queue.append(closure)
    }

    private func startNext() {
        guard !queue.isEmpty else { return }

        let closure = queue.removeFirst()
        Task {
            await closure()
            startNext()
        }
    }
}
