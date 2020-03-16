//
//  RemoteLogger.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

public struct LogRecord {
    let timestamp: TimeInterval
    let label: String
    let level: Level
    let message: String
    let meta: [String: String]?
}

public protocol RemoteLoggerBuffering {
    var haveBufferedData: Bool { get }
    func append(record: LogRecord)
    func retrieve(_ actions: @escaping (_ records: [LogRecord], _ finished: @escaping (Bool) -> Void) -> Void)
}

public protocol RemoteLoggerTransport {
    var isAvailable: Bool { get }
    func send(_ records: [LogRecord], completion: @escaping (Result<Void, Error>) -> Void)
}

public class RemoteLogger: Logger {
    private let buffering: RemoteLoggerBuffering
    private let transport: RemoteLoggerTransport

    public init(buffering: RemoteLoggerBuffering, transport: RemoteLoggerTransport) {
        self.buffering = buffering
        self.transport = transport
    }

    public func log(
        level: Level,
        label: String,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let record = LogRecord(
            timestamp: Date().timeIntervalSince1970,
            label: label,
            level: level,
            message: message(),
            meta: meta()
        )

        if transport.isAvailable {
            buffering.retrieve { records, finish in
                self.transport.send(records + [ record ]) { result in
                    switch result {
                        case .success:
                            finish(true)
                        case .failure:
                            self.buffering.append(record: record)
                            finish(false)
                    }
                }
            }
        } else {
            buffering.append(record: record)
        }
    }
}
