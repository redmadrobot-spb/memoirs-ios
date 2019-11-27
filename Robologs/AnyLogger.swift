//
//  AnyLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Type erased wrapper for implement `Hashable` - protocol in `Logger`
struct AnyLogger: Hashable, Equatable {
    public let source: Logger

    static func == (lhs: AnyLogger, rhs: AnyLogger) -> Bool {
        lhs.source.key == rhs.source.key
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(source.key)
    }
}
