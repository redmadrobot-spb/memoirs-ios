//
//  RandomizedRecordGenerator.swift
//  Example
//
//  Created by Roman Mazeev on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

class RandomizedRecordGenerator {
    private let logger: Logger
    private(set) var isPlaying: Bool = false
    private var timing: LogsGeneratorTiming
    private var recordGenerator: LogGeneratorRecordGenerator

    private var recordsPerSecond: Double
    private var period: Double

    var logIntensity: Float {
        Float((recordsPerSecond * period) / 100)
    }

    init(logger: Logger) {
        self.logger = logger

        let period = TimeInterval.random(in: 0.1...1)
        timing = LogsGeneratorTiming(period: period)
        self.period = period

        let recordsPerSecond = Double.random(in: 1...100)
        recordGenerator = UniformRecordGenerator(record: {
            GeneratedLogRecord(
                level: Level.allCases.randomElement() ?? .info,
                label: "Test label",
                message: "Test message")
        }, recordsPerSecond: recordsPerSecond)
        self.recordsPerSecond = recordsPerSecond
    }

    func start() {
        isPlaying = true

        timing.start { range in
            self.recordGenerator.records(for: range).forEach { generatedRecord in
                self.logger.log(
                    level: generatedRecord.level,
                    label: generatedRecord.label,
                    message: "\(public: generatedRecord.message)",
                    meta: generatedRecord.meta?.mapValues { "\(public: $0)" as LogString } ?? [:]
                )
            }
        }
    }

    func stop() {
        isPlaying = false
        timing.stop()

        updateIntensity()
    }

    func updateIntensity() {
        let period = TimeInterval.random(in: 0.1...1)
        timing = LogsGeneratorTiming(period: period)
        self.period = period

        let recordsPerSecond = Double.random(in: 1...100)
        recordGenerator = UniformRecordGenerator(record: {
            GeneratedLogRecord(
                level: Level.allCases.randomElement() ?? .info,
                label: "",
                message: "Test message")
        }, recordsPerSecond: recordsPerSecond)
        self.recordsPerSecond = recordsPerSecond
    }
}
