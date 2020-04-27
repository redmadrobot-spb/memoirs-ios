//
// SynchronizedDictionary
// Robologs
//
// Created by Dmitry Shadrin on 04.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

class SynchronizedDictionary<Key, Value>: ExpressibleByDictionaryLiteral where Key: Hashable {
    private var dictionary: [Key: Value]
    private let queue: DispatchQueue = DispatchQueue(label: "com.redmadrobot.robologs.synchronizedDictionary", attributes: .concurrent)

    required init(dictionaryLiteral elements: (Key, Value)...) {
        dictionary = Dictionary(uniqueKeysWithValues: elements)
    }

    subscript(key: Key) -> Value? {
        get {
            queue.sync {
                dictionary[key]
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key] = newValue
            }
        }
    }
}
