//
//  SynchronizedDictionary.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 04.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

class SynchronizedDictionary<Key, Value>: ExpressibleByDictionaryLiteral where Key: Hashable {
    private var dictionary: [Key: Value]
    private let queue: DispatchQueue

    required init(dictionaryLiteral elements: (Key, Value)...) {
        dictionary = Dictionary(uniqueKeysWithValues: elements)
        queue = DispatchQueue(label: "com.redmadrobot.robologs.synchronizedDictionary", attributes: .concurrent)
    }

    subscript(key: Key) -> Value? {
        get {
            queue.sync {
                dictionary[key]
            }
        }
        set {
            guard let newValue = newValue else { return }

            queue.async(flags: .barrier) { [unowned self] in
                self.dictionary[key] = newValue
            }
        }
    }
}
