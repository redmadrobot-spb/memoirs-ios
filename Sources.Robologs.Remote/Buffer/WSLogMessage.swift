//
// Created by Alex Babaev on 26.04.2021.
//

import Foundation
import Robologs

public struct WSLogMessage: Codable {
    public let timestamp: Date
    public let level: Level
    public let source: String
    public let label: String
    public let body: String
    public let meta: [String: String]
    public let position: UInt64

    public init(timestamp: Date, level: Level, source: String, label: String, body: String, meta: [String: String], position: UInt64) {
        self.timestamp = timestamp
        self.level = level
        self.source = source
        self.label = label
        self.body = body
        self.meta = meta
        self.position = position
    }

    enum CodingKeys: String, CodingKey {
        case timestamp = "timestampMillis"
        case priority = "priority"
        case source = "source"
        case label = "label"
        case body = "body"
        case meta = "meta"
        case position = "position"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(UInt(timestamp.timeIntervalSince1970 * 1000), forKey: .timestamp)
        let rawPriority: String
        switch level {
            case .verbose: rawPriority = "VERBOSE"
            case .debug: rawPriority = "DEBUG"
            case .info: rawPriority = "INFO"
            case .warning: rawPriority = "WARN"
            case .error: rawPriority = "ERROR"
            case .critical: rawPriority = "CRITICAL"
        }
        try container.encode(rawPriority, forKey: .priority)
        try container.encode(source, forKey: .source)
        try container.encode(label, forKey: .label)
        try container.encode(body, forKey: .body)
        try container.encode(meta, forKey: .meta)
        try container.encode(position, forKey: .position)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let timestamp = try container.decode(UInt.self, forKey: .timestamp)
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1000.0))

        let rawPriority = try container.decode(String.self, forKey: .priority)
        switch rawPriority {
            case "VERBOSE": level = .verbose
            case "DEBUG": level = .debug
            case "INFO": level = .info
            case "WARN": level = .warning
            case "ERROR": level = .error
            case "CRITICAL": level = .critical
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: CodingKeys.priority,
                    in: container,
                    debugDescription: "Unimplemented priority level"
                )
        }

        source = try container.decode(String.self, forKey: .source)
        label = try container.decode(String.self, forKey: .label)
        body = try container.decode(String.self, forKey: .body)
        meta = try container.decode([String: String]?.self, forKey: .meta) ?? [:]
        position = try container.decode(UInt64.self, forKey: .position)
    }
}
