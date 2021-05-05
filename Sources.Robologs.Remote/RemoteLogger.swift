//
// RemoteLogger
// Robologs
//
// Created by Alex Babaev on 27 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

public class RemoteLogger: Logger {
    private let isSensitive: Bool
    private let senderId: String
    private let senders: [LogSender]

    public init(isSensitive: Bool, senderId: String, senders: [LogSender]) {
        self.isSensitive = isSensitive
        self.senderId = senderId
        self.senders = senders
    }

    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]?,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let timestamp = Date().timeIntervalSince1970
        let position = nextPosition
        let message = SerializedLogMessage(
            position: position,
            timestamp: timestamp,
            level: level,
            message: message().string(isSensitive: isSensitive),
            label: label,
            meta: meta()?.mapValues { $0.string(isSensitive: isSensitive) },
            file: isSensitive ? "" : file,
            function: isSensitive ? "" : function,
            line: isSensitive ? 0 : line
        )

        senders.forEach { $0.send(senderId: senderId, message: message) }
    }

    // MARK: - Log Position (part of identifier)

    private let positionKey: String = "robologs.remoteLogger.position"
    private var cachedPosition: UInt64!
    private var position: UInt64 {
        get {
            if cachedPosition == nil {
                cachedPosition = UserDefaults.standard.object(forKey: positionKey) as? UInt64 ?? 0
            }

            return cachedPosition
        }
        set {
            cachedPosition = newValue
            UserDefaults.standard.set(cachedPosition, forKey: positionKey)
        }
    }

    private let positionIncrementQueue: DispatchQueue = .init(label: "RemoteLogger.positionIncrementingQueue")
    private var nextPosition: UInt64 {
        positionIncrementQueue.sync {
            if position == UInt64.max {
                position = 0
            } else {
                position += 1
            }
            return position
        }
    }
}
