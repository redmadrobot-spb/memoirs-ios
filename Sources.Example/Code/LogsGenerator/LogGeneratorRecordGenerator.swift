//
// LogGeneratorRecordGenerator
// Example
//
// Created by Roman Mazeev on 30.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

protocol LogGeneratorRecordGenerator {
    func records(for range: TimeRange) -> [GeneratedLogRecord]
}
