//
//  InMemoryBuffering.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

/// Simplest buffering - just keeps log records in memory.
public class InMemoryBuffering: RemoteLoggerBuffering {
    private var records: [LogRecord] = []

    /// Create new instance of `InMemoryBuffering`
    public init() {}

    public var haveBufferedData: Bool {
        !records.isEmpty
    }

    public func append(record: LogRecord) {
        records.append(record)
    }

    public func retrieve(_ actions: @escaping ([LogRecord], @escaping (Bool) -> Void) -> Void) {
        let pendedRecords = records
        records = []
        actions(pendedRecords) { isFinished in
            if !isFinished {
                self.records = pendedRecords + self.records
            }
        }
    }
}
