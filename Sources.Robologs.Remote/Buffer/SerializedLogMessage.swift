//
// SerializedLogMessage
// Robologs
//
// Created by Alex Babaev on 26 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

public struct SerializedLogMessage: Codable {
    public let position: UInt64
    public let timestamp: TimeInterval
    public let level: Level
    public let message: String
    public let label: String
    public let meta: [String: String]?
    public let file: String
    public let function: String
    public let line: UInt

    public init(position: UInt64, timestamp: TimeInterval, level: Level, message: String, label: String, meta: [String: String]?,
        file: String, function: String, line: UInt) {
        self.position = position
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.label = label
        self.meta = meta
        self.file = file
        self.function = function
        self.line = line
    }

    var protobufMessage: LogMessage {
        LogMessage.with { logMessage in
            logMessage.position = position
            logMessage.priority = level.protoBufLevel
            logMessage.label = label
            logMessage.body = message
            logMessage.source = collectContext(file: file, function: function, line: line)
            logMessage.timestampMillis = UInt64(timestamp * 1000)
            logMessage.meta = meta ?? [:]
        }
    }

    public func protobufMessageData() throws -> Data {
        try protobufMessage.serializedData()
    }
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
