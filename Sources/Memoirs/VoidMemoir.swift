//
// VoidMemoir
// Memoirs
//
// Created by Alex Babaev on 27 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class VoidMemoir: Memoir {
    public init() {
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
    }
}
