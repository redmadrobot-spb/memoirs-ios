//
// UniformRecordGenerator
// Robologs
//
// Created by Vladislav Maltsev on 04.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

struct UniformRecordGenerator: LogGeneratorRecordGenerator {
    let record: () -> GeneratedLogRecord
    let recordsPerSecond: Double

    func records(for range: TimeRange) -> [GeneratedLogRecord] {
        let recordsCount = Int(recordsPerSecond * range.interval)
        return (0 ..< recordsCount).map { _ in record() }
    }
}
