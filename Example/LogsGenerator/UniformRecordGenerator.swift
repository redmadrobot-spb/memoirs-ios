//
//  UniformRecordGenerator.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Foundation

struct UniformRecordGenerator: LogGeneratorRecordGenerator {
    let record: () -> GeneratedLogRecord
    let recordsPerSecond: Double

    func records(for range: TimeRange) -> [GeneratedLogRecord] {
        let recordsCount = Int(recordsPerSecond * range.interval)
        return Array(repeating: record(), count: recordsCount)
    }
}
