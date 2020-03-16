//
//  InMemoryBuffering.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

public class InMemoryBuffering: RemoteLoggerBuffering {
    private var records: [LogRecord] = []

    public var haveBufferedData: Bool {
        !records.isEmpty
    }

    public func append(record: LogRecord) {
        records.append(record)
    }

    public func retrieve(_ actions: @escaping ([LogRecord], @escaping (Bool) -> Void) -> Void) {
        actions(records) { finished in
            if finished {
                self.records = []
            }
        }
    }
}
