//
//  EventEmmiter.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 Elsewhere. All rights reserved.
//

import Robologs

class LogsGenerator {
    private let timing: LogsGeneratorTiming
    private let recordGenerator: LogGeneratorRecordGenerator
    private(set) var isPlaying: Bool = false

    init(
        timing: LogsGeneratorTiming,
        recordGenerator: LogGeneratorRecordGenerator
    ) {
        self.timing = timing
        self.recordGenerator = recordGenerator
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
    }
}
