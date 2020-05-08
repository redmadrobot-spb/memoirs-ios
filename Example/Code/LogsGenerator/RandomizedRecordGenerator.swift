//
// RandomizedRecordGenerator
// Example
//
// Created by Roman Mazeev on 30.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation
import Robologs

class RandomizedRecordGenerator {
    private(set) var isPlaying: Bool = false
    private var timing: LogsGeneratorTiming!
    private var recordGenerator: LogGeneratorRecordGenerator!

    private var recordsPerSecond = 0.0
    private var period = 0.0

    var logIntensity: Float {
        Float((recordsPerSecond * period) / 100)
    }

    init() {
        updateIntensity()
    }

    func start() {
        isPlaying = true

        timing.start { range in
            self.recordGenerator.records(for: range).forEach { generatedRecord in
                Loggers.instance.logger.log(
                    level: generatedRecord.level,
                    generatedRecord.message,
                    label: generatedRecord.label,
                    meta: generatedRecord.meta
                )
            }
        }
    }

    func stop() {
        isPlaying = false
        timing.stop()

        updateIntensity()
    }

    private var position: UInt64 = 0
    private var nextPosition: UInt64 {
        position += 1
        return position
    }

    private let lettersForRandom = Array("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM")

    private func updateIntensity() {
        let period = TimeInterval.random(in: 0.1...1)
        timing = LogsGeneratorTiming(period: period)
        self.period = period

        let recordsPerSecond = Double.random(in: 1...100)
        recordGenerator = UniformRecordGenerator(
            record: {
                GeneratedLogRecord(
                    level: Level.allCases.randomElement() ?? .info,
                    label: (0 ..< 5).map { _ in "\(self.lettersForRandom.randomElement() ?? "_")" }.joined(separator: ""),
                    message: "Test message \(self.nextPosition): \(SingleLogViewController.randomString)"
                )
            },
            recordsPerSecond: recordsPerSecond
        )
        self.recordsPerSecond = recordsPerSecond
    }
}
