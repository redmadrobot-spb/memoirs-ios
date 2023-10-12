//
// VoidMemoir
// Memoirs
//
// Created by Alex Babaev on 27 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

public final class VoidMemoir: Memoir {
    public init() {
    }

    @inlinable
    public func append(
        _ item: MemoirItem,
        message: @autoclosure @Sendable () throws -> SafeString,
        meta: @autoclosure () -> [String: SafeString]?,
        tracers: [Tracer],
        timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) rethrows {
    }
}
