//
//  AnyLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Type erased wrapper for implement `Hashable` - protocol in `Logger`
struct AnyLogger: Hashable, Equatable {
    public let base: Logger

    static func == (lhs: AnyLogger, rhs: AnyLogger) -> Bool {
        lhs.base.key == rhs.base.key
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(base.key)
    }
}
