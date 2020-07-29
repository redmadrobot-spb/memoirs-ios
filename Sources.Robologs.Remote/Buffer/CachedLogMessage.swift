//
// CachedLogMessage
// Robologs
//
// Created by Alex Babaev on 26 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

struct CachedLogMessage: Codable {
    let position: UInt64
    let timestamp: TimeInterval
    let level: Level
    let message: String
    let label: String
    let meta: [String: String]?
    let file: String
    let function: String
    let line: UInt
}

extension Level: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let level = try container.decode(String.self)
        switch level {
            case "v": self = .verbose
            case "d": self = .debug
            case "i": self = .info
            case "w": self = .warning
            case "e": self = .error
            case "c": self = .critical
            default: self = .debug // Don't want to break here
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .verbose: try container.encode("v")
            case .debug: try container.encode("d")
            case .info: try container.encode("i")
            case .warning: try container.encode("w")
            case .error: try container.encode("e")
            case .critical: try container.encode("c")
        }
    }
}
