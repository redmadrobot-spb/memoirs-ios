//
// Created by Alex Babaev on 21.04.2021.
//

import Foundation
import Robologs
import RobologsRemote

public class LocalWebSocketLogger: Logger {
    private let server: WebSocketServer
    private var position: UInt64
    private var isSensitive: Bool

    public init(server: WebSocketServer, initialPosition: UInt64 = 0, isSensitive: Bool = false) {
        self.server = server
        self.isSensitive = isSensitive
        position = initialPosition
    }

    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        position += 1
        let log = SerializedLogMessage(
            position: position,
            timestamp: Date().timeIntervalSince1970,
            level: level,
            message: message().string(isSensitive: isSensitive),
            label: label,
            meta: meta()?.mapValues { $0.string(isSensitive: isSensitive) },
            file: file,
            function: function,
            line: line
        )

        do {
            try server.send(log: log)
        } catch {
            print("Error sending log: \(error)")
        }
    }
}
