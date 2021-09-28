//
// MultiplexingMemoir
// Memoirs
//
// Created by Dmitry Shadrin on 05 December 2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

/// A memoir that stores several memoirs in itself and redirects all items to them. It has no side effects.
public class MultiplexingMemoir: Memoir {
    public let memoirs: [Memoir]

    public init(memoirs: [Memoir]) {
        self.memoirs = memoirs
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
        memoirs.forEach { $0.append(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line) }
    }
}
