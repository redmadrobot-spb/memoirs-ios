//
// Subscribers
// MemoirSubscriptions
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class Subscribers<T> {
    private var subscriberListeners: [UUID: (T) -> Void] = [:]

    public init() {
    }

    public func subscribe(listener: @escaping (T) -> Void) -> Subscription {
        let uuid = UUID()
        subscriberListeners[uuid] = listener

        return Subscription { [weak self] in
            self?.subscriberListeners[uuid] = nil
        }
    }

    public func fire(_ value: T) {
        subscriberListeners.values.forEach { $0(value) }
    }
}
